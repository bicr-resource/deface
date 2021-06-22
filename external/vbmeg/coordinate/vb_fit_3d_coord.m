function	[trans_mat, marker_mri] = vb_fit_3d_coord(marker, mri)
% Transform Marker coordinate to MRI coordinate
%
% Usage:
% trans_mat = trans_head(marker, mri)
%
% --- Input
% Reference points in Marker cordinate
%
% marker(1,:): Left ear
% marker(2,:): Nose
% marker(3,:): Right ear
%
% Reference points in MRI cordinate
% mri(1,:): Left ear  in MRI
% mri(2,:): Nose      in MRI
% mri(3,:): Right ear in MRI
%
% --- Output
% trans_mat = Rigid Body Transformation matrix  (4 x 3)
%             from Marker coordinate to MRI coordinate
% x_mri = [x_marker 1]*trans_mat
% 
% Transform Marker coordinate to MRI coordinate
%  by Rigid Body Transformation (Rotation + Translation)
% Three point matching (usualy Left/Right ear & Nose are used)
%
% Coordinate Transform by trans_mat
% x_mri = ( x_marker - org_marker )*rot + org_mri
%       = x_marker*rot + (org_mri - org_marker*rot)
%
% trans_mat = [rot ; trans_org]        (4 x 3)
% trans_org = org_mri - org_marker*rot
%
% 2005-06-07 made by M. Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%
% XYZ-Axis of MRI cord.
%

% X-axis: mri(1) -> mri(3) : Left->Right ear line
ex  = mri(3,:)-mri(1,:); 
exx = sqrt(sum(ex.^2));
ex  = ex/exx;
% Z-axis: perpendicular to X & Y-axis
ez  = cross(ex,mri(2,:)-mri(1,:)); 
ezz = sqrt(sum(ez.^2));
ez  = ez/ezz;
% Y-axis: X axis -> mri(2) :perpendicular to X-axis & path through Nose
ey  = cross(ez,ex); 

% Unit vectors of XYZ-axis
rot_mri = [ex; ey; ez]; 

% Origin
org_mri = sum((mri(2,:)-mri(1,:)).*ex)*ex + mri(1,:); 

%
% XYZ-Axis of Marker cord.
%

% X-axis: mri(1) -> mri(3) : Left->Right ear line
ex  = marker(3,:)-marker(1,:); 
exx = sqrt(sum(ex.^2));
ex  = ex/exx;
% Z-axis: perpendicular to X & Y-axis
ez  = cross(ex,marker(2,:)-marker(1,:)); 
ezz = sqrt(sum(ez.^2));
ez  = ez/ezz;
% Y-axis: X axis -> mri(2) :perpendicular to X-axis & path through Nose
ey  = cross(ez,ex); 

% Unit vectors of XYZ-axis
rot_marker = [ex; ey; ez]; 

% Origin 
org_marker = sum((marker(2,:)-marker(1,:)).*ex)*ex + marker(1,:); 

% Rotation matrix from marker cord to MRI cord
rot = rot_marker'*rot_mri;

trans_org = org_mri - org_marker*rot;
trans_mat = [rot ; trans_org];

marker_mri = [marker ones(3,1)]*trans_mat;
