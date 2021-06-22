function	Iextract = vb_open_area(Jarea, R, nextIX, nextDD)
% opening of cortex 2D-surface
%  Iextract = vb_open_area(Jarea, R, nextIX, nextDD)
% 孤立点を削除
% Iextract : 新しい頂点リスト
% Jarea    : 頂点リスト
%   R      : 近傍点の半径 ( m )
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Iextract = vb_cut_area(Jarea, R, nextIX, nextDD);
Iextract = vb_fat_area(Iextract, R, nextIX, nextDD);

