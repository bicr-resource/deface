function	[V, F, xxn] = vb_surf_smooth_data(V,F,xx,vg,Para)
% smoothing surface by spring model and 3D-image data
%  [V, F, xxn] = vb_surf_smooth_data(V,F,xx,vg,Para)
%
% Ver 1.0  by M. Sato  2004-2-10
%
% ポリゴンモデルをマスクパターンの境界面に膨らませ
% バネ力による平滑化を行う
% 平滑化バネ力＋外向き力(内側)／内向き力(外側)
%
%  V(n, 1:3)  : 頂点の位置
%  F(j, 1:3)  : 三角面３頂点のインデックス
% xx(n, 1:3)  : 頂点の法線方向(nx,ny,nz)
% xxn(n, 1:3) : 頂点の法線方向(nx,ny,nz)
% vg(NX,NY,NZ): 3D-ボクセル・マスクパターン
%
% Para.tangent_rate         : 接線方向力係数
% Para.tangent_normal_ratio : 法線方向力係数
% Para.mask_ratio           : 画像強度力係数 ( 強度>閾値:外向き)
% Para.mask_threshold       : 画像強度閾値   ( 強度<閾値:内向き)
% Para.vsize                : ボクセルサイズ
% Para.normal_subtract;
% Para.Nloop
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

c1	   = Para.tangent_rate;
c2	   = Para.tangent_rate*Para.tangent_normal_ratio;
c3	   = Para.normal_subtract;
c4	   = Para.mask_ratio;
g0	   = Para.mask_threshold;

Nloop  = Para.Nloop;
Ndisp  = Para.Ndisp;
cmode  = Para.cmode;
vangle = Para.vangle;
NX	   = Para.NX;
NY	   = Para.NY;
nfig   = 1;

Npoint = size(V,1);  		% number of dipoles
Npatch = size(F,1);  		% number of patch
gsize  = size(vg);

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
% 外向き(内側)・内向き(外側)の力
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

    % 近傍点数で正規化
    fd	 = fd./Nv(:,ones(1,3));

	% 頂点差分ベクトルと法線の内積
    nnf  = sum(xxn.*fd,2);
    
    % 頂点差分ベクトルの法線射影
    fn   = xxn.*nnf(:,ones(1,3));
    
    % 頂点差分ベクトルの接線射影
    % DEBUG
    ft  = fd - fn; 
    % DEBUG
    
	% 法線方向の平均力を引く
    fns = sum(fn,1)/Npoint;
    
    % V 座標をボクセルインデックスに変換
    jv	= floor(V)+1;
    jj	= sub2ind(gsize,jv(:,1),jv(:,2),jv(:,3));

    % 内側マスク強度
    gg	= tanh(vg(jj)-g0);

    fg	= xxn.*gg(:,ones(1,3));
    
    V	= V + c1*ft + c2*(fn - c3*fns(ones(Npoint,1),:)) + c4*fg;

	if rem(i,Ndisp)==0,
		subplot(NY,NX,nfig); nfig=nfig+1;
		vb_plot_head_V(V,F,cmode);
		view(vangle);
		tlabel = sprintf('Iteration = %d',i);
		title(tlabel);
		axis equal
	end;
end

