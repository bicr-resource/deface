function [nii] = load_nii_ras(fname)
% load NIFTI file and convert image into RAS orientation
%  nii = load_nii_ras(fname)
%  fname : NIFTI file name
%
% Made by Masa-aki Sato 2008-02-17
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

nii = load_nii_cbi(fname);

if isfield(nii,'filetype') & nii.filetype > 0
	%  NIFTI data format
	nii = change_orient_ras(nii);
else
	%  Analyze data format : LAS format
	dim = size(nii.img);
	
	% --- flip image left-right
	nii.img(1:dim(1),:,:) = nii.img(dim(1):-1:1,:,:);
end

