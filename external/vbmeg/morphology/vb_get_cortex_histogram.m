function [hst, x] = vb_get_cortex_histogram(fname,fana,Nbin)
% Get image intensity histogram
%  [hst, x] = vb_get_cortex_histogram(fname,fana)
% --- Input
% fname = brain mask file
% fana  = analyze file
% --- Output
% hst : histogram of image intensity in brain region
% x   : intensity list corresponding to hst
%
% 2007/06/15 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%% Label value
%  1 = brain (CSF)
%  2 = Gray
%  3 = White
%  4 = Cerebellum
%  5 = Brainstem

if ~exist('Nbin','var'), Nbin = 50; end;

load(fname, 'avw', 'XYZspm');

B = avw.img;

% Index for background region other than gray & white 
ix = find( B(:)~=2 & B(:)~=3);

% Load subject MRI image
[B, Vdim, Vsize] = vb_load_analyze_to_right(fana);

% Remove background
B(ix) = 0;

% voxel larger than threshold
ix = find( B(:) > 0 );

B = B(ix);

[hst, x] = hist(B, Nbin);
