function	[V,F] = vb_trans_index(V,FF,indx)
% Select vertex and patch from surface
%    [V,F] = vb_trans_index(V,FF,indx)
% --- Input
% V  : vertex of surface
% FF : patch index
% indx : index of selected vertex
% --- Output
% V : selected vertex
% F : patch index which include selected vertex
%
% Ver 1.0  by M. Sato  2004-2-10
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%
%------ 3�ѷ��ֹ�򿷤���ĺ��������б�����褦���Ѵ� -------
%
Npoint = size(V,1);  	% ĺ����
Nnew = length(indx);
V	 = V(indx,:);

% ��ĺ���ֹ椫�鿷����ĺ���ֹ���Ѵ������Ѵ�ɽ
% Itrans(i)=0 : ��ĺ���ֹ� = i �Ͽ�����ĺ���˴ޤޤ�ʤ�
% Itrans(i)=j : ��ĺ���ֹ� = i �Ͽ�����ĺ�� = j ���б�
Itrans		 = zeros(Npoint,1);
Itrans(indx) = 1:Nnew;

% 3�ѷ��ֹ�򿷤���ĺ��������б�����褦���Ѵ�
% 3�ѷ������Ƥ�ĺ����������ĺ���˴ޤޤ��3�ѷ���õ��
FF	= Itrans(FF);
ixF = find(prod(FF ,2) ~= 0 );
F   = FF(ixF,:);

return
