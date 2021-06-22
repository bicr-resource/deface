function [F, V] = vb_face_extract(imagefile, Radius, step, pmax, Bval, hstep)
% Extract face surface from MRI image
%  [F, V] = vb_face_extract(imagefile, Radius, step)
%  [F, V] = vb_face_extract(imagefile, Radius, step, pmax, Bval, hstep)
%
% ---- Output
%  V  : Face vertex coordinate: (x,y,z)  [Nvertex x 3]
%  F  : Triangle patch index [Npatch x 3]
% ---- Input
%  imagefile  : MRI Analyze/NIFTI image file name
%
% ----- Optional input
% Radius = [ -2 2 6 -6]; [mm]
%        : Radius of Morfology operation
%  R > 0 : dilation
%  R < 0 : erosion
%
% step  : subsampling step size [mm]
% pmax  : Prob. to detrmine Threshold value for face extraction (0.998)
% Bval  : Threshold value for background separation
%         This value is automatically determined in the default mode
% hstep : step size to round the value of image intensity
% --------------------------------------------------
% MRI構造画像から顔表面画像の抽出
%  V  : 顔表面頂点        face vertex
%  F  : その三角面パッチ  patch index
%
% Masa-aki Sato 2010-10-18
%  Image intensity is rounded by deviding 'hstep'
%  before making mask to avoid noisy fluctuation
% 2011-06-20 taku-y
%  [minor] Progress message was added. 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 2, Radius = [ -2 2 ]; end;
if nargin < 3, step = 2; end;
if nargin < 4, pmax = 0.998; end;
if nargin < 5, Bval = []; end;
if nargin < 6, hstep = 1; end;

disp('  0 % processed');

%
% Load 3D MRI image to analyze_right_hand coordinate
%
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% --- Analyze righthand voxel coordinate   
% X: Left(1)   -> Right (Vdim(1))
% Y: Back(1)   -> Front (Vdim(2))
% Z: Bottom(1) -> Top   (Vdim(3)) 
[B, Vdim, Vsize] = vb_load_analyze_to_right(imagefile);

disp(' 10 % processed');

% Calculate background noise threshold value
% by estimating backgound distribution
if isempty(Bval)
	[Bval, hstep] = vb_back_threshold(B, pmax);
end

disp(' 20 % processed');

B    = round(B/hstep);
Bval = round(Bval/hstep);

% 閾値より大きい値を持つボクセルを頭部として抽出
% Make mask image from MRI data
Bmask = vb_image_to_mask(B, Bval, step);

if vb_matlab_version > 6, Bmask = int8(Bmask); end;

% Expand Z-axis to avoid top head reaches to image boundary
Zex = ceil(10/step); % 10 mm
[Nx,Ny,Nz]=size(Bmask);

% vb_disp_nonl(sprintf('\nExpand image'));

if vb_matlab_version > 6,
	B = zeros(Nx,Ny,Nz + Zex, 'int8');
	B(1:Nx,1:Ny,1:Nz) = Bmask;
else
	B = zeros(Nx,Ny,Nz + Zex);
	B(1:Nx,1:Ny,1:Nz) = Bmask;
end

disp(' 40 % processed');

% Apply morphology operations
% Dilation/erosion are done consecutively according to Radius
B = vb_morphology_operation(B, Radius, step);

disp(' 80 % processed');

% face extraction
%  V  : 顔表面頂点        face vertex
%  F  : その三角面パッチ  patch index

[F, V]  = vb_surf_extract(B, step);

disp(' 95 % processed');

% Change Analyze Left-hand voxcel coordinate to Right-hand SPM (m) coord.
%   Transformation from Analyze to SPM is not changed 
%   despite of mask image expansion along Z-axis
%   since SPM is defined in original image
V = vb_analyze_right_to_spm_right(V,Vdim,Vsize);

