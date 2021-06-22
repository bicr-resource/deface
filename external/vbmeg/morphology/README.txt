function Jreduce = reduce_cortex(parm,Jindx,Reduce_ratio);
% 解像度を下げて皮質点を作成
% Make new cortex model with reduced resolution

% Jindx    : もとの解像度の皮質点インデックス
% Jreduce  : 低解像度皮質点のインデックス
% Reduce_ratio : 皮質データから点を間引くときの比率
Reduce_ratio = 1/2 : 点を1/2 に間引く

----------------------------------------------------
function	Iextract = fat_area(Jarea, R, nextIX, nextDD)
% 半径 R 以内の近傍点をリストに加える
% Dilation according to surface-distance
% Iextract : 新しい頂点リスト
% Jarea    : 頂点リスト
%   R      : 近傍点の半径 ( m )
R = 0.015  : 境界から半径 15mm 胃内の点を加える

function	Iextract = cut_area(Jarea, R, nextIX, nextDD)
% 境界から半径 R 以内の近傍点をリストから削除
% Erosion according to surface-distance
R = 0.015  : 境界から半径 15mm 胃内の点を削除

function	Iextract = close_area(Jarea, R, nextIX, nextDD)
% 穴を埋める
function	Iextract = open_area(Jarea, R, nextIX, nextDD)
% 孤立点を削除

function	Iextract = merge_area(Jarea, V)
% 複数領域の合併
% Merge area
% Iextract : 新しい頂点リスト
% Jarea{n} : 頂点リスト(セルアレイ)

function	xxP = gauss_filter(parm,Rradius,Rmax,xxP,Iextract)
% Gauss filtering of fMRI activity

------------------------------------------
function	B = dilation_3d(B, R)
% Dilation : 境界から半径 R 以内の近傍点を加える
% 内部境界点を抽出してから近傍点操作を行う

% B : 3D-マスクパターン
% R : 近傍点の半径 (ボクセルサイズを１とした時の長さ)
ボクセルの一辺のサイズが w (mm) であるとき
半径 r (mm) 以内の点を加えるためには
R = r/w

function	B = erosion_3d(B, R)
% Erosion : 境界から半径 R 以内の近傍点を削除
% 外部境界点を抽出してから近傍点操作を行う

function	B = closing_3d(B, R1, R2)
% 穴を埋める
%		dilation_3d(B, R1)
%		erosion_3d( B, R2)

function	B = opening_3d(B, R1, R2)
% 孤立点を削除
%		erosion_3d( B, R1)
%		dilation_3d(B, R2)

