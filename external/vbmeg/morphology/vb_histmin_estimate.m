function	[ix_min, ix_max, z] = vb_histmin_estimate(y,N)
% smoothing histgram and find first local minimum
%   [ix_min, ix_max, z] = vb_histmin_estimate(y)
%   [ix_min, ix_max, z] = vb_histmin_estimate(y,N)
% y ; histgram
% N : smoothing width [ = 5 ]
% z : smoothing histgram
% ix_min : first local minimum point
% ix_max : max point in ix > ix_min
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% N : smoothing width
if nargin==1, N = 5; end;

% Gaussian smoothing filter
t = (1:N)/N;
b = [fliplr(exp(-3*t.^2)), 1, exp(-3*t.^2)];
b = b/sum(b);

% plot(b); return

% Gaussian smoothing of histgram
a = 1;
z = filter(b,a, [y zeros(1,N)]);

z = z(N+1:end);

% local minimum point of smoothing histgram
ix = find( z(1:end-2) >= z(2:end-1) ...
	     & z(2:end-1) <= z(3:end));

% first local minimum point
ix_min = ix(1);

% max point in ix > ix_min
[zmax, ix_max] = max(z(ix_min:end));
ix_max = ix_max(1) + ix_min - 1;
