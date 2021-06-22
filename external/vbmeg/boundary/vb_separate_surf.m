function	[Fall, Vall, Nall, Vinx] = vb_separate_surf(F,V,seedID)
% extract each connected surface
%  [Fall, Vall, Nall, Vinx] = vb_separate_surf(F,V)
% --- Input
% V : vertex of surface
% F : patch index
% --- Output
% Vall{n} : vertex of n-th connected surface
% Fall{n} : patch index of n-th connected surface
% Nall(n) : # of points for n-th connected surface
% Vinx{n} : original vertex index of n-th connected surface
%
% Ver 1.0  by M. Sato  2006-6-4
%  M. Sato  2008-1-16 changed start index
% Ver 2.0
%  M. Sato  2008-7-26 changed algorithm
%     seedID is not used (remained for old version compatibility)
% ポリゴンモデルの連結面を取り出す
%
% 　 アルゴリズム 
%０．周辺頂点リストに関するループ
%１．周辺頂点リストからルート頂点を選ぶ
%２．ルート点の未処理隣接三角面を探す
%３．隣接三角面頂点を連結頂点リストと候補 周辺頂点リストに加える
%４．未処理の周辺頂点が残っていれば１へ戻る
%５．候補 周辺頂点リストを新しい周辺頂点リストにして０に戻る
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);
Npatch = size(F,1);  	% 三角面数

Plist = zeros(Npoint,1);	% 候補頂点リスト
Vlist = zeros(Npoint,1);	% 頂点リスト

Vflg  = zeros(Npoint,1);	% 頂点処理済みフラグ
Fflg  = zeros(Npatch,1);	% 三角面処理済みフラグ

% Vertex index inside surface 'F'
Vindx = unique(F(:));

% Discard vertex outside 'F'
Vflg(:) = -1;
Vflg(Vindx) = 0;

% 隣接三角面インデックスリストの作成
% xxF{n} : 頂点 n に隣接する面の頂点番号と面番号
xxF  = vb_neighbor_index(V,F);

% ルートインデックス
seedID = Vindx(1);
Plist(1) = [seedID];

Nsurf = 1;
Nall  = [];
Vflg(seedID) = Nsurf;
Nlist = 1;% 候補 周辺頂点数
Ntotal = 0;

while 1,
	
	while Nlist > 0,
		Vlist(:) = 0;	% 周辺頂点リスト
		
		% 周辺頂点に関するループ
		for n=1:Nlist,
		    % root インデックスの更新
		    root = Plist(n);
			
			% root の隣接点インデックスリスト
			nextID = xxF{root}; 	
		    
		    % 隣接点リスト
		    nlist1 = nextID(:,1); 	% 隣接点リスト1
		    nlist2 = nextID(:,2); 	% 隣接点リスト2
		    flist  = nextID(:,3); 	% 隣接三角面リスト
		    
		    % 未処理の面インデックスを探す
		    nextix = find( Fflg(flist) == 0 );
		    
		    if isempty(nextix), continue;  end;
		    
		    % 未処理面のインデックスリスト
		    nlist1 = nlist1(nextix);
		    nlist2 = nlist2(nextix);
		    flist  = flist(nextix);
		    
		    Fflg(flist) = Nsurf;
		    Vlist(nlist1) = 1;
		    Vlist(nlist2) = 1;
		    
		end;
		% END-周辺頂点に関するループ
		
		% Next root index
		ix = find(Vlist == 1 & Vflg == 0);
		
		Nlist = length(ix);
		if Nlist == 0, break; end;
		
		% 候補 周辺頂点リストの更新
		Plist(1:Nlist) = ix;
		Vflg(ix) = Nsurf;
		Ntotal = Ntotal + Nlist;
	end
	% --- END of connected surface search ---
	
	% 処理済みの頂点数
	ix = find(Vflg == Nsurf);
	Nall(Nsurf) = length(ix);
	
	% 未処理の頂点を取り出す
	ix_rest = find(Vflg == 0);
	Nrest = length(ix_rest);
	
	fprintf('Nsurf= %d, N= %d, Ntotal=%d, Nrest=%d\n', ...
	        Nsurf,Nall(Nsurf),Ntotal,Nrest)

	if isempty(ix_rest), break; end;
	
	Nlist = 1;
	Nsurf = Nsurf + 1;
	seedID = ix_rest(1);
	Plist(1) = seedID;
	Vflg(seedID) = Nsurf;
end

% 大きい面の順に並び替え
[Nall , id]= sort( -Nall );

Vinx = cell(Nsurf,1);
Vall = cell(Nsurf,1);
Fall = cell(Nsurf,1);

for n=1:Nsurf
	% id(n)-番目の面の頂点を取り出す
	indx = find( Vflg == id(n) );
	[Vnew, Fnew] = vb_trans_index( V, F, indx);
	Nall(n) = length(indx);
	Vinx{n} = indx;
	Vall{n} = Vnew;
	Fall{n} = Fnew;
end

return


