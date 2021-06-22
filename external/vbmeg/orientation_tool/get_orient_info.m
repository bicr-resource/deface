function [orient, R, T] = get_orient_info(nii)
% Get orientation, rotation, translation info from NIFTI file
%   [orient, R, T] = get_orient_info(nii)
%  
% --- transform from voxcel to real coordinate
% R : 3 x 3 rotation matrix
% T : 3 x 1 translation matrix
%   [x ; y ; z] = R * [i ; j ; k] + T
%
% i = 0 .. dim[1]-1
% j = 0 .. dim[2]-1
% k = 0 .. dim[3]-1
%
%   orient = [aixs_dir(1) ,aixs_dir(2) ,aixs_dir(3) ]
% aixs_dir is one of following number
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

hdr = nii.hdr;

if ~isfield(nii,'filetype') | nii.filetype == 0
	% Analyze format
	% no sform/qform
	% assume LAS format : [-1 2 3]
	vsize  = hdr.dime.pixdim(2:4);
	origin = hdr.hist.originator(1:3);
	
	T = - origin.*vsize;
	T = T(:);
	R = [-vsize(1) 0 0; 0 vsize(2) 0; 0 0 vsize(3)];
	orient = [-1 2 3]; 
   return;
end

%  check sform_code or qform_code
%
if hdr.hist.sform_code > 0
	tmode = 0;
elseif hdr.hist.qform_code > 0
	tmode = 1;
else
	tmode = 0;
end

if tmode == 0,
	% --- sform transform
	% i = 0 .. dim[1]-1
	% j = 0 .. dim[2]-1
	% k = 0 .. dim[3]-1
	% x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
	% y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
	% z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
	% --- matrix form
	% [x ; y ; z] = R * [i ; j ; k] + T
	
	R = [hdr.hist.srow_x(1:3)
		 hdr.hist.srow_y(1:3)
		 hdr.hist.srow_z(1:3)];
	
	T = [hdr.hist.srow_x(4)
		 hdr.hist.srow_y(4)
		 hdr.hist.srow_z(4)];
	
else
	% --- qform transform
	b = hdr.hist.quatern_b;
	c = hdr.hist.quatern_c;
	d = hdr.hist.quatern_d;
	a = sqrt(1.0-(b*b+c*c+d*d));
	
	qfac = hdr.dime.pixdim(1);
	i = hdr.dime.pixdim(2);
	j = hdr.dime.pixdim(3);
	k = qfac * hdr.dime.pixdim(4);
	
	R = [a*a+b*b-c*c-d*d     2*b*c-2*a*d        2*b*d+2*a*c
	     2*b*c+2*a*d         a*a+c*c-b*b-d*d    2*c*d-2*a*b
	     2*b*d-2*a*c         2*c*d+2*a*b        a*a+d*d-c*c-b*b];
	
	R = R * diag([i j k]);
	
	T = [hdr.hist.qoffset_x
	     hdr.hist.qoffset_y
	     hdr.hist.qoffset_z];
end

% --- orient
orient = get_orient_from_rot(R);

return;					% orient_hdr
