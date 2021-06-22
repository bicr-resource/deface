function [V,F,xx,Vinfo,indx] = vb_get_cortex_surf_from_std(std_brain_file,snfile)
% Transform standard brain model to an individual brain 
% -- Usage
% [V,F,xx,Vinfo] = vb_get_cortex_surf_from_std(std_brain_file,snfile)
%  
%%% --- Required Parameter
% std_brain_file : Standard brain model file (.brain.mat)
% snfile : coordinate transform file for coregistration to standard brain
%
% Masa-aki Sato 2009-9-30
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[V,F,xx] = vb_load_cortex(std_brain_file);

% Convert to subject SPM-right coordinate
if nargin==2 && ~isempty(snfile)
	sn = load(deblank(snfile)); 
	V = vb_unsn( V'*1000, sn)'*0.001;  
end

NP = size(V,1);
NL = F.NdipoleL;

% Left/Right hemisphere normal vector
normal_mode = 0;
[F1, V1, xx1, indx1] = vb_out_normal_surf(F.F3L,V(1:NL,:), normal_mode);
[F2, V2, xx2, indx2] = vb_out_normal_surf(F.F3R - NL,V(NL+1:end,:), normal_mode);

omega1  = vb_solid_angle_check(V1,F1);
omega2  = vb_solid_angle_check(V2,F2);

fprintf('omegaL/4pi = %e\n',omega1);
fprintf('omegaR/4pi = %e\n',omega2);

V  = [V1 ; V2];
xx = [xx1; xx2];
indx = [indx1; indx2 + NL];
NL = size(V1,1);

Ndipole = size(V,1);

fprintf('Original Vertex = %d , New = %d\n',NP, Ndipole)
fprintf('Original Left Vertex = %d , New = %d\n',F.NdipoleL, NL)

% Left/Right hemisphere patch
F.F3L = F1;
F.F3R = F2 + NL;
F.F3  = [F.F3L ; F.F3R];
F.NdipoleL = NL;

% Dimensional info
Vinfo.NdipoleL  = NL ;
Vinfo.Ndipole   = Ndipole;
Vinfo.Npatch    = size(F,1);
Vinfo.Coord     = 'SPM_Right_m';

return


% SPM Standard brain cortex in MNI-mm coordinate (origin in MNI-space)
load(std_brain_file,'vert','face','normal')

sn = load(deblank(snfile)); 

% Convert to subject SPM-right coordinate
V = vb_unsn( vert', sn)'*0.001;  

[V,F,xx] = vb_separate_LR_cortex(V,face);
