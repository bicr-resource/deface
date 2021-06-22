function	Iextract = vb_close_area(Jarea, R, nextIX, nextDD)
% closing of cortical 2D-surface
%  Iextract = vb_close_area(Jarea, R, nextIX, nextDD)
% �������
% Iextract : ������ĺ���ꥹ��
% Jarea    : ĺ���ꥹ��
%   R      : ��˵����Ⱦ�� ( m )
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Iextract = vb_fat_area(Jarea, R, nextIX, nextDD);
Iextract = vb_cut_area(Iextract, R, nextIX, nextDD);

