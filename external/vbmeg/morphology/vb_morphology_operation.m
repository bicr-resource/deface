function	B = vb_morphology_operation(B, Radius, step, plot_mode, zindx, Nfig)
% Dilation/erosion are done consecutively according to Radius
%  B = vb_morphology_operation(B, Radius, step)
%-------- モルフォロジー変換 --------
% [IN]  B         : 3D-Image data
% [IN]  Radius    : Radius of Morfology operation 
% [IN]  step      : subsampling step size 
%
% [OUT] B         : 3D-Image data
%
% 穴埋め・孤立点削除 (モルフォロジー) 変換の順序と半径
% ---- Define order and size of dilation/erosion by Radius ----
%
% Radius : Radius of Morfology operation
% -- Example
% Radius = [ -2 2 ];
% R > 0  : dilation
% R < 0  : erosion
% 1. remove small island in background  (R = -2,  2)
% 2. fill holes inside the brain        (R =  6, -6)
%
% -- Optional input
% [IN]  plot_mode : Plot slice image.(0-2 : No,  3 : Yes)
% [IN]  zindx     : スライス画像表示の Z-座標リスト
% [IN]  Nfig      : number of subplot
%
% Made by M. Sato 2004-3-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%
%-------- モルフォロジー変換 --------
%
if  ~exist('plot_mode','var'), plot_mode = 0; end;
if  ~exist('step','var'), step = 1; end;

% Radius of Morfology operation
R = Radius/step; 

Nclose = length(R);

if Nclose == 0, return; end;

if plot_mode == 3,
	NY = 2;
	NX = ceil(Nclose/NY);
	figure;
end

%tic

for n = 1:Nclose

	if R(n) == 0,
		continue;
	elseif R(n) < 0,
		% 境界削除 (Erosion)
		fprintf('erosion (R = %f)\n',R(n)*step)
		B = vb_erosion_3d(B, abs(R(n)));
		%vb_ptime(toc);tic
	else
		% 境界拡張 (Dilation)
		fprintf('dilation (R = %f)\n',R(n)*step)
		B = vb_dilation_3d(B, R(n));
		%vb_ptime(toc);tic
	end
	
	if plot_mode == 3
		subplot(NY,NX,n)
		plot_one_slice(B);
		title(sprintf('R = %f\n',R(n)*step))
	end
end

%vb_ptime(toc); 

if  plot_mode > 1,
	% Z-coordinate for slice plot
	if ~exist('zindx','var'), zindx = [40:20:200]; end;
	if ~exist('Nfig','var'),  Nfig  = [3, 3]; end;
	
	% スライス画像表示の Z-座標リスト
	zindx = round(zindx/step);

	vb_plot_slice( B, [], zindx, 1, Nfig);
end

% # of on voxcel in each slice
%Nvoxel = squeeze( sum(sum(B,2),1) );
%
