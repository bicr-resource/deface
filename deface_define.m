function d = deface_define
% Setting file of deface program.
%
% Copyright (C) 2018, ATR All Rights Reserved.

%
% --- definition of filename
%

% <<Input file>>  : T1 filename
d.t1_filename          = 'mprage.nii';

% <<Output file>> : defaced T1 filename
d.defaced_t1_filename  = ['defaced_', d.t1_filename];

% <<Intermediate files>>
d.t1b_filename            = ['m', d.t1_filename];            % bias corrected T1 file.
d.t1c_filename            = ['c1',  d.t1_filename];          % gray matter extracted from T1 file.
d.mri_deface_t1b_filename = ['mri_deface_', d.t1b_filename]; % mri_deface applied to bias corrected T1-file.
d.face_mask_filename      = 'face_mask.nii';                 % face removal area is contained to this file.
d.defaced_t1b_filename    = ['defaced_', d.t1b_filename];    % defaced bias corrected T1 file.
d.head_surface_filename   = 'head_surface.mat';              % defaced surface data is contained to this file.

%
% --- processing host settings
%
d.host = {'localhost'};
d.parallel_computation = 0;
