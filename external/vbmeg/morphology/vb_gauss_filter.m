function	xxP = vb_gauss_filter(parm,Rradius,Rmax,xxP,Iextract)
% Gauss filtering of fMRI activity
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

CW = vb_smooth_filter_norm(parm,Rradius,Rmax,Iextract);

xxP = CW*xxP;

