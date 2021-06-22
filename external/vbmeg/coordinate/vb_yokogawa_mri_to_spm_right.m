function Vspm_right = vb_yokogawa_mri_to_spm_right(Vyokogawa_mri)
% change Yokogawa MRI(mm) coordinate to spm Right-hand coord.
% Vspm_right = vb_yokogawa_mri_to_spm_right(Vyokogawa_mri)
% --- Input
% Vyokogawa_mri : NV x 3 Yokogawa MRI(mm) coordinate
% --- Output
% Vspm_right : NV x 3 spm Right-hand voxcel coord
%
% --- Yokogawa MRI coordinate   
%
% [Right-hand coordinate]
% X: Right(191/2)   -> Left(-191/2) 
% Y: Front(256/2)   -> Back(-256/2)
% Z: Bottom(-256/2) -> Top(256/2) 
%
% --- SPM coordinate   
%
% [Right-hand coordinate]
% X: Left(-191/2)   -> Right(191/2) 
% Y: Back(-256/2)   -> Front(256/2)
% Z: Bottom(-256/2) -> Top(256/2) 
%
% written by M Osako  2006-06-14
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)



Vspm_right = Vyokogawa_mri/1000;
Vspm_right(:,1) = -Vspm_right(:,1);
Vspm_right(:,2) = -Vspm_right(:,2);

