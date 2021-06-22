function [ID, DD] = vb_find_geodesic(Jstart, Jend, xxF, xxD ,Rmax)
% find minimum path along cortical surface
%   [ID, DD] = vb_find_geodesic(Jstart, Jend, xxF, xxD ,Rmax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        最短距離経路探索
% 隣接近傍点リスト( xxF ) とその距離( xxD ) を使って
% 皮質に沿って最短距離で開始点から終点までの経路を探索
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
%   Jstart	: 開始点のインデックス
%   Jend	: 終点のインデックス
%   xxF{i}  : 隣接近傍点インデックス
%   xxD{i}  : 隣接近傍点距離
%   Rmax	: 探索最大半径
% OUTPUT
%   ID  : 経路点インデックス
%   DD	: 累積距離
%
% Made by Masa-aki Sato on 2005-1-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% アルゴリズム ： 最近傍点リストを用いた Tree 探索
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%１．自分自身をルートにする
%２．各ルート点の隣接近傍点の集合を候補点リストに登録する
%３．候補点リストの中でこれまでに試されていない新しい候補点を抽出する
%４．出発点から候補点までの累積距離を計算(経路に依存)
%５．出発点から候補点までの最短累積距離を求める
%６．累積距離が指定半径以内にある点を見つける
%７．上記の点を新しいルートにして２．へ戻る
%８．終点に到達したら終了
%９．指定半径以内にある新しいルートが無くなったときに終了

nextID  = Jstart; 	% 近傍点インデックスリスト
prevID  = 0; 		% 1つ前の点のインデックスリスト
nextDD	= 0;		% 近傍点累積距離リスト
rootix	= Jstart;  	% ルートのインデックスリスト
rootd	= 0;  		% ルートの累積距離リスト
itree	= 0;  		% tree number

while itree==0 | ~isempty(rootix),  
    itree	 = itree+1;
    nroot	 = size(rootix,1); % 今回のルート点数
    
    % 候補点 : 全てのルートの隣接近傍点
    ixlist = []; % 隣接近傍点インデックスリスト
    jplist = []; % 1つ前の点のインデックス
    ddlist = []; % 隣接近傍点への累積距離リスト
    
    for i=1:nroot, 
    	iroot  = rootix(i);	% ルートのインデックス
	    ixlist = [ixlist; xxF{iroot}]; 				% 隣接近傍点インデックス
	    ddlist = [ddlist; xxD{iroot} + rootd(i) ];	% 隣接近傍点への累積距離
	    newnum = length(xxF{iroot});
	    jplist = [jplist; iroot(ones(newnum,1))];	% 1つ前の点のインデックス
    end;
    
    % 候補点の絞り込み
    ixuniq = unique(ixlist);  			% 重複インデックスを削除
    nextix = vb_setdiff2(ixuniq,nextID);  	% 探索済みのインデックスを削除

    % 探索候補点インデックス
    nextix = nextix(:);
    Nnext  = length(nextix);
    nextd  = zeros(Nnext,1);
    prevj  = zeros(Nnext,1);
    
    for i=1:Nnext,  % Loop of new dipoles
    	% ixlist の中で nextix(i) に等しいインデックスを抽出
    	% Jstart から nextix(i) へ複数の経路に対応
        jx = find( nextix(i)==ixlist );
        
        % nextix(i) への最短累積距離を探す
        [dmin ,jmin] = min(ddlist(jx)); 
        % 最短累積距離
        nextd(i) = dmin;
        % 1つ前の点のインデックス
        prevj(i) = jplist(jx(jmin));
    end
    
    % 終点に到達したかチェック
    jfinal  = find(nextix == Jend);
    
    if isempty(jfinal)
	    % 最大半径以内の候補点を探す
	    okix	= find(nextd<Rmax); % 最大半径以内の候補点を探す
	    rootix	= nextix(okix);  	% 最大半径以内の候補点(次回のルート点)
	    rootd	= nextd(okix);  	% その最短累積距離
	    prevj   = prevj(okix);		% 1つ前の点のインデックス
	
	    % 近傍点リスト
	    nextID = [nextID ; rootix ];% 近傍点リスト
	    prevID = [prevID ; prevj ];	% 1つ前の点のインデックス
	    nextDD = [nextDD ; rootd  ];% 最短累積距離
	else
	    nextID = [nextID ; Jend ];% 近傍点リスト
	    prevID = [prevID ; prevj(jfinal)];	% 1つ前の点のインデックス
	    nextDD = [nextDD ; nextd(jfinal)];	% 最短累積距離
	    break;
	end
end

ID = [];
DD = [];

Nend = length(nextID);
iend = Nend;
% Backtrack
% 1つ前の点のインデックスをもとに終点から開始点へ経路探索

for n=1:Nend
	ID    = [ID; nextID(iend)];
	DD    = [DD; nextDD(iend)];
	jpre  = prevID(iend);
	
	if jpre == 0, break; end;
	
	iend  = find( jpre == nextID );
end	

ID = flipud(ID);
DD = flipud(DD);
