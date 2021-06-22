function	[Vspm, origin] = vb_mni_mm_to_spm_right(Vmni, fname)
% Transform MNI coordinate to SPM-Right coordinate 
%   [Vspm, origin] = vb_mni_mm_to_spm_right(Vmni, fname)
% Vmni  ; MNI [mm] coordinate (Npoint x 3)
% fname : file name (MNI_152) of T1 image file
% Vspm  : SPM-Right [m] coordinate 
% origin: origin of MNI cordinate in SPM-Right [m] coordinate 
% Vspm  = Vmni + origin;  (Vmni = 0 at origin)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[Trans , dim] = get_coord_trans_mat(fname);

% Trans : transform matrix from voxcel to RAS mm coordinate
%   [x  y  z  1] = [i  j  k  1] * Trans
% Xstd = Vox  * Trans
% Vox  = Xstd * inv(Trans)

% Center position of 3D image 
center = vb_affine_trans(dim/2 , Trans);

% Get SPM-Right coordinate (center = 0 & mm -> m)
Vspm = vb_repadd(Vmni, -center) * 0.001;

% origin of MNI cordinate in SPM-Right coordinate 
origin = -center * 0.001;
