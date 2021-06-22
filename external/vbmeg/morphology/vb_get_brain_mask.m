function [avw ,Xcenter] = vb_get_brain_mask(fname,region_id,LR,step,Radius)
% Get brain/cortex mask image from subject brain mask file
%  [avw ,Xcenter] = vb_get_brain_mask(fname,region_id,LR,step,Radius)
% --- Input
% fname = brain mask file
% region_id = 'brain' [Defoult] or 'cortex'
% --- Optional input
% LR = 'left' , 'right'
%    if empty or not given, both hemisphere are included [Defoult]
% step   : voxel size of mask image = 1  [mm]
% Radius : Morphology Radius = [2 -2] [mm]
% --- Output
% avw.img  : 3D mask image (voxel size = step [mm])
% avw.hdr.dime.dim(2:4)    : mask image dimension
% avw.hdr.dime.pixdim(2:4) : voxel size [mm] = [step step step]
% 
% Xcenter : Center of cortex to separate left/right (SPM_right_[m])
%
% 2007/06/13 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%% Label value
%  1 = brain (CSF)
%  2 = Gray
%  3 = White
%  4 = Cerebellum
%  5 = Brainstem

if ~exist('region_id','var'), region_id = 'brain'; end;
if ~exist('LR','var'), LR = []; end;
if ~exist('step','var'), step = 1; end;

load(fname, 'avw', 'XYZspm');

B = avw.img;

switch	region_id
case	'brain'
	% brain
	ix = find( B(:) > 0 );
	if ~exist('Radius','var'), Radius = [2 -2];end
case	'cortex'
	% cortex
	ix = find( B(:)==2 | B(:)==3);
	if ~exist('Radius','var'), Radius = [2 -2];end
end

% Analyze image dimension & voxel size
Vdim  = size(B);
Vsize = avw.hdr.dime.pixdim(2:4);

% Transform index to Analyze voxel coordinate (= 3D index)
[x,y,z] = ind2sub(Vdim,ix);
% Analyze mm-coordinate
V = vb_analyze_to_analyze_mm([x,y,z],Vdim,Vsize);

% Central region coordinate (SPM_right_[m] coordinate)
Xcenter = mean(XYZspm{1}.xyz);

% Mask image dimension (voxel size = step [mm])
Dim = vb_mask_image_size(Vdim,Vsize,step); 

% voxel coordinate
V  = V/step;
J  = max(floor(V) , 1);
ix = sub2ind(Dim, J(:,1),J(:,2),J(:,3));

% Make mask image with voxel size = step [mm]
B = zeros(Dim);
B(ix) = 1;

% Morphology smoothing
B = vb_morphology_operation(B, Radius, step);

% Left/right center index
x0 = vb_spm_right_to_analyze_right_mm(Xcenter,Vdim,Vsize);
x0 = round(x0(1)/step);

switch LR
case	'left'
	B((x0+1):end,:,:) = 0;
case	'right'
	B(1:x0-1,:,:) = 0;
end

avw.img = B;
avw.hdr.dime.dim(2:4)    = Dim(:)';
avw.hdr.dime.pixdim(2:4) = [step step step];

return

