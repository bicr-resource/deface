function	Vspm = vb_vox_to_spm_right(V,Vdim,Vsize,nflag)
% Change SBI-Voxcel coordinate to Right-hand SPM coordinate
%  Vspm = vb_vox_to_spm_right(V)            : normal vector
%  Vspm = vb_vox_to_spm_right(V,Vdim,Vsize) : coordinate vector
%  Vspm = vb_vox_to_spm_right(V,Vdim,Vsize,nflag)
% ---- Input
% V     : NV x 3 SBI-Voxcel coordinate
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% nflag = 1 : normal vector : no translation and scaling is applied
% ---- Output
% Vspm : NV x 3 right-handed SPM coordinate 
%
% --- MRI-Voxel coordinate   
%
% [Right-hand coordinate]
% X:Front(1) -> Back(256)
% Y:Top(1)   -> Bottom(256) 
% Z:Left(1)  -> Right(191) 
%
% --- SPM coordinate   
%
% [Right-hand coordinate]
% X: Left(-191/2)   -> Right(191/2) 
% Y: Back(-256/2)   -> Front(256/2)
% Z: Bottom(-256/2) -> Top(256/2) 
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
	Vspm(:,1) = V(:,3);
	Vspm(:,2) = - V(:,1);
	Vspm(:,3) = - V(:,2);
else
	Vspm(:,1) =   V(:,3) - Vdim(1)*Vsize(1)*0.5;
	Vspm(:,2) = - V(:,1) + Vdim(2)*Vsize(2)*0.5;
	Vspm(:,3) = - V(:,2) + Vdim(3)*Vsize(3)*0.5;
end
