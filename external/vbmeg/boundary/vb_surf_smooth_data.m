function	[V, F, xxn] = vb_surf_smooth_data(V,F,xx,vg,Para)
% smoothing surface by spring model and 3D-image data
%  [V, F, xxn] = vb_surf_smooth_data(V,F,xx,vg,Para)
%
% Ver 1.0  by M. Sato  2004-2-10
%
% �ݥꥴ���ǥ��ޥ����ѥ�����ζ����̤��Ĥ�ޤ�
% �Х��Ϥˤ��ʿ�경��Ԥ�
% ʿ�경�Х��ϡܳ�������(��¦)���������(��¦)
%
%  V(n, 1:3)  : ĺ���ΰ���
%  F(j, 1:3)  : �����̣�ĺ���Υ���ǥå���
% xx(n, 1:3)  : ĺ����ˡ������(nx,ny,nz)
% xxn(n, 1:3) : ĺ����ˡ������(nx,ny,nz)
% vg(NX,NY,NZ): 3D-�ܥ����롦�ޥ����ѥ�����
%
% Para.tangent_rate         : ���������Ϸ���
% Para.tangent_normal_ratio : ˡ�������Ϸ���
% Para.mask_ratio           : ���������Ϸ��� ( ����>����:������)
% Para.mask_threshold       : ������������   ( ����<����:�����)
% Para.vsize                : �ܥ����륵����
% Para.normal_subtract;
% Para.Nloop
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

c1	   = Para.tangent_rate;
c2	   = Para.tangent_rate*Para.tangent_normal_ratio;
c3	   = Para.normal_subtract;
c4	   = Para.mask_ratio;
g0	   = Para.mask_threshold;

Nloop  = Para.Nloop;
Ndisp  = Para.Ndisp;
cmode  = Para.cmode;
vangle = Para.vangle;
NX	   = Para.NX;
NY	   = Para.NY;
nfig   = 1;

Npoint = size(V,1);  		% number of dipoles
Npatch = size(F,1);  		% number of patch
gsize  = size(vg);

% �����̤�ˡ���٥��ȥ�
xxf  = zeros(Npatch,3);
% ����������
nns  = zeros(Npatch,1);
% ������ĺ���κ�ʬ�٥��ȥ�
VV1  = zeros(Npatch,3);
VV2  = zeros(Npatch,3);
VV3  = zeros(Npatch,3);

% ĺ��ˡ�� = ĺ�������ܤ��뻰����ˡ����ʿ��
xxn  = zeros(Npoint,3);	
xxs  = zeros(Npoint,1);
% ĺ����ʬ�٥��ȥ�
fd   = zeros(Npoint,3);
% ��ĺ���ζ�˵����
Nv   = zeros(Npoint,1);
% ĺ����ʬ�٥��ȥ��ˡ��������
nnf  = zeros(Npoint,1);
% ������������
ft	 = zeros(Npoint,3);
% ˡ����������
fn	 = zeros(Npoint,3);
% ������(��¦)�������(��¦)����
fg	 = zeros(Npoint,3);

% V ��ɸ�Υܥ����륤��ǥå���
jv	 = zeros(Npoint,3);
jj	 = zeros(Npoint,1);
% ��¦�ޥ�������
gg	 = zeros(Npoint,1);

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

% �Х���ʿ�경�ܳ�������(��¦)���������(��¦)

for i=1:Nloop,

    % �����̣�ĺ��
    V1=V(F1,:);
    V2=V(F2,:);
    V3=V(F3,:);
    
    % �����̤�ˡ���٥��ȥ�
    xxf   = vb_cross2( V2 - V1, V3 - V1 );

    % Normalization
    nns   = sqrt(sum(xxf.^2,2));
    xxf   = xxf./nns(:,ones(1,3));		
    
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
	    
	    xxn(j1,:) = xxn(j1,:) + xxf(n,:);
	    xxn(j2,:) = xxn(j2,:) + xxf(n,:);
	    xxn(j3,:) = xxn(j3,:) + xxf(n,:);
	    
		% ĺ����ʬ�٥��ȥ�(��˵��)
	    fd(j1,:) = fd(j1,:) + VV1(n,:); 
	    fd(j2,:) = fd(j2,:) + VV2(n,:); 
	    fd(j3,:) = fd(j3,:) + VV3(n,:); 
    end;
    
    % ˡ����������
    xxs   = sqrt(sum(xxn.^2,2));
    xxn   = xxn./xxs(:,ones(1,3));

    % ��˵������������
    fd	 = fd./Nv(:,ones(1,3));

	% ĺ����ʬ�٥��ȥ��ˡ��������
    nnf  = sum(xxn.*fd,2);
    
    % ĺ����ʬ�٥��ȥ��ˡ���ͱ�
    fn   = xxn.*nnf(:,ones(1,3));
    
    % ĺ����ʬ�٥��ȥ�������ͱ�
    % DEBUG
    ft  = fd - fn; 
    % DEBUG
    
	% ˡ��������ʿ���Ϥ����
    fns = sum(fn,1)/Npoint;
    
    % V ��ɸ��ܥ����륤��ǥå������Ѵ�
    jv	= floor(V)+1;
    jj	= sub2ind(gsize,jv(:,1),jv(:,2),jv(:,3));

    % ��¦�ޥ�������
    gg	= tanh(vg(jj)-g0);

    fg	= xxn.*gg(:,ones(1,3));
    
    V	= V + c1*ft + c2*(fn - c3*fns(ones(Npoint,1),:)) + c4*fg;

	if rem(i,Ndisp)==0,
		subplot(NY,NX,nfig); nfig=nfig+1;
		vb_plot_head_V(V,F,cmode);
		view(vangle);
		tlabel = sprintf('Iteration = %d',i);
		title(tlabel);
		axis equal
	end;
end

