function	[B, V, F, xx] = vb_make_head_surf_model(parm)
% Make 1 shell head model from brain model and gray matter segment
%  [B, V, F, xx] = vb_make_head_surf_model(parm)
%%% --- Required Parameter
% parm.analyze_file : MRI image file
% parm.brain_file   : Brain model file (.brain.mat)
% parm.gray_file    : Gray matter segment file made by SPM 'Segment'
%   SPM2 - 'Segment' output 3 image files for gray/white/CSF 
%   Only gray matter file (*_seg1.hdr/img) is necessary
%   SPM5 might output different naming files
%
%%% --- Optional Parameter
% parm.Nvertex = 5000;  # of head vertex
% 
% - Radius of Morphology operation [mm]
% parm.Radius_csf  = [6 6 -4 -4 ]; Radius for CSF mask smoothing
% 
%%% --- Advanced Optional Parameter
% parm.Radius_fill = [4];    cortex fill radius
% parm.Radius_gray = [-2 2]; Radius to remove noise in gray matter image
%
% parm.Nloop  = 200; % Iteration number for fit boundary
% parm.Nlast  = 10 ; % Iteration number for smoothing by spring model
% 
% parm.Glevel = [0.8]; % level of gray matter selection threshold
%
% Masa-aki Sato 2009-9-30
% [minor] 2011-02-22 taku-y
%  Relax MRI size check: MATLAB returns a very little (<1e-8) value for
%  sum(abs(Vsize-vsize)) even though Vsize=[1 1 1] and vsize=[1.0 1.0
%  1.0], likely to be numerical error. 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Glevel = [0.8];
Radius_fill = [4];             % cortex fill
Radius_gray = [-2 2];          % gray matter
Radius_csf  = [6 6 -4 -4 ];  % mask smoothing

mode = 1; % = 1: make head surface, = 0: only make mask file
step = 2; % subsampling step for mask image [mm]

if isfield(parm,'Glevel'), Glevel = parm.Glevel; end;
if isfield(parm,'Radius_fill'), Radius_fill = parm.Radius_fill; end;
if isfield(parm,'Radius_gray'), Radius_gray = parm.Radius_gray; end;
if isfield(parm,'Radius_csf'),  Radius_csf  = parm.Radius_csf; end;
if isfield(parm,'vstep'), step = parm.vstep; end;
if isfield(parm,'test_mode'), mode = parm.test_mode; end;

% Load cortical surface
warning('off', 'MATLAB:load:variableNotFound');
load(parm.brain_file, 'brain_parm');
warning('on',  'MATLAB:load:variableNotFound');

if exist('brain_parm', 'var')
    % V2 format
    [V0L,F0L,n0L,V0R,F0R,n0R] = vb_load_orig_brain_surf(brain_parm);
    [FL,VL] = reducepatch(F0L, V0L, 10000);
    [FR,VR] = reducepatch(F0R, V0R, 10000);
    V = [VL; VR];
    V = V/1000;
    NdipoleL = size(VL,1);
    F.F3  = [FL; FR + NdipoleL];
    F.F3R = FR;
    F.F3L = FL;
    F.NdipoleL = NdipoleL;
    
else
    % V1 format
    [V,F] = vb_load_cortex(parm.brain_file);
end

% convert cortex to analyze_right_mm coordinate
[Vdim, Vsize] = analyze_hdr_read(parm.analyze_file);
V = vb_spm_right_to_analyze_right_mm(V, Vdim, Vsize);

if isfield(parm,'gray_file') && ~isempty(parm.gray_file)
	% Load gray matter segment image
	[Bg, vdim, vsize] = vb_load_analyze_to_right(parm.gray_file);
	
	if sum(abs(Vsize-vsize))>=1e-3 || sum(abs(Vdim-vdim))>=1e-3
		error('MRI image and segment image is not the same size')
	end
	
	% Make mask pattern from gray matter segment file
	Bg  = vb_image_to_mask2(Bg, Glevel, step, Vsize);
	Bg  = vb_morphology_operation(Bg, Radius_gray, step);
	Dim = size(Bg);
else
	Bg  = [];
	Dim = ceil(Vdim.*Vsize/step);
end
	
% fill inside of cortex surface
% B : voxcel mask pattern for cortex
fprintf('Fill Cortex \n')
[B] = vb_cortex_fill(V,F,step,Radius_fill,'LR', Dim);

if mode < 0, return; end;

if ~isempty(Bg)
	% merge mask pattern
	if vb_matlab_version > 6,
		B = int8(B) + int8(Bg);
	else
		B = double(B) + double(Bg);
	end
end

if nargout==1,
	% Morphology smoothing
	ix = find(B(:) > 0);
	B(ix) = 1;
	B = vb_morphology_operation(B, Radius_csf, step);
else
	% Morphology smoothing and surface extraction
	parm.vstep  = step;
	parm.Radius = Radius_csf;
	
	[V, F, xx, B] = vb_mask_to_surf_expand(B, parm);
	V = vb_analyze_right_mm_to_spm_right(V, Vdim, Vsize);
end

if mode == 0
	Nslice = 9;
	zmax = round(max(V(:,3))/step);
	zmin = round(min(V(:,3))/step);
	zstep = fix((zmax-zmin)/Nslice);
	zindx = (1:Nslice)*zstep + zmin;
	vb_plot_slice( B, V/step, zindx);
end
