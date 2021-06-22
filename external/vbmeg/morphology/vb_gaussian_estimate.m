function	[xmax,s,C,err] = vb_gaussian_estimate(Nhist,level,jmax)
% Parameter estimation of Gaussian distribution
%  [xmax,s,C,err] = vb_gaussian_estimate(Nhist,level,jmax)
%
% Nhist : histogram
% level : level of histogram
% jmax  : Max index of histogram to estimation
%
% xmax: Peak point of histogram : center of Gaussian
% s   : Variance 
% C   : normalization constant
% err : Estimated error
%
% pdf(x) = C * exp( - ((x - xmax)/s)^2/2 )
% 
% P(x) = exp( - (x/s)^2/2 )
%      = exp( - A * x^2 )
%  s^2 = 1/(2*A)
%
% dP/dA = - x^2 * P(x)
%  E    = <( y - P(x) )^2>
%    dE/dA  = < (y - P) * x^2 * P>
% d^2E/dA^2 = < (x^2 * P)^2 > + ...
% a_new = a + da
% dE/da(a_new) = dE/da + da * d^2E/da^2 = 0
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%clear all
%%% DEBUG
%j0 = 20;
%jmax  = 100;
%level = (0:jmax)/jmax;
%Nhist = 2* exp( - 3 * (level - level(j0)).^2 );

dmin  = 1e-10;
Niter = 1000;

if nargin < 3, jmax = length(Nhist); end;

Nhist = Nhist(1:jmax);
level = level(1:jmax);

[ymax ,imax]= max(Nhist);
xmax = level(imax);

% Parameter estimation of Gaussian distribution
x = level(imax:jmax) - xmax;
y = Nhist(imax:jmax)/ymax;

% Initial estimation by using log(y)
% ( log(y) = A * x^2 )
A = sum(log(y).* x.^2)/sum(x.^4);
dmin = abs(A) * dmin;

% Quasi-Newton iteration 
for n=1:Niter
	P   = exp( - A * x.^2 );
	dE  = sum((y - P) .* x.^2 .* P);
	ddE = sum((x.^2 .* P).^2)  ;
	dA  = - dE/ddE;
	
	if abs(dA) < dmin, break; end;
	
	A   = A + dA;
end

% y = C * P(x)
P  = exp( - A * x.^2 );
C  = sum(y.* P)/sum(P.^2);

% s : Variance of Gaussian distribution 
%     s^2 = 1/(2*A)
s = 1/sqrt(abs(2*A));

% Normalization constant
C = C * ymax ;

ix = find( level >= (xmax + 3*s) );

if isempty(ix)
	kmax = jmax;
else
	kmax = min(ix(1) , jmax);
end

% pdf  : Gaussian histogram
pdf = C * exp(-0.5*((level(1:kmax) - xmax)/s).^2);

err = sum(abs(Nhist(1:kmax) - pdf))/sum(abs(Nhist(1:kmax)));

return

plot(level,Nhist)
hold on
plot(level,pdf,'-r')

