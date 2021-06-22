function	[s,pdf,err] = vb_rayleigh_estimate(Nhist,level,jmax)
% Parameter estimation of Rayleigh distribution
%  [s,pdf,err] = vb_rayleigh_estimate(Nhist,level,jmax)
%
% Nhist : histogram
% level : level of histogram
% jmax  : Max index of histogram to estimation
%
% s   : Variance of Rayleigh distribution 
% pdf : Estimated Rayleigh histogram
% err : Estimated error
% 
% ÇØ·Ê¥Î¥¤¥º¤¬½¾¤¦RayleighÊ¬ÉÛ¤ÎÊ¬»¶¤ò¿äÄê
% RayleighÊ¬ÉÛ
%  x >= 0
% P(x) = a * x * exp( - a * x^2/2 )
% Cummulative probability
% Q(x) = ¢é P(x) = 1 - exp( - a * x^2/2 )
%      = 1 - exp( - (x/s)^2/2 )
% P(s) : Max of P(x)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 3, jmax = length(Nhist); end;

% Parameter estimation of Rayleigh distribution
x = level(1:jmax);
y = Nhist(1:jmax);

[Hmax ,imax]= max(y);

% If max point is at imax = 1, this distribution is not Rayleigh
if imax == 1, imax = 3; end;

xmax = level(imax);

% Cumulative histogram
ysum = cumsum(y);
fsum = 1-exp(-0.5*(x/xmax).^2);

% proportinal constant estimation ( ysum = A * fsum )
A = sum(ysum.*fsum)/sum(fsum.^2);
% 1 - (Cumulative histogram)
%   = exp( - (x/s)^2/2 ) 
ysum = 1 - ysum/A;

% s : Variance of Rayleigh distribution 
% ysum  = exp( - (x/s)^2/2 ) 
s = 1/sqrt(abs(2*(log(ysum(imax))/x(imax)^2)));

% Check Rayleigh distribution
% pdf  : estimated Rayleigh histogram

xx = [0 x];
% 1 - (Cumulative histogram)
fsum = exp(-0.5*(xx/s).^2);
% Estimated Rayleigh distribution
pdf = A*[fsum(1:end-1) - fsum(2:end)];

ix = find( x >= 4*s );

if isempty(ix)
	kmax = jmax;
else
	kmax = ix(1);
end

%kmax = min(4*imax, jmax);
err = sum(abs(y(1:kmax) - pdf(1:kmax)))/sum(abs(y(1:kmax)));
