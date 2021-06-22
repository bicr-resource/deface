function	[xyz, BZ] = vb_get_boundary(B,vlevel)
% get boundary surface point index of mask image
%  [xyz, BZ] = vb_get_boundary(B,vlevel)
%   B      : 3D-mask image
% vlevel   : Threshold
% xyz : voxel coordinate of boundary
%   BZ     : boundary mask image
%
% 2007/06/14 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('vlevel','var'), vlevel = 0.5; end;

[N1,N2,N3] = size(B);

BZ = zeros(N1,N2,N3);

% West-East (X-axis) ŒŸ¿‹≈¿•§•Û•«•√•Ø•π
NN1 = N1-1;
jw  = 1:NN1;
je  = 2:N1;
% North-South (Y-axis) ŒŸ¿‹≈¿•§•Û•«•√•Ø•π
NN2 = N2-1;
jn  = 1:NN2;
js  = 2:N2;

NX2 = N1*N2;

for j3 = 1:N3
	% West-East (X-axis) ŒŸ¿‹≈¿»Ê≥”
	ix = find( (B(jw,:,j3)-vlevel) .* (B(je,:,j3)-vlevel) <= 0 );
	
	% 2D-subscript of inner boundary point
	% ----- [j1,j2] = ind2sub([NN1,N2], ix );
	j2 = floor((ix-1)/NN1)+1;
	j1 = rem((ix-1),NN1)+1;
	jx = j1+ N1*(j2 - 1)+ NX2*(j3 - 1);
	
	% set flag on the boundary points
	BZ(jx) = 1;

	% North-South (Y-axis) ŒŸ¿‹≈¿»Ê≥”
	ix = find( (B(:,jn,j3)-vlevel) .* (B(:,js,j3)-vlevel) <= 0 );

	% ----- [j1,j2] = ind2sub([N1,N2], ix );
	j2 = floor((ix-1)/N1)+1;
	j1 = rem((ix-1),N1)+1;
	jx = j1+ N1*(j2 - 1)+ NX2*(j3 - 1);
	
	% set flag on the boundary points
	BZ(jx) = 1;

	% Up-Down (Z-axis) ŒŸ¿‹≈¿»Ê≥”
	if j3 < N3,
		ix = find( (B(:,:,j3)-vlevel) .* (B(:,:,j3+1)-vlevel) <= 0 );

		% ----- [j1,j2] = ind2sub([N1,N2], ix );
		j2 = floor((ix-1)/N1)+1;
		j1 = rem((ix-1),N1)+1;
		jx = j1+ N1*(j2 - 1)+ NX2*(j3 - 1);
		
		% set flag on the boundary points
		BZ(jx) = 1;
	end
end

ix = find( BZ(:) > 0 );

% ----- [j1,j2,j3] = ind2sub([N1,N2,N3], ix );
j3  = floor((ix-1)/NX2)+1;
ix  = rem((ix-1),NX2) +1;

j2 = floor((ix-1)/N1)+1;
j1 = rem((ix-1),N1)+1;

xyz = [j1, j2, j3];
