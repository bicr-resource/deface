function	[V, F, xxn] = vb_surf_smooth_fit(V,F,xx,B,Para)
% Fit surface to the boundary of the mask
%  [V, F, xx] = vb_surf_smooth_fit(V,F,xx,B,Para)
% --- Input
%  V(n, 1:3)  : vertex
%  F(j, 1:3)  : patch index
% xx(n, 1:3)  : normal vector
% B(NX,NY,NZ) : mask image : inside of surface is filled out
%               surface is expanded to fit to the boundary of mask region
% Para.Nloop  : iteration number
% Para.tangent_rate   : spring constant
% Para.mask_ratio     : mask image force constant
% Para.mask_threshold : mask threthold
%
% --- Output
%  V(n, 1:3)  : vertex
%  F(j, 1:3)  : patch index
% xx(n, 1:3)  : normal vector
% --- Mehod
% ポリゴンモデルをマスクパターンの境界面に膨張、バネ力による平滑化を行う
%
%  V(n, 1:3)  : 頂点の位置
%  F(j, 1:3)  : 三角面３頂点のインデックス
% xx(n, 1:3)  : 頂点の初期法線方向(nx,ny,nz)
% xxn(n, 1:3) : 頂点の最終法線方向(nx,ny,nz)
% B(NX,NY,NZ) : 3D-ボクセル・マスクパターン
%
% Para.Nloop  : 繰り返し回数
% Para.vstep  : ボクセルサイズ
%
% Para.tangent_rate   : バネ強度
% Para.mask_ratio     : マスク強度力係数 ( 強度>閾値:外向き)
% Para.mask_threshold : マスク強度閾値   ( 強度<閾値:内向き)
%
% change coordinate to index
%     V = [-1/2,-1/2,-1/2] - [1/2,1/2,1/2]
% <=> J = [1,1,1]
%   J   = floor(V + 0.5) + 1;
%
% 合力 =  tangent_rate * (平滑化バネ力)
%       + mask_ratio   * (外向き法線方向) * (マスク強度 - 閾値)
% 
% Ver 1.0  by M. Sato  2004-2-5
% Ver 2.0  by M. Sato  2006-11-11
% M. Sato 2007-3-16
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Para','var'), Para = []; end
if ~isfield(Para,'Nloop'), Para.Nloop = 200; end
if ~isfield(Para,'Ndisp'), Para.Ndisp = Para.Nloop+1; end
if ~isfield(Para,'vstep'), Para.vstep = 1; end
if ~isfield(Para,'tangent_rate'),   Para.tangent_rate   = 0.3; end
if ~isfield(Para,'mask_ratio'),     Para.mask_ratio     = 0.5; end
if ~isfield(Para,'mask_threshold'), Para.mask_threshold = 0.3; end

tangent_rate = Para.tangent_rate;
image_rate   = Para.mask_ratio;
threshold    = Para.mask_threshold;
step		 = Para.vstep;

Nloop		 = Para.Nloop;
Npoint		 = size(V,1);  	% number of vertex
Npatch		 = size(F,1);  	% number of patch
[NX,NY,NZ]	 = size(B);		% image size

% Plot parameter
Ndisp = Para.Ndisp;
Nfig  = fix(Nloop/Ndisp);

if Nfig < 2,
	NYfig = 1;
else
	NYfig = 2;
end
NXfig = max(ceil(Nfig/NYfig), 1);
nfig  = NXfig*NYfig + 1;

fclr = [];
eclr = [];
light_mode = 1;
vangle = [-70 20];

% ３角面の法線ベクトル
xxf  = zeros(Npatch,3);
% ３角面面積
nns  = zeros(Npatch,1);
% ３角面頂点の差分ベクトル
VV1  = zeros(Npatch,3);
VV2  = zeros(Npatch,3);
VV3  = zeros(Npatch,3);

% 頂点法線 = 頂点に隣接する三角面法線の平均
xxn  = zeros(Npoint,3);	
xxs  = zeros(Npoint,1);
% 頂点差分ベクトル
fd   = zeros(Npoint,3);
% 各頂点の近傍点数
Nv   = zeros(Npoint,1);
% 頂点差分ベクトルと法線の内積
nnf  = zeros(Npoint,1);
% 接線方向の力
ft	 = zeros(Npoint,3);
% 法線方向の力
fn	 = zeros(Npoint,3);
% 外向き(内側)・内向き(外側)のイメージ強度による力
fg	 = zeros(Npoint,3);

% V 座標のボクセルインデックス
jv	 = zeros(Npoint,3);
jj	 = zeros(Npoint,1);
% 内側マスク強度
gg	 = zeros(Npoint,1);

% 三角面３頂点のインデックス
F1	 = F(:,1);
F2	 = F(:,2);
F3	 = F(:,3);

% ３角面の法線ベクトル
xxf  = vb_cross2( V(F2,:)-V(F1,:) , V(F3,:)-V(F1,:) );

% 三角面３頂点の法線ベクトル平均
xxk  = xx(F1,:)+xx(F2,:)+xx(F3,:);

xdot = sum( xxk .* xxf ,2);
ix	 = find(sign(xdot) < 0 );

% ３角面の法線ベクトルと
% 頂点の法線ベクトル 'xx' (外向き)の向きをそろえる
F(ix,2) = F3(ix);
F(ix,3) = F2(ix);

F2		= F(:,2);
F3		= F(:,3);

% 各頂点の近傍点数
for n=1:Npatch,
	inx = F(n,:)';
	Nv(inx) = Nv(inx) + 2; 
end;

% バネ力平滑化＋外向き力(内側)＋内向き力(外側)

for i=1:Nloop,

    % 三角面３頂点
    V1=V(F1,:);
    V2=V(F2,:);
    V3=V(F3,:);
    
    % ３角面の法線ベクトル
    xxf   = vb_cross2( V2 - V1, V3 - V1 );

    % Normalization
    nns   = sqrt(sum(xxf.^2,2));
    xxf   = xxf./nns(:,ones(1,3));		
    
	% 三角面各頂点の差分ベクトル
    VV1   = V2 + V3 - 2*V1;
    VV2   = V3 + V1 - 2*V2;
    VV3   = V1 + V2 - 2*V3;

	% 頂点法線 = 頂点に隣接する三角面法線の平均
	xxn   = zeros(Npoint,3);	
	% 頂点差分ベクトル(近傍和)
    fd	  = zeros(Npoint,3);
	
	for n=1:Npatch,
	    % 三角面３頂点インデックス
		j1=F1(n);
		j2=F2(n);
		j3=F3(n);
	    
	    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
	    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
	    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
	    
		% 頂点差分ベクトル(近傍和)
	    fd(j1,:) = fd(j1,:) + VV1(n,:); 
	    fd(j2,:) = fd(j2,:) + VV2(n,:); 
	    fd(j3,:) = fd(j3,:) + VV3(n,:); 
    end;
    
    % 法線の正規化
    xxs   = sqrt(sum(xxn.^2,2));
    xxn   = xxn./xxs(:,ones(1,3));

    % 頂点差分ベクトルを近傍点数で正規化
    fd	 = fd./Nv(:,ones(1,3));
    
    % V 座標をボクセルインデックスに変換
    jv	= floor(V/step + 0.5) + 1;
    % Check limit
    ixv = find(jv(:,1) > 0 & jv(:,1) <= NX ...
             & jv(:,2) > 0 & jv(:,2) <= NY ...
             & jv(:,3) > 0 & jv(:,3) <= NZ);

	%---- sub2ind ----
	jj  = jv(ixv,1) + NX*( (jv(ixv,2) - 1) + NY*(jv(ixv,3) - 1) );

    % 内側マスク強度
	gg	= zeros(Npoint,1);
    gg(ixv)	= B(jj) - threshold;
%    gg(ixv) = max(B(jj) - threshold, 0);

    fg	= xxn.*gg(:,ones(1,3));
    
    V	= V + tangent_rate*fd + image_rate*fg;

	if rem(i,Ndisp)==0,
		if nfig > NYfig*NXfig
			figure;
			nfig=1;
		else
			nfig=nfig+1;
		end
		subplot(NYfig,NXfig,nfig); 
		vb_plot_surf(V,F,fclr,eclr,light_mode);
		view(vangle);
		tlabel = sprintf('Iteration = %d',i);
		title(tlabel);
	end;
end

