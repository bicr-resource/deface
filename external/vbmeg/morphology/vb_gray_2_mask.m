function	PP = vb_gray_2_mask(Pimage,level)
% make mask image
% PP = vb_gray_2_mask(Pimage,level)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)
Dim = size(Pimage);
PP	= zeros(Dim);

ix	= find( Pimage >= level );
PP(ix) = 1;
