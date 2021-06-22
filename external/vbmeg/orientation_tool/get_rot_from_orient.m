function R = get_rot_from_orient(orient)
% get rotation matrix from orientation index vector
% R = get_rot_from_orient(orient)
% --- orient
% orient : axis dim to get RAS coordinate
%        = [orient_x  orient_y  orient_z]
% orient_x : Left to Right axis dim of current image
% orient_y : Posterior to Anterior axis dim of current image
% orient_z : Inferior  to Superior  axis dim of current image
%            current image axis dim is [+-1/+-2/+-3] for [+-x/+-y/+-z]
% 
% Left to Right           1
% Posterior to Anterior   2
% Inferior to Superior    3
% Right to Left          -1
% Anterior to Posterior  -2
% Superior to Inferior   -3
%
%  Part of this file is copied and modified under GNU license from
%  NIFTI TOOLBOX developed by Jimmy Shen
%
% Made by Masa-aki Sato 2008-02-17

% --- sform transform
% i = 0 .. dim[1]-1
% j = 0 .. dim[2]-1
% k = 0 .. dim[3]-1
% x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
% y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
% z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
% --- matrix form
% [x ; y ; z] = R * [i ; j ; k] + T

R = zeros(3,3);

for i = 1:3
   ix = abs(orient(i));
   R(i,ix) = sign(orient(i));
end

return;
