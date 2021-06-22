function	[Vx, Fx, xx, B] = vb_mask_to_surf_expand(B, Para)
% Extract smooth surface from mask image and expand/shrink
%  [V, F, xx, B] = vb_mask_to_surf_expand(B, Para)
% --- Input & Output
%  V(n, 1:3)  : vertex
%  F(j, 1:3)  : patch index
% xx(n, 1:3)  : normal vector
% B(NX,NY,NZ) : mask image : inside of surface is filled out
% --- Parameter
% Para : parameter structure ( = default value )
% Para.Nvertex = 5000 : # of vertex
% Para.Nloop  = 200 : iteration number for fit boundary
% Para.Nlast  = 10  : iteration number for smoothing by spring model
% Para.tangent_rate   = 0.3  : spring constant
% Para.mask_ratio     = 0.5  : mask image force constant
% Para.mask_threshold = 0.3  : mask threthold
% Para.vstep  = 1   : voxel size of mask image [mm]
% Para.Radius = [ 6 -6 ] : morphological smoothing [mm]
%             = [ 6 ]    : morphological expansion
%             = []       : No morphological operation
% --- 膨張モデル
% Para.tangent_rate   = 0.3 :  バネ力係数
% Para.mask_ratio     = 0.5 : マスク強度力係数 ( 強度>閾値:外向き)
% Para.mask_threshold = 0.3 : マスク強度閾値   ( 強度<閾値:内向き)
%
% 合力 =  tangent_rate * (平滑化バネ力)
%       + mask_ratio   * (外向き法線方向) * (マスク強度 - 閾値)
% --- バネモデル平滑化
%
% 合力 =  tangent_rate * (平滑化バネ力)
%
% 2006/10/12 M. Sato
% 2006/11/11 M. Sato
% M. Sato 2007/6/14
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Para','var'), Para = []; end

% --- subsampling step for mask image [mm]
% 3D 画像処理のための間引きステップサイズ
if ~isfield(Para,'vstep'), 
	step = 1; 
	Para.vstep = step;
else
	step = Para.vstep;
end;

if ~isfield(Para,'Nloop'), Para.Nloop = 200; end
if ~isfield(Para,'Nlast'), Para.Nlast = 20; end
if ~isfield(Para,'Nvertex'), Para.Nvertex = 5000; end
if ~isfield(Para,'tangent_rate'), Para.tangent_rate = 0.3; end
if ~isfield(Para,'Radius'),Para.Radius  = [6 -6];end 
if ~isfield(Para,'plot_mode'), Para.plot_mode = 0; end

Dim = size(B);

% Binarize mask image
ix = find( B(:) > 0 );
B  = zeros(Dim);
B(ix) = 1;

%
% --- Apply morphology operation
% 
B = vb_morphology_operation(B, Para.Radius, step);

%
% --- 3次元データの平滑化
% 
tic
fprintf('smoothing\n')
B = smooth3(B,'gaussian',3);
vb_ptime(toc);

%
%------- マスクパターンの境界面に膨張
%
tic
fprintf('--- Surface expansion\n')

% マスクパターンの境界座標
V  = vb_get_boundary(B);
% Scale back to original image
V  = V*step - step/2;
X0 = fix(mean(V/step));	% 中心点

[Vx, Fx, xx] = vb_make_inner_sphere(V, Para.Nvertex);% 内接球面作成

if Para.plot_mode > 1
	dmax = 10;
	vb_plot_slice_surf( B, Vx/step, Fx, X0(1), 'x',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(2), 'y',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(3), 'z',[1 1],'r-',dmax);
end

[Vx, Fx, xx] = vb_surf_smooth_fit(Vx,Fx,xx, B, Para);% 境界面に膨張

vb_ptime(toc)

if Para.plot_mode > 1
	dmax = 10;
	vb_plot_slice_surf( B, Vx/step, Fx, X0(1), 'x',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(2), 'y',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(3), 'z',[1 1],'r-',dmax);
end

%
%------- バネモデル による平滑化
%
tic
fprintf('--- Surface smoothing by spring model\n')

Para.Nloop = Para.Nlast; 	% バネモデル平滑化繰り返し回数
[Vx, Fx, xx] = vb_surf_smooth(Vx,Fx,xx,Para);

vb_ptime(toc)

fprintf('# of patches : %d\n',size(Fx,1));
fprintf('# of vertices: %d\n',size(Vx,1));

if Para.plot_mode > 1
	dmax = 10;
	vb_plot_slice_surf( B, Vx/step, Fx, X0(1), 'x',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(2), 'y',[1 1],'r-',dmax);
	vb_plot_slice_surf( B, Vx/step, Fx, X0(3), 'z',[1 1],'r-',dmax);
end

