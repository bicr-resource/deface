function	[F,V,xx,Vlist] = vb_close_surf(F,V)
%  Make closed surface 
% [F,V,xx] = vb_close_surf(F,V)
% [F,V,xx,Vlist] = vb_close_surf(F,V)
% --- Input and Output
%  V    : surface vertex [Nvertex x 3]
%  F    : triangle patch index for surface [Npatch x 3]
%  xx   : outward normal vector [Nvertex x 3]
% --- Optional variable for check
% Vlist : boundary vertex list [cell array]
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

DEBUG = 0;
%Jedge = [9 2; 9 1; 1 10; 1 2 ; 2 9; 3 4; 2 1];

fprintf('Make closed surface\n')

% Make vertex index list for boundary closed loop
[Vlist] = vb_boundary_edge(F,V);

Flist = [];
Nline = length(Vlist);

% Make triangle index to close surface 
% by using vertex index for boundary closed loop
for n=1:Nline
	% make closed loop index list
	ID = Vlist{n};
	NV = length(ID);
	
	% Make triangle index to close surface
	Fadd  = [ repmat(ID(1),[NV-2, 1]), ID(2:NV-1), ID(3:NV)];
	Flist = [Flist ; Fadd];
end

% Add patch list to close surface
F = [F ; Flist];

fprintf('Surface is closed\n')
fprintf('Make normal vector outward \n')

[F, V, xx] = vb_out_normal(F,V);

omega  = vb_solid_angle_check(V,F);

fprintf('Closed surface index = %f\n',omega);

if DEBUG == 1
	for n=1:Nline
		ID = Vlist{n};
		plot3(V(ID,1),V(ID,2),V(ID,3),'r-')
		hold on
		plot3(V([ID(1) ID(n)],1),V([ID(1) ID(n)],2),V([ID(1) ID(n)],3),'r-')
	end
end

return


return
