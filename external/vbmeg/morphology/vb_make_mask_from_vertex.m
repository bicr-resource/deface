function	B = vb_make_mask_from_vertex(Vdim, XYZ, Z)
% Make mask from vertex coordinate
%  B = vb_make_mask_from_vertex(Vdim, XYZ, Z)
% Vdim : mask image dimension
% XYZ  : vertex coordinate of mask point [Npoint x 3]
%  Z   : mask value for XYZ
%  B   : mask image
%
% 2007/06/09 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Z','var'), Z = ones(size(XYZ,1),1); end;

XYZ = fix(XYZ);

ix = find(  XYZ(:,1) >=1  & XYZ(:,1) <= Vdim(1) ...
          & XYZ(:,2) >=1  & XYZ(:,2) <= Vdim(2) ...
          & XYZ(:,3) >=1  & XYZ(:,3) <= Vdim(3) );

Npoint = length(ix);

XYZ = XYZ(ix,:);
Z   = Z(ix);

B = zeros(Vdim);

for n=1:Npoint
	B(XYZ(n,1), XYZ(n,2), XYZ(n,3)) = Z(n);
end
