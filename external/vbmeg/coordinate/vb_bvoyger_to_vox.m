function	Vox = vb_bvoyger_to_vox(V,Vdim,Vsize,nflag)
% change BrainVoyger coordinate to SBI-Voxcel coordinate
%  Vox = vb_bvoyger_to_vox(V)            : normal vector
%  Vox = vb_bvoyger_to_vox(V,Vdim,Vsize) : coordinate vector
%  Vox = vb_bvoyger_to_vox(V,Vdim,Vsize,nflag)
% --- Input
% V     : NV x 3 BrainVoyger coordinate
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% nflag = 1 : normal vector : no translation and scaling is applied
% --- Output
% Vox   : NV x 3 SBI-Voxcel coordinate
%
% --- Brain-Voyager coordinate (1 voxcel size = mm)
%
% [Left-hand coordinate]
% X:Front(0) -> Back(255)
% Y:Top(0)   -> Bottom(255)
% Z:Right(0) -> Left(255)
%
% --- MRI-Voxel coordinate   
%
% [Right-hand coordinate]
% X:Front(1) -> Back(256)
% Y:Top(1)   -> Bottom(256) 
% Z:Left(1)  -> Right(191) 
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

if nflag==1
	Vox = V;
	Vox(:,3) = - V(:,3);
else
	NV  = size(V,1);
	Vox = zeros(NV,3);
	
	Vox(:,1) = V(:,1) + 1; 
	Vox(:,2) = V(:,2) + 1; 
	Vox(:,3) = 256 - V(:,3) - fix( (256 - Vdim(1)*Vsize(1))/2 );
end
