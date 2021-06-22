function  [Dim, Vorigin] = vb_mask_image_size(Vdim,Vsize,step)
% Calculate mask image size for subsampling step size
%  Dim = vb_mask_image_size(Vdim,Vsize,step)
%  [Dim, Vorigin] = vb_mask_image_size(Vdim,Vsize,step)
% --- Input
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image in [mm]
% step  : step size for image voxel in [mm]
% --- Output
% Dim : mask image size when voxel size is step [mm]
% Vorigin : Origin of Analyze Right [mm] coord. in SPM [mm] coord.
% --- Analyze mm coordinate   
%
% [Right-hand coordinate]
% X: Left(1)   -> Right(191) 
% Y: Back(1)   -> Front(256)
% Z: Bottom(1) -> Top(256) 
%
% --- SPM coordinate   
%
% [Right-hand coordinate]
% X: Left(-191/2)   -> Right(191/2) 
% Y: Back(-256/2)   -> Front(256/2)
% Z: Bottom(-256/2) -> Top(256/2) 
%
% written by M. Sato  2007-3-14
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('step','var'), step = 1; end;

Vorigin = - 0.5 * Vdim .* Vsize;
Dim = ceil((Vdim .* Vsize)/step);
