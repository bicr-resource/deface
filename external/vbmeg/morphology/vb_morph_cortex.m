function	[Vnew,Fnew,xx,Indx,ddmin] = ...
            vb_morph_cortex(V, F, Nvertex, Radius, step, LR_mode)
% smoothing cortex combined left and right cortex
% [Vnew,Fnew,xx,Indx,ddmin]=vb_morph_cortex(V, F, Nvertex, Radius, step, LR_mode)
%
% �����Ⲥ�ʿ�경����ʿ�경�����ǥ����
% ������Ǿ���ĤˤޤȤ��
%--- Input 
%
% F.F3/F3L/F3R  : ��(3�ѷ�)�������룳�Ĥ�ĺ���ֹ� ( �̤ο�, 3)  
% V       : ĺ������ �� ĺ���ο�, 3��
% 
% Nvertex : # of output cortex vertex 
% Radius  : morphology radius    (mm)
% step    : voxcel size of mask (mm)
% LR_mode = 'LR' : Left & Right cortex
%         = 'L'  : Left  cortex
%         = 'R'  : Right cortex
%
%--- Output 
%
% Fnew.F3/F3L/F3R  : ��(3�ѷ�)�������룳�Ĥ�ĺ���ֹ� ( �̤ο�, 3)  
% Vnew    : ĺ������ �� ĺ���ο�, 3��
% xx      : ������ˡ��
% Indx    : Old vertex index list corresponding to new vertex
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% 3D ���������Τ���δְ������ƥåץ�����
% subsampling step for mask image [mm]
if ~exist('step','var'), step = 2; end;

% ����ᡦ��Ω����� (���ե�����) �Ѵ���Ⱦ��
% Radius of Morfology operation [mm]
if ~exist('Radius','var'), Radius = 4; end;

if ~exist('LR_mode','var'), LR_mode = 'LR'; end;

% 
% ����̤�D�ޥ����ѥ�������Ѵ�
% �������ɤ�Ĥ֤� & ���ե������Ѵ�
%
[B, Vorgin] = vb_cortex_fill(V,F,step,Radius,LR_mode);

% ��������� 
[Fc, Vc, xx] = vb_surf_extract(B, step, Vorgin);

% �ܥ������ɸ���鸵�κ�ɸ�ؤ��Ѵ� [m]
%Vc = vb_trans_vox_to_surf(Vc, Vorgin, step);
Vc = Vc*0.001;

Ndipole = size(Vc,1);
Npatch  = size(Fc,1);

% �����٤򲼤�������������
Fnew.F3		  = Fc;
Fnew.F3L	  = Fc;
Fnew.F3R	  = [];
Fnew.NdipoleL = Ndipole;

[Vnew, Fnew]  = vb_reduce_vertex(Vc,Fnew,Nvertex);

% ˡ�������򳰸�����·����
% xx : ������ˡ��
[Fc, Vnew, xx, Vmiss] = vb_out_normal( Fnew.F3 ,Vnew);

Fnew.F3		  = Fc;
Fnew.F3L	  = Fc;
Fnew.F3R	  = [];
Fnew.NdipoleL = size(Vnew,1);

% # of disconnected vertex
fprintf('# of reduced vertex      = %d\n', size(Vnew,1)) 
fprintf('# of disconnected vertex = %d\n', size(Vmiss,1)) 

% �Ķ��̤Υ����å�: omega = 1
omega  = vb_solid_angle_check(Vnew,Fc);
fprintf('Closed surface index (=1) : %f\n', omega)

% Find old vertex point corresponding to new vertex
% Zstep : Number of steps to divide Z-axis
% Rmax  : find nearest point within radius Rmax [m]
Zstep = 50;
Rmax  = 0.01;

[Indx ,ddmin] = vb_find_nearest_point(V, Vnew, Rmax, Zstep);

fprintf('Max distance between new and old vertex = %f\n',max(ddmin))
