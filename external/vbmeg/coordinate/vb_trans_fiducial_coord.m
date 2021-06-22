function	[trans_mat, marker_trans] = vb_trans_fiducial_coord(marker)
% Transform matrix to fiducial coordinate
%
% Usage:
%  trans_mat = vb_trans_fiducial_coord(marker)
%  [trans_mat, marker_trans] = vb_trans_fiducial_coord(marker)
% --- Input
% Fiducial coordinate
% marker(1,:): Left ear 
% marker(2,:): Nose     
% marker(3,:): Right ear
%
% --- Output
% trans_mat = Rigid Body Transformation matrix  (4 x 3)
% marker_trans : transformed fiducial coordinate
% 
% X_trans = vb_affine_trans(X, trans_mat)
%
% Origin: perpendicular to Left->Right ear line from Nose 
% X-axis: Origin -> Nose
% Y-axis: Right->Left ear line
% Z-axis: Origin -> Up
%
% Coordinate Transform by trans_mat
% x_trans = ( x - org_marker ) * rot
%         = x*rot - org_marker*rot
%         = [x, 1] * trans_mat
% trans_mat = [rot ; - org_marker*rot]        (4 x 3)
%
% 2008-07-25 made by M. Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Left = 1;
Nose = 2;
Right= 3;

% Origin: perpendicular to Left->Right ear line from Nose 
% X-axis: Origin -> Nose
% Y-axis: Right->Left ear line
% Z-axis: Origin -> Up

% Approximate Origin : center of left-right
co  = (marker(Left,:) + marker(Right,:))/2; 

% Y-axis: Right->Left ear line
ey  = marker(Left,:)-marker(Right,:); 
ey  = ey/sqrt(sum(ey.^2));

% Approximate X-axis: center -> Nose
ex0 = marker(Nose,:) - co; 

% Z-axis: Origin -> Up
% orthogonal to ex0 & ey
ez  = cross(ex0 , ey); 
ez  = ez/sqrt(sum(ez.^2));

% X-axis: Origin -> Nose
% orthogonal to ey & ez
ex  = cross(ey,ez); 
ex  = ex/sqrt(sum(ex.^2));

% Rotation matrix
rot = [ex(:) ey(:) ez(:)]; 

% Origin : perpendicular to Left->Right ear line from Nose 
org_marker = sum(ex0.*ey)*ey + co; 

trans_mat = [rot ; - org_marker * rot];

marker_trans = [marker ones(3,1)]*trans_mat;
