function	[a, b, c, err, E, A, C] = vb_exponential_estimate(y,x,mode)
% MSE estimation of exponential function parameters [a, b, c]
%    [a, b, c, err] = vb_exponential_estimate(y,x)
%
%    y = a + b * exp( c * x )
%  
%  err = mean((y - a - b*exp( c * x )).^2)/mean(y.^2)
%
%  if mode=1 is given, a = 0 is assumed:
%    [a, b, c] = vb_exponential_estimate(y,x, mode)
%    y = b * exp( c * x ) 
%
% Masa-aki Sato 2009-12-22
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%  Niter : # of iteration for MSE optimization = 5000 [Default]

if nargin < 3, mode = 0; end;

Niter  = 5000; 
errmin = 1e-10;
ddmin  = 1e-10;

% --- MSE for ( log(y) = c*x + B ) 
[a, b, c] = exponent_init(y,x);
ex = exp(c*x);

yy = mean(y.^2);

ddmin  = ddmin * yy;
%errmin = errmin* yy;

A = zeros(Niter,1);
C = zeros(Niter,1);
E = zeros(Niter,1);

% Quasi-Newton iteration 
for n=1:Niter
	% error
	dy = (a + b*ex - y);
	
	% E(c)''
	da  = b*mean( dy.*ex.*(x.^2) );
	db  = (b^2)*mean( (ex.*x).^2 );
	ddE = da + db;
	
	if ddE < ddmin, 
		ddE = db; 
		fprintf('-')
	end;
	
	% E(c)'
	dE = b * mean( dy.*x.*ex );
	% dc = - E'/E''
	c  = c - dE/ddE;
	
	ex = exp(c*x);
	
	% y = a + b*ex
	[b,a] = slope_estimate(y,ex,mode);
	
	A(n) = a;
	C(n) = c;
	E(n) = mean((y - a - b*ex).^2)/yy;
	
	if n > 1 && abs(E(n-1) - E(n)) < errmin, 
		break; 
	end;
	
end

err = sum(abs(y - a - b*ex))/sum(abs(y));

if nargout < 5, return; end;

A = A(1:n);
C = C(1:n);
E = E(1:n);

%fprintf('\n MSE err for y = %g\n',E(end))

return

% 
% --- MSE for ( log(y) = c*x + B ) 
%     y = a + b * exp( c * x )
%
function	[a,b,c] = exponent_init(y,x)

ix = find(y > 0); 

%  log(y) = c * x + B
xx = x(ix);
ly = log(y(ix));

c = slope_estimate(ly, xx);

ex = exp(c*x);

%  y = a + b * exp( c * x ) = a + b * ex
[b,a] = slope_estimate(y, ex, 1);

return
% 
% --- Slope estimation: MSE for ( y = c*x + b ) 
%
function	[c, b] = slope_estimate(y,x,mode)
% slope estimation
%   [c, b] = slope_estimate(y,x)
%   [c, b] = slope_estimate(y,x,mode)
% mode = 0: [default]
%   y = c * x + b
%   dy = (y - <y>) = c * (x -<x>) = c * dx
%   y = c * x + (<y> - c * <x>)
%   c = <dy*dx>/<dx.^2>
%   b = <y> - c * <x>
% mode = 1: 
%   y = c * x 
%   c = <y*x>/<x.^2>

if nargin==2 || mode~=1
	% mean
	mx = mean(x);
	my = mean(y);
	
	% zero mean 
	dx = x - mx;
	dy = y - my;
	c = sum(dy.*dx)/sum(dx.^2);
	b = my - c * mx;
else
	c = sum(y.*x)/sum(x.^2);
	b = 0;
end

return
