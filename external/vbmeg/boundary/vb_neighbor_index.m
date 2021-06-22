function	xxF = vb_neighbor_index(V,F)
% nearest neighbor index of each vertex
%  xxF = vb_neighbor_index(V,F)
% --- Input
% V : vertex of surface
% F : patch index
% --- Output
% xxF{n} : neighboring vertex index of n-th vertex
%        = [ 2nd-vertex of j-th patch, 3rd-vertex of j-th patch, j]
%          [(# of patch connected to n-th vertex) x 3]
% Ver 1.0  by M. Sato  2004-2-10
%
% xxF{n} : ĺ�� n �����ܤ����̤�ĺ���ֹ�����ֹ�
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);  		% ĺ����
Npatch = size(F,1);  		% �����̿�
xxF    = cell(Npoint,1); 	% ����ĺ������ǥå����ꥹ��

% �����̤˴ؤ���롼��
for j=1:Npatch,
    % �����̤�ĺ������ǥå���
    k1 = F(j,1); 
    k2 = F(j,2); 
    k3 = F(j,3); 
    
    % ��ĺ�����������ꥹ�Ȥ�¾��ĺ�������ֹ��ä���
	xxF{k1} = [ xxF{k1} ; k2 , k3 ,j];
	xxF{k2} = [ xxF{k2} ; k3 , k1 ,j];
	xxF{k3} = [ xxF{k3} ; k1 , k2 ,j];
end;
