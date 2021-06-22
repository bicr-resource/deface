function	Vana = vb_analyze_to_analyze_mm(Vana,Vdim,Vsize)
% Change Analyze voxel coord to Analyze mm coord.
%  Vana = vb_analyze_to_analyze_mm(Vana,Vdim,Vsize)
% --- Input
% Vana  : NV x 3 Analyze Right-hand voxel coordinate
% Vdim  : Voxel dimension of Analyze image
% Vsize : Voxel size of Analyze image
% --- Output
% Vana  : NV x 3 Analyze Right-hand [mm] coordinate
%
% --- Analyze mm coordinate   
%
% [Right-hand coordinate]
% X: Left(1)   -> Right(191) 
% Y: Back(1)   -> Front(256)
% Z: Bottom(1) -> Top(256) 
%
% written by M. Sato  2007-3-14
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Change Analyze voxel coord to Analyze mm coord.
Vana(:,1) =  Vana(:,1) * Vsize(1);
Vana(:,2) =  Vana(:,2) * Vsize(2);
Vana(:,3) =  Vana(:,3) * Vsize(3);

