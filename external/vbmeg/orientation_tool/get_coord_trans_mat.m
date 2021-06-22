function	[Trans, dim] = get_coord_trans_mat(fname)
% Get transform matrix from voxcel to RAS mm coordinate
%  [Trans,dim] = get_coord_trans_mat(fname)
% Trans : transform matrix from voxcel to RAS mm coordinate
%   [x  y  z  1] = [i  j  k  1] * Trans
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[hdr, filetype] = load_nii_hdr(fname);

nii.hdr = hdr;
nii.filetype = filetype;

% get rotation and translation
[orient, R, T] = get_orient_info(nii);
%   [x ; y ; z] = R * [i ; j ; k] + T
%   [x  y  z] =  [i  j  k] * R' + T'
%   [x  y  z  1] = [i  j  k  1] * Trans

Trans = [R' zeros(3,1); T' 1];
dim = hdr.dime.dim(2:4);

