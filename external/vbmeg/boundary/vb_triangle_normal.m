function	xxf = vb_triangle_normal(V,F)
% normal vector of patch triangle
%  xxf = vb_triangle_normal(V,F)
%
% --- Input
% V : vertex of surface
% F : triangle patch index
% --- Output
% xxf  : normal vector of triangle
%
% Ver 1.0  by M. Sato  2004-2-10
%
% 三角面の法線と頂点法線計算
%  V(n, 1:3)  : 頂点の位置
%  F(j, 1:3)  : 三角面３頂点のインデックス
%
% xxf : ３角面の法線ベクトル
% xxn : 頂点法線 = 頂点に隣接する三角面法線の平均
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);  	% 頂点数
Npatch = size(F,1);

% 三角面３頂点のインデックス
F1	 = F(:,1);
F2	 = F(:,2);
F3	 = F(:,3);

% 三角面３頂点
V1 = V(F1,:);
V2 = V(F2,:);
V3 = V(F3,:);

% ３角面の法線ベクトル
xxf = vb_cross2( V2 - V1, V3 - V1 );

% Normalization
xxs = sqrt(sum(xxf.^2,2));
xxs = max(xxs,eps);
xxf = xxf./xxs(:,ones(1,3));

