function	Vspm = vb_vox_to_analyze_right(V,Vdim,Vsize,nflag)
% change SBI-Voxcel(mm) coordinate to Right-hand Analyze voxcel coordinate
%  Vspm = vb_vox_to_analyze_right(V)            : normal vector
%  Vspm = vb_vox_to_analyze_right(V,Vdim,Vsize) : coordinate vector
%  Vspm = vb_vox_to_analyze_right(V,Vdim,Vsize,nflag)
% --- Input
% V     : NV x 3 SBI-Voxcel(mm) coordinate
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% nflag = 1 : normal vector : no translation and scaling is applied
% --- Output
% Vana  : NV x 3 Analyze Right-hand voxcel coordinate
%
% --- MRI-Voxel(mm) coordinate   
%
% [Right-hand coordinate]
% X:Front(1) -> Back(256)
% Y:Top(1)   -> Bottom(256) 
% Z:Left(1)  -> Right(191) 
%
% --- Analyze voxcel coordinate   
%
% [Right-hand coordinate]
% X: Left(1)   -> Right(191) 
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
Vspm = zeros(NV,3);

if nflag == 1
	Vspm(:,1) =   V(:,3);
	Vspm(:,2) = - V(:,1);
	Vspm(:,3) = - V(:,2);
else
	Vspm(:,1) =   V(:,3)/Vsize(1);
	Vspm(:,2) = - V(:,1)/Vsize(2) + Vdim(2);
	Vspm(:,3) = - V(:,2)/Vsize(3) + Vdim(3);
end
