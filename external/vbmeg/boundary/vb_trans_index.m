function	[V,F] = vb_trans_index(V,FF,indx)
% Select vertex and patch from surface
%    [V,F] = vb_trans_index(V,FF,indx)
% --- Input
% V  : vertex of surface
% FF : patch index
% indx : index of selected vertex
% --- Output
% V : selected vertex
% F : patch index which include selected vertex
%
% Ver 1.0  by M. Sato  2004-2-10
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%
%------ 3角形番号を新しい頂点情報に対応するように変換 -------
%
Npoint = size(V,1);  	% 頂点数
Nnew = length(indx);
V	 = V(indx,:);

% 旧頂点番号から新しい頂点番号へ変換する変換表
% Itrans(i)=0 : 旧頂点番号 = i は新しい頂点に含まれない
% Itrans(i)=j : 旧頂点番号 = i は新しい頂点 = j に対応
Itrans		 = zeros(Npoint,1);
Itrans(indx) = 1:Nnew;

% 3角形番号を新しい頂点情報に対応するように変換
% 3角形の全ての頂点が新しい頂点に含まれる3角形を探す
FF	= Itrans(FF);
ixF = find(prod(FF ,2) ~= 0 );
F   = FF(ixF,:);

return
