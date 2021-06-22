function	G = vb_sarvas_basis(V, xx, pick, Qpick)
% Lead field for spherical brain model (Sarvas Eq.)
%   G = vb_sarvas_basis(V, xx, pick, Qpick)
% --- INPUT
%  V(n,:)  : dipole position (3-D coordinate) at n-th vertex
% xx(n,:)  : dipole current direction (unit vector) at n-th vertex
%  pick(k, 1:3) : Sensor coil position  : コイル位置, 
% Qpick(k, 1:3)	: Sensor coil direction : コイル方向
% --- OUTPUT
% G : Lead field matrix ( Nvertex , Npick) 
%
% 2006-12-16 made by M.Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NV      = size(V,1);
Npick   = size(pick,1);

G = zeros(NV , Npick);

if NV >= Npick
	
	for i=1:Npick,
		G(:,i) = vb_sarvas_new(V, xx, pick(i,:), Qpick(i,:) );
	end
else
	
	for i=1:NV
		G(i,:) = vb_sarvas_sensor(V(i,:),xx(i,:),pick, Qpick)';
	end
end
