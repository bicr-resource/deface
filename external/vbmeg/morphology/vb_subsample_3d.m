function	B = vb_subsample_3d(B)
% subsampling by half
%  B = vb_subsample_3d(B)
%  B : 3D-image
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[N1,N2,N3] = size(B);

if mod(N1,2) ~= 0,
	B = cat(1, B, zeros(1,N2,N3));
	N1= N1+1;
end

if mod(N2,2) ~= 0,
	B = cat(2, B, zeros(N1,1,N3));
	N2= N2+1;
end

if mod(N3,2) ~= 0,
	B = cat(3, B, zeros(N1,N2,1));
	N3= N3+1;
end

% データの間引き間隔
% subsampling step
step = 2;

% neighbor index list for boundary detection
% (X-axis) 隣接点インデックス
j1d = 1:step:(N1-1);
j1u = 2:step:N1;
% (Y-axis) 隣接点インデックス
j2d = 1:step:(N2-1);
j2u = 2:step:N2;

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

% データの間引き
% subsampling
B = B(1:step:N1,1:step:N2,1:step:N3)/8;


