function	[xc ,r] = vb_center_sphere(x)
% Find Center of Sphere from set of points 'X'
%  [xc ,r] = vb_center_sphere(x)
% --- Input
% x  : N data points in D-dim space (N,D)
% --- Output
% xc : Center of Sphere to fit the data
% r  : Radius of Sphere to fit the data
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

N	= size(x,1);
xm	= sum(x,1)/N;			% <x>
x	= x - xm(ones(N,1),:);	% X  = x - <x>
xx	= sum(x.^2,2);			% R^2 for x(n)
rr	= sum(xx)/N;			% <R^2>
drr	= xx - rr;				% dRR = R^2 - <R^2>

C	= (x'* x)/N;			% <X*X'>
B	= (x'* drr)/N;			% <dRR*X>

xc	= 0.5*(C \ B)';			% = inv(<X*X'>) * <dRR*X>
r   = sqrt(sum(sum( (x - xc(ones(N,1),:)).^2 ))/N);
xc  = xc + xm;

