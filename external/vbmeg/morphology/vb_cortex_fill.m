function  [B, XL, XR] = ...
			vb_cortex_fill(V,F,step,Radius,LR_mode,Dim,mask_mode)
% fill inside of cortex surface
%  [B, XL, XR] = vb_cortex_fill(V,F,step,Radius,LR_mode,Dim,mask_mode)
%
% ����̤��������ɤ�Ĥ֤���D�ޥ����ѥ�������Ѵ�
% 
%--- Input Brain Data
%
% V  ��  : Cortical vertex point cordinate   [Nvertex, 3]
% F      : Patch index structure
%  .F3R	 : Right cortex
%  .F3L	 : Left  cortex
%  .F3	 : Left + Right
%  .NdipoleL  : # of vertex for Left cortex
% 
% step    : voxcel size of mask (mm)
% Radius  : morphology radius for smoothing
% LR_mode = 'LR' : Left & Right cortex
%         = 'L'  : Left  cortex
%         = 'R'  : Right cortex
%
% if mask_mode == -1, no filling   is done
% if mask_mode ==  0, no morphology is done
% if mask_mode ==  1, morphology is done��(Default)
%    XLeft = (XLeftCenter + XCenter)/2 : start of filling
% if mask_mode ==  2, morphology is done
%    XLeft = XLeftCenter  : start of filling
% Dim : dimension of mask image
% --- Output
% B  : voxcel mask pattern for cortex
% 
% XL = Center of Left cortex
% XR = Center of Right cortex
%
%
% Made by M. Sato 2007-3-15
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('LR_mode','var'), LR_mode = 'LR'; end;
if ~exist('mask_mode','var'), mask_mode = 1; end;

% DEBUG mode flag
debug_mode = 0;

% Vertex for Left/Right cortex
Ndipole  = size(V,1);
NdipoleL = F.NdipoleL;
NdipoleR = Ndipole - NdipoleL;

VL = V(1:NdipoleL,:);
VR = V((NdipoleL+1):Ndipole,:);

%
%------- ������Ǿ���ɤ�Ĥ֤����ϰ��ַ׻�
%
% Center of Left/Right cortex
XL = sum(VL)/(NdipoleL*step);
XR = sum(VR)/(NdipoleR*step);
% Center of (Left-Right)
XC = (XL(1) + XR(1))/2;

% ��Ǿ���ɤ�Ĥ֤����ϰ���
if mask_mode ~=  2
	XL(1) = (XL(1) + XC)/2;
end
XL	  = round(XL);
% ��Ǿ���ɤ�Ĥ֤����ϰ���
if mask_mode ~=  2
	XR(1) = (XR(1) + XC)/2;
end
XR	  = round(XR);

%
%-------- �ޥ����ѥ�����κ��� --------
%

% ���ѷ�ʬ��Ĺ��
dmin   = step/2;

% Surface patch of Left/Right cortex
switch	LR_mode
case	'LR'
	F = F.F3;
case	'L'
	F = F.F3L;
	V = VL;
case	'R'
	F = F.F3R - NdipoleL;
	V = VR;
end

% Ǿ�����ޥ������Ѵ�
B = vb_surf_to_mask(V,F,step,dmin,Dim);

if mask_mode == -1 && debug_mode==1,
	vb_plot_surf(V,F)
	vb_plot_slice( B, [XL], [XL(3)], 1, [1, 1], 20);
	title('Left Brain Center')
	vb_plot_slice( B, [XR], [XR(3)], 1, [1, 1], 20);
	title('Right Brain Center')
end

if mask_mode == -1, return; end;

%
%------- ������Ǿ���ɤ�Ĥ֤�

%
% �������ޥ�������
% voxcel value for filled voxcel
filval = 1;
% ���������ɤ�Ĥ֤��������͡������ͤ�꾮�����ͤ��ɤ�Ĥ֤�
% threshold value for filling in
level  = 0.5;

switch	LR_mode
case	'LR'
	% ��Ǿ�������ɤ�Ĥ֤�
	B = vb_flood_fill_3d(B, XL, filval, level);
	% ��Ǿ�������ɤ�Ĥ֤�
	B = vb_flood_fill_3d(B, XR, filval, level);
case	'L'
	% ��Ǿ�������ɤ�Ĥ֤�
	B = vb_flood_fill_3d(B, XL, filval, level);
case	'R'
	% ��Ǿ�������ɤ�Ĥ֤�
	B = vb_flood_fill_3d(B, XR, filval, level);
end

if mask_mode == 0, return; end;
if ~exist('Radius','var')| isempty(Radius), return; end;

%
%-------- ���ե������Ѵ� --------
%

% Radius of Morfology operation
R = Radius/step; 

% �����
B = vb_closing_3d(B, R, R);
B = vb_opening_3d(B, R, R);
