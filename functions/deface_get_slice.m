function [B2d] = deface_get_slice(B,indx,vdim,mode,XYZ)
% get slice image 
%---
%  deface_get_slice(B,indx,vdim,mode)
%  [B2d] = deface_get_slice(B,indx,vdim,mode,XYZ)
%
% --- Input
% B : 3D-image [NBx, NBy, NBz]. The coordinate system must be RAS. 
%     Note that the default of ANALYZE coordinate is LAS. 
% indx : slice index in vdim-axis
% vdim : slice cut direction
%      = 'x' : Sagittal cut : Y-Z plane
%      = 'y' : Coronal cut : X-Z plane
%      = 'z' : Transverse (Axial) cut : X-Y plane
% --- Optional input
% mode : 2D plot mode for X-Y 
%      = 0   : plot without transpose
%      = 1   : plot by transposing 2D-image matrix
% XYZ  = [Xmax Ymax Zmax] : 3D image size
% --- Output
% B2d   : 2D-image matrix with rgb color[NxMx3]
%
% written by M. Sato  2005-8-1
% Modified by M Sato  2007-3-16
% Modified by M Sato  2015-11-27 (Normalization changed)
%---
%
% Copyright (C) 2018, ATR All Rights Reserved.

if nargin < 2, indx = fix(NBx/2); end;
if nargin < 3, vdim = 'x'; end;
if nargin < 4, mode = 0; end;

indx = round(indx);

[NBx,NBy,NBz]=size(B);

if ~exist('XYZ', 'var'), XYZ = [NBx,NBy,NBz]; end;
if length(XYZ) ~= 3, error('Image size must be 3dim'); end;

xdim = [0, XYZ(1)];
ydim = [0, XYZ(2)];
zdim = [0, XYZ(3)];

% Normalization of voxel values
bmin = min(B(:));

if bmin >= 0
	B = B/max(B(:)); 
else
	% image with negative values
	B = (B - bmin)/(max(B(:)) - bmin);
end

% Analyze-slice-cut direction
switch	vdim,
case	'x',
 % 'SAG' : Sagittal cut : Y-Z plane
 B2   = reshape(B(indx,:,:),NBy,NBz);
 valX = ydim;
 valY = zdim;
 strX = 'Y';
 strY = 'Z';
 strZ = 'X';
case	'y',
 % 'COR' : Coronal cut : X-Z plane
 B2   = reshape(B(:,indx,:),NBx,NBz);
 valX = xdim;
 valY = zdim;
 strX = 'X';
 strY = 'Z';
 strZ = 'Y';
case	'z',
 % 'TRN' : Transverse (Axial) cut : X-Y plane
 B2   = B(:,:,indx);
 valX = xdim;
 valY = ydim;
 strX = 'X';
 strY = 'Y';
 strZ = 'Z';
end;

% Reduction of dimension of voxel matrix
B2 = squeeze(B2); 

if mode==0
  % Flip
  B2 = B2';
  
  % Index color -> True color
  B2d = repmat(B2,[1 1 3]);
end
