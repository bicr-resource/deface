function  [V, F, xx, Xcenter] = vb_make_smooth_cortex_surf(subj_mask,analyzefile,Para)
% Make cortex surface from brain mask image
% [V, F, xx, Xcenter] = vb_make_smooth_cortex_surf(subj_mask,analyzefile,Para)
% --- Input 
% analyzefile : Subject analyzefile
% subj_mask   : Subject brain mask file
%
% Para.gray_val : threshold value for gray matter
%   if it is empty, only brain mask is used
%   if is is given, voxel with larger intensity than 'val' is selected
%
% --- バネモデル平滑化パラメタ
% Para.Nvertex = 3000; 出力頂点数
% Para.Radius = [2 -2]; morphological smoothing
% Para.vstep  = 1;   イメージ処理ボクセルサイズ [mm]
% Para.Nloop  = 200; マスク境界フィット繰り返し回数
% Para.Nlast  = 0;   バネモデル平滑化繰り返し回数
%
% --- Output
% [V, F, xx] : surface vertex, patch index, normal vector
%              SPM-right-[m] coordinate
% Xcenter : Center of cortex to separate left/right (SPM-right-[m])
%
% 
% 2007/7/05 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% --- バネモデル平滑化パラメタ
if ~isfield(Para,'Nvertex'), Para.Nvertex = 3000; end
if ~isfield(Para,'Radius'),Para.Radius  = [2 -2];end 
if ~isfield(Para,'Nloop'), Para.Nloop = 200; end
if ~isfield(Para,'Nlast'), Para.Nlast = 0; end
if ~isfield(Para,'vstep'), Para.vstep = 1; end;
if ~isfield(Para,'plot_mode'), Para.plot_mode = 0; end

% Gray matter threshold
if isfield(Para,'gray_val'), 
	val = Para.gray_val;
else
	val = [];
end

% Z-slice index for display
zindx = fix([80:15:200]);

if ~isempty(val),
	Nbin = 60;
	[hst, x] = vb_get_cortex_histogram(subj_mask,analyzefile,Nbin);
	stairs(x,hst);	hold on
	plot([val val],[0 max(hst)],'-r'); 
	xlim([0 160])
	title('histgram of brain region')
end
%
% --- Get subject cortex mask (voxel size = step [mm])
%
step = Para.vstep;

if	isempty(val)
	[avw ,Xcenter] = vb_get_brain_mask(subj_mask,'cortex','', step);
else
	[avw ,Xcenter] = vb_get_cortex_mask(subj_mask, analyzefile,'',step,val);
end

% --- Show boundary of mask
if Para.plot_mode==1,
	[xyz] = vb_get_boundary(avw.img);
	vb_plot_slice( avw.img, xyz, fix(zindx/step), 1, [3, 3], 1);
end

%
% --- Extract smooth surface from mask image [analyze_right_mm]
%
[V, F, xx] = vb_mask_to_surf_expand(avw.img, Para);

%
% --- Plot surface on MRI slice
%
[B, Vdim, Vsize] = vb_load_analyze_to_right(analyzefile);

Vana  = vb_analyze_mm_to_analyze(V,Vdim,Vsize);

zindx = fix(zindx/Vsize(3));
dmax  = 10;
xymode=1;

vb_plot_slice_surf(B, Vana, F, zindx, 'z',[3 3],'r-',dmax,xymode);

figure
vb_plot_surf(V,F,[],[],1,1);
view([ -130 10]);

%
% --- SPM-right-[m] coordinate
%
V = vb_analyze_right_mm_to_spm_right(V,Vdim,Vsize);


return

if ~exist('fname','var') | isempty(fname), return; end;

%
% --- Save file
%
fprintf('Save %s \n',fname)
vb_fsave(fname,'V','F','xx','Xcenter')



