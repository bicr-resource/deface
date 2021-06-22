function deface_process(t1_file)
% deface T1 image..
% (subj_dir/mprage.nii is assumed.)
%
% [Usage]
%    deface_process(t1_file);
%
% [Input]
%    t1_file : T1 mrifile(.nii)
%
% [Output]
%   none
%
% [Output files]
%   These files are created in the same directory as the T1 file.
%             /defaced_mprage.nii  (defaced T1 image)
%             /c1mprage.nii
%             /mmprage.nii
%             /c1mprage_brain_mask.nii
%             /defaced_mmprage.nii
%             /face_mask.nii
%             /head_surface.mat
%     are created.
%
% Copyright (C) 2018, ATR All Rights Reserved.

if ~exist('t1_file', 'var')
    disp('Please input T1 mrfile(.nii)');
    return;
end
if exist(t1_file, 'file') ~= 2
    disp(['Specified file not found : ', t1_file]);
    return;
end

% set path
d = deface_define;
deface_setpath;

subj_dir = fileparts(t1_file);


fprintf('Started processing : %s\n', t1_file);

%
% --- Create gray matter and bias correction file using SPM
%
disp('Now doing bias correction and creating gray matter file.');
deface_segment_biascorrection(t1_file);

%
% --- Make mask file by processing bias corrected file
%
t1b_file                = fullfile(subj_dir, d.t1b_filename);
mri_deface_t1b_filename = fullfile(subj_dir, d.mri_deface_t1b_filename);

% Apply deface tool to bias corrected file
disp('Now defacing...');
deface_1st_deface(t1b_file, mri_deface_t1b_filename);

% create face mask
gray_file        = fullfile(subj_dir, d.t1c_filename);
face_mask_file   = fullfile(subj_dir, d.face_mask_filename);
deface_create_face_mask(t1b_file, mri_deface_t1b_filename, gray_file, face_mask_file);


%
% --- Deface
%
t1_defaced_file  = fullfile(subj_dir, d.defaced_t1_filename);
deface_remove_face_mask(t1_file, face_mask_file, t1_defaced_file);


%
% --- Head surface extraction
%
t1b_defaced_file = fullfile(subj_dir, d.defaced_t1b_filename);
deface_remove_face_mask(t1b_file, face_mask_file, t1b_defaced_file);

disp('Now doing head surface extraction...');
head_surf_file   = fullfile(subj_dir, d.head_surface_filename);
surf_face = vb_job_face(t1b_defaced_file);
save(head_surf_file, 'surf_face');

disp('Finished processing.');
