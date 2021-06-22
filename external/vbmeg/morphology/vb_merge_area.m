function	Iextract = vb_merge_area(Jarea, V)
% Merge area for 2D cortex surface
%  Iextract = vb_merge_area(Jarea, V)
% ʣ���ΰ�ι�ʻ
%
% Iextract : ������ĺ���ꥹ��
% Jarea{n} : ĺ���ꥹ��(���륢�쥤)
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NV	 = size(V,1); % Number of all vertex
NJ	 = size(Jarea,1);

flag = zeros(NV,1);

for n=1:NJ,
	indx	 = Jarea{n};

	% Include n-th area
	flag(indx) = 1;
end;

Iextract = find( flag > 0 );
