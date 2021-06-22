function	[Fnew, Vnew, Vmiss, Fmiss] = vb_get_disconect_surf(F,V)
% get disconnect surface
%  [Fnew, Vnew, Vmiss, Fmiss] = vb_get_disconect_surf(F,V)
% V から 連結している頂点を取り出す
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[Fnew, Vnew, xx, Vmiss, Fmiss] = vb_out_normal(F,V);

% # of disconnected vertex
Nmiss = size(Vmiss,1);
fprintf('# of disconnected vertex = %d\n', Nmiss) 
% 閉局面のチェック: omega = 1
omega  = vb_solid_angle_check(Vnew,Fnew);
fprintf('Closed surface index (=1) for eye : %f\n', omega)
