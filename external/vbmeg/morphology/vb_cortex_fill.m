function  [B, XL, XR] = ...
			vb_cortex_fill(V,F,step,Radius,LR_mode,Dim,mask_mode)
% fill inside of cortex surface
%  [B, XL, XR] = vb_cortex_fill(V,F,step,Radius,LR_mode,Dim,mask_mode)
%
% 皮質面の内部を塗りつぶし３Dマスクパターンに変換
% 
%--- Input Brain Data
%
% V  　  : Cortical vertex point cordinate   [Nvertex, 3]
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
% if mask_mode ==  1, morphology is done　(Default)
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
%------- 左右の脳を塗りつぶす開始位置計算
%
% Center of Left/Right cortex
XL = sum(VL)/(NdipoleL*step);
XR = sum(VR)/(NdipoleR*step);
% Center of (Left-Right)
XC = (XL(1) + XR(1))/2;

% 左脳を塗りつぶす開始位置
if mask_mode ~=  2
	XL(1) = (XL(1) + XC)/2;
end
XL	  = round(XL);
% 右脳を塗りつぶす開始位置
if mask_mode ~=  2
	XR(1) = (XR(1) + XC)/2;
end
XR	  = round(XR);

%
%-------- マスクパターンの作成 --------
%

% 三角形分割長さ
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

% 脳皮質をマスクに変換
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
%------- 左右の脳を塗りつぶす

%
% 内部点マスクの値
% voxcel value for filled voxcel
filval = 1;
% 内部点を塗りつぶす時の閾値：この値より小さい値を塗りつぶす
% threshold value for filling in
level  = 0.5;

switch	LR_mode
case	'LR'
	% 左脳内部の塗りつぶし
	B = vb_flood_fill_3d(B, XL, filval, level);
	% 右脳内部の塗りつぶし
	B = vb_flood_fill_3d(B, XR, filval, level);
case	'L'
	% 左脳内部の塗りつぶし
	B = vb_flood_fill_3d(B, XL, filval, level);
case	'R'
	% 右脳内部の塗りつぶし
	B = vb_flood_fill_3d(B, XR, filval, level);
end

if mask_mode == 0, return; end;
if ~exist('Radius','var')| isempty(Radius), return; end;

%
%-------- モルフォロジー変換 --------
%

% Radius of Morfology operation
R = Radius/step; 

% 穴埋め
B = vb_closing_3d(B, R, R);
B = vb_opening_3d(B, R, R);
