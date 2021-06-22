function	[V, F, xxn] = vb_surf_smooth(V,F,xx,Para)
% smoothing surface by spring model
%  [V_out, F_out, xx_out] = vb_surf_smooth(V, F, xx, Para)
%
%  V(n, 1:3)  : vertex on the surface
%  F(j, 1:3)  : patch index for surface
% xx(n, 1:3)  : normal vector at each vertex
% 
% Para.Nloop  : loop iteration number
% Para.tangent_rate : coefficient of spring force
% Para.normal_mode = 0: force = spring force
% Para.normal_mode = 1: force = spring force + compensatory expansion force 
% --------------------------------------------------
% �ݥꥴ���ǥ��Х��Ϥˤ��ʿ�경��Ԥ�
%
%  V(n, 1:3)  : ĺ���ΰ���
%  F(j, 1:3)  : �����̣�ĺ���Υ���ǥå���
% xx(n, 1:3)  : ĺ����ˡ������(nx,ny,nz)
% 
% Para.Nloop  : �����֤����
% Para.tangent_rate : ���������Ϸ���
% Para.normal_mode = 0: ʿ�경�Х���
% Para.normal_mode = 1: ʿ�경�Х��� + ʿ��Ⱦ�¤��ݤ�ˡ�������� (default)
%
% ʿ�경�Х��� =  tangent_rate * (��˵����ʿ�Ѻ�ɸ�Ȥκ�)
%
% Ver 1.0  by M. Sato  2004-2-10
% modefied M. Sato 2006-10-15
% modefied M. Sato 2010-10-3
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% normal_mode = 0: ʿ�경�Х���
% normal_mode = 1: ʿ�경�Х��� + ʿ��Ⱦ�¤��ݤ�ˡ��������
normal_mode = 1;

if ~exist('Para','var'), Para = []; end
if ~isfield(Para,'Nloop'), Para.Nloop = 50; end
if ~isfield(Para,'tangent_rate'), Para.tangent_rate = 0.3; end
if isfield(Para,'normal_mode'), normal_mode = Para.normal_mode; end;

tangent_rate = Para.tangent_rate;

Nloop  = Para.Nloop;

Npoint = size(V,1);  		% number of dipoles
Npatch = size(F,1);  		% number of patch

% ������ĺ���٥��ȥ�
V1  = zeros(Npatch,3);
V2  = zeros(Npatch,3);
V3  = zeros(Npatch,3);
% ������ĺ���κ�ʬ�٥��ȥ�
VV1 = zeros(Npatch,3);
VV2 = zeros(Npatch,3);
VV3 = zeros(Npatch,3);

% ĺ����ʬ�٥��ȥ�
fd   = zeros(Npoint,3);
% ��ĺ���ζ�˵����
Nv   = zeros(Npoint,1);
% ĺ����ʬ�٥��ȥ��ˡ��������
nnf  = zeros(Npoint,1);

% �����̣�ĺ���Υ���ǥå���
F1	 = F(:,1);
F2	 = F(:,2);
F3	 = F(:,3);

% �����̤�ˡ���٥��ȥ�
xxf  = vb_cross2( V(F2,:)-V(F1,:) , V(F3,:)-V(F1,:) );

% �����̣�ĺ����ˡ���٥��ȥ�ʿ��
xxk  = xx(F1,:)+xx(F2,:)+xx(F3,:);

xdot = sum( xxk .* xxf ,2);
ix	 = find(sign(xdot) < 0 );

% �����̤�ˡ���٥��ȥ��
% ĺ����ˡ���٥��ȥ� 'xx' (������)�θ����򤽤���
F(ix,2) = F3(ix);
F(ix,3) = F2(ix);

F2		= F(:,2);
F3		= F(:,3);

% ��ĺ���ζ�˵����
for n=1:Npatch,
	inx = F(n,:)';
	Nv(inx) = Nv(inx) + 2; 
end;

% ʿ�경�Х��ϡܳ�������

for i=1:Nloop,

    % �����̣�ĺ��
    V1=V(F1,:);
    V2=V(F2,:);
    V3=V(F3,:);
    
    % �����̤�ˡ���٥��ȥ�
    xxf   = vb_cross2( V2 - V1, V3 - V1 );

    % Normalization
    xxf   = vb_repmultiply(xxf, 1./sqrt(sum(xxf.^2,2)));
    
	% �����̳�ĺ���κ�ʬ�٥��ȥ�
    VV1   = V2 + V3 - 2*V1;
    VV2   = V3 + V1 - 2*V2;
    VV3   = V1 + V2 - 2*V3;

	% ĺ��ˡ�� = ĺ�������ܤ��뻰����ˡ����ʿ��
	xxn   = zeros(Npoint,3);	
	% ĺ����ʬ�٥��ȥ�(��˵��)
    fd	  = zeros(Npoint,3);
	
	for n=1:Npatch,
	    % �����̣�ĺ������ǥå���
		j1=F1(n);
		j2=F2(n);
		j3=F3(n);
	    
	    % �����̤�ˡ���٥��ȥ����
	    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
	    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
	    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
	    
		% ĺ����ʬ�٥��ȥ�(��˵��)
	    fd(j1,:) = fd(j1,:) + VV1(n,:); 
	    fd(j2,:) = fd(j2,:) + VV2(n,:); 
	    fd(j3,:) = fd(j3,:) + VV3(n,:); 
    end;

    % ˡ����������
    xxn = vb_repmultiply(xxn, 1./sqrt(sum(xxn.^2,2)));

    % ��˵������������
    fd  = vb_repmultiply(fd, 1./Nv);
    
    % �������Ѳ��٥��ȥ��ˡ�������ͱ�ʿ��
    ds  = mean( sum(fd .* xxn, 2) );
    % dd  = mean( sqrt(sum(fd .^2, 2)) ) % mean displacement
    
    if normal_mode==1
    	% ʿ�경�Х��� + ʿ��Ⱦ�¤��ݤ�ˡ��������
    	V  = V + tangent_rate * (fd - ds*xxn);
    else
    	% ʿ�경�Х��� 
    	V  = V + tangent_rate * fd ;
    end
end

if nargout < 3, return; end;

% �����̣�ĺ��
V1=V(F1,:);
V2=V(F2,:);
V3=V(F3,:);

% �����̤�ˡ���٥��ȥ�
xxf   = vb_cross2( V2 - V1, V3 - V1 );

% Normalization
xxf   = vb_repmultiply(xxf, 1./sqrt(sum(xxf.^2,2)));

% ĺ��ˡ�� = ĺ�������ܤ��뻰����ˡ����ʿ��
xxn   = zeros(Npoint,3);	

for n=1:Npatch,
    % �����̣�ĺ������ǥå���
	j1=F1(n);
	j2=F2(n);
	j3=F3(n);
    
    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
end;

% ˡ����������
xxn = vb_repmultiply(xxn, 1./sqrt(sum(xxn.^2,2)));
