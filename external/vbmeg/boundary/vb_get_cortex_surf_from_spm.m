function [V,F,xx] = vb_get_cortex_surf_from_spm(brainfile,snfile)
% Transform standard brain model to an individual brain 
% -- Usage
% [V,F,xx] = vb_get_cortex_surf_from_std(brainfile,snfile)
%  
%%% --- Required Parameter
% brainfile : Brain model file (.brain.mat)
% snfile
%
% Masa-aki Sato 2009-9-30
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% SPM Standard brain cortex in MNI-mm coordinate (origin in MNI-space)
load(brainfile,'vert','face','normal')

sn = load(deblank(snfile)); 

% Convert to subject SPM-right coordinate
V = vb_unsn( vert', sn)'*0.001;  

[V,F,xx] = vb_separate_LR_cortex(V,face);
