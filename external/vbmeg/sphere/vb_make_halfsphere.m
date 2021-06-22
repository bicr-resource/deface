function	[F,V,Jlist,NDlist] = vb_make_halfsphere(Nsphere)
% 球面三角分割
% Nsphere  : 頂点数を指定して分割数を決める
% F(m,1:3) : triangle vertex index for m-th triangle
% V(n,1:3) : (x,y,z) coordinate for n-th vertex
% Ahead(m) : area of m-th triangle
% Jlist{n}  : theta(n) に対応する点のインデックス
% NDlist(n) : Jlist{n} の点数
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Pos.theta_min  = 0;
Pos.theta_max  = 0.5*pi;
Pos.phi_min    = 0;
Pos.phi_max    = 2*pi;
Pos.r		   = 1;				

%resol	= sqrt(7.5*pi/(Nsphere));
%Ntheta	= fix(pi/(2*resol));
%Nphi	= fix(2*pi/resol);

[Ntheta, Nphi, Nall ] = vb_calc_sphere_point_num(Nsphere);

Pos.Ntheta	   = Ntheta;
Pos.Nphi	   = Nphi	;

[x, NDlist, Jlist] = vb_make_sphere_point(Pos);	% Cortex point

F = vb_make_triangle(Jlist);

V	  = x(:,1:3);

return

%%%%% DEBUG
% NDlist
%for j=1:3
%	Jlist{j};
%end
%
%NF=22;
%F(1:NF,:);
%%%%% DEBUG

Npoint = size(V,1);
Npatch = size(F,1);
Ahead  = zeros(Npatch,1);

for i=1:Npatch,
    xpl      = vb_cross2(V(F(i,2),:)-V(F(i,1),:), ...
    			      V(F(i,3),:)-V(F(i,1),:));
    Ahead(i) = sqrt(xpl*xpl')/2;      % patche area by cross product
end

Amean = sum(Ahead)/Npatch;
Amax  = max(Ahead);
Amin  = min(Ahead);
Aimg  = sum(abs(imag(Ahead)));

