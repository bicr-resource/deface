function	xxn = vb_vertex_normal(V,F,xxf)
% normal vector assigned for vertex
%  xxn = vb_vertex_normal(V,F,xxf)
%
% --- Input
% V : vertex of surface
% F : triangle patch index
% xxf  : normal vector of triangle
% --- Output
% xxn  : normal vector assigned for vertex
%
% Ver 1.0  by M. Sato  2004-2-10
%
% 三角面の法線と頂点法線計算
%  V(n, 1:3)  : 頂点の位置
%  F(j, 1:3)  : 三角面３頂点のインデックス
% xxf : ３角面の法線ベクトル
% xxn : 頂点法線 = 頂点に隣接する三角面法線の平均
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);  	% 頂点数
Npatch = size(F,1);

% 頂点法線 = 頂点に隣接する三角面法線の平均
xxn   = zeros(Npoint,3);	

for n=1:Npatch,
    % 三角面３頂点インデックス
	j1=F(n,1);
	j2=F(n,2);
	j3=F(n,3);
    
    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
end;

% 法線の正規化
xxs = sqrt(sum(xxn.^2,2));
xxs = max(xxs,eps);
xxn = xxn./xxs(:,ones(1,3));
