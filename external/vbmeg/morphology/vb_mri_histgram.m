function	[Nhist, level, step] = vb_mri_histgram(B, Nmax, NMAX)
% calculate MRI image histogram
%  [Nhist, level, step]	= vb_mri_histgram(B)
%  [Nhist, level, step] = vb_mri_histgram(B, Nmax, NMAX)
%   B   : Image intensity
% Nhist ; Histogram
% level : level of histogram
% step  : step size of level (integer)
% if max(B) <= NMAX, step = 1
% else,              step = round( max(B)/Nmax );
%
% Masa-aki Sato 2010-10-18
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Histogram level
if nargin < 2, Nmax = 256; end;
if nargin < 3, NMAX = Nmax; end;

% Max of MRI image
Bmax = fix(max(B(:)));

% Adjust histogram level according to Bmax
if Bmax <= NMAX,
	step = 1;
else
	step = round(Bmax/Nmax);
end

Nlevel	= 0:step:Bmax;

[Nhist, level]	= hist(B(:),Nlevel);

level = level + step;

return

if nargin < 2, Nmax = 1024; end;
if nargin < 3, NMAX = 2048; end;

% Max of MRI image
Bmax = fix(max(B(:)));

% Adjust histogram level according to Bmax
if Bmax < NMAX, Nmax = Bmax; end;

% histogram for MRI image intensity
step = 1;
Nlevel	= (0:step:Nmax)*(Bmax/Nmax);

[Nhist, level]	= hist(B(:),Nlevel);

level = level + step*(Bmax/Nmax);
