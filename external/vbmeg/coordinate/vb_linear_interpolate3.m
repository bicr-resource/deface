function	W = vb_linear_interpolate3(dd)
% Linear interpolation matrix of three neighbor point values
%  according to distance from interpolation point
%    W = vb_linear_interpolate3(dd)
% --- Input
% dd(n,1:3) : n-th distance from interpolation point to three neighbor points
% --- Output
%  W(n,1:3) : n-th interpolation coefficient
% --- Interpolation using 'W'
%  y(n,1:3) = Three data values corresponding to the distance dd(n,1:3)
%  y_interp(n) = sum( W(n,1:3) .* y(n,1:3) , 2)
%  y_interp = sum( W .* y , 2)
%
% --- Interpolation
% Linear interpolation of three channel points for one vertex
% Interpolation point is correspond to origin [0,0]
% Three data points with distance d(i) are mapped to [x,y] as
%  [x(i),y(i)] = [ex(i) , ey(i)] * d(i) , i=1:3
% Linear function in [x,y] space
%  f(x,y) = a*x + b*y + c;
%  D = [ex.*d ; ey.*d ; ones(1,3)] : transfer matrix of three points
%  f(i) = [a, b, c] * D(:,i)  , i=1:3
%  [a, b, c] = f * inv(D)
%  f(0,0) = c = f * inv(D) * [0; 0; 1]
%         = f * ( D \ [0; 0; 1])
%
%  M. Sato  2008-8-1
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NP = size(dd,1);
W  = zeros(NP,3);

% Three unit vector for three points
theta = [0, 2*pi/3, 4*pi/3];
ex = cos(theta); 
ey = sin(theta);
ez = ones(1,3);

% Linear interpolation of three channel points for one vertex
for n=1:NP
	d = dd(n,1:3);
	D = [ex.*d ; ey.*d ; ez];
	C = D \ [0; 0; 1];
	W(n,:) = C';
end
