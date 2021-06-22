function	[V, F, xxn] = vb_surf_smooth(V,F,xx,Para)
% smoothing surface by spring model
%  [V_out, F_out, xx_out] = vb_surf_smooth(V, F, xx, Para)
%
%  V(n, 1:3)  : vertex on the surface
%  F(j, 1:3)  : patch index for surface
% xx(n, 1:3)  : normal vector at each vertex
% 
% Para.Nloop  : loop iteration number
% Para.tangent_rate : coefficient of spring force
% Para.normal_mode = 0: force = spring force
% Para.normal_mode = 1: force = spring force + compensatory expansion force 
% --------------------------------------------------
% ポリゴンモデルをバネ力による平滑化を行う
%
%  V(n, 1:3)  : 頂点の位置
%  F(j, 1:3)  : 三角面３頂点のインデックス
% xx(n, 1:3)  : 頂点の法線方向(nx,ny,nz)
% 
% Para.Nloop  : 繰り返し回数
% Para.tangent_rate : 接線方向力係数
% Para.normal_mode = 0: 平滑化バネ力
% Para.normal_mode = 1: 平滑化バネ力 + 平均半径を保つ法線方向力 (default)
%
% 平滑化バネ力 =  tangent_rate * (近傍点の平均座標との差)
%
% Ver 1.0  by M. Sato  2004-2-10
% modefied M. Sato 2006-10-15
% modefied M. Sato 2010-10-3
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% normal_mode = 0: 平滑化バネ力
% normal_mode = 1: 平滑化バネ力 + 平均半径を保つ法線方向力
normal_mode = 1;

if ~exist('Para','var'), Para = []; end
if ~isfield(Para,'Nloop'), Para.Nloop = 50; end
if ~isfield(Para,'tangent_rate'), Para.tangent_rate = 0.3; end
if isfield(Para,'normal_mode'), normal_mode = Para.normal_mode; end;

tangent_rate = Para.tangent_rate;

Nloop  = Para.Nloop;

Npoint = size(V,1);  		% number of dipoles
Npatch = size(F,1);  		% number of patch

% ３角面頂点ベクトル
V1  = zeros(Npatch,3);
V2  = zeros(Npatch,3);
V3  = zeros(Npatch,3);
% ３角面頂点の差分ベクトル
VV1 = zeros(Npatch,3);
VV2 = zeros(Npatch,3);
VV3 = zeros(Npatch,3);

% 頂点差分ベクトル
fd   = zeros(Npoint,3);
% 各頂点の近傍点数
Nv   = zeros(Npoint,1);
% 頂点差分ベクトルと法線の内積
nnf  = zeros(Npoint,1);

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

% 平滑化バネ力＋外向き力

for i=1:Nloop,

    % 三角面３頂点
    V1=V(F1,:);
    V2=V(F2,:);
    V3=V(F3,:);
    
    % ３角面の法線ベクトル
    xxf   = vb_cross2( V2 - V1, V3 - V1 );

    % Normalization
    xxf   = vb_repmultiply(xxf, 1./sqrt(sum(xxf.^2,2)));
    
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
	    
	    % ３角面の法線ベクトルの和
	    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
	    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
	    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
	    
		% 頂点差分ベクトル(近傍和)
	    fd(j1,:) = fd(j1,:) + VV1(n,:); 
	    fd(j2,:) = fd(j2,:) + VV2(n,:); 
	    fd(j3,:) = fd(j3,:) + VV3(n,:); 
    end;

    % 法線の正規化
    xxn = vb_repmultiply(xxn, 1./sqrt(sum(xxn.^2,2)));

    % 近傍点数で正規化
    fd  = vb_repmultiply(fd, 1./Nv);
    
    % 各点の変化ベクトルの法線方向射影平均
    ds  = mean( sum(fd .* xxn, 2) );
    % dd  = mean( sqrt(sum(fd .^2, 2)) ) % mean displacement
    
    if normal_mode==1
    	% 平滑化バネ力 + 平均半径を保つ法線方向力
    	V  = V + tangent_rate * (fd - ds*xxn);
    else
    	% 平滑化バネ力 
    	V  = V + tangent_rate * fd ;
    end
end

if nargout < 3, return; end;

% 三角面３頂点
V1=V(F1,:);
V2=V(F2,:);
V3=V(F3,:);

% ３角面の法線ベクトル
xxf   = vb_cross2( V2 - V1, V3 - V1 );

% Normalization
xxf   = vb_repmultiply(xxf, 1./sqrt(sum(xxf.^2,2)));

% 頂点法線 = 頂点に隣接する三角面法線の平均
xxn   = zeros(Npoint,3);	

for n=1:Npatch,
    % 三角面３頂点インデックス
	j1=F1(n);
	j2=F2(n);
	j3=F3(n);
    
    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
end;

% 法線の正規化
xxn = vb_repmultiply(xxn, 1./sqrt(sum(xxn.^2,2)));
