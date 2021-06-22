function	xxn = vb_vertex_normal(V,F,xxf)
% normal vector assigned for vertex
%  xxn = vb_vertex_normal(V,F,xxf)
%
% --- Input
% V : vertex of surface
% F : triangle patch index
% xxf  : normal vector of triangle
% --- Output
% xxn  : normal vector assigned for vertex
%
% Ver 1.0  by M. Sato  2004-2-10
%
% �����̤�ˡ����ĺ��ˡ���׻�
%  V(n, 1:3)  : ĺ���ΰ���
%  F(j, 1:3)  : �����̣�ĺ���Υ���ǥå���
% xxf : �����̤�ˡ���٥��ȥ�
% xxn : ĺ��ˡ�� = ĺ�������ܤ��뻰����ˡ����ʿ��
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);  	% ĺ����
Npatch = size(F,1);

% ĺ��ˡ�� = ĺ�������ܤ��뻰����ˡ����ʿ��
xxn   = zeros(Npoint,3);	

for n=1:Npatch,
    % �����̣�ĺ������ǥå���
	j1=F(n,1);
	j2=F(n,2);
	j3=F(n,3);
    
    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
end;

% ˡ����������
xxs = sqrt(sum(xxn.^2,2));
xxs = max(xxs,eps);
xxn = xxn./xxs(:,ones(1,3));
