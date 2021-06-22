function  [Vnew,Fnew,xxnew,Indx,Vinfo] = vb_smooth_cortex_LR(V, F, Para)
% smoothing cortex and remove corpus area
%  [Vnew,Fnew,xxnew,Indx,Vinfo] = vb_smooth_cortex_LR(V, F, Para)
%--- Input 
%
% V  ��  : Cortical vertex point cordinate [Nvertex, 3]
% F      : Patch index structure
%  .F3R	 : Right cortex
%  .F3L	 : Left  cortex
%  .F3	 : Left + Right
%
% Para.Nvertex  = 3000 : Reduced number of cortex
% Para.Dim      : Dimension of mask image
% Para.vstep    : subsampling step size of mask image [mm]
% Para.Nloop    = 200: iteration number for expanding sphere to brain surface
% Para.Nlast    = 0:   iteration number for additional smoothing
% Para.R_fill   = [4] :radius for fill-in cortex surface
% Para.R_smooth = [ 6 6 -6 -6] : radius for morphological smoothing
% Para.R_cut    = [ 6 6 -6 -6 -6 -4] 
%               : radius for cut morphed cortex to make elimination mask
%--- Output 
% Vnew  : Cortical vertex point cordinate [Nvertex, 3]
% xxnew : Normal vector to cortical surface   [Nvertex, 3]
% Fnew   : Patch index structure
%  .F3R	 : Right cortex
%  .F3L	 : Left  cortex
%  .F3	 : Left + Right
% Vinfo        : Vertex dimension structure
%   .Ndipole   : # of vertex
%   .NdipoleL  : # of vertex in Left cortex
%   .Npatch    : # of patch
%   .Coord     = 'Analyze_Right_mm';
% Indx   : Old vertex index list corresponding to new vertex
%
% --- Method: �����Ⲥ�ʿ�경����ʿ�경�����ǥ����
% ��Ǿ�����D�ޥ����ѥ�������Ѵ��������ɤ�Ĥ֤� & ���ե�����ʿ�경
% ��Ǿ���������
% ��Ǿ�����D�ޥ����ѥ�������Ѵ��������ɤ�Ĥ֤� & ���ե�����ʿ�경
% ��Ǿ��������� 
% ����Ǿ�����D�ޥ����ѥ�������Ѵ��������ɤ�Ĥ֤� 
% ���ե�������ĥ�Ǻ������碌��
% Ǿ���ΰ�˽Ťʤ����٤˥��ե������̾�
% ����Ǿ����Ǿ���ΰ���
% �Хͥ�ǥ�ʿ�경
% ĺ����ְ���
%
% Made by M. Sato 2006-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Para','var'), Para = []; end

if ~isfield(Para,'Dim') | isempty(Para.Dim)
	error('Size of mask image is not specified');
else
	Dim = Para.Dim;
end
% --- subsampling step for mask image [mm]
% 3D ���������Τ���δְ������ƥåץ�����
if ~isfield(Para,'vstep'), 
	error('Step size of mask image is not specified');
else
	step = Para.vstep;
end;

% Reduced number of cortex
if ~isfield(Para,'Nvertex'), 
	Nvertex = 3000; 
else
	Nvertex = Para.Nvertex;
end;

% --- Radius of Morfology operation [mm]
% ����ᡦ��Ω����� (���ե�����) �Ѵ���Ⱦ��
if ~isfield(Para,'R_fill'),
  	R_fill   = [4]; 
else
	R_fill = Para.R_fill;
end;
  	
if ~isfield(Para,'R_cut'),
   	R_cut = [ 6 6 -6 -6 -6 -4]; 
else
	R_cut = Para.R_cut;
end;
if ~isfield(Para,'R_smooth'),
	R_smooth = [ 6 6 -6 -6]; 
else
	R_smooth = Para.R_smooth;
end;

if ~isfield(Para,'Nloop'), Para.Nloop = 200; end
if ~isfield(Para,'Nlast'), Para.Nlast = 0; end
if ~isfield(Para,'tangent_rate'),   Para.tangent_rate   = 0.3; end
if ~isfield(Para,'mask_ratio'),     Para.mask_ratio     = 0.5; end
if ~isfield(Para,'mask_threshold'), Para.mask_threshold = 0.3; end

if ~isfield(Para,'plot_mode'),
	plot_mode = 0;
else
	plot_mode = Para.plot_mode;
end;

% 
% ����̤�D�ޥ����ѥ�������Ѵ�
% �������ɤ�Ĥ֤� & ���ե������Ѵ�
%
% --- Make mask to remove central region from LR cortex
[BB] = vb_cortex_fill(V, F, step, R_fill, 'LR', Dim);

if  plot_mode > 0,
	% subplot �� ��
	Nfig  = [3, 3];
	% ���饤������ɽ���� Z-��ɸ�ꥹ��
	zindx = [10:10:Dim(3)];
	fclr = [0.8 0.7 0.6];
	eclr = 'w';
	light_mode=1;
end

BB  = vb_morphology_operation(BB, R_cut, step);

if  plot_mode > 1,
	vb_plot_slice( BB, [], zindx, 1, Nfig);
end

%
% --- Make smooth left cortex
%
B = vb_cortex_fill(V, F, step, R_fill, 'L', Dim);
B = vb_morphology_operation(B, R_smooth, step);

if  plot_mode > 1,
	vb_plot_slice( B, [], zindx, 1, Nfig);
end

% ��������� 
%[FL, VL, xxL] = vb_surf_extract(B, step);

NL = F.NdipoleL;
[VL,FL,xxL] = vb_make_inner_sphere(V(1:NL,:), Nvertex);
[VL,FL,xxL] = vb_surf_smooth_fit(VL,FL,xxL, B, Para);

%
% --- Make smooth right cortex
%
B = vb_cortex_fill(V, F, step, R_fill, 'R', Dim);
B = vb_morphology_operation(B, R_smooth, step);

if  plot_mode > 1,
	vb_plot_slice( B, [], zindx, 1, Nfig);
end

% ��������� 
%[FR, VR, xxR] = vb_surf_extract(B, step);

[VR,FR,xxR] = vb_make_inner_sphere(V((NL+1):end,:), Nvertex, 1);
[VR,FR,xxR] = vb_surf_smooth_fit(VR,FR,xxR, B, Para);

fprintf('# of left cortex = %d\n',size(VL,1))
fprintf('# of right cortex = %d\n',size(VR,1))

if Para.Nlast > 0,
	% �Хͥ�ǥ��ɽ��ʿ�경
	fprintf('Surface smooth by spring model\n')
	tic
	Para.Nloop = Para.Nlast;
	[VL, FL, xxL] = vb_surf_smooth(VL,FL,xxL,Para);
	[VR, FR, xxR] = vb_surf_smooth(VR,FR,xxR,Para);
	vb_ptime(toc)
end

% remove center region vertex by using mask
fprintf('Remove central region from left cortex\n')

VL_indx = vb_remove_vertex_by_mask(VL,BB,step);
[VL, FL] = vb_trans_index( VL, FL, VL_indx);

fprintf('Remove central region from right cortex\n')
VR_indx = vb_remove_vertex_by_mask(VR,BB,step);
[VR, FR] = vb_trans_index( VR, FR, VR_indx);

fprintf('# of left cortex  = %d\n',size(VL,1))
fprintf('# of right cortex = %d\n',size(VR,1))

% ˡ�������򳰸����ˤ���
[FL, VL, xxL] = vb_out_normal( FL ,VL);
omega  = vb_solid_angle_check(VL,FL);
fprintf('Closed surface index (=1) for left  cortex: %f\n', omega)

[FR, VR, xxR] = vb_out_normal( FR ,VR);
omega  = vb_solid_angle_check(VR,FR);
fprintf('Closed surface index (=1) for right cortex: %f\n', omega)

NdipoleL = size(VL,1);

Vnew  = [VL ; VR];
xxnew = [xxL; xxR];

Fnew.F3L = FL;
Fnew.F3R = FR + NdipoleL;
Fnew.F3	 = [FL ; FR + NdipoleL];

Fnew.NdipoleL = NdipoleL;

Ndipole = size(Vnew,1);
Npatch  = size(Fnew.F3,1);

% Dimensional info
Vinfo.Ndipole   = Ndipole;
Vinfo.NdipoleL  = NdipoleL;
Vinfo.Npatch    = Npatch;
Vinfo.Coord     = 'Analyze_Right_mm';

% # of vertex
fprintf('# of vertex  = %d\n', Ndipole) 

% Find old vertex point corresponding to new vertex
% Zstep : Number of steps to divide Z-axis
% Rmax  : find nearest point within radius Rmax [mm]
Zstep = 100;
Rmax  = 10;

%return
tic
fprintf('Find original vertex corresponding to the smoothed surface\n')
[Indx ,ddmin] = vb_find_nearest_point(V, Vnew, Rmax, Zstep);

fprintf('Max distance between new and old vertex = %f\n',max(ddmin))
vb_ptime(toc)

if Para.plot_mode > 0
	dmax = 10;
	X0 = mean(Vnew);
	F3 = Fnew.F3;
	vb_plot_slice_surf( B, Vnew/step, F3, round(X0(1)/step), 'x',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vnew/step, F3, round(X0(2)/step), 'y',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vnew/step, F3, round(X0(3)/step), 'z',[1 1],'r-',dmax);
end
