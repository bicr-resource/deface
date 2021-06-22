function	Iextract = vb_cut_area(Jarea, R, nextIX, nextDD)
% Erosion according to surface-distance
%  Iextract = vb_cut_area(Jarea, R, nextIX, nextDD)
% 境界から半径 R 以内の近傍点をリストから削除
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

FLAG = zeros(NV,1);
flag = zeros(NV,1);

% Internal point flag
FLAG(Jarea) = 1;
flag(Jarea) = 1;

for n=1:NJ,
	i	 = Jarea(n);
	dd0  = nextDD{i};

	% Find neighbor point within R from internal point
	inx  = find( dd0 <= R );
	indx = nextIX{i}(inx);

	% Exclude points if R-neighbor include external point
	flag(i) = prod(FLAG(indx));
end;

Iextract = find( flag > 0 );
