function	B = vb_closing_2d(B, R1, R2)
% ∑Í§ÚÀ‰§·§Î
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)


if nargin < 3, R2 = R1; end;

B = vb_dilation_2d(B, R1 );
B = vb_erosion_2d( B, R2 );

