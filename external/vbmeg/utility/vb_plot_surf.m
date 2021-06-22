function    vb_plot_surf(V,F,fclr,eclr,light_mode,max_mode)
% plot surface
%  vb_plot_surf(V,F,fclr,eclr,light_mode,max_mode)
% --- Input
% V : vertex coordinate
% F : patch index
% --- Optional input
% fclr = face color
% eclr = edge color
% if light_mode = 1, lighting 
% if max_mode   = 1, set axis limit
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('fclr','var') | isempty(fclr), fclr = [0.8 0.7 0.6]; end;
if ~exist('eclr','var') | isempty(eclr), eclr = 'none'; end;
if ~exist('light_mode','var') | isempty(light_mode), light_mode=0; end;
if ~exist('max_mode','var')   | isempty(max_mode), max_mode=0; end;

% ∂ ÃÃ…Ωº®
patch('Faces',F,'Vertices',V,'FaceColor',fclr,'EdgeColor',eclr);
lighting phong;
material dull;
axis equal

xlabel('X');
ylabel('Y');
zlabel('Z');

if  max_mode == 1
    Vmax = max(V);
    Vmin = min(V);
    xlim([Vmin(1) Vmax(1)]);
    ylim([Vmin(2) Vmax(2)]);
    zlim([Vmin(3) Vmax(3)]);
end
if  light_mode == 1
    camlight(-60,0);
    camlight(60,0);
    camlight(180,0);
    %camlight headlight;
end
