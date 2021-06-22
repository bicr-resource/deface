function    [Xspm] = vb_nifti_mm_to_spm_right_mm(Xnft, fname)
% Transform NIFTI mm coordinate to SPM-Right-m coordinate
%   [Xspm] = vb_nifti_mm_to_spm_right_mm(Xnft, fname)
% Xnft  ; NIFTI [mm] coordinate (Npoint x 3)
% fname : file name of T1 image file
% Xspm  : SPM-Right [m] coordinate 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[hdr, filetype] = load_nii_hdr(fname);

%  --- File type check field
%  nii.filetype =
%     0 : Analyze .hdr/.img , (.hdr : 348 byte)
%     1 : NIFTI   .hdr/.img , (.hdr : 348 byte)
%     2 : NIFTI   .nii      , (.nii : 348 byte hdr + image data)

if filetype == 0
    % Analyze format
    Xspm = Xnft;
    return
end

[Trans , dim] = get_coord_trans_mat(fname);

% Trans : transform matrix from voxcel to mm coordinate defined by NIFTI
%   [x  y  z  1] = [i  j  k  1] * Trans
% Xnft = Vox  * Trans
% Vox  = Xnft * inv(Trans)

% Image center in NIFTI coordinate
center = vb_affine_trans(dim/2 , Trans);

% Vox  = dim/2 <-> Xnft = center
% Xspm = 0     <-> Xnft = center
% Xspm = Xnft - center 
% Xnft = Xspm + center

% Get SPM-Right-mm coordinate
Xspm = vb_repadd(Xnft , -center);

return

% Get NIFTI mm coordinate from SPM-Right-m
% Xnft = vb_repadd(Xspm * 1000 , center) ;
