function	Vana = vb_spm_right_to_analyze_left(Vspm,Vdim,Vsize,nflag)
% change Right-hand SPM (m) coordinate to analyze Left-hand voxcel coord.
%  Vana = vb_spm_right_to_analyze_left(Vspm)            : normal vector
%  Vana = vb_spm_right_to_analyze_left(Vspm,Vdim,Vsize) : coordinate vector
%  Vana = vb_spm_right_to_analyze_left(Vspm,Vdim,Vsize,nflag)
% --- Input
% Vspm  : NV x 3 Right-hand SPM (m) coord.
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% nflag = 1 : normal vector : no translation and scaling is applied
% --- Output
% Vana  : NV x 3 Analyze Left-hand voxcel coordinate
%
% --- Analyze voxcel coordinate   
%
% [Left-hand coordinate]
% X: Right(1)  -> Left(191) 
% Y: Back(1)   -> Front(256)
% Z: Bottom(1) -> Top(256) 
%
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
	Vana(:,1) = -Vspm(:,1);
	return; 
end;

% Change [m] to [mm]
Vspm = Vspm*1000;

NV   = size(Vspm,1);
Vana = zeros(NV,3);

Vana(:,1) = -Vspm(:,1)/Vsize(1) + Vdim(1)*0.5;	% Right<->Left
Vana(:,2) =  Vspm(:,2)/Vsize(2) + Vdim(2)*0.5;
Vana(:,3) =  Vspm(:,3)/Vsize(3) + Vdim(3)*0.5;

