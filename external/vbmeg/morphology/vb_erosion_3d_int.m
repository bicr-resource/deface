function	Bout = vb_erosion_3d_int(B, R)
% Erosion : Erase boundary points with radius R
% Use int8-type for MATLAB ver.7
%
% 境界から半径 R 以内の近傍点を削除
% 外部境界点を抽出してから近傍点操作を行う
%
% Bout  : Output mask pattern
% B     : 3D-マスクパターン (3D-mask pattern)
% B = 1 : 内部点 (interior point)
%   = 0 : 外部点 (outer point)
% R     : 近傍点の半径 (Radius of eraser)
%
% 2005-1-18  M. Sato 
% 内部点マスクを前後左右上下に動かし、内部境界点を抽出
% 
% 2005-7-2   M. Sato 
% Z方向にループを回し、2D イメージ処理をするように変更
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% 整数型データタイプ宣言
B = int8(B);

[N1,N2,N3] = size(B);

Bout = B;	% Output mask

% Make outer point mask (外部点)
% 整数型データタイプ宣言
Bo     = zeros(N1,N2,N3,'int8');
iz	   = find( B == 0 );
Bo(iz) = 1;

% neighbor index list
% (X-axis) 隣接点インデックス
j1d = 1:(N1-1);
j1u = 2:N1;
% (Y-axis) 隣接点インデックス
j2d = 1:(N2-1);
j2u = 2:N2;

% Make neighbor index within R
Rmax = ceil(R);
x	 = -Rmax:Rmax;

[x1, x2, x3 ] = ndgrid(x);

jx = find( (x1.^2 + x2.^2 +x3.^2 ) <= R^2 );
x1 = x1(jx);
x2 = x2(jx);
x3 = x3(jx);

NN   = length(jx);
N1N2 = N1*N2;

Bx = zeros(N1,N2, 'int8');	% (内部境界点) inside boundary point mask

for zz = 1:N3
	
	Bx = zeros(N1,N2, 'int8');
	
	% 内部点マスクを前後左右上下(26近傍点方向)に動かす。
	
	Bx(j1d, : ) = Bx(j1d, : ) + B(j1u, : , zz );
	Bx(j1u, : ) = Bx(j1u, : ) + B(j1d, : , zz );
	Bx( : ,j2d) = Bx( : ,j2d) + B( : ,j2u, zz );
	Bx( : ,j2u) = Bx( : ,j2u) + B( : ,j2d, zz );
	
	if zz > 1,
		Bx = Bx + B(:,:,zz-1);
	end
	if zz < N3,
		Bx = Bx + B(:,:,zz+1);
	end
	
	% 内部点マスクと外部点マスクを前後左右に動かしたものとの積
	Bx = Bx.*Bo(:,:,zz);
	
	% 内部境界点の抽出
	iz = find( Bx > 0 );
	Nz = length(iz);
	
	% 2D-subscript of inner boundary point
	% ----- [j1,j2] = ind2sub([N1,N2], iz );
	j3  = zz;
	j2  = floor((iz-1)/N1)+1;
	j1  = rem((iz-1),N1)+1;
	
	% 内部境界点 index
	k1 = zeros(Nz,1);
	k2 = zeros(Nz,1);
	
	for n=1:NN,
		% Make mask point subscript with fixed neighbor index
		k1 = j1 + x1(n);
		k2 = j2 + x2(n);
		k3 = j3 + x3(n);
	
		% Check index limit
		k1 = max(k1,1);
		k2 = max(k2,1);
		k3 = max(k3,1);
		
		k1 = min(k1,N1);
		k2 = min(k2,N2);
		k3 = min(k3,N3);
		
		% Delete neighbor points from mask
		%---- ind2sub ----
		inx = k1+ N1*(k2 - 1)+ N1N2*(k3 - 1);
		
		Bout(inx) = 0;
	end;
end
