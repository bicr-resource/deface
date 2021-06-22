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
%  zindx     : ���饤������ɽ���� Z-��ɸ�ꥹ��
%  Nfig      : number of subplot
% --- output
%  B         : masked image
%
% MRI��¤��������ޥ����ѥ�����κ���
%
% M. Sato 2006-9-13
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('step','var'), step = 1; end;
if ~exist('Vsize','var'), Vsize = [1 1 1]; end;
if ~exist('Bval','var'), Bval = 0.5; end;

%-------- �ޥ����ѥ�����κ��� --------

% Size of original image data
[NX,NY,NZ] = size(B);

% 3�����ǡ�����ʿ�경
%tic
fprintf('Gaussian smoothing\n')
B = smooth3(B,'gaussian',3);
%vb_ptime(toc);

ix = round(1:(step/Vsize(1)):NX);
iy = round(1:(step/Vsize(2)):NY);
iz = round(1:(step/Vsize(3)):NZ);

% �ǡ����δְ���
% subsampling
B = B(ix,iy,iz);

% Size of subsampled image data
[NBx,NBy,NBz]=size(B);

% Make mask image

Nval = length(Bval);

switch	Nval
case	1,
	% ���ͤ���礭���ͤ���ĥܥ���������
	ix = find( B > Bval );
	B  = zeros(NBx,NBy,NBz);
	B(ix) = 1;
case	2,
	% 2�Ĥ����ͤδ֤ˤ����ͤ���ĥܥ���������
	ix = find( (Bval(1) < B) & (B < Bval(2)) );
	B  = zeros(NBx,NBy,NBz);
	B(ix) = 1;
end

if  ~exist('plot_mode','var'), return; end;

if  plot_mode > 1,
	% ���饤������ɽ���� Z-��ɸ�ꥹ��
	zindx = round(zindx/step);

	vb_plot_slice( B, [], zindx, 1, Nfig);
end
