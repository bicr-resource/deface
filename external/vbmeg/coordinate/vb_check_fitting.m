function	[dmin, Vmap] = vb_check_fitting(facefile, V, trans_mat)
%   Check fitting 
%   [dmin, Vmap] = vb_check_fitting(facefile, V, trans_mat)
% ---- Input 
% facefile   : MRI face-file          (*.face.mat)
% V          = Head points by digitizer
% trans_mat  = transformation matrix
%
% ---- Output
% dmin   = distance between head points and face
% Vmap   = posision of head points mapped onto face surface
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Minimun distance search radius
Rmax   = 0.003; 

%
% --- Load MRI face data
%
load(facefile ,'surf_face');

%
% ---- Check fitting ----
%

% fitting distance
V = vb_affine_trans( V, trans_mat);

[ix ,dmin] = vb_find_nearest_point(surf_face.V, V, Rmax);

dmin  = dmin*1000;
Vmap  = surf_face.V(ix,:);
Nall  = length(dmin);
dmean = sum(dmin)/Nall;

fprintf('Mean distance for %d points = %f [mm]\n',Nall, dmean)

return
%
% ---- END ----
%
