function Xout = vb_rigid_transform(X, para)
% Apply rigid body transformation to 'X'
%   Xout = vb_rigid_transform(X, para)
% --- Input
% X    : 3D-coordinate to be transformed (Nx3 vector)
% para : [ dX ; th ] rigid body transformation parameter (6x1 vector)
%   dX : Translation parameter of 3 directions        (3x1 vector)
%   th : Rotation angle around x, y, z axis [radian]  (3x1 vector) 
% --- Output
% Xout     : transformed coordinate   (Nx3 vector)
%
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

dX = para(1:3);
th = para(4:6);

Rot_x = [1 0 0 ;...
         0  cos(th(1)) -sin(th(1));...
         0  sin(th(1))  cos(th(1));...
         ];
        
Rot_y = [ cos(th(2)) 0 -sin(th(2));...
          0 1 0 ;...
          sin(th(2)) 0  cos(th(2));...
         ];
        
Rot_z = [ cos(th(3)) -sin(th(3)) 0;...
          sin(th(3))  cos(th(3)) 0;...
          0 0 1 ;...
         ];
                    
% Rotation matrix
Rot  = Rot_z * Rot_y * Rot_x;

% Rotation
Xout =  X * Rot;

% Translation
Xout(:,1) = Xout(:,1) + dX(1);
Xout(:,2) = Xout(:,2) + dX(2);
Xout(:,3) = Xout(:,3) + dX(3);

