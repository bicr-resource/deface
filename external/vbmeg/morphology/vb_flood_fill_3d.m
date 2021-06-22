function V = vb_flood_fill_3d(V,indx,fillval,level)
% flood_fill
%  V = vb_flood_fill_3d(V,indx,fillval,level)
% 閾値'level'より小さい値を持つボクセルを'fillval'で塗りつぶす
% 
% V    = 3D イメージ
% V(x,y,z) : 点(x,y,z)における値
%
% indx = [xc,yc,zc] 初期ルートインデックス
% fillval: 塗りつぶす値 > level
% level  : 閾値
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Vflag  : 塗りつぶされたボクセルのマスクパターン

[NX,NY,NZ] = size(V);

xc = indx(1);
yc = indx(2);
zc = indx(3);

% Vflag0: 塗りつぶされたボクセルの 2D マスクパターン
[V(:,:,zc), Vflg0] = vb_flood_fill_2d(V(:,:,zc),[xc yc],fillval,level);

Vflg = Vflg0;

for n=(zc+1):NZ
	% z = (n-1) で塗りつぶされたパターンを抽出し
	ix = find( Vflg > 0);

	% z = n での塗りつぶし点の初期値
	% [i,j] = ind2sub([NX,NY],ix) の高速計算
	j  = floor((ix-1)/NX)+1;
	i  = rem((ix-1),NX)+1;

	% 2D 塗りつぶし
	[V(:,:,n), Vflg] = vb_flood_fill_2d(V(:,:,n),[i,j],fillval,level);
end

Vflg = Vflg0;

for n=(zc-1):-1:1
	% z = (n+1) で塗りつぶされたパターンを抽出
	ix = find( Vflg > 0);

	% z = n での塗りつぶし点の初期値
	% [i,j] = ind2sub([NX,NY],ix) の高速計算
	j  = floor((ix-1)/NX)+1;
	i  = rem((ix-1),NX)+1;

	% 2D 塗りつぶし
	[V(:,:,n), Vflg] = vb_flood_fill_2d(V(:,:,n),[i,j],fillval,level);
end
