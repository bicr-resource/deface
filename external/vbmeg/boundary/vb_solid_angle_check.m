function omega  = vb_solid_angle_check(V,F)
% total solid angle for surface
%   omega  = vb_solid_angle_check(V,F)
% omega : 重心から見た三角面の立体角総和 / (4*pi)
%         閉局面に対しては omega = 1 となるべき
% V     : 境界三角面の頂点座標
% F     : 境界三角面頂点インデックス
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% 三角面の数　Number of triangle patch
NF	= size(F,1);
NV	= size(V,1);

% 三角面の頂点　triangle vertex
x1	= V(F(:,1),:);
x2	= V(F(:,2),:);
x3	= V(F(:,3),:);

% 重心座標
x0	= sum(V,1)/NV;
xn	= x0( ones(NF,1) ,:);

% xn から見た三角面頂点ベクトル　triangle vector
xa	= x1 - xn;
xb	= x2 - xn;
xc	= x3 - xn;

% 立体角計算
abc	= sum(xa.*vb_cross2(xb,xc), 2);

ra	= sqrt(sum(xa.^2,2));
rb	= sqrt(sum(xb.^2,2));
rc	= sqrt(sum(xc.^2,2));

ya	= sum(xb.*xc,2);
yb	= sum(xc.*xa,2);
yc	= sum(xa.*xb,2);

% 立体角総和
omega = sum(atan(abc./(ra.*rb.*rc + ra.*ya + rb.*yb + rc.*yc)));
omega = omega/(2*pi);
