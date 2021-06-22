function	[xxn ,F] = vb_out_normal_vect(V,F)
% normal vector
%  [xxn ,F] = vb_out_normal_vect(V,F)
% --- Input
% V : vertex of surface
% F : patch index
% --- Output
% xxn : normal vector
% F : patch index
%
%
% Ver 1.0  by M. Sato  2004-2-10
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%
%------  �����̤�ˡ���׻� -------
%
Nnew = size(V,1);

% �����̤�ˡ���׻�
xxf  = vb_triangle_normal(V,F);
% ĺ����ˡ���׻�
xxn  = vb_vertex_normal(V,F,xxf);

% �����νſ����濴�ˤ������γ������٥��ȥ�
Vsum = sum(V ,1)/Nnew;
Vc	 = V-Vsum(ones(Nnew,1),:);
% �����νſ����濴�ˤ������γƻ����̤νſ�
Vxx  = (Vc(F(:,1),:) + Vc(F(:,2),:) + Vc(F(:,3),:))/3;

% �������٥��ȥ��Ʊ��������ˡ���ο�
Nsum = sum( sum(xxf.*Vxx ,2) > 0 );

% �����̿�
Npatch = size(F,1);  	

% ˡ���θ������������ȵդξ���ˡ���θ�����դˤ���
if Nsum < (Npatch/2),
	xxn    = - xxn;
	F2	   = F(:,2);
	F(:,2) = F(:,3);
	F(:,3) = F2;
end;

return
