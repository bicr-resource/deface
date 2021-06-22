function	B = vb_dipole_gradio(V,J,pick, Qpick, Wsensor)
% Magnetic field of Gradiometer 
%   B = vb_dipole_gradio(V,J,pick, Qpick, Wsensor)
% --- INPUT
%   Dipole current source
%     V  : current dipole position   ( NP x 3 )
%     J  : current dipole moment     ( NP x 3 )
%   MEG sensor
%  pick(n,1:3) : n-th coil position   [m]
% Qpick(n,1:3) : n-th coil direction 
% Wsensor(m,n) = n-th coil weight for m-th channel
%    basis(channel,dipole) = Wsensor * basis(coil,dipole)
% --- OUTPUT
%   B : Lead field matrix          ( NP x Nch )
%
%   NP  : # of dipole points
%   Nch : # of MEG sensor channel
%
% ÁÐ¶Ë»Ò¼§¾ìº¹Ê¬·×»»
% V ¤ÎÁÐ¶Ë»Ò J ¤¬ ´ÑÂ¬ÅÀ pick1 ¤È pick2 ¤Ëºî¤ë¼§¾ì¤Îº¹Ê¬¤Î Q Êý¸þ¼Í±Æ
%
%  Ver-2.0 2007-2-22 Made by M. Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)


B   = vb_dipole_magnetic(V, J, pick, Qpick );
% B : Lead field matrix          ( dipole x coil )

B = B * Wsensor';

%B   = vb_dipole_magnetic(V, J, pick1, pickv ) ...
%	- vb_dipole_magnetic(V, J, pick2, pickv );
