function	Iextract = vb_fat_area(Jarea, R, nextIX, nextDD)
% Dilation according to surface-distance
%  Iextract = vb_fat_area(Jarea, R, nextIX, nextDD)
% Ⱦ�� R ����ζ�˵����ꥹ�Ȥ˲ä���
%
% Iextract : ������ĺ���ꥹ��
% Jarea    : ĺ���ꥹ��
%   R      : õ�������˵����Ⱦ�� ( m )
%
% nextIX{i} : ��-i �ζ�˵���Υ���ǥå����ꥹ��
% nextDD{i} : ��-i �ȶ�˵��������˱�ä���Υ
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NV	 = size(nextIX,1); % Number of all vertex
NJ	 = length(Jarea);

flag = zeros(NV,1);

flag(Jarea) = 1;

for n=1:NJ,
	i	 = Jarea(n);
	dd0  = nextDD{i};

	% Find neighbor index within R
	inx  = find( dd0 <= R );	
	indx = nextIX{i}(inx);

	% Include neighbor point	
	flag(indx) = 1;
end;

Iextract = find( flag > 0 );
