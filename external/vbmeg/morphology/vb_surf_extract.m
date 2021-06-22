function [F, V, xx, Vmiss, Fmiss, Nmiss]  = vb_surf_extract(B, step, Vorgin)
% Extract boundary surface from mask image
%   [F, V, xx]  = vb_surf_extract(B)
%   [F, V, xx]  = vb_surf_extract(B, step)
%   [F, V, xx]  = vb_surf_extract(B, step, Vorgin)
% ---
% [IN]  B         : mri Image data
% --- Optional
% [IN]  step      : subsampling step size [mm] (= 0)
% [IN]  Vorgin    : coordinate of origin  [mm] (= [0, 0, 0])
%
% [OUT] V         : surface vertex
% [OUT] F         : triangle patch index
% [OUT] xx        : normal unit vector of surface
%
%   マスクパターンから境界表面の抽出
%
% Made by M. Sato 2004-3-28
% Modified by M. Sato 2007-3-16
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Vorgin','var'), Vorgin = [0, 0, 0]; end;
if ~exist('step','var'), step = 1; end;

%
%-------- 境界面抽出 --------
%

% 3次元データの平滑化
tic
fprintf('smoothing\n')
B = smooth3(B,'gaussian',3);
vb_ptime(toc);

% 等価強度サーフェスの抽出
tic
fprintf('surface extraction\n')
Val = 0.5;
[F,V] = isosurface(B,Val);
vb_ptime(toc);

% exchange x-y coordinate
x      = V(:,1);
V(:,1) = V(:,2);
V(:,2) = x;

% Scale back to original image
NP = size(V,1);
V  = V*step - step/2;
V  = V + Vorgin(ones(NP,1),:);

% connected surface extraction
% V     : 連結している頂点
% F     : その三角面パッチ
% xx    : F の外向き法線
tic
fprintf('connected surface extraction\n')
[Fall, Vall, Nall] = vb_separate_surf(F,V);
F = Fall{1};
V = Vall{1};

% 法線方向を外向きに揃える
[F, V, xx] = vb_out_normal(F,V);
vb_ptime(toc)

% # of disconnected vertex
fprintf('# of connected vertex    = %d\n', Nall(1)) 

% 閉局面のチェック: omega = 1
omega  = vb_solid_angle_check(V,F);
fprintf('Closed surface index (=1) : %f\n', omega)
fprintf('# of disconnected vertex = %d\n', sum(Nall(2:end))) 

if nargout < 4, return; end;

Nsurf = size(Vall,1)-1;

if Nsurf == 0, 
	Fmiss = [];
	Vmiss = [];
	Nmiss = 0;
	return; 
end;

Fmiss = cell(Nsurf,1);
Vmiss = cell(Nsurf,1);
Nmiss = zeros(Nsurf,1);

for n=1:Nsurf
	Fmiss{n} = Fall{n+1};
	Vmiss{n} = Vall{n+1};
	Nmiss(n) = Nall(n+1);
end


