function	Iextract = vb_fat_area(Jarea, R, nextIX, nextDD)
% Dilation according to surface-distance
%  Iextract = vb_fat_area(Jarea, R, nextIX, nextDD)
% 半径 R 以内の近傍点をリストに加える
%
% Iextract : 新しい頂点リスト
% Jarea    : 頂点リスト
%   R      : 探索する近傍点の半径 ( m )
%
% nextIX{i} : 点-i の近傍点のインデックスリスト
% nextDD{i} : 点-i と近傍点の皮質に沿った距離
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NV	 = size(nextIX,1); % Number of all vertex
NJ	 = length(Jarea);

flag = zeros(NV,1);

flag(Jarea) = 1;

for n=1:NJ,
	i	 = Jarea(n);
	dd0  = nextDD{i};

	% Find neighbor index within R
	inx  = find( dd0 <= R );	
	indx = nextIX{i}(inx);

	% Include neighbor point	
	flag(indx) = 1;
end;

Iextract = find( flag > 0 );
