function	[B] = vb_surf_to_filled_mask(V, F, Dim, step, Radius, X0)
% Make filled mask image from surface cordinate
%  [B] = vb_surf_to_filled_mask(V, F, Dim, step, X0, Radius)
% --- Input
% V��  : surface vertex point cordinate   [Nvertex, 3]
% F    : Patch index structure
% Dim  : mask image dimension
% --- Optional Input
% step = 2   : voxcel size [mm]
% Radius = [ 4 -4 ] : morphological smoothing [mm]
%        = [ 6 ]    : morphological extraction
%        = []       : No morphological operation
% X0  ; start point to filling in
%--- Output 
% B(nx,ny,nz) : mask image
% size(B) = Dim
%
% 2007-3-16 M. Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 3, error('Input arguments is wrong'); end;
if ~exist('step','var'), step = 2; end
if ~exist('Radius','var'), Radius  = [4 -4 ];end

%%% DEBUG
Debug_mode = 0;

%
% Closed surface check
%
disp('--- Closed surface check');
omega = vb_solid_angle_check(V,F);

fprintf('Solid angle = 4pi x %f\n',omega);
if abs(omega-1)>1e-10, 
  disp('Surface is not closed.');
  return;
else
  disp('Surface is closed.');
end

%
%-------- ɽ�̤�ޥ������Ѵ�
%
fprintf('--- Make mask image from surface\n')
dmin = step/2;	% ���ѷ�ʬ��Ĺ��

B = vb_surf_to_mask(V, F, step, dmin, Dim);

%
%------- ���������ɤ�Ĥ֤�
%
fprintf('--- Fill out inside the surface \n')

filval = 1;		% �������ޥ�������
level  = 0.5;	% �����ͤ�꾮�����ͤ��ɤ�Ĥ֤�

if ~exist('X0','var')
	X0  = fix(mean(V/step));	% �濴��
end

B   = vb_flood_fill_3d(B, X0, filval, level);

if Debug_mode == 2, return; end
%
% --- Apply morphology erosion
% 
B = vb_morphology_operation(B, Radius, step);

return
% --- END ---

if Debug_mode == 1, return; end

% 3�����ǡ�����ʿ�경
tic
fprintf('smoothing\n')
B = smooth3(B,'gaussian',3);
vb_ptime(toc);
