function	Bout = vb_erosion_3d_int(B, R)
% Erosion : Erase boundary points with radius R
% Use int8-type for MATLAB ver.7
%
% ��������Ⱦ�� R ����ζ�˵������
% ��������������Ф��Ƥ����˵������Ԥ�
%
% Bout  : Output mask pattern
% B     : 3D-�ޥ����ѥ����� (3D-mask pattern)
% B = 1 : ������ (interior point)
%   = 0 : ������ (outer point)
% R     : ��˵����Ⱦ�� (Radius of eraser)
%
% 2005-1-18  M. Sato 
% �������ޥ��������庸���岼��ư���������������������
% 
% 2005-7-2   M. Sato 
% Z�����˥롼�פ�󤷡�2D ���᡼�������򤹤�褦���ѹ�
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% �������ǡ������������
B = int8(B);

[N1,N2,N3] = size(B);

Bout = B;	% Output mask

% Make outer point mask (������)
% �������ǡ������������
Bo     = zeros(N1,N2,N3,'int8');
iz	   = find( B == 0 );
Bo(iz) = 1;

% neighbor index list
% (X-axis) ����������ǥå���
j1d = 1:(N1-1);
j1u = 2:N1;
% (Y-axis) ����������ǥå���
j2d = 1:(N2-1);
j2u = 2:N2;

% Make neighbor index within R
Rmax = ceil(R);
x	 = -Rmax:Rmax;

[x1, x2, x3 ] = ndgrid(x);

jx = find( (x1.^2 + x2.^2 +x3.^2 ) <= R^2 );
x1 = x1(jx);
x2 = x2(jx);
x3 = x3(jx);

NN   = length(jx);
N1N2 = N1*N2;

Bx = zeros(N1,N2, 'int8');	% (����������) inside boundary point mask

for zz = 1:N3
	
	Bx = zeros(N1,N2, 'int8');
	
	% �������ޥ��������庸���岼(26��˵������)��ư������
	
	Bx(j1d, : ) = Bx(j1d, : ) + B(j1u, : , zz );
	Bx(j1u, : ) = Bx(j1u, : ) + B(j1d, : , zz );
	Bx( : ,j2d) = Bx( : ,j2d) + B( : ,j2u, zz );
	Bx( : ,j2u) = Bx( : ,j2u) + B( : ,j2d, zz );
	
	if zz > 1,
		Bx = Bx + B(:,:,zz-1);
	end
	if zz < N3,
		Bx = Bx + B(:,:,zz+1);
	end
	
	% �������ޥ����ȳ������ޥ��������庸����ư��������ΤȤ���
	Bx = Bx.*Bo(:,:,zz);
	
	% ���������������
	iz = find( Bx > 0 );
	Nz = length(iz);
	
	% 2D-subscript of inner boundary point
	% ----- [j1,j2] = ind2sub([N1,N2], iz );
	j3  = zz;
	j2  = floor((iz-1)/N1)+1;
	j1  = rem((iz-1),N1)+1;
	
	% ���������� index
	k1 = zeros(Nz,1);
	k2 = zeros(Nz,1);
	
	for n=1:NN,
		% Make mask point subscript with fixed neighbor index
		k1 = j1 + x1(n);
		k2 = j2 + x2(n);
		k3 = j3 + x3(n);
	
		% Check index limit
		k1 = max(k1,1);
		k2 = max(k2,1);
		k3 = max(k3,1);
		
		k1 = min(k1,N1);
		k2 = min(k2,N2);
		k3 = min(k3,N3);
		
		% Delete neighbor points from mask
		%---- ind2sub ----
		inx = k1+ N1*(k2 - 1)+ N1N2*(k3 - 1);
		
		Bout(inx) = 0;
	end;
end
