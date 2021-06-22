function	[V, Vflag] = vb_flood_fill_2d(V,start,fillval,level)
% 閾値'level'より小さい値を持つボクセルを'fillval'で塗りつぶす
% V      : 2D イメージ
% V(x,y) : 点(x,y)における値 ( x=1:NX, y=1:NY )
%
% start  : 初期ルートインデックス
% fillval: 塗りつぶす値 > level
% level  : 閾値
%
% 2005-1-18  M. Sato 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Vflag  : 塗りつぶされたボクセルのマスクパターン

% 隣接頂点を順番に辿っていく手順
% 　 アルゴリズム 
%０．周辺頂点リストに関するループ
%１．周辺頂点に関するループ
%２．周辺頂点の未処理隣接頂点に対する処理
%３．新規周辺頂点リストに処理した頂点を追加する
%４．未処理の周辺頂点が残っていれば１へ戻る
%５．新規周辺頂点リストを周辺頂点リストにして０に戻る

if nargin<3, fillval=1; end;
if nargin<4, level=1; end;
if fillval < level, 
	error('level value is larger than fill value\n')
end

[NX,NY] = size(V);

NN	  = NX*NY;
D	  = 2;

% Vflag(x,y) = 1 : (x,y) は処理済み
Vflag = zeros(NX,NY);	% 頂点処理済みフラグ
Plist = zeros(NN,D);	% 周辺頂点インデックス
Vlist = zeros(NN,D);	% 候補 頂点インデックス
Nroot = size(start,1);	% 周辺頂点数

Nlist = 0; % 候補 頂点数の初期化

% 初期ルートインデックスのチェック
for n=1:Nroot,
    % root インデックス
    root = start(n,:); 
	
	if root(1)<1 | root(1)>NX | root(2)<1 | root(2)>NY,
		continue;
	end
	
	if	V(root(1),root(2)) < level,
		V(root(1),root(2)) 	   = fillval;
		Vflag(root(1),root(2)) = 1;
		Nlist          = Nlist + 1;
		Vlist(Nlist,:) = root ;
	end;
end

% ルートインデックスの初期化
Nroot = Nlist;
Plist(1:Nroot,:) = Vlist(1:Nroot,:);

% 周辺頂点リストに関するループ
while Nroot > 0,

    Nlist = 0; % 候補 頂点数の初期化

	% 周辺頂点に関するループ
	for n=1:Nroot,
	    % root インデックスの更新
	    root = Plist(n,:); 
		
		% root の隣接点 (x+1,y)
		next = [root(1)+1, root(2)];
		
		if root(1) < NX ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,
			
			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
		% root の隣接点 (x-1,y)
		next = [root(1)-1, root(2)];
		
		if root(1) > 1 ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,

			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
		% root の隣接点 (x,y+1)
		next = [root(1), root(2) + 1];
		
		if root(2) < NY ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,

			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
		% root の隣接点 (x,y-1)
		next = [root(1), root(2) - 1];
		
		if root(2) > 1 ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,

			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
	end;
	% END-周辺頂点に関するループ
	
	% 候補 周辺頂点リストの更新
    Nroot = Nlist;
	Plist(1:Nroot,:) = Vlist(1:Nroot,:);
	
end

