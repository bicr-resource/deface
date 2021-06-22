function   [avw] = change_orient_ras(avw,orient)
% change_orientation
%   [avw] = change_orient_ras(avw,orient)
% --- Input
% avw : NIFTI/Analyze data structure
% orient : axis dim to get RAS coordinate
%        - necessary for Analyze
%        - unnecessary for NIFTI
% --- orient
% orient : axis dim to get RAS coordinate
%        = [orient_x  orient_y  orient_z]
% orient_x : Left to Right axis dim of current image
% orient_y : Posterior to Anterior axis dim of current image
% orient_z : Inferior  to Superior  axis dim of current image
%            current image axis dim is [+-1/+-2/+-3] for [+-x/+-y/+-z]
% --- sform transform
% i = 0 .. dim[1]-1
% j = 0 .. dim[2]-1
% k = 0 .. dim[3]-1
% x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
% y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
% z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
% --- matrix form
% [x ; y ; z] = R * [i ; j ; k] + T
%
%  Part of this file is copied and modified under GNU license from
%  NIFTI TOOLBOX developed by Jimmy Shen
%
% Made by Masa-aki Sato 2008-02-17


hdr = avw.hdr;

if isfield(avw,'filetype') & avw.filetype > 0
	%  NIFTI data format
	ftype = 1;
else
	%  Analyze data format
	ftype = 0;
end

if exist('orient','var')
	R = get_rot_from_orient(orient);

	if ftype == 0
		%  Analyze data format
		T = hdr.hist.originator(1:3);
		T = abs( R * T(:) );
	else
		error('No orient is necessary for NIFTI file ')
	end
elseif ftype == 1
	%  NIFTI data format
	% orient : axis dim to get RAS coordinate
	[orient, R0, T] = get_orient_info(avw);
	% rotation matrix from orient 
	R = get_rot_from_orient(orient);
else
	error('Orient is necessary for Analyze file ')
end

% --- change axis of image to RAS according to orient
img = permute(avw.img, abs(orient));

% orient = [3 1 2]
% img(j3,j1,j2) = img(j1,j2,j3)

dim = size(img);

% --- flip image according to orient
if orient(1) < 0
	img(1:dim(1),:,:) = img(dim(1):-1:1,:,:);
end
if orient(2) < 0
	img(:,1:dim(2),:) = img(:,dim(2):-1:1,:);
end
if orient(3) < 0
	img(:,:,1:dim(3)) = img(:,:,dim(3):-1:1);
end

% image with RAS orientation
avw.img = img;

% --- transform voxcel size 
vsize = hdr.dime.pixdim(2:4); % pixdim of original image
vsize = abs(R * vsize(:));    % pixdim of transformed RAS image

avw.hdr.dime.dim(2:4)    = dim;
avw.hdr.dime.pixdim(2:4) = vsize';

avw.hdr.hist.sform_code  = 1;

% --- No translation of origine
% --- sform transform
% i = 0 .. dim[1]-1
% j = 0 .. dim[2]-1
% k = 0 .. dim[3]-1
% x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
% y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
% z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]

avw.hdr.hist.srow_x = [1 0 0 0]*vsize(1);
avw.hdr.hist.srow_y = [0 1 0 0]*vsize(2);
avw.hdr.hist.srow_z = [0 0 1 0]*vsize(3);

% origine = image center
% 0 = srow_x[0] * dim(1)/2 + srow_x[3]
avw.hdr.hist.srow_x(4) = - avw.hdr.hist.srow_x(1) * dim(1)/2;
avw.hdr.hist.srow_y(4) = - avw.hdr.hist.srow_y(2) * dim(2)/2;
avw.hdr.hist.srow_z(4) = - avw.hdr.hist.srow_z(3) * dim(3)/2;

avw.hdr.hist.originator(1:3) = 0;


avw.hdr.hist.qform_code  = 0;

avw.hdr.hist.quatern_b   = 0;
avw.hdr.hist.quatern_c   = 0;
avw.hdr.hist.quatern_d   = 0;
avw.hdr.hist.qoffset_x   = 0;
avw.hdr.hist.qoffset_y   = 0;
avw.hdr.hist.qoffset_z   = 0;

return

%avw.
%avw.
%avw.

% DIM     = avw.hdr.dime.dim(2:4)           % 画像サイズ
% VOX     = avw.hdr.dime.pixdim(2:4)        % voxelサイズ
% 
% origin in voxcel-space -> origin in MNI-mm space
%origin = vox(:) .* origin(:);
%
%Trans  = [vox(1) 0 0 -origin(1) ; ...
%          0 vox(2) 0 -origin(2) ; ...
%          0 0 vox(3) -origin(3) ; ...
%          0 0      0    1     ];

return
