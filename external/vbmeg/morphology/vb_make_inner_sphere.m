function	[V,F,xx,X0] = vb_make_inner_sphere(Vox,Nvertex,mode,rate)
% vb_make_inner_sphere
%  [V,F,xx,X0] = vb_make_inner_sphere(Vox,Nvertex,mode)
% --- Input
% Vox : surface coordinate
% Nvertex : Number of sphere vertex to be made
% mode = 0 : min radius of Vox
%      = 1 : mean radius of Vox
% rate : rate factor of radius
% --- Output
% V : vertex
% F : patch
% xx : normal vector of sphere
% X0 : center of sphere
%
% Made by M. Sato 2007-3-16
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('rate','var'), rate = 1; end;

%
%------- 球面作成
%
X0  = mean(Vox);	% 中心点

% Radius of inner sphere
R = (Vox(:,1)-X0(1)).^2 + (Vox(:,2)-X0(2)).^2 + (Vox(:,3)-X0(3)).^2;

if ~exist('mode','var') | mode == 0,
	R = mean(sqrt(R))*rate;
else
	R = sqrt(min(R))*rate;
end

% Unit sphere
[F,xx] = vb_make_fullsphere(Nvertex);

V = [R*xx(:,1)+X0(1), R*xx(:,2)+X0(2), R*xx(:,3)+X0(3)];
