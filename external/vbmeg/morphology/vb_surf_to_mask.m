function	B = vb_surf_to_mask(V,F,vstep,step,Dim)
% Make surface to mask image
%   B = vb_surf_to_mask(V,F,vstep,step,Dim)
%
% V(NV,3) : vertex point coordinate on the surface
% F(NF,3) : patch index
% vstep   : voxcel size
% step    : minimum length for edge
% Dim = [NX, NY, NZ] : Dimension of mask image
%
% B(NX, NY, NZ) : mask image
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)


NX	= Dim(1);
NY	= Dim(2);
NZ	= Dim(3);
NXY = NX*NY;

NV	= size(V,1);
NF	= size(F,1);

% Voxcel image
B	= zeros(NX, NY, NZ);
V   = V/vstep;
step = step/vstep;
%
% Set voxcel at vertex point 'ON'
% 三角形頂点のボクセルを ON にする
% change coordinate to index
%     V = [-1/2,-1/2,-1/2] - [1/2,1/2,1/2]
% <=> J = [1,1,1]

%J  = floor(V) + 1;
J  = floor(V + 0.5) + 1;
ix = J(:,1)+ NX*(J(:,2) - 1)+ NXY*(J(:,3) - 1);

B(ix) = 1;

%
% Find triangle larger than step size
% 格子サイズより長い辺を持つ三角形を探す
% triangle vertex　三角形頂点
x1 = V(F(:,1),:);
x2 = V(F(:,2),:);
x3 = V(F(:,3),:);

% triangle edge　三角形辺
z1 = x1 - x2;
z2 = x2 - x3;
z3 = x3 - x1;

% edge length　辺の長さ
d1 = sqrt(sum(z1.^2,2));
d2 = sqrt(sum(z2.^2,2));
d3 = sqrt(sum(z3.^2,2));

% Largest edge length in each triangle　最長辺
[dd ,imax] = max([d1 d2 d3],[],2);

% find edge larger than step　格子サイズより長い辺を探す
idx = find( dd > step );
ND  = length(idx);

if ND == 0, return; end;

% Max length
dmax = max(dd);

% 2D index to specify vertex point inside the triangle
% 三角形内部の分割点を表すインデックス生成
Nmax = ceil(dmax/step);
NN   = (Nmax+1)*(Nmax+2)/2;
inx1 = zeros(NN,1);
inx2 = zeros(NN,1);
id   = 0;

% 0 <= k2 <= k1 <= Nmax 
% 0 <= Nmax - k1 + k2 <= Nmax 
for k1=0:Nmax
	for k2=0:k1
		id = id + 1;
		inx1(id) = k1;
		inx2(id) = k2;
	end;
end

% large triangle loop
for m = 1:ND
	% 
	n  = idx(m);		% triangle index
	d  = dd(n);			% largest edge length
	Nd = ceil(d/step);	% # of edge division
	
	% triangle vertex
	y1 = x1(n,:);
	y2 = x2(n,:);
	y3 = x3(n,:);
	
	% 0 <= Nd - k1 + k2 <= Nd 
	% 0 <=  kk1 + kk2   <= Nd
	NT  = (Nd+1)*(Nd+2)/2;
	kk1 = Nd - inx1(1:NT);	% kk1 = Nd - k1
	kk2 = inx2(1:NT);		% kk2 = k2

	% area coordinate index
	% kk1 + kk2 + kk3 = Nd
	kk3 = Nd - kk1 - kk2;	% kk1 + kk2 + kk3 = Nd
	
	% triangle inner coordinate 
	j1 = floor(( kk1*y1(1) + kk2*y2(1) + kk3*y3(1) )/Nd ) + 1;
	j2 = floor(( kk1*y1(2) + kk2*y2(2) + kk3*y3(2) )/Nd ) + 1;
	j3 = floor(( kk1*y1(3) + kk2*y2(3) + kk3*y3(3) )/Nd ) + 1;

	% 1D-index corresponding to (j1, j2, j3)
	ii = j1+ NX*(j2 - 1)+ NXY*(j3 - 1);
	
	% 
	B(ii) = 1;
	
end

