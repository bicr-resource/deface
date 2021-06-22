function	[V, F, xxn] = vb_surf_smooth_fit(V,F,xx,B,Para)
% Fit surface to the boundary of the mask
%  [V, F, xx] = vb_surf_smooth_fit(V,F,xx,B,Para)
% --- Input
%  V(n, 1:3)  : vertex
%  F(j, 1:3)  : patch index
% xx(n, 1:3)  : normal vector
% B(NX,NY,NZ) : mask image : inside of surface is filled out
%               surface is expanded to fit to the boundary of mask region
% Para.Nloop  : iteration number
% Para.tangent_rate   : spring constant
% Para.mask_ratio     : mask image force constant
% Para.mask_threshold : mask threthold
%
% --- Output
%  V(n, 1:3)  : vertex
%  F(j, 1:3)  : patch index
% xx(n, 1:3)  : normal vector
% --- Mehod
% �ݥꥴ���ǥ��ޥ����ѥ�����ζ����̤���ĥ���Х��Ϥˤ��ʿ�경��Ԥ�
%
%  V(n, 1:3)  : ĺ���ΰ���
%  F(j, 1:3)  : �����̣�ĺ���Υ���ǥå���
% xx(n, 1:3)  : ĺ���ν��ˡ������(nx,ny,nz)
% xxn(n, 1:3) : ĺ���κǽ�ˡ������(nx,ny,nz)
% B(NX,NY,NZ) : 3D-�ܥ����롦�ޥ����ѥ�����
%
% Para.Nloop  : �����֤����
% Para.vstep  : �ܥ����륵����
%
% Para.tangent_rate   : �ХͶ���
% Para.mask_ratio     : �ޥ��������Ϸ��� ( ����>����:������)
% Para.mask_threshold : �ޥ�����������   ( ����<����:�����)
%
% change coordinate to index
%     V = [-1/2,-1/2,-1/2] - [1/2,1/2,1/2]
% <=> J = [1,1,1]
%   J   = floor(V + 0.5) + 1;
%
% ���� =  tangent_rate * (ʿ�경�Х���)
%       + mask_ratio   * (������ˡ������) * (�ޥ������� - ����)
% 
% Ver 1.0  by M. Sato  2004-2-5
% Ver 2.0  by M. Sato  2006-11-11
% M. Sato 2007-3-16
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Para','var'), Para = []; end
if ~isfield(Para,'Nloop'), Para.Nloop = 200; end
if ~isfield(Para,'Ndisp'), Para.Ndisp = Para.Nloop+1; end
if ~isfield(Para,'vstep'), Para.vstep = 1; end
if ~isfield(Para,'tangent_rate'),   Para.tangent_rate   = 0.3; end
if ~isfield(Para,'mask_ratio'),     Para.mask_ratio     = 0.5; end
if ~isfield(Para,'mask_threshold'), Para.mask_threshold = 0.3; end

tangent_rate = Para.tangent_rate;
image_rate   = Para.mask_ratio;
threshold    = Para.mask_threshold;
step		 = Para.vstep;

Nloop		 = Para.Nloop;
Npoint		 = size(V,1);  	% number of vertex
Npatch		 = size(F,1);  	% number of patch
[NX,NY,NZ]	 = size(B);		% image size

% Plot parameter
Ndisp = Para.Ndisp;
Nfig  = fix(Nloop/Ndisp);

if Nfig < 2,
	NYfig = 1;
else
	NYfig = 2;
end
NXfig = max(ceil(Nfig/NYfig), 1);
nfig  = NXfig*NYfig + 1;

fclr = [];
eclr = [];
light_mode = 1;
vangle = [-70 20];

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
% ������(��¦)�������(��¦)�Υ��᡼�����٤ˤ����
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

    % ĺ����ʬ�٥��ȥ���˵������������
    fd	 = fd./Nv(:,ones(1,3));
    
    % V ��ɸ��ܥ����륤��ǥå������Ѵ�
    jv	= floor(V/step + 0.5) + 1;
    % Check limit
    ixv = find(jv(:,1) > 0 & jv(:,1) <= NX ...
             & jv(:,2) > 0 & jv(:,2) <= NY ...
             & jv(:,3) > 0 & jv(:,3) <= NZ);

	%---- sub2ind ----
	jj  = jv(ixv,1) + NX*( (jv(ixv,2) - 1) + NY*(jv(ixv,3) - 1) );

    % ��¦�ޥ�������
	gg	= zeros(Npoint,1);
    gg(ixv)	= B(jj) - threshold;
%    gg(ixv) = max(B(jj) - threshold, 0);

    fg	= xxn.*gg(:,ones(1,3));
    
    V	= V + tangent_rate*fd + image_rate*fg;

	if rem(i,Ndisp)==0,
		if nfig > NYfig*NXfig
			figure;
			nfig=1;
		else
			nfig=nfig+1;
		end
		subplot(NYfig,NXfig,nfig); 
		vb_plot_surf(V,F,fclr,eclr,light_mode);
		view(vangle);
		tlabel = sprintf('Iteration = %d',i);
		title(tlabel);
	end;
end

