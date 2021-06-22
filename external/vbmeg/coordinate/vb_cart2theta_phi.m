function	[ xa ,ya ,phi, theta ] = vb_cart2theta_phi(x , mode)
% Project 3D coordinate to 2D-plane with modified projection
%   [ xa ,ya ] = vb_cart2theta_phi(x , mode)
% --- Input
%  X : 3D cartesian coordinate (N x 3)
% mode = 'x', '-x' : project y-z plane
%      = 'y', '-y' : project z-x plane
%      = 'z', '-z' : project x-y plane
% --- Output
% [ xa ,ya ] : transformed 2D coordinate
%
% Ver 1.0 written by M. Sato  2003-3-15
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

switch	mode,
case	'z',
	[phi,theta,r] = cart2sph(x(:,1),x(:,2),x(:,3));
case	'x',
	[phi,theta,r] = cart2sph(x(:,2),x(:,3),x(:,1));
case	'y',
	[phi,theta,r] = cart2sph(x(:,3),x(:,1),x(:,2));
case	'-z',
	[phi,theta,r] = cart2sph(x(:,1),x(:,2),-x(:,3));
case	'-x',
	[phi,theta,r] = cart2sph(x(:,2),x(:,3),-x(:,1));
case	'-y',
	[phi,theta,r] = cart2sph(x(:,3),x(:,1),-x(:,2));
end;

%rho = 0.5*pi-theta;
rho = 2 * sin((0.5*pi-theta)/2);

[xa,ya] = pol2cart(phi,rho);
