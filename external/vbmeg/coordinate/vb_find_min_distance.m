function	[yindx, yout, ddmin] = vb_find_min_distance(x,y)
% Find min distance point in y from x
% [yindx, yout, ddmin] = vb_find_min_distance(x,y)
% --- Input
% x : set of coordinate (N x D )
% y : set of coordinate (M x D )
% --- Output
% yout(n,:) : min distance point in y from x(n,:)
% yindx(n)  : min distance point index 
% ddmin(n)  : min distance from x(n,:)
%
%  M. Sato  2006-2-3
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

N  = size(x,1);
M  = size(y,1);

dd    = zeros(M,1);
ddmin = zeros(N,1);
yindx = zeros(N,1);

for n=1:N
%	xn = x(n,:);
%	dd = (y(:,1) - xn(1)).^2 ...
%	   + (y(:,2) - xn(2)).^2 ...
%	   + (y(:,3) - xn(3)).^2;
	
	dd = sum(vb_repadd(y, -x(n,:) ).^2, 2);
	[ddmin(n) ,yindx(n)] = min(dd);
end;

if nargout == 1, return; end;

yout = y(yindx,:);

if nargout == 3, ddmin = sqrt(ddmin); end;
