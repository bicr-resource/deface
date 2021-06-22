function	[xyz,F] = vb_get_boundary_mesh(v,vlevel)
% get boundary surface of mask image
%  [xyz,F] = vb_get_boundary_mesh(v,vlevel)
% �ޥ��������̤����
%    v       : 3D-�ܥ������Υޥ������᡼��
%   vlevel   : ����
%
%   xyz      : ��������ɸ
%   F        : �����̥���ǥå���
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 2, vlevel = 0.5; end;

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

% Boundary lattice flag
vb = zeros(N1+1, N2+1, N3+1);
vx = zeros(N1+1, N2+1, N3+1);
vy = zeros(N1+1, N2+1, N3+1);
vz = zeros(N1+1, N2+1, N3+1);

F =[];
% 256x256x256���ϥ��꡼���顼�ˤʤ�
% ���ꥨ�顼���򤱤뤿�ᡢ2D-����׻��Υ롼�פˤ���
% 2D-����׻��Υ롼�פ�����3D-����׻�����®
vw = zeros(N1+1, N2+1, 1);
vn = zeros(N1+1, N2+1, 1);
vd = zeros(N1+1,    1, N3+1);

% Extract boundary points

for n=1:N3,
	% West-East (X-axis) ���������
	iw			= find( (v(jw,:,n)-vlevel) .* (v(je,:,n)-vlevel) <= 0 );
	
	if ~isempty(iw),
		% 2D-subscript of boundary point
		[j1,j2,j3]	= ind2sub([N1-1,N2,1], iw );
		jw1			= sub2ind([N1+1,N2+1], j1+1,j2  );
		jw2			= sub2ind([N1+1,N2+1], j1+1,j2+1);
		vw			= zeros(N1+1, N2+1, 1);
		% boundary surface base point for Y-Z plane
		vw(jw1)		= 1;
		vx(:,:,n)	= vx(:,:,n) + vw;
		% boundary lattice point
		vw(jw2)		= vw(jw2) + 1;
		vb(:,:,n)	= vb(:,:,n)   + vw;
		vb(:,:,n+1) = vb(:,:,n+1) + vw;
	end;
	
	% North-South (Y-axis) ���������
	iw		   = find( (v(:,jn,n)-vlevel) .* (v(:,js,n)-vlevel) <= 0 );
	
	if ~isempty(iw),
		% 2D-subscript of boundary point
		[j1,j2,j3]	= ind2sub([N1,N2-1,1], iw );
		jw1			= sub2ind([N1+1,N2+1], j1,  j2+1);
		jw2			= sub2ind([N1+1,N2+1], j1+1,j2+1);
		vw			= zeros(N1+1, N2+1, 1);
		% boundary surface base point for Z-X plane
		vw(jw1)		= 1;
		vy(:,:,n)	= vy(:,:,n) + vw;
		% boundary lattice point
		vw(jw2)		= vw(jw2) + 1;
		vb(:,:,n)	= vb(:,:,n)   + vw;
		vb(:,:,n+1) = vb(:,:,n+1) + vw;
	end;
end;

for n=1:N2,
	% Up-Down (Z-axis) ���������
	id		   = find( (v(:,n,jd)-vlevel) .* (v(:,n,ju)-vlevel) <= 0 );
	
	if ~isempty(id),
		% 2D-subscript of boundary point
		[j1,j2,j3]	= ind2sub([N1, 1, N3-1], id );
		j2(:)		= 1;
		jw1			= sub2ind([N1+1,1,N3+1], j1,  j2,j3+1);
		jw2			= sub2ind([N1+1,1,N3+1], j1+1,j2,j3+1);
		% boundary surface base point for X-Y plane
		vd			= zeros(N1+1,1,N3+1);
		vd(jw1)		= 1;
		vz(:,n,:)	= vz(:,n,:) + vd;
		% boundary lattice point
		vd(jw2)		= vd(jw2) + 1;
		vb(:,n  ,:)	= vb(:,n  ,:) + vd;
		vb(:,n+1,:) = vb(:,n+1,:) + vd;
	end;
end;

% Make triangle index 

% Boundary lattice points
ix	   = find( vb > 0 );
NB	   = length(ix);

% index transformation table
vb(ix) = 1:NB;

% Boundary lattice point coordinate
[kx,ky,kz] = ind2sub([N1+1, N2+1, N3+1], ix );

xyz=[kx-1 ,ky-1 ,kz-1 ];

% West-East (X-axis) ���ܶ���
iw	= find( vx > 0 );
% 3D-subscript of boundary surface base point
[j1,j2,j3]	= ind2sub([N1+1, N2+1, N3+1], iw );

% other corner points in the square
jw1			= sub2ind([N1+1,N2+1,N3+1], j1,j2+1,j3  );
jw2			= sub2ind([N1+1,N2+1,N3+1], j1,j2  ,j3+1);
jw3			= sub2ind([N1+1,N2+1,N3+1], j1,j2+1,j3+1);

% add triangle index
F=[F; vb(iw),vb(jw1),vb(jw2) ; vb(jw1),vb(jw2),vb(jw3)];

% North-South (Y-axis) ���ܶ���
iw	= find( vy > 0 );
% 3D-subscript of boundary surface base point
[j1,j2,j3]	= ind2sub([N1+1, N2+1, N3+1], iw );

% other corner points in the square
jw1			= sub2ind([N1+1,N2+1,N3+1], j1+1,j2,j3  );
jw2			= sub2ind([N1+1,N2+1,N3+1], j1  ,j2,j3+1);
jw3			= sub2ind([N1+1,N2+1,N3+1], j1+1,j2,j3+1);

% add triangle index
F=[F; vb(iw),vb(jw1),vb(jw2) ; vb(jw1),vb(jw2),vb(jw3)];

% Up-Down (Z-axis) ���ܶ���
iw	= find( vz > 0 );
% 3D-subscript of boundary surface base point
[j1,j2,j3]	= ind2sub([N1+1, N2+1, N3+1], iw );

% other corner points in the square
jw1			= sub2ind([N1+1,N2+1,N3+1], j1+1,j2  ,j3);
jw2			= sub2ind([N1+1,N2+1,N3+1], j1  ,j2+1,j3);
jw3			= sub2ind([N1+1,N2+1,N3+1], j1+1,j2+1,j3);

% add triangle index
F=[F; vb(iw),vb(jw1),vb(jw2) ; vb(jw1),vb(jw2),vb(jw3)];
