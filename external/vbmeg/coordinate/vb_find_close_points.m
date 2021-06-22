function	[yindx, ddmin] = vb_find_close_points(x,y,Nnear)
% Find close distance points in y from x
% [yindx, ddmin] = vb_find_close_points(x,y,Nnear)
% --- Input
% x : set of coordinate (N x D )
% y : set of coordinate (M x D )
% Nnear : Number of close points for each x(n,:)
% --- Output
% yindx(n,:)  : close point index in y for x(n,:) [N x Nnear]
% ddmin(n,:)  : close point distance from x(n,:)
%
%  M. Sato  2008-8-1
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Nnear','var'), Nnear=3; end;

N  = size(x,1);
M  = size(y,1);

dd    = zeros(M,1);
ddmin = zeros(N,Nnear);
yindx = zeros(N,Nnear);

for n=1:N
	dd = sum(vb_repadd(y, -x(n,:) ).^2, 2);
	[dd, ix] = sort(dd);
	
	yindx(n,:) = ix(1:Nnear)';
	ddmin(n,:) = dd(1:Nnear)';
end;

if nargout == 1, return; end;
if nargout == 2, ddmin = sqrt(ddmin); end;
