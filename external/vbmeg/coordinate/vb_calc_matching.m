function	dmin = vb_calc_matching(para, V0, V, Weight)
% Calculate distance for transformed points
%
%   dmin = vb_calc_fitting(para, V0, V)
% --- Input
% para   : [ dX ; th ] rigid body transformation parameter (6x1 vector)
%   dX   : Translation parameter of 3 directions        (3x1 vector)
%   th   : Rotation angle around x, y, z axis [radian]  (3x1 vector) 
% V0     : transformed point set (Npoint x 3)
% V      : reference points      (Npoint x 3)
% Weight : Error weight for each point (Npoint x 1)
% --- Output
% dmin = Min distance from rigid-transformed 'V0' to reference point set 'Vref'
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

dmin = sum( sum(( vb_rigid_transform(V0, para) - V ).^2 , 2) .* Weight );
