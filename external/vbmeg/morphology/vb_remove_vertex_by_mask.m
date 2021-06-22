function  indx = vb_remove_vertex_by_mask(V,B,step);
% remove mask region from vertex 'V'
%  indx = vb_remove_vertex_by_mask(V,B,step)
% --- Input
% V    : 3D surface coordinate in [mm]
% B    : 3D mask image
% step : voxcel size of mask image in [mm]
% --- Output
%  indx : selected index of V after removing masked region
%
% Made by M. Sato 2004-3-28
% Made by M. Sato 2007-3-16
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% change coordinate to index
%     V = [-1/2,-1/2,-1/2] - [1/2,1/2,1/2]
% <=> J = [1,1,1]

%J  = floor(V) + 1;
J  = floor(V/step + 0.5) + 1;

% change 3D-subscript to 1D-index
[NX,NY,NZ] = size(B);
NXY = NX*NY;

ix = J(:,1)+ NX*(J(:,2) - 1)+ NXY*(J(:,3) - 1);

indx = find( B(ix) == 0 );

