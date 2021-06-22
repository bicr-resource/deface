function	[Vnew,Fnew,xx,Indx,ddmin] = ...
            vb_morph_cortex(V, F, Nvertex, Radius, step, LR_mode)
% smoothing cortex combined left and right cortex
% [Vnew,Fnew,xx,Indx,ddmin]=vb_morph_cortex(V, F, Nvertex, Radius, step, LR_mode)
%
% 皮質の皺を平滑化した平滑化皮質モデルを作る
% 左右の脳を一つにまとめる
%--- Input 
%
% F.F3/F3L/F3R  : 面(3角形)を構成する３つの頂点番号 ( 面の数, 3)  
% V       : 頂点位置 （ 頂点の数, 3）
% 
% Nvertex : # of output cortex vertex 
% Radius  : morphology radius    (mm)
% step    : voxcel size of mask (mm)
% LR_mode = 'LR' : Left & Right cortex
%         = 'L'  : Left  cortex
%         = 'R'  : Right cortex
%
%--- Output 
%
% Fnew.F3/F3L/F3R  : 面(3角形)を構成する３つの頂点番号 ( 面の数, 3)  
% Vnew    : 頂点位置 （ 頂点の数, 3）
% xx      : 外向き法線
% Indx    : Old vertex index list corresponding to new vertex
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% 3D 画像処理のための間引きステップサイズ
% subsampling step for mask image [mm]
if ~exist('step','var'), step = 2; end;

% 穴埋め・孤立点削除 (モルフォロジー) 変換の半径
% Radius of Morfology operation [mm]
if ~exist('Radius','var'), Radius = 4; end;

if ~exist('LR_mode','var'), LR_mode = 'LR'; end;

% 
% 皮質面を３Dマスクパターンに変換
% 内部の塗りつぶし & モルフォロジー変換
%
[B, Vorgin] = vb_cortex_fill(V,F,step,Radius,LR_mode);

% 境界面抽出 
[Fc, Vc, xx] = vb_surf_extract(B, step, Vorgin);

% ボクセル座標から元の座標への変換 [m]
%Vc = vb_trans_vox_to_surf(Vc, Vorgin, step);
Vc = Vc*0.001;

Ndipole = size(Vc,1);
Npatch  = size(Fc,1);

% 解像度を下げて皮質点を作成
Fnew.F3		  = Fc;
Fnew.F3L	  = Fc;
Fnew.F3R	  = [];
Fnew.NdipoleL = Ndipole;

[Vnew, Fnew]  = vb_reduce_vertex(Vc,Fnew,Nvertex);

% 法線方向を外向きに揃える
% xx : 外向き法線
[Fc, Vnew, xx, Vmiss] = vb_out_normal( Fnew.F3 ,Vnew);

Fnew.F3		  = Fc;
Fnew.F3L	  = Fc;
Fnew.F3R	  = [];
Fnew.NdipoleL = size(Vnew,1);

% # of disconnected vertex
fprintf('# of reduced vertex      = %d\n', size(Vnew,1)) 
fprintf('# of disconnected vertex = %d\n', size(Vmiss,1)) 

% 閉局面のチェック: omega = 1
omega  = vb_solid_angle_check(Vnew,Fc);
fprintf('Closed surface index (=1) : %f\n', omega)

% Find old vertex point corresponding to new vertex
% Zstep : Number of steps to divide Z-axis
% Rmax  : find nearest point within radius Rmax [m]
Zstep = 50;
Rmax  = 0.01;

[Indx ,ddmin] = vb_find_nearest_point(V, Vnew, Rmax, Zstep);

fprintf('Max distance between new and old vertex = %f\n',max(ddmin))
