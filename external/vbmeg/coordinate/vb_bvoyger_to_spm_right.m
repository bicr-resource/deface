function	Vspm = vb_bvoyger_to_spm_right(V,nflag)
% change BrainVoyger coordinate to SPM Right coordinate
%  Vspm = bvoyger_spm_right(V)   : coordinate vector
%  Vspm = bvoyger_spm_right(V,1) : normal vector
% --- Input
% V     : NV x 3 BrainVoyger coordinate
% nflag = 0 : SBI-compatible-version ( before vbmeg ver 0.5)
%       = 1 : normal vector : no translation and scaling is applied
%       = 2 : Adjust origin of BV and SPM coordinate
% --- Output
% Vspm   : NV x 3 SPM Right coordinate
%
% --- Brain-Voyager coordinate (1 voxcel size = mm)
%
% [Left-hand coordinate]
% X:Front(0) -> Back(255)
% Y:Top(0)   -> Bottom(255)
% Z:Right(0) -> Left(255)
%
%  Analyze image is imported to BV (256x256x256 mm) space
%  such that the center of image is aligned
%      Center of image in BV        : [255/2. 255/2. 255/2]
%  <-> Center of image in SPM space : [ 0, 0, 0]
%
% --- Right-hand SPM coordinate  [mm] 
%
% [Right-hand coordinate]
% X: Left(-191/2)   -> Right(191/2) 
% Y: Back(-256/2)   -> Front(256/2)
% Z: Bottom(-256/2) -> Top(256/2) 
%
%
% written by M. Sato  2006-7-20
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin == 1,
	nflag = 0;
end;

NV   = size(V,1);
Vspm = zeros(NV,3);

switch nflag
case	0
	%  SBI-compatible-version ( before vbmeg ver 0.5)
	Vspm(:,1) = 255/2 - V(:,3) + 1  ;
	Vspm(:,2) = 255/2 - V(:,1) - 1/2;
	Vspm(:,3) = 255/2 - V(:,2) - 1/2;
case	2
	%  Modified version
	%      Center of image in BV        : [255/2. 255/2. 255/2]
	%  <-> Center of image in SPM space : [ 0, 0, 0]
	Vspm(:,1) = 255/2 - V(:,3); 
	Vspm(:,2) = 255/2 - V(:,1); 
	Vspm(:,3) = 255/2 - V(:,2); 
case	1
	%  normal vector
	Vspm(:,1) = - V(:,3);
	Vspm(:,2) = - V(:,1);
	Vspm(:,3) = - V(:,2);
end
