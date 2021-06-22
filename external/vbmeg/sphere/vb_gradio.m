function b=vb_gradio( r1, r2, rd, q )
% vb_gradio : Rev.1.0, 2001-11-17
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)


b = sarvas( r1, rd, q ) - sarvas( r2, rd, q );
