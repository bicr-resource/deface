function V = vb_flood_fill_3d(V,indx,fillval,level)
% flood_fill
%  V = vb_flood_fill_3d(V,indx,fillval,level)
% ����'level'��꾮�����ͤ���ĥܥ������'fillval'���ɤ�Ĥ֤�
% 
% V    = 3D ���᡼��
% V(x,y,z) : ��(x,y,z)�ˤ�������
%
% indx = [xc,yc,zc] ����롼�ȥ���ǥå���
% fillval: �ɤ�Ĥ֤��� > level
% level  : ����
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Vflag  : �ɤ�Ĥ֤��줿�ܥ�����Υޥ����ѥ�����

[NX,NY,NZ] = size(V);

xc = indx(1);
yc = indx(2);
zc = indx(3);

% Vflag0: �ɤ�Ĥ֤��줿�ܥ������ 2D �ޥ����ѥ�����
[V(:,:,zc), Vflg0] = vb_flood_fill_2d(V(:,:,zc),[xc yc],fillval,level);

Vflg = Vflg0;

for n=(zc+1):NZ
	% z = (n-1) ���ɤ�Ĥ֤��줿�ѥ��������Ф�
	ix = find( Vflg > 0);

	% z = n �Ǥ��ɤ�Ĥ֤����ν����
	% [i,j] = ind2sub([NX,NY],ix) �ι�®�׻�
	j  = floor((ix-1)/NX)+1;
	i  = rem((ix-1),NX)+1;

	% 2D �ɤ�Ĥ֤�
	[V(:,:,n), Vflg] = vb_flood_fill_2d(V(:,:,n),[i,j],fillval,level);
end

Vflg = Vflg0;

for n=(zc-1):-1:1
	% z = (n+1) ���ɤ�Ĥ֤��줿�ѥ���������
	ix = find( Vflg > 0);

	% z = n �Ǥ��ɤ�Ĥ֤����ν����
	% [i,j] = ind2sub([NX,NY],ix) �ι�®�׻�
	j  = floor((ix-1)/NX)+1;
	i  = rem((ix-1),NX)+1;

	% 2D �ɤ�Ĥ֤�
	[V(:,:,n), Vflg] = vb_flood_fill_2d(V(:,:,n),[i,j],fillval,level);
end
