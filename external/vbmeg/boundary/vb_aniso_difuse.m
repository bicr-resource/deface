function	v = vb_aniso_difuse(v,u,Nloop,c)
% anisotropic difusion
% v = vb_aniso_difuse(v,u,Nloop,c)
%
% 2005/2/5 M.Sato
%
% v : ʿ�경����ޥ����ѥ�����(�����Ƭ����)
% u : v ������ѥ�����(�������Ƭ��)
% Nloop : �Ȼ����
% c     : �Ȼ�����
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      �������Ȼ����¤ˤ�붭���̤�ʿ�경
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N1, N2, N3]=size(v);

siz=[N1 N2 N3];

% ����������ǥå����ꥹ�Ȥκ���

% West-East (X-axis) ����������ǥå���
jw = 1:(N1-1);
je = 2:N1;
% North-South (Y-axis) ����������ǥå���
jn = 1:(N2-1);
js = 2:N2;
% Up-Down (Z-axis) ����������ǥå���
jd = 1:(N3-1);
ju = 2:N3;

% 256x256x256���ϥ��꡼���顼�ˤʤ�
% ���ꥨ�顼���򤱤뤿�ᡢ2D-����׻��Υ롼�פˤ���
% 2D-����׻��Υ롼�פ�����3D-����׻�����®
vw = zeros(N1-1, N2, 1);
vn = zeros(N1, N2-1, 1);
vd = zeros(N1, 1, N3-1);

% �������Ȼ����¤ˤ�붭���̤�ʿ�경

for n=1:Nloop,
	for k=1:N3,
		% West-east 
		vw   = ( v(je,:,k) - v(jw,:,k) ).*( u(je,:,k) + u(jw,:,k) )*0.5;
		v(jw,:,k) = v(jw,:,k) + c*vw;
		v(je,:,k) = v(je,:,k) - c*vw;
		% North-south
		vn   = ( v(:,js,k) - v(:,jn,k) ).*( u(:,js,k) + u(:,jn,k) )*0.5;
		v(:,jn,k) = v(:,jn,k) + c*vn;
		v(:,js,k) = v(:,js,k) - c*vn;
	end;
		
		% Doun-up
	for k=1:N2,
		vd   = ( v(:,k,ju) - v(:,k,jd) ).*( u(:,k,ju) + u(:,k,jd) )*0.5;
		v(:,k,jd) = v(:,k,jd) + c*vd;
		v(:,k,ju) = v(:,k,ju) - c*vd;
	end;
	
end;	


