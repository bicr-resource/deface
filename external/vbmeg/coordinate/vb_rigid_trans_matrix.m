function trans_mat = vb_rigid_trans_matrix(para)
% Make rigid body transform matrix from 6 parameters
%  trans_mat = vb_rigid_trans_matrix(para)
% --- Input
% para : [ dX ; th ] rigid body transformation parameter (6x1 vector)
%   dX : Translation parameter of 3 directions        (3x1 vector)
%   th : Rotation angle around x, y, z axis [radian]  (3x1 vector) 
% --- Output
% trans_mat : rigid body transform matrix ( 4 x 3 )
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

% Rotation & Translation
trans_mat = [ Rot ; dX(:)' ];

