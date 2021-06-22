function	B = vb_dilation_2d(B, R)
% Dilation : 境界から半径 R 以内の近傍点を加える
% 内部境界点を抽出してから近傍点操作を行う
%
% B     : 2D-マスクパターン
% B = 1 : 内部点
%   = 0 : 外部点
% R     : 近傍点の半径
%
% 2005-1-18  M. Sato 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[N1,N2] = size(B);

Bo = zeros(N1,N2);	% (外部点) outer point mask
Bx = zeros(N1,N2);	% (内部境界点) inside boundary point mask

% neighbor index list
% (X-axis) 隣接点インデックス
j1d = 1:(N1-1);
j1u = 2:N1;
% (Y-axis) 隣接点インデックス
j2d = 1:(N2-1);
j2u = 2:N2;

% Make outer point mask (外部点)
iz	   = find( B == 0 );
Bo(iz) = 1;

% 外部点マスクを前後左右上下(8近傍点方向)に動かす
Bx(j1d, : ) = Bx(j1d, : ) + Bo(j1u, : );
Bx(j1u, : ) = Bx(j1u, : ) + Bo(j1d, : );
Bx( : ,j2d) = Bx( : ,j2d) + Bo( : ,j2u);
Bx( : ,j2u) = Bx( : ,j2u) + Bo( : ,j2d);

% 内部点マスクと外部点マスクを前後左右に動かしたものとの積
Bx = Bx.*B;

% 内部境界点の抽出
iz = find( Bx > 0 );
Nz = length(iz);

% 3D-subscript of inner boundary point
[j1,j2] = ind2sub([N1,N2], iz );

% Make neighbor index within R
Rmax  = ceil(R);
x	  = -Rmax:Rmax;

[x1, x2 ] = ndgrid(x);

jx = find( (x1.^2 + x2.^2 ) <= R^2 );

x1 = x1(jx);
x2 = x2(jx);

NN = length(jx);

% 内部境界点 index
k1 = zeros(Nz,1);
k2 = zeros(Nz,1);

for n=1:NN,
	% Make mask point subscript with fixed neighbor index
	k1 = j1 + x1(n);
	k2 = j2 + x2(n);

	% Check index limit
	k1 = max(k1,1);
	k2 = max(k2,1);
	
	k1 = min(k1,N1);
	k2 = min(k2,N2);
	
	% Add neighbor points to mask
	inx = k1+ N1*(k2 - 1);
	
	B(inx) = 1;
end;
