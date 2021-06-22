function	dmin = vb_calc_fitting(para, V0, Vref, parm)
% Calculate min distance for transformed points
%
%   dmin = vb_calc_fitting(para, V0, Vref, parm)
% --- Input
% para : [ dX ; th ] rigid body transformation parameter (6x1 vector)
%   dX : Translation parameter of 3 directions        (3x1 vector)
%   th : Rotation angle around x, y, z axis [radian]  (3x1 vector) 
% V0   : transformed point set 
% Vref : reference points
% parm : parameters
%     .Rmax = first search radius
%     .Npos = # of head points
%     .pos_rate = distance weight for head points vs face points
% --- Output
% dmin = Min distance from rigid-transformed 'V0' to reference point set 'Vref'
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V0,1);
Npos   = parm.Npos;

if  Npos == 0 | Npos == Npoint
	dmin = vb_distance_min3d( Vref, vb_rigid_transform(V0, para) , parm.Rmax );
else
	dmin1 = vb_distance_min3d( Vref, ...
	           vb_rigid_transform(V0(1:Npos,:), para) , parm.Rmax );
	dmin2 = vb_distance_min3d( Vref, ...
	           vb_rigid_transform(V0(Npos+1:end,:), para) , parm.Rmax );
	           
	dmin = parm.pos_rate * dmin1 + parm.scan_rate * dmin2;
end

pause(1/1000); % pause(sec): The chance to cancel is given to MATLAB. 
