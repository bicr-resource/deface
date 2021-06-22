function [X ,NDlist ,Jlist ] = vb_make_sphere_point(Pos)
% Make points on a hemisphere
% Pos で指定された球面座標の範囲に座標点を作成する
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Pos の構造体
%   theta  : 仰角    : [theta_min theta_max] (0:水平 pi/2:真上)
%   phi    : 方位角  : [  phi_min   phi_max] (0:pi)
%   r      : Radius
%   Ntheta : Number of divisions in theta
%   Nphi   : Number of divisions in phi

% X            = [rx, vphi, vtheta] : (N x 9) matrix
% rx           = (theta,phi,r)で指定される座標ベクトル
% vphi, vtheta : rx に垂直な２つの接線ベクトル
% Jlist{n} : theta(n) に対応する点のインデックス
% NDlist(n) : Jlist{n} の点数

theta_step = (Pos.theta_max - Pos.theta_min);
phi_range  = (Pos.phi_max   - Pos.phi_min)/2;

if theta_step > 0,
	theta_step = theta_step/Pos.Ntheta;
end;

Nphi   = Pos.Nphi;

theta  = theta_step*[0:Pos.Ntheta]+Pos.theta_min;
Ntheta = length(theta);
NDlist = zeros(Ntheta,1);

Phi    = [];
Theta  = [];
Nstart = 1;
Jlist  = cell(Ntheta,1);

for n=1:Ntheta,
	DNphi=fix(Nphi*cos(theta(n))/2);
	
	if DNphi> 0,
		if DNphi <2,
			DNphi=2;
		end;
		dphi=phi_range/DNphi;
	else
		dphi=0;
	end;
	
	if (phi_range < pi) | ( DNphi == 0 ),
		jj		  = 0:(2*DNphi);
		phi 	  = jj*dphi + Pos.phi_min;
		NDlist(n) = 2*DNphi+1;
		Jlist{n}  = jj + Nstart;
		Nstart	  = Nstart + 2*DNphi+1;
	else
		jj		  = 0:(2*DNphi-1);
		phi 	  = jj*dphi + Pos.phi_min;
		NDlist(n) = 2*DNphi;
		Jlist{n}  = jj + Nstart;
		Nstart	  = Nstart + 2*DNphi;
	end;
	
	Phi    = [Phi, phi];
    Theta  = [Theta, theta(n)*ones(1,length(phi)) ];
end;

N=length(Theta);

r	  = Pos.r;

[x ,y ,z ] = sph2cart(Phi,Theta,r); 
[x1,y1,z1] = sph2cart(Phi+0.5*pi, zeros(1,length(Theta)), 1); 
[x2,y2,z2] = sph2cart(Phi, Theta+0.5*pi, 1); 

X		  = [x(:),y(:),z(:), x1(:),y1(:),z1(:), x2(:),y2(:),z2(:)];

