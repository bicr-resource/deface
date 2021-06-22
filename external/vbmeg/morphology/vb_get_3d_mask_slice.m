function [B2,Xindx, Yindx] = vb_get_3d_mask_slice(B,indx,cut_dim,Vdim)
% Get single slice of 3D mask image
%---
%  [B2,Xindx, Yindx] = vb_get_3d_mask_slice(B,indx,cut_dim,Vdim)
%
% --- Input
% B : 3D mask image [NBx, NBy, NBz]. 
%   Axis is the same as Analyze_right voxel coordinate except scale
% indx : slice index in cut_dim-axis 
%        specified by Analyze_right voxel coordinate
% cut_dim : slice cut direction
%      = 'x' : Sagittal cut : Y-Z plane
%      = 'y' : Coronal cut  : X-Z plane
%      = 'z' : Transverse (Axial) cut : X-Y plane
% --- Optional input
% Vdim  = [Xmax Ymax Zmax] : 3D image size of analyze_right image
% --- Output
% B2    : 2D-image matrix
% Xindx : X coordinate value
% Yindx : Y coordinate value
%
% written by M. Sato  2005-8-1
% Modified by M Sato  2007-3-16
%---
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 3, error('Input argument error'); end;

[NBx,NBy,NBz] = size(B);

if ~exist('Vdim', 'var'), Vdim = [NBx,NBy,NBz]; end;
if length(Vdim) ~= 3, error('Image size must be 3dim'); end;

XYZ  = Vdim(:)' ./ [NBx,NBy,NBz];

xdim = [1:NBx] - 0.5;
ydim = [1:NBy] - 0.5;
zdim = [1:NBz] - 0.5;

xdim = xdim*XYZ(1);
ydim = ydim*XYZ(2);
zdim = zdim*XYZ(3);

% Analyze-slice-cut direction
switch	cut_dim,
case	'x',
	% 'SAG' : Sagittal cut : Y-Z plane
	indx = round(indx/XYZ(1));
	B2   = reshape(B(indx,:,:),NBy,NBz);
	Xindx = ydim;
	Yindx = zdim;
case	'y',
	% 'COR' : Coronal cut : X-Z plane
	indx = round(indx/XYZ(2));
	B2   = reshape(B(:,indx,:),NBx,NBz);
	Xindx = xdim;
	Yindx = zdim;
case	'z',
	% 'TRN' : Transverse (Axial) cut : X-Y plane
	indx = round(indx/XYZ(3));
	B2   = B(:,:,indx);
	Xindx = xdim;
	Yindx = ydim;
end;

% Reduction of dimension of voxel matrix
B2 = squeeze(B2); 

