function	xxf = vb_triangle_normal(V,F)
% normal vector of patch triangle
%  xxf = vb_triangle_normal(V,F)
%
% --- Input
% V : vertex of surface
% F : triangle patch index
% --- Output
% xxf  : normal vector of triangle
%
% Ver 1.0  by M. Sato  2004-2-10
%
% �����̤�ˡ����ĺ��ˡ���׻�
%  V(n, 1:3)  : ĺ���ΰ���
%  F(j, 1:3)  : �����̣�ĺ���Υ���ǥå���
%
% xxf : �����̤�ˡ���٥��ȥ�
% xxn : ĺ��ˡ�� = ĺ�������ܤ��뻰����ˡ����ʿ��
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);  	% ĺ����
Npatch = size(F,1);

% �����̣�ĺ���Υ���ǥå���
F1	 = F(:,1);
F2	 = F(:,2);
F3	 = F(:,3);

% �����̣�ĺ��
V1 = V(F1,:);
V2 = V(F2,:);
V3 = V(F3,:);

% �����̤�ˡ���٥��ȥ�
xxf = vb_cross2( V2 - V1, V3 - V1 );

% Normalization
xxs = sqrt(sum(xxf.^2,2));
xxs = max(xxs,eps);
xxf = xxf./xxs(:,ones(1,3));

