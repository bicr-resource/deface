function	[B, Vdim, Vsize, Trans] = vb_load_analyze_to_right(fname)
% Load Analyze/Nifti file to RAS image
%  [B, Vdim, Vsize] = vb_load_analyze_to_right(fname)
% --- Input
% fname - Analyze/Nifti filename 
%         Default Analyze file is left-handed  LAS image
%         Default Nifti   file is Right-handed RAS image
% --- Output
% B     : 3D image data  [Xdim, Ydim, Zdim ]
% Vdim  : image size  [Xdim  Ydim  Zdim ] (voxels)
% Vsize : voxel size  [x y z ] (mm)
% Trans : transform matrix from voxcel to Right-hand mm coordinate
%   [x  y  z  1] = [i  j  k  1] * Trans
%
%
% written by M. Sato  2008-2-18
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% load analyze/nifti image file to RAS orientation
avw = load_nii_ras(fname);

B = avw.img;

Vdim  = size(B);
Vsize = avw.hdr.dime.pixdim(2:4);

if nargout<4, return; end;

[orient, R, T] = get_orient_info(avw);
Trans = [R' zeros(3,1); T' 1];
%   [x ; y ; z]  = R * [i ; j ; k] + T
%   [x  y  z  1] = [i  j  k  1] * Trans

return

