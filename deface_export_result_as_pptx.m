function pptx_file = deface_export_result_as_pptx(work_root, id_list, pptx_file)
% export defaced result to powerpoint file(.pptx)
% [Usage]
%    pptx_file = deface_export_result_as_pptx(work_dir, id_list, pptx_file);
% [Input]
%     work_root : 
%       id_list : 
%     pptx_file : save filename(.pptx)
%
% Copyright (C) 2018, ATR All Rights Reserved.

warning off;
exportToPPTX('close');
warning on;

% create new PPTX file on memory
exportToPPTX('new');

d = deface_define;

for k=1:length(id_list)
    fprintf('Now putting result... (%d/%d)\n', k, length(id_list));

    subj_dir = fullfile(work_root, id_list{k});

    % insert new slide
    exportToPPTX('addslide');

    %
    % --- plot defaced head surface
    %
    head_surf    = fullfile(subj_dir, d.head_surface_filename);
    load(head_surf, 'surf_face');

    h = figure; vb_plot_surf(surf_face.V, surf_face.F);
    set(gca, 'Color', 'k', 'Position', [0, 0, 1, 1]);
    set(h,   'Color', 'k');
    view([-200, 0]);
    axis tight; zoom(gca, 0.8);
    camlight headlight;

    exportToPPTX('addpicture', h,'Position',[0 2 4 3]);
    close(h);
    
    %
    % --- load MRimage
    %
    original_mri = fullfile(subj_dir, d.t1_filename);
    defaced_mri  = fullfile(subj_dir, d.defaced_t1_filename);
    cortex_mri   = fullfile(subj_dir, d.t1c_filename);
    face_mask_mri = fullfile(subj_dir, d.face_mask_filename);
    
    [B, Vdim, Vsize]    = vb_load_analyze_to_right(original_mri);
    [Bd]                = vb_load_analyze_to_right(defaced_mri);
    [Bc]                = vb_load_analyze_to_right(cortex_mri);
    [Bm]                = vb_load_analyze_to_right(face_mask_mri);
    

    % plot Sagittal center slice(before and defaced)
    h = figure;

    % before
    set(h, 'Position', [680   554   418   420], 'Units', 'pixels');
    vb_plot_3d_image(B, ceil(Vdim(1)/2), 'x'); axis off % before
    set(gca, 'Position', [0,0,1,1], 'Units', 'normalized');
    set(h, 'Color', 'k');
    exportToPPTX('addpicture',gcf,'Position',[4 2 3 3]);
    close(h);
    
    % defaced
    h = figure;
    set(h, 'Position', [680   554   418   420], 'Units', 'pixels');
    vb_plot_3d_image(Bd, ceil(Vdim(1)/2), 'x'); axis off; % after
    set(gca, 'Position', [0,0,1,1], 'Units', 'normalized');
    set(h, 'Color', 'k');
    exportToPPTX('addpicture',gcf,'Position',[7 2 3 3]);
    close(h);
    
    % plot sagital slices to check if cortex not deleted.
    fig = plot_slice(B, Bd, Bc, Bm, Vdim, Vsize);
    set(fig, 'Position', [0, 0, 1231, 250]);
    exportToPPTX('addpicture',gcf,'Position',[0 4.9 10 2]);
    close(fig);

    % Slide title
    cortex_mask_intersection = intersect(find(Bm(:) ~= 0), find(Bc ~= 0));
    title_str = id_list{k};
    if ~isempty(cortex_mask_intersection)
        title_str = sprintf('%s\n%s', title_str, 'Be careful: the cerebral cortex may be scraped.');
    end
    exportToPPTX('addtext', title_str, 'Position', [0, 0, 10, 2], 'FontSize', 32, 'HorizontalAlignment', 'center');
end

% export slide on memory into pptx_file
pptx_file = exportToPPTX('save',pptx_file);
fprintf('PPTX file created : %s\n', pptx_file);


function fig = plot_slice(B, B2, Bc, Bm, Vdim, Vsize)

% Plot sagittal center
% (slice interval = 30mm)
center = ceil(Vdim(1)/2);
step   = ceil(30/Vsize(1));
slices = [center - 2*step: step : center + 2*step]; % [-60mm, -30mm, 0mm, 30mm, 60mm]


fig = figure;
Nfig = length(slices);
for k=1:Nfig
    vb_subaxis(1, Nfig, k, 'SH', 0, 'SV', 0, 'PL', 0, 'PR', 0, 'MT', 0, 'MB', 0, 'ML', 0, 'MR', 0);
    B2d  = deface_get_slice(B2, slices(k), 'x');
    B2dm = deface_get_slice(Bm, slices(k), 'x');
    B2dc = deface_get_slice(Bc, slices(k), 'x');

    B2dm = set_3d_mask_color_to(B2dm, 'c');
    B2dc = set_3d_mask_color_to(B2dc, 'y');

    Bmerged = overlay_3d_mask(B2d, B2dm);
    Bmerged = overlay_3d_mask(Bmerged, B2dc);
    
    image(Bmerged, 'CDataMapping', 'scaled');
    set(gca,'YDir','normal','XLimMode','manual','YLimMode','manual');
    axis off; axis equal; axis tight;
end

function B2d = set_3d_mask_color_to(B, color)

Br = B(:,:,1);
Bg = B(:,:,2);
Bb = B(:,:,3);
ix = intersect(intersect(find(Br), find(Bg)), find(Bb));

switch(color)
    case 'y'
        r = 255/255;
        g = 255/255;
        b = 0/255;
    case 'c'
        r = 0/255;
        g = 255/255;
        b = 255/255;
end

Br(ix) = r;
Bg(ix) = g;
Bb(ix) = b;

B2d = cat(3, Br, Bg, Bb);

function B2d = overlay_3d_mask(B2d, B2dmask)

ix = find(B2dmask ~= 0);
if ~isempty(ix)
    B2d(ix) = B2dmask(ix);
end

