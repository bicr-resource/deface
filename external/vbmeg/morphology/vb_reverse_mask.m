function	PP = vb_reverse_mask(Pimage,level)
% reverse mask pattern
% B = vb_reverse_mask(Bin, level)
% --- Input
% Bin   : image data
% level : threshold
% --- Output
% B = 0 for Bin >  level
%   = 1 for Bin <= level
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Dim = size(Pimage);
PP	= zeros(Dim);

ix	= find( Pimage <= level);
PP(ix) = 1;
