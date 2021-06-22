function	xxF = vb_neighbor_index(V,F)
% nearest neighbor index of each vertex
%  xxF = vb_neighbor_index(V,F)
% --- Input
% V : vertex of surface
% F : patch index
% --- Output
% xxF{n} : neighboring vertex index of n-th vertex
%        = [ 2nd-vertex of j-th patch, 3rd-vertex of j-th patch, j]
%          [(# of patch connected to n-th vertex) x 3]
% Ver 1.0  by M. Sato  2004-2-10
%
% xxF{n} : 頂点 n に隣接する面の頂点番号と面番号
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);  		% 頂点数
Npatch = size(F,1);  		% 三角面数
xxF    = cell(Npoint,1); 	% 隣接頂点インデックスリスト

% ３角面に関するループ
for j=1:Npatch,
    % ３角面の頂点インデックス
    k1 = F(j,1); 
    k2 = F(j,2); 
    k3 = F(j,3); 
    
    % 各頂点の隣接点リストに他の頂点と面番号を加える
	xxF{k1} = [ xxF{k1} ; k2 , k3 ,j];
	xxF{k2} = [ xxF{k2} ; k3 , k1 ,j];
	xxF{k3} = [ xxF{k3} ; k1 , k2 ,j];
end;
