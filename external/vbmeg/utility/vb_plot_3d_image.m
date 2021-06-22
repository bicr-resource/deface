function [strX,strY,strZ,B2] = vb_plot_3d_image(B,indx,vdim,mode,XYZ)
% plot single analyze slice image 
%---
%  vb_plot_3d_image(B,indx,vdim,mode)
%  [strX,strY,strZ,B2] = vb_plot_3d_image(B,indx,vdim,mode,XYZ)
%
% --- Input
% B : 3D-image [NBx, NBy, NBz]. The coordinate system must be RAS. 
%     Note that the default of ANALYZE coordinate is LAS. 
% indx : slice index in vdim-axis
% vdim : slice cut direction
%      = 'x' : Sagittal cut : Y-Z plane
%      = 'y' : Coronal cut : X-Z plane
%      = 'z' : Transverse (Axial) cut : X-Y plane
% --- Optional input
% mode : 2D plot mode for X-Y 
%      = 0   : plot without transpose
%      = 1   : plot by transposing 2D-image matrix
% XYZ  = [Xmax Ymax Zmax] : 3D image size
% --- Output
% strX : 3D-axis direction for X-axis in 2D-plot image 
% strY : 3D-axis direction for Y-axis in 2D-plot image 
% strZ : 3D-axis direction for Z-axis in 2D-plot image 
% B2   : 2D-image matrix
%
% written by M. Sato  2005-8-1
% Modified by M Sato  2007-3-16
% Modified by M Sato  2015-11-27 (Normalization changed)
%---
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 2, indx = fix(NBx/2); end;
if nargin < 3, vdim = 'x'; end;
if nargin < 4, mode = 0; end;

indx = round(indx);

[NBx,NBy,NBz]=size(B);

if ~exist('XYZ', 'var'), XYZ = [NBx,NBy,NBz]; end;
if length(XYZ) ~= 3, error('Image size must be 3dim'); end;

xdim = [0, XYZ(1)];
ydim = [0, XYZ(2)];
zdim = [0, XYZ(3)];

% Normalization of voxel values
bmin = min(B(:));

if bmin >= 0
	B = B/max(B(:)); 
else
	% image with negative values
	B = (B - bmin)/(max(B(:)) - bmin);
end

% Analyze-slice-cut direction
switch	vdim,
case	'x',
 % 'SAG' : Sagittal cut : Y-Z plane
 B2   = reshape(B(indx,:,:),NBy,NBz);
 valX = ydim;
 valY = zdim;
 strX = 'Y';
 strY = 'Z';
 strZ = 'X';
case	'y',
 % 'COR' : Coronal cut : X-Z plane
 B2   = reshape(B(:,indx,:),NBx,NBz);
 valX = xdim;
 valY = zdim;
 strX = 'X';
 strY = 'Z';
 strZ = 'Y';
case	'z',
 % 'TRN' : Transverse (Axial) cut : X-Y plane
 B2   = B(:,:,indx);
 valX = xdim;
 valY = ydim;
 strX = 'X';
 strY = 'Y';
 strZ = 'Z';
end;

% Reduction of dimension of voxel matrix
B2 = squeeze(B2); 

if mode==0
  % Flip
  B2 = B2';
  
  % Index color -> True color
  B3 = repmat(B2,[1 1 3]);

  image(valX, valY, B3, 'CDataMapping','scaled');
  set(gca,'YDir','normal','XLimMode','manual','YLimMode','manual');
else
  % Index color -> True color
  B3 = repmat(B2,[1 1 3]); 
  
  str  = strX;
  strX = strY;
  strY = str;
	
  val  = valX;
  valX = valY;
  valY = val;

  image(valX, valY, B3, 'CDataMapping','scaled');
end

colormap('gray');
axis equal
axis tight

return
%--------------------------
%
% IMAGE(X,Y,C) は、X と Y がベクトルのとき、C(1,1) と C(M,N) のピクセルの中
%  心の位置を指定します。要素 C(1,1) は、(X(1)、Y(1))を中心とし、要素 C(M,N)
%  は(X(end)、Y(end))を中心とし、C の残りの要素の中心のピクセルは、
%  これらの2点の間に等間隔に設定される
%
% XDir, YDir, ZDir  : {normal} | reverse
%  値の増加する方向。Axesの値の増加する方向を制御するモード
%
% XLimMode, YLimMode, ZLimMode : {auto} | manual
%  Axesの範囲を設定するモード
%  プロットされるデータをベースに、MATLABがAxesの範囲を計算するか、または、
%  ユーザが、XLim, YLim, ZLimプロパティを使って明示的に値を設定するか
