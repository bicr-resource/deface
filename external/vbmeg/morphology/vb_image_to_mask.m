function B = vb_image_to_mask(B, Bval, step, Vsize, plot_mode, zindx, Nfig)
% make mask-image by thresholding
%   Gaussian smoothing is done before thresholding
% 	B = vb_image_to_mask(B)
% 	B = vb_image_to_mask(B, Bval)
% 	B = vb_image_to_mask(B, Bval, step)
% 	B = vb_image_to_mask(B, Bval, step, Vsize)
% --- input
%  B         : mri Image data
%  step      : subsampling step size [mm]  Default: [1]
%  Bval      : Threshold value for binary mask ,Default: [0.5]
%   = scalar    : extract voxcel B > Bval
%   = [BV1 BV2] : extract voxcel BV1 < B < BV2
% Vsize      : voxcel size [1 x 3] ,Default: [1 1 1]
% --- Optional input
%  plot_mode : Plot slice image.(0-2 : No,  3 : Yes)
%  zindx     : スライス画像表示の Z-座標リスト
%  Nfig      : number of subplot
% --- output
%  B         : masked image
%
% MRI構造画像からマスクパターンの作成
%
% M. Sato 2006-9-13
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('step','var'), step = 1; end;
if ~exist('Vsize','var'), Vsize = [1 1 1]; end;
if ~exist('Bval','var'), Bval = 0.5; end;

%-------- マスクパターンの作成 --------

% Size of original image data
[NX,NY,NZ] = size(B);

% 3次元データの平滑化
%tic
fprintf('Gaussian smoothing\n')
B = smooth3(B,'gaussian',3);
%vb_ptime(toc);

ix = round(1:(step/Vsize(1)):NX);
iy = round(1:(step/Vsize(2)):NY);
iz = round(1:(step/Vsize(3)):NZ);

% データの間引き
% subsampling
B = B(ix,iy,iz);

% Size of subsampled image data
[NBx,NBy,NBz]=size(B);

% Make mask image

Nval = length(Bval);

switch	Nval
case	1,
	% 閾値より大きい値を持つボクセルを抽出
	ix = find( B > Bval );
	B  = zeros(NBx,NBy,NBz);
	B(ix) = 1;
case	2,
	% 2つの閾値の間にある値を持つボクセルを抽出
	ix = find( (Bval(1) < B) & (B < Bval(2)) );
	B  = zeros(NBx,NBy,NBz);
	B(ix) = 1;
end

if  ~exist('plot_mode','var'), return; end;

if  plot_mode > 1,
	% スライス画像表示の Z-座標リスト
	zindx = round(zindx/step);

	vb_plot_slice( B, [], zindx, 1, Nfig);
end
