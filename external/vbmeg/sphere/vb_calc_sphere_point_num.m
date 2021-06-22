function [Ntheta, Nphi, Nall ] = vb_calc_sphere_point_num(Nsphere)
% 球面上の点数が Nsphere に近い分割を求める
% 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)
theta_min  = -0.5*pi;

mode  = 1;
resol = sqrt(6*pi/(Nsphere));
Nmax  = 2*fix(pi/(2*resol));

Ltheta = 2*[1:Nmax];
Lphi =  zeros(Nmax,1);
Lall =  zeros(Nmax,1);

for n = 3:Nmax
	Ntheta=2*n;
	% angle step size
	step = pi/Ntheta;
	% Max # of phi devision
	Nphi = fix(2*pi/step);
	
	theta = step*[1:Ntheta-1] + theta_min;
	% Total # of points
	Nall  = sum( 2*fix( Nphi*cos(theta)/2 ) ) + 2;
	
	Lphi(n)=Nphi;
	Lall(n)=Nall;
	
	if Nall > Nsphere, break; end;
	
end

if mode == 0
	[dmin,ix] = min(abs( Lall - Nsphere ));
else
	ix = n;
end

Nall   = Lall(ix);
Ntheta = Ltheta(ix);
Nphi   = Lphi(ix);
