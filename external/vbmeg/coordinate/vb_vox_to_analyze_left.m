function	Vana = vb_vox_to_analyze_left(V,Vdim,Vsize,nflag)
% change SBI-Voxcel(mm) coordinate to Light-hand Analyze voxcel coordinate
%  Vana = vb_vox_to_analyze_left(V)            : normal vector
%  Vana = vb_vox_to_analyze_left(V,Vdim,Vsize) : coordinate vector
%  Vana = vb_vox_to_analyze_left(V,Vdim,Vsize,nflag)
% --- Input
% V     : NV x 3 SBI-Voxcel coordinate
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% nflag = 1 : normal vector : no translation and scaling is applied
% --- Output
% Vana  : NV x 3 Analyze Left-hand voxcel coordinate
%
% --- MRI-Voxel coordinate   
%
% [Right-hand coordinate]
% X:Front(1) -> Back(256)
% Y:Top(1)   -> Bottom(256) 
% Z:Left(1)  -> Right(191) 
%
% --- Analyze voxcel coordinate   
%
% [Left-hand coordinate]
% X: Right(1)   -> Left(191) 
% Y: Back(1)   -> Front(256)
% Z: Bottom(1) -> Top(256) 
%
% written by M. Sato  2005-8-1
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)


if nargin == 1,
	nflag = 1;
elseif nargin < 4, 
	nflag = 0; 
end;

NV   = size(V,1);
Vana = zeros(NV,3);

if nflag == 1
	Vana(:,1) = - V(:,3);
	Vana(:,2) = - V(:,1);
	Vana(:,3) = - V(:,2);
else
	Vana(:,1) = - V(:,3)/Vsize(1) + Vdim(1) ;
	Vana(:,2) = - V(:,1)/Vsize(2) + Vdim(2);
	Vana(:,3) = - V(:,2)/Vsize(3) + Vdim(3);
end
