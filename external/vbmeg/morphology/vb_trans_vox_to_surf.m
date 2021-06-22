function	V = vb_trans_vox_to_surf(Vox, Vorgin)
% transform [mm] coordinate to 3D surface coordinate in [m]
%   V = vb_trans_vox_to_surf(Vox, Vorgin)
% ---Input
% Vox    : voxel coordinate in [mm]
% Vorgin : Origin of voxel coordinate
% --- Output
% V      : 3D surface coordinate in [m]
%
% Vox = V*1000 - Vorgin
%  V  = (Vox + Vorgin)*0.001;
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

V = [Vox(:,1)+Vorgin(1), Vox(:,2)+Vorgin(2), Vox(:,3)+Vorgin(3)];
V = V * 0.001;
