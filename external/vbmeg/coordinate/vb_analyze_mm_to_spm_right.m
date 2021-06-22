function	Vspm = vb_analyze_mm_to_spm_right(Vana,Vdim,Vsize,nflag)
% change Analyze Left-hand mm coordinate to Right-hand SPM (m) coord.
%  Vspm = vb_analyze_mm_to_spm_right(Vana)            : normal vector
%  Vspm = vb_analyze_mm_to_spm_right(Vana,Vdim,Vsize) : coordinate vector
%  Vspm = vb_analyze_mm_to_spm_right(Vana,Vdim,Vsize,nflag)
% --- Input
% Vana  : NV x 3 Analyze Left-hand voxcel coordinate
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% nflag = 1 : normal vector : no translation and scaling is applied
% --- Output
% Vspm  : NV x 3 Right-hand SPM (m) coord.
%
% --- Analyze mm coordinate   
%
% [Left-hand coordinate]
% X: Right(1)  -> Left(191) 
% Y: Back(1)   -> Front(256)
% Z: Bottom(1) -> Top(256) %
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

if nflag == 1, 
	Vspm(:,1) = -Vana(:,1);
	return; 
end;

NV   = size(Vana,1);
Vspm = zeros(NV,3);

Vspm(:,1) = -( Vana(:,1) - Vdim(1)*0.5*Vsize(1) );
Vspm(:,2) =  ( Vana(:,2) - Vdim(2)*0.5*Vsize(2) );
Vspm(:,3) =  ( Vana(:,3) - Vdim(3)*0.5*Vsize(3) );

% Change [mm] to [m]
Vspm = Vspm*0.001;
