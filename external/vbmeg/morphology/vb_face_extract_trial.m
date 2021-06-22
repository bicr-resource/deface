function  [B, F, V, Vmiss, Fmiss] = vb_face_extract_trial(imagefile,Para)
% Morfology operation for face extraction
%  [B, F, V] = vb_face_extract_trial(imagefile,Para)
% MRI構造画像から顔表面画像の抽出する最適パラメタを試す
%
% job_mode  = -1;	% stop after making binary mask by thresholding
% job_mode  = 0;	% stop after morphology
% job_mode  = 1;	% stop after face extraction
%                 	% extraction disconnected surface other than face
% job_mode  = 2;	% make mask data for face (closed surface)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Para','var'), Para.job_mode = 1; end;

if ~isfield(Para,'job_mode'), 
	job_mode = 1;
else
	job_mode = Para.job_mode ;
end;
if ~isfield(Para,'plot_mode'), 
	plot_mode = 1;
else
	plot_mode = Para.plot_mode ;
end;
if ~isfield(Para,'Radius'), 
	Radius = [ -2 2 ]; 
else
	Radius = Para.Radius ;
end;
if ~isfield(Para,'step'), 
	step = 2; 
else
	step = Para.step  ;
end;
if ~isfield(Para,'Bval'), 
	Bval = []; 
else
	Bval = Para.Bval  ;
end;
if ~isfield(Para,'pmax'), 
	pmax = 0.998; 
	Bval = []; 
else
	pmax = Para.pmax ;
	Bval = []; 
end;
if ~isfield(Para,'zmin'), 
	zmin = 10;
else
	zmin = Para.zmin;
end;

if ~isfield(Para,'zindx'), 
	% スライス画像表示の Z-座標リスト
	zindx = [40:20:200];
else
	zindx = Para.zindx;
end;
if ~isfield(Para,'Nfig'), 
	% subplot の 数
	Nfig  = [3, 3];
else
	Nfig  = Para.Nfig ;
end;
if ~isfield(Para,'Msize'), 
	% Marker size
	Msize = 4;
else
	Msize = Para.Msize;
end;


%
% Load 3D MRI image to analyze_right_hand coordinate
%
[B, DIM] = vb_load_analyze_to_right(imagefile);

% Calculate background noise threshold value
% by estimating Rayleigh distribution which represent backgound noise

if isempty(Bval)
	[Bval, Nhist, level] = vb_back_threshold(B,pmax,plot_mode);
end

if job_mode == -2, return; end;

% 閾値より大きい値を持つボクセルを頭部として抽出
% Make mask image from MRI data
B = vb_image_to_mask(B, Bval, step, plot_mode, zindx, Nfig);

if job_mode < 0, return; end;

% Apply morphology operations
% Dilation/erosion are done consecutively according to Radius
B = vb_morphology_operation(B, Radius, step, plot_mode, zindx, Nfig);

if job_mode == 0, return; end;

% face extraction
%  V  : 顔表面頂点        face vertex
%  F  : その三角面パッチ  patch index

[F, V, xx, Vmiss, Fmiss]  = vb_surf_extract(B, step);

% 顔表示
if plot_mode > 0,
	figure;
	vb_plot_surf(V,F,[0.8 0.7 0.6],'none',1);
	view([135, 15]);
end

Nmin  = 20;
Vmax  = max(V);
Vmin  = min(V);
Nsurf = size(Vmiss,1);
NX = 2; NY = 2;
nfig = NX*NY;

if plot_mode > 0,
	for n=1:Nsurf
		if size(Vmiss{n},1) < Nmin, continue; end;
		nfig = nfig+1;
		if nfig > NX*NY, figure; nfig = 1; end;
		subplot(NY,NX,nfig)
		vb_plot_surf(Vmiss{n},Fmiss{n},[0.8 0.7 0.6],'none',1);
		hold on
		xlim([Vmin(1) Vmax(1)]);
		ylim([Vmin(2) Vmax(2)]);
		zlim([Vmin(3) Vmax(3)]);
		view([135, 15]);
	end
end

if plot_mode == 2,
	% Histgram of MRI intensity
	figure;
	plot(level,Nhist);
	hold on
	plot([Bval Bval], [0 Nhist(round(Bval))*2], 'r-');
	title('Histgram of MRI intensity')

	% 元の画像に抽出した曲面を重ね合わせ
	[B, DIM] = vb_load_analyze_to_right(imagefile);
	vb_plot_slice( B, V, zindx, 1, Nfig, Msize);
end

if job_mode == 1, return; end;

% Make mask image from face vertex
%  B  : Mask image

B = vb_face_to_mask(V,F,DIM,step,zmin,plot_mode,zindx);

%%%%%%% Additional Plot

if job_mode < 3, return; end;

