function	B = vb_neighbor_smooth_3d(B)
% averaging by nearest neighbor
% B = vb_neighbor_smooth_3d(B)
% B : 3D-image
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[N1,N2,N3] = size(B);

% データの間引き間隔
% subsampling step
step = 2;

% neighbor index list for boundary detection
% (X-axis) 隣接点インデックス
j1d = 1:(N1-1);
j1u = 2:N1;
% (Y-axis) 隣接点インデックス
j2d = 1:(N2-1);
j2u = 2:N2;

% 前後左右上下に動かし平均化
for zz = 1:N3
	B(j1d, : , zz ) = B(j1d, : , zz ) + B(j1u, : , zz );
end

for zz = 1:N3
	B( : ,j2d, zz ) = B( : ,j2d, zz ) + B( : ,j2u, zz );
end

for zz = 1:(N3-1)
	B(:,:,zz) = B(:,:,zz) + B(:,:,zz+1);
end

B = B/8;


