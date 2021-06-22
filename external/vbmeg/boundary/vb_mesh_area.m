function	[sarea, asum, adev] = vb_mesh_area(V,F)
% area of patch triangle
%  area = vb_mesh_area(V,F)
% --- Input
% V(n,1:3) : vertex of surface
% F(m,1:3) : patch index
% --- Output
% area(m) : area of patch triangle F(m,1:3)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npatch = size(F,1);  		% number of patch

% 三角面３頂点のインデックス
F1	 = F(:,1);
F2	 = F(:,2);
F3	 = F(:,3);

% ３角面の法線ベクトル
xxf  = vb_cross2( V(F2,:)-V(F1,:) , V(F3,:)-V(F1,:) );

sarea = sqrt(sum(xxf.^2,2));

asum=sum(sarea)/Npatch;

adev=sqrt(sum((sarea-asum).^2)/Npatch);
