function  [Vx,Fnew,xx,Vindx,Vinfo] = vb_smooth_cortex(V, F, Para)
% Make smooth cortex from brain model by morphological smoothing
%  [Vnew,Fnew,xxnew,Vindx,Vinfo] = vb_smooth_cortex(V, F, Para)
%--- Input 
%
% V  　  : Cortical vertex point cordinate , Analyze_right [mm]
% F      : Patch index structure
%  .F3R	 : Right cortex
%  .F3L	 : Left  cortex
%  .F3	 : Left + Right
%
% Para.Dim      : Dimension of mask image
% Para.vstep    : subsampling step size of mask image [mm]
% Para.R_fill   = [4] :radius for fill-in cortex surface
% Para.R_smooth = [ 6 6 -6 -6] :radius for morphological smoothing
% Para.Nloop    = 200: iteration number for expanding sphere to brain surface
% Para.Nlast    = 0:   iteration number for additional smoothing
% Para.Nvertex  = 3000 : Reduced number of cortex
%--- Output 
%
% Vnew  : Cortical vertex point cordinate     [Nvertex, 3]
% xxnew : Normal vector to cortical surface   [Nvertex, 3]
% Fnew   : Patch index structure
%  .F3R	 : Right cortex
%  .F3L	 : Left  cortex
%  .F3	 : Left + Right
% Vinfo        : Vertex dimension structure
%   .Ndipole   : # of vertex
%   .NdipoleL  : # of vertex in Left cortex
%   .Npatch    : # of patch
%   .Coord     = 'Analyze_Right_mm';
% Vindx   : Old vertex index list corresponding to new vertex
%
% --- Method: 皮質の皺を平滑化した平滑化皮質モデルを作る
% 皮質面を３Dマスクパターンに変換
% 内部の塗りつぶし & モルフォロジー変換
% 内部に球面を作成
% 球面をマスクパターンの境界面に膨張
% (バネモデル による平滑化)
%
% Made by M. Sato 2006-3-28
% Made by M. Sato 2006-11-11
% Made by M. Sato 2007-3-16
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Para','var'), Para = []; end

if ~isfield(Para,'Dim') | isempty(Para.Dim)
	error('Size of mask image is not specified');
else
	Dim = Para.Dim;
end

% --- subsampling step for mask image [mm]
% 3D 画像処理のための間引きステップサイズ
if ~isfield(Para,'vstep'), 
	error('Step size of mask image is not specified');
else
	step = Para.vstep;
end;

% Number of vertex
if ~isfield(Para,'Nvertex'), Para.Nvertex = 3000; end;

% --- Radius of Morfology operation [mm]
% 穴埋め・孤立点削除 (モルフォロジー) 変換の半径
if ~isfield(Para,'R_fill'),	  Para.R_fill   = [4]; end;
if ~isfield(Para,'R_smooth'), Para.R_smooth = [ 6 6 -6 -6]; end;

% Surface smoothing parameter
if ~isfield(Para,'Nloop'), Para.Nloop = 200; end
if ~isfield(Para,'Nlast'), Para.Nlast = 0; end
if ~isfield(Para,'plot_mode'),Para.plot_mode = 0; end;


%
% --- Make mask from LR cortex
% 
% 皮質面を３Dマスクパターンに変換
% 内部の塗りつぶし & モルフォロジー変換
%      Dim = size(B)
tic
fprintf('--- Make mask image from cortical surface\n')
B = vb_cortex_fill(V, F, step, Para.R_fill, 'LR', Dim);
vb_ptime(toc)

% モルフォロジー変換
B = vb_morphology_operation(B, Para.R_smooth, step);

if  Para.plot_mode > 2,
	% subplot の 数
	Nfig  = [3, 3];
	% スライス画像表示の Z-座標リスト
	zindx = [20:10:Dim(3)];
	vb_plot_slice( B, [], zindx, 1, Nfig);
end

%
% --- 3次元データの平滑化
% 
tic
fprintf('smoothing\n')
B = smooth3(B,'gaussian',3);
vb_ptime(toc);

%
%------- マスクパターンの境界面に膨張
%
tic
fprintf('--- Surface expansion\n')

% 内接球面作成 R = (mean radius of V)
[Vx0, Fx, xx, X0] = vb_make_inner_sphere(V, Para.Nvertex);

% 境界面に膨張
[Vx, Fx, xx] = vb_surf_smooth_fit(Vx0,Fx,xx, B, Para);

if Para.plot_mode > 1
	dmax = 10;
	vb_plot_slice_surf( B, Vx0/step, Fx, X0(1)/step, 'x',[1 1],'r-',dmax);
	vb_plot_slice_surf([], Vx/step,  Fx, X0(1)/step, 'x',[1 1],'b-',dmax);
	vb_plot_slice_surf( B, Vx0/step, Fx, X0(2)/step, 'y',[1 1],'r-',dmax);
	vb_plot_slice_surf([], Vx/step,  Fx, X0(2)/step, 'y',[1 1],'b-',dmax);
	vb_plot_slice_surf( B, Vx0/step, Fx, X0(3)/step, 'z',[1 1],'r-',dmax);
	vb_plot_slice_surf([], Vx/step,  Fx, X0(3)/step, 'z',[1 1],'b-',dmax);
end

%
%------- バネモデル による平滑化
%
fprintf('--- Surface smoothing by spring model\n')

if Para.Nlast > 0,
	Para.Nloop = Para.Nlast; 	% バネモデル平滑化繰り返し回数
	[Vx, Fx, xx] = vb_surf_smooth(Vx,Fx,xx,Para);
end

vb_ptime(toc)

if Para.plot_mode > 0
	dmax = 10;
	vb_plot_slice_surf( B, Vx/step, Fx, X0(1)/step, 'x',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(2)/step, 'y',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(3)/step, 'z',[1 1],'r-',dmax);
end

Ndipole = size(Vx,1);
Npatch  = size(Fx,1);

fprintf('# of patches : %d\n',Npatch);
fprintf('# of vertices: %d\n',Ndipole);

% Find old vertex point corresponding to new vertex
% Zstep : Number of steps to divide Z-axis
% Rmax  : find nearest point within radius Rmax [mm]
Zstep = 100;
Rmax  = 10;

fprintf('Find original vertex corresponding to the smoothed surface\n')
[Vindx ,ddmin] = vb_find_nearest_point(V, Vx, Rmax, Zstep);

fprintf('Max distance between new and old vertex = %f [mm]\n',max(ddmin))

% Find Left/Right cortex
NdipoleL = F.NdipoleL;

ixL = find(Vindx <= NdipoleL);
ixR = find(Vindx >  NdipoleL);

% Left/Right ordering
Vix = [ixL ; ixR ];
Vx  = Vx(Vix,:);
NL  = length(ixL);

Itrans = zeros(Ndipole,1);
Itrans(Vix) = 1:Ndipole;

Fx = Itrans(Fx);

Fnew.F3L = vb_patch_select([1:NL],Fx,Ndipole);
Fnew.F3R = vb_patch_select([(NL+1):Ndipole],Fx,Ndipole);
%Fnew.F3 = [Fnew.F3L ; Fnew.F3R];
Fnew.F3  = Fx;
Fnew.NdipoleL = NL ;

% Dimensional info
Vinfo.NdipoleL  = NL ;
Vinfo.Ndipole   = Ndipole;
Vinfo.Npatch    = Npatch;
Vinfo.Coord     = 'Analyze_Right_mm';
