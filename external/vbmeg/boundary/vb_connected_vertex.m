function	[Vinx, Nall, ix_rest] = vb_connected_vertex(Vindx,F)
% extract connected vertex index
%  [Vinx, Nall, ix_rest] = vb_connected_vertex(Vindx,F)
% --- Input
% Vindx : vertex index list for search
% F     : patch index list
% --- Output
% Vinx{n} : vertex index of n-th connected surface
% Nall(n) : # of points for n-th connected surface
% ix_rest : disconnected points
%
% Ver 1.0  by M. Sato  2006-11-11
%
% ポリゴンモデルの連結面を取り出す
% ポリゴンモデルの三角面法線の向きを外向きに揃える
%
% 　 アルゴリズム 
%０．候補 周辺頂点リストに関するループ
%１．候補 周辺頂点リストからルート頂点を選ぶ
%２．ルート点の未処理隣接三角面を探す
%３．隣接三角面の中で前回最終頂点を含むものを探す
%４．三角面頂点の並び方を揃える
%５．三角面のもう一つの頂点を今回の最終頂点にする
%６．周辺頂点リストに向きを確定した辺の頂点を追加する
%７．未処理面が残っていれば２へ戻る
%８．未処理の周辺頂点が残っていれば１へ戻る
%９．確定した周辺頂点リストを新しい候補リストにして０に戻る
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = max([F(:); Vindx(:)]);  % 頂点数

% 'Vindx'を含むパッチのみを取り出す
F = vb_patch_select(Vindx,F,Npoint);

Npoint = max([F(:); Vindx(:)]);  % 頂点数
Npatch = size(F,1);  	% 三角面数

Plist = zeros(Npoint,2);	% 候補 周辺頂点リスト
Vlist = zeros(Npoint,2);	% 向き確定 周辺頂点リスト
Vflg  = zeros(Npoint,1);	% 頂点処理済みフラグ
Fflg  = zeros(Npatch,1);	% 三角面処理済みフラグ
FF	  = zeros(Npatch,3);	% 三角面インデックス

% 'Vindx'以外を除外
Vflg(:) = -1;

% 'Vindx'を未処理にする
Vflg(Vindx) = 0;

% 隣接三角面インデックスリストの作成
% xxF{n} : 頂点 n に隣接する面の頂点番号と面番号
xxF  = vb_neighbor_index(zeros(Npoint,1),F);

% ルートインデックス
nextID = [];

for j = 1:length(Vindx)
	root = Vindx(j);
	nextID = xxF{root};
 	if ~isempty(nextID),  break; end;
end

if isempty(nextID), 
	ix_rest = Vindx;
	Vinx = [];
	Nall = 0;
	Fall = [];
	return
end

Plist(1,:) = [root, nextID(1,1)];

Nsurf = 1;
Nall  = [];

while 1,
	
	Nlist =1;% 候補 周辺頂点数
	Nroot =0;% 処理済み頂点数
	
	while Nlist > 0,
	
		Nedge = 0;% 向き確定 周辺頂点数
		
		% 周辺頂点に関するループ
		for n=1:Nlist,
		    % root インデックスと next インデックスの更新
		    root = Plist(n,1);
		    next = Plist(n,2);
			
			% root の隣接点インデックスリスト
			nextID = xxF{root}; 	
		    
		    % 隣接点リスト
		    nlist1 = nextID(:,1); 	% 隣接点リスト1
		    nlist2 = nextID(:,2); 	% 隣接点リスト2
		    flist  = nextID(:,3); 	% 隣接三角面リスト
		    
		    % 未処理の面インデックスを探す
		    nextix = find( Fflg(flist) == 0 );
		    
		    if isempty(nextix), 
		    	continue;
		    end;
		    
		    % 未処理面のインデックスリスト
		    nlist1 = nlist1(nextix);
		    nlist2 = nlist2(nextix);
		    flist  = flist(nextix);
		    
		    Nnext  = length(nextix);
		    Nnew   = Nnext;
		
		    % root に隣接する未処理面ループ
		    for i=1:Nnext, 
		    	% nlist1/2 の中で、前回の隣接頂点 next を含む面の探索
		        jx1  = find( nlist1==next );
		        jx2  = find( nlist2==next );
		        
		        if ~isempty(jx1),
			       	nold  = next;
		        	jj	  = jx1(1);	    % next を含む面のリスト内番号
		        	fid   = flist(jj);  % next を含む面の面番号
		        	next  = nlist2(jj); % この面のもう一つの三角面頂点
	
		        	% 向き確定 周辺頂点リストに追加
		        	Nedge = Nedge + 1;
		        	Vlist(Nedge,:) = [next nold];
			        % 三角面頂点インデックスの入れ替え
			        FF(fid,:) = [root, nold, next];
			        % この面を処理済みリストに入れる
			        Fflg(fid) = 1;
					% この頂点を処理済みにする(面番号代入)
					Vflg([root, nold, next]) = Nsurf;
			        
			        % この面を隣接面リストから削除
			        inew   = [1:(jj-1),(jj+1):Nnew];
			        flist  = flist(inew);
			        nlist1 = nlist1(inew);
			        nlist2 = nlist2(inew);
			        Nnew   = Nnew-1;
		        elseif ~isempty(jx2),
			       	nold  = next;
		        	jj	  = jx2(1);	    % next を含む面のリスト内番号
		        	fid   = flist(jj);  % next を含む面の面番号
		        	next  = nlist1(jj); % この面のもう一つの三角面頂点
	
		        	% 向き確定 周辺頂点リストに追加
		        	Nedge = Nedge + 1;
		        	Vlist(Nedge,:) = [next nold];
			        % 三角面頂点インデックスの入れ替え
			        FF(fid,:) = [root, nold, next];
			        % この面を処理済みリストに入れる
			        Fflg(fid) = 1;
					% この頂点を処理済みにする(面番号代入)
					Vflg([root, nold, next]) = Nsurf;
			        
			        % この面を隣接面リストから削除
			        inew   = [1:(jj-1),(jj+1):Nnew];
			        flist  = flist(inew);
			        nlist1 = nlist1(inew);
			        nlist2 = nlist2(inew);
			        Nnew   = Nnew-1;
		        end;
		    end
		    % END- (root) に隣接する未処理面ループ 
		    
		end;
		% END-周辺頂点に関するループ
		
		% 候補 周辺頂点リストの更新
		Nlist = Nedge;
		Plist(1:Nedge,:) = Vlist(1:Nedge,:);
	
	end
	% --- END of connected surface search ---
	
	% 処理済みの頂点数
	Nall(Nsurf) = sum(Vflg == Nsurf);
	
	% 未処理の頂点を取り出す
	ix_rest = find(Vflg == 0);

	if isempty(ix_rest), break; end;
	
	Plist = zeros(Npoint,2);	% 候補 周辺頂点リスト
	Vlist = zeros(Npoint,2);	% 向き確定 周辺頂点リスト
	
	% ルートインデックス
	seedJJ = [];
	
	for jj = 1:length(ix_rest)
		seedID = ix_rest(jj);
		seedJJ = xxF{seedID};
	 	if ~isempty(seedJJ),  break; end;
	 end

	if isempty(seedJJ), break; end;
	
	Plist(1,:) = [seedID, seedJJ(1,1)];
	
	Nsurf = Nsurf + 1;
end

inxf = find(Fflg == 1);
FF	 = FF(inxf,:);

% 未処理の頂点を取り出す
ix_rest = find(Vflg == 0);
ix_rest = ix_rest';

% 大きい面の順に並び替え
[Nall , id]= sort( -Nall );

Vinx = cell(Nsurf,1);

for n=1:Nsurf
	% id(n)-番目の面の頂点を取り出す
	indx = find( Vflg == id(n) );
	Vinx{n} = indx';
	Nall(n) = length(indx);
end

return


