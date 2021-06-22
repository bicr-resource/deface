function [Ncor,r,U,S] = vb_ellipsoid_check(xyz, Vol, R)
%
%INPUTS:
%  xyz:  an N*3 array of N points contained in cluster
% Vol : Volume of ellipsoid
%
%OUTPUTS:
%  U: eigenvector (principal direction)
%  r :radius of principal axis for Vol
% Ncor : Number of points inside the ellipsoid
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

N   = size(xyz,1);
X0  = sum(xyz)/N;
xyz = xyz - repmat(X0, [N 1]);

% covariance matrix
XX  = xyz'*xyz;

% eigenvector of covariance matrix
[U, S] = eig(XX);

% eigenvalue of covariance matrix
S = sqrt(diag(S));

if exist('R','var'),
	R = sort(R);
	[S, ix] = sort(S);
	U = U(:,ix);
	S = R;
end;


% Vol = (4*pi/3)*R^3 = (4*pi/3)*r(1)*r(2)*r(3)
R3 = Vol*(3/pi*4);

% radius of principal axis for Vol
r = S*(R3/prod(S))^(1/3);

% transform to principal coordinate
y = xyz*U;

% normalized radius
dd = (y(:,1)/r(1)).^2 + (y(:,2)/r(2)).^2 + (y(:,3)/r(3)).^2 ;

% find inside of ellipsoid
ix = find( dd <= 1 );

% Number of points inside the ellipsoid
Ncor = length(ix);


