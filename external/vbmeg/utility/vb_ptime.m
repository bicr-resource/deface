function vb_ptime(T)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)
ehour = floor(T/3600);
emin  = floor((T-ehour*3600)/60);
esec  = floor( T - ehour*3600 - emin*60);
fprintf('ELAPSED : %d hours %d min. %d sec.\n', ehour,emin,esec );
