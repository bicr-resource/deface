function	[yindx, yout, ddmin] = vb_find_min_distance_2d(x,y)
% Find min distance point in y from x
% [yindx, yout, ddmin] = vb_find_min_distance_2d(x,y)
% --- Input
% x : set of 2D coordinate (N x 2)
% y : set of 2D coordinate (M x 2)
% --- Output
% yindx(n)     : min distance point index from x(n,1:2)
% yout(n,1:2)  : min distance point in y from x(n,1:2)
% ddmin(n)     : min distance from x(n,1:2)
%
%  rhayashi  2007-5-15
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

N  = size(x,1);
M  = size(y,1);

dd    = zeros(M,1);
ddmin = zeros(N,1);
yindx = zeros(N,1);

for n=1:N
    xn = x(n,:);
    dd = (y(:,1) - xn(1)).^2 ...
       + (y(:,2) - xn(2)).^2;
       
    [ddmin(n) ,yindx(n)] = min(dd);
end;

if nargout == 1, return; end;

yout = y(yindx,:);

if nargout == 3, ddmin = sqrt(ddmin); end;
