function	[Vmni, origin] = vb_spm_right_to_mni_mm(Vspm, fname)
% Transform SPM-Right-m coordinate to MNI mm coordinate 
%   [Vmni, origin] = vb_spm_right_to_mni_mm(Vspm, fname)
% Vmni  ; MNI [mm] coordinate (Npoint x 3)
% fname : file name (MNI_152) of T1 image file
% Vspm  : SPM-Right [m] coordinate 
% origin: origin of MNI cordinate in SPM-Right [m] coordinate 
% Vspm  = Vmni + origin;  (Vmni = 0 at origin)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[Trans , dim] = get_coord_trans_mat(fname);

% Trans : transform matrix from voxcel to MNI mm coordinate
%   [x  y  z  1] = [i  j  k  1] * Trans
% Xmni = Vox  * Trans
% Vox  = Xmni * inv(Trans)

% Center position of 3D image in MNI mm
center = vb_affine_trans(dim/2 , Trans);

% Xspm = 0       <-> Xmni = center
% Xspm = -center <-> Xmni = 0
% Xspm = Xmni - center 
% Xmni = Xspm + center

% Get MNI mm coordinate
Vmni = vb_repadd(Vspm * 1000 , center) ;

% origin of MNI cordinate in SPM-Right coordinate 
%origin = -center ;
origin = -center * 0.001;
