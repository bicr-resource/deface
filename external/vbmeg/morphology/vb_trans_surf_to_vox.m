function	[Vox, Para] = vb_trans_surf_to_vox(V, analyze_file, step)
% Transform 3D surface coordinate to Analyze_right [mm] to make mask image
%   [Vox, Para] = vb_trans_surf_to_vox(V, analyze_file, step)
% ---Input
% V    : 3D surface coordinate : Spm_right [m]
% analyze_file : analyze file corresponding to surface coordinate 'V'
% step  =  Voxel size of mask image [mm]
% --- Output
% Vox    : Analyze_right [mm] coordinate 
%
% Para.Vdim   =  Voxel dimension of Analyze image
% Para.Vsize  =  Voxel size of Analyze image [mm]
% Para.vstep  =  Voxel size of mask image [mm] = step
% Para.Dim    =  Dimension of mask image
%
% Made by M. Sato 2004-3-28
% Made by M. Sato 2007-3-16 (New ver)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%
%----- 座標変換: Spm_right [m] -> Analyze_right [mm]
%
[Vdim, Vsize] = analyze_hdr_read(analyze_file);

Para.vstep  = step;
Para.Vdim   = Vdim ; %  Voxel dimension of Analyze image
Para.Vsize  = Vsize; %  Voxel size of Analyze image [mm]
Para.Dim    = vb_mask_image_size(Vdim,Vsize,step);

Vox = vb_spm_right_to_analyze_right_mm(V, Vdim, Vsize);
