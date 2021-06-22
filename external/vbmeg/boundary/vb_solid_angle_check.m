function omega  = vb_solid_angle_check(V,F)
% total solid angle for surface
%   omega  = vb_solid_angle_check(V,F)
% omega : �ſ����鸫�������̤�Ω�γ����� / (4*pi)
%         �Ķ��̤��Ф��Ƥ� omega = 1 �Ȥʤ�٤�
% V     : ���������̤�ĺ����ɸ
% F     : ����������ĺ������ǥå���
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% �����̤ο���Number of triangle patch
NF	= size(F,1);
NV	= size(V,1);

% �����̤�ĺ����triangle vertex
x1	= V(F(:,1),:);
x2	= V(F(:,2),:);
x3	= V(F(:,3),:);

% �ſ���ɸ
x0	= sum(V,1)/NV;
xn	= x0( ones(NF,1) ,:);

% xn ���鸫��������ĺ���٥��ȥ롡triangle vector
xa	= x1 - xn;
xb	= x2 - xn;
xc	= x3 - xn;

% Ω�γѷ׻�
abc	= sum(xa.*vb_cross2(xb,xc), 2);

ra	= sqrt(sum(xa.^2,2));
rb	= sqrt(sum(xb.^2,2));
rc	= sqrt(sum(xc.^2,2));

ya	= sum(xb.*xc,2);
yb	= sum(xc.*xa,2);
yc	= sum(xa.*xb,2);

% Ω�γ�����
omega = sum(atan(abc./(ra.*rb.*rc + ra.*ya + rb.*yb + rc.*yc)));
omega = omega/(2*pi);
