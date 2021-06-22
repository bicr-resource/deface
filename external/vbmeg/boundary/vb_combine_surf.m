function	[F, V, xx] = vb_combine_surf(Fall, Vall, ix_select)
% combine multiple surfaces
%  [F, V, xx] = vb_combine_surf(Fall, Vall, ix_select)
% --- Input
% Vall{n} : vertex of n-th connected surface
% Fall{n} : patch index
% ix_select : number of surface to be selected
% --- Output
% V  : vertex of combined surface
% F  : patch index
% xx : outward normal vector of combined surface
%
% Ver 1.0  by M. Sato  2006-6-4
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

N  = length(ix_select);
NV = zeros(N,1);
NF = zeros(N,1);

for n = 1:N
	j  = ix_select(n);
	NV(n) = size(Vall{j},1);
	NF(n) = size(Fall{j},1);
end

V  = zeros(sum(NV),3);
F  = zeros(sum(NF),3);
xx = zeros(sum(NV),3);

Nvertex = 0;
Npatch  = 0;

for n = 1:N
	j  = ix_select(n);
	n1 = Nvertex + 1;
	n2 = Nvertex + NV(n);
	
	V(n1:n2,:) = Vall{j};

	% normal vector
	[xxn ,FF] = vb_out_normal_vect(Vall{j}, Fall{j});

	xx(n1:n2,:) = xxn;

	m1 = Npatch + 1;
	m2 = Npatch + NF(n);
	
	F(m1:m2,:) = FF + Nvertex;

	Nvertex = Nvertex + NV(n);
	Npatch  = Npatch  + NF(n);
end
