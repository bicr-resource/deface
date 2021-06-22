function [avw ,Xcenter] = vb_get_cortex_mask(fname,fana,LR,step,val,R)
% Get brain/cortex mask image from subject brain mask file
%  [avw ,Xcenter] = vb_get_cortex_mask(fname,fana,LR,step,val,R)
% --- Input
% fname = brain mask file
% fana  = analyze file
% --- Optional input
% LR = 'left' , 'right'
%    if empty or not given, both hemisphere are included [Defoult]
% step : voxel size of mask image = 1  [mm]
% val  : threshold value for gray & white matter
% R    : Morphology R = [2 -2] [mm]
% --- Output
% avw.img  : 3D mask image (voxel size = step [mm])
% avw.hdr.dime.dim(2:4)    : mask image dimension
% avw.hdr.dime.pixdim(2:4) : voxel size [mm] = [step step step]
% 
% Xcenter : Center of cortex to separate left/right (SPM_right_[m])
%
% 2007/06/15 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%% Label value
%  1 = brain (CSF)
%  2 = Gray
%  3 = White
%  4 = Cerebellum
%  5 = Brainstem

if ~exist('LR','var'), LR = ''; end;
if ~exist('val','var'), val = 90; end;
if ~exist('step','var'), step = 1; end;
if ~exist('R','var'), R = [2 2 -2];end

load(fname, 'avw', 'XYZspm');

B = avw.img;

% Index for gray/white region
ix = find( B(:)==2 | B(:)==3);

% Make mask for brain/cortex
Vdim  = size(B);
B = zeros(Vdim);
B(ix) = 1;

% Morphology smoothing
B = vb_morphology_operation(B, R);

% Background voxel index
ix = find( B(:) == 0 );

% Load subject MRI image
[B, Vdim, Vsize] = vb_load_analyze_to_right(fana);

% Remove background
B(ix) = 0;

% voxel larger than threshold
ix = find( B(:) >= val );

% Transform index to Analyze voxel coordinate (= 3D index)
[x,y,z] = ind2sub(Vdim,ix);
% Analyze mm-coordinate
V = vb_analyze_to_analyze_mm([x,y,z],Vdim,Vsize);

% Central region coordinate (SPM_right_[m] coordinate)
Xcenter = mean(XYZspm{1}.xyz);

% Mask image dimension (voxel size = step [mm])
Dim = vb_mask_image_size(Vdim,Vsize,step); 

% Transform  to voxel coordinate in mask image
V  = V/step;
J  = max(floor(V) , 1);
ix = sub2ind(Dim, J(:,1),J(:,2),J(:,3));

% Make mask image with voxel size = step [mm]
B = zeros(Dim);
B(ix) = 1;

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

