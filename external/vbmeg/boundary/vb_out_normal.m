function	[Fnew, Vnew, xxn, Vmiss, Fmiss] = vb_out_normal(F,V,seedID)
% extract connected surface & make normal vector outward
%  [Fnew, Vnew, xxn, Vmiss, Fmiss] = vb_out_normal(F,V)
% --- Input
% V : vertex of surface
% F : patch index
% --- Output
% Vnew : vertex of connected surface
% Fnew : patch index
% xxn  : normal vector
% Vmiss : disconnected vertex
% Fmiss : patch index for disconnected surface
%
% M. Sato  2006-6-4
%
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

if nargin<3, seedID=1; end;

Npoint = size(V,1);  	% 頂点数
Npatch = size(F,1);  	% 三角面数

Plist = zeros(Npoint,2);	% 候補 周辺頂点リスト
Vlist = zeros(Npoint,2);	% 向き確定 周辺頂点リスト
Vflg  = zeros(Npoint,1);	% 頂点処理済みフラグ
Fflg  = zeros(Npatch,1);	% 三角面処理済みフラグ
FF	  = zeros(Npatch,3);	% 三角面インデックス

% 隣接点インデックスリストの作成
xxF  = vb_neighbor_index(V,F);

% ルートインデックス
Plist(1,:) = [seedID, xxF{seedID}(1,1)];

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
				% この頂点を処理済みにする
				Vflg([root, nold, next]) = 1;
		        
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
				% この頂点を処理済みにする
				Vflg([root, nold, next]) = 1;
		        
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

% 処理済みの頂点と三角面を取り出す
indx = find(Vflg == 1);
inxf = find(Fflg == 1);
FF	 = FF(inxf,:);

[Vnew, Fnew] = vb_trans_index( V, FF, indx);
[xxn , Fnew] = vb_out_normal_vect(Vnew,Fnew);

%fprintf('New version\n')

if nargout <= 3, return; end;

% 未処理の頂点と三角面を取り出す
vmiss = find(Vflg == 0);

[Vmiss, Fmiss] = vb_trans_index(V,F,vmiss);

return

