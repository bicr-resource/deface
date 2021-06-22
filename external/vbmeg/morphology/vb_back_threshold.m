function 	[th, step, y, pdf, err] = vb_back_threshold(B,pmax,Nwid,Imax)
% Calculate threshold for background selection from MRI image
%  [threshold] = vb_back_threshold(B)
%  [threshold] = vb_back_threshold(B,pmax)
%  [threshold, step, Nhist, pdf] = vb_back_threshold(B,pmax,Nwid,Imax)
% --- Input
% B    : MRI image
% --- Optional input
% pmax : Probability that the voxcel is background (= 0.998)
%        if (image intensity) < threshold 
% Nwid : Width of Gaussian filter to smooth histgram
% Imax : Max number of histgram bin (256)
% --- Output
% threshold: threshold for background selection
%   Background histogram is modeled by Rayleigh distribution
% --- Optional Output
% Nhist : Histogram of MRI image intensity
% pdf   : Estimated background histogram
% step  : Intensity level step size 
%
% if max(B) <= Imax, step = 1
% else               step = round(max(B)/Imax);
%
% Made by M. Sato 2004-3-28
% M. Sato 2010-10-10
%  Histogram is smoothed by Gaussian filter with width (Nwid=5)
%    to find first local minimum point
%  Three histgram distributions (Rayleigh, Gaussian, Exponential) are examined
%  if (error of Rayleigh) < 0.1, Rayleigh is selected
%  othewise, least error method is selected
% M. Sato 2010-10-18
%  Histogram level setting is modified
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% --------------------------------------------------------
% MRI構造画像 B から背景消去の為の閾値設定
% pmax : 背景ノイズが従うRayleigh分布に含まれると判断する閾値確率
%        この値が大きいほど閾値が大きくなる
%
% 背景ノイズが従うRayleigh分布の分散を推定し、
% この分布に含まれる確率が pmax である閾値を求める

if ~exist('pmax','var'), pmax = 0.998; end;
if ~exist('Imax','var'), Imax = 256; end;
if ~exist('Nwid','var'), Nwid = 5; end;

% Rayleigh threshold = rmax * (variance)
rmax = sqrt(2*abs(log(1-pmax)));
% Gaussian threshold = xpeak + rgas * (variance)
rgas = erfinv(pmax) * sqrt(2);
% Exponential threshold = xpeak + abs(rexp/c);
% pdf = a + b * exp( - c * x );
rexp = log(1-pmax);

% Max error to select Rayleigh distribution
err_max = 0.1;

% y : MRI image histogram
[y,x,step] = vb_mri_histgram(B(:), Imax);
Bmax = max(B(:));

% Smoothing histgram and find first local minimum
%   z : smoothing histgram
[ix_min, ix_max, z] = vb_histmin_estimate(y,Nwid);
x0 = x(ix_min);

% Max point of histogram
[ymax ,imax]= max(y);
if imax == 1, imax = 3; end;

% Background histogram estimate region
kmax = max(ceil(imax*rmax), ix_min);
ix = 1:kmax;

% Variance of Rayleigh distribution
[s1,pdf1,err1] = vb_rayleigh_estimate(y,x,kmax);
% Rayleigh threshold,
x1 = s1*rmax;

% Center and variance of Gaussian
[x2,s2,C,err2] = vb_gaussian_estimate(y(imax:kmax),x(imax:kmax));

% pdf2  : Gaussian distribution
pdf2 = C * exp(-0.5*((x(ix) - x2)/s2).^2);

% threshold,
x2  = x2 + s2*rgas;

% parameter of Exponential distribution

[a, b, c, err3] = vb_exponential_estimate(y(imax:kmax), x(imax:kmax));

% pdf3 : Exponential distribution
pdf3 = a + b * exp( c * x(ix) );
% ∫ c * exp( c*x ) = exp( c*x )
x3  = x(imax) + abs(rexp/c);

if err1 < err_max
	th  = x1;
	pdf = pdf1;
	err = err1;
	str = 'Rayleigh';
else
	
	[tmp,jmode] = min([err2, err3]);
	
	switch	jmode
	case	1
		th  = x2;
		pdf = pdf2;
		err = err2;
		str = 'Gaussian';
	case	2
		th  = x3;
		pdf = pdf3;
		err = err3;
		str = 'Exponential';
	end
end

fprintf('Max intensity = %g\n',Bmax)
fprintf('Histgram step = %d\n',step)

fprintf('Rayleigh    = %g (err=%g)\n',x1,err1)
fprintf('Gaussian    = %g (err=%g)\n',x2,err2)
fprintf('Exponential = %g (err=%g)\n\n',x3,err3)

fprintf('%s distribution estimation\n',str)
fprintf('Threshold   = %g (err=%g)\n',th,err)

if nargout < 5, return; end;
%%%%%%%%%%%%%%%%%%%%% Plot Histgram %%%%%%%%%%%%%%%%%%%%

zmax = max(z);
zmid = z(ix_max);

%ix_th = find( x >= th);
ix_th = round(th/step);

% Plot histgram
subplot(2,2,1)
plot(y)
hold on
plot(z,'-r')

plot(ix, pdf1,'-c')
plot(ix, pdf2,'-m')
plot(ix, pdf3,'-y')

plot([ix_th ix_th], [0 0.5*ymax],'-r')

ylim([0 ymax]);
xlim([0 ix_min])
title('Low intensity histogram')

% Plot histgram
subplot(2,2,2)
plot(y)
hold on
plot(z,'-r')

plot(ix, pdf1,'-c')

plot([ix_th ix_th], [0 8*zmax],'-r')

ylim([0 zmax]);
xlim([0 ix_min])
title('Low intensity histogram')

% Plot histgram
subplot(2,2,3)
plot(y)
hold on
plot(z,'-r')

plot(ix, pdf2,'-m')
plot(ix, pdf3,'-y')

plot([ix_th ix_th], [0 8*zmax],'-r')

ylim([0 zmax]);
xlim([0 ix_min])
title('Low intensity histogram')

% Plot histgram
%figure
subplot(2,2,4)
plot(y)
hold on
plot(z,'-r')

plot(ix, pdf1,'-c')
plot(ix, pdf2,'-m')
plot(ix, pdf3,'-y')

plot([ix_th ix_th], [0 zmax],'-r')

ylim([0 2*zmid]);
xlim([0 1.5*ix_max])
title('Intensity histogram')

return
%%%%%%%%%%%%%%%%%%%%%%%%  END %%%%%%%%%%%%%%%%%%%%
xx  = x(1:kmax);

% Plot histgram
subplot(2,2,1)
plot(x,y)
hold on
plot(x,z,'-r')

plot(xx, pdf1,'-c')
plot(xx, pdf2,'-y')
plot(xx, pdf3,'-m')

plot([th th], [0 0.5*ymax],'-r')

ylim([0 max(y)]);
xlim([0 x0])
title('Low intensity histogram')

% Plot histgram
subplot(2,2,2)
plot(x,y)
hold on
plot(x,z,'-r')

plot(xx, pdf1,'-c')

plot([th th], [0 8*zmax],'-r')

ylim([0 max(z)]);
xlim([0 x0])
title('Low intensity histogram')

% Plot histgram
subplot(2,2,3)
plot(x,y)
hold on
plot(x,z,'-r')

plot(xx, pdf2,'-c')
plot(xx, pdf3,'-y')

plot([th th], [0 8*zmax],'-r')

ylim([0 max(z)]);
xlim([0 x0])
title('Low intensity histogram')

% Plot histgram
%figure
subplot(2,2,4)
plot(x,y)
hold on
plot(x,z,'-r')

plot(xx, pdf,'-y')
plot([th th], [0 zmax],'-r')

ylim([0 2*zmax]);
xlim([0 1.5*x(ix_max)])
title('Low intensity histogram')
title('Intensity histogram')

return
%%%%%%%%%%%%%%%%%%%%%%  END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bhigh = max(Nhist(j0+1:end));

subplot(2,1,1)

plot(level,Nhist);
hold on
%plot([level(imax) level(imax)], [0 Hmax*1.1], 'b-');
plot([th th], [0 0.5*max(Nhist)], 'r-');
plot(x0,rpdf,'-r')
xlim([0 2*th]);

title('Low intensity histogram of MRI (Rayleigh dist)')

subplot(2,1,2)
plot(level,Nhist);
hold on
plot([th th], [0 Nhist(j0)], 'r-');
plot(x0,rpdf,'-r')
xlim([th*0.8 Bmax]);
ylim([0 Bhigh]);

title('Intensity histogram of MRI (Rayleigh dist)')

return

% Variance of Rayleigh distribution (smoothed histgram)
[s2,pdf2,err2] = vb_rayleigh_estimate(z,x,kmax);
% Rayleigh threshold,
x2 = s2*rmax;

% Find histogram increasing point
jx = find( x >= x1);
j0 = jx(1);
dh = y(j0+1:end) - y(j0:end-1);
jj = find( dh > 0 );
j0 = j0 + jj(1) - 1;
xm = x(j0);
