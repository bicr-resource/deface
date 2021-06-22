function	[xyz, Z] = vb_make_upsample_vertex(XYZ, Z, upmode)
% Make upsample coordinate to 1mm from vertex in 2mm voxel size
%  [xyz, Z] = vb_make_upsample_vertex(XYZ, Z)
% XYZ  : vertex coordinate of mask point [Npoint x 3]
%  Z   : mask value for XYZ
% xyz  : upsample coordinate of mask point [Npoint*8 x 3]
%
% 2007/06/09 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

x = XYZ(:,1); 
y = XYZ(:,2); 
z = XYZ(:,3);

if exist('upmode','var') & upmode == 1,
	xp = x - sign(x); 
	yp = y - sign(y); 
	zp = z - sign(z);
else
	xp = x + 1; 
	yp = y + 1; 
	zp = z + 1;
end

xyz = [...
   x,  y, z; ...
   xp, y, z; ...
   x, yp, z; ...
   xp,yp, z; ...
   x,  y,zp; ...
   xp, y,zp; ...
   x, yp,zp; ...
   xp,yp,zp];

if nargout == 1, return; end

if exist('Z','var'), 
	Z = repmat(Z, [8 1]); 
else
	Z = [];
end;

