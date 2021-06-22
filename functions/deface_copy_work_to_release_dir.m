function deface_copy_work_to_release_dir(work_root, id_list, release_root, release_subdir)
% copy working directory files into release directory.
% [Usage]
%    deface_copy_work_to_release_dir(work_root, id_list, release_root, release_subdir);
% [Input]
%        work_root : working root directory.
%     release_root : release root directory
%          id_list : List of subdirectories under work_root to be copied.    {Nx1}
%   release_subdir : (optional)
%                     if you want to create directory under subject directory,
%                      e.g. release_root/subj1/t1/mprage.nii
%                      set 't1' to this value.
%
% Copyright (C) 2018, ATR All Rights Reserved.


%
% --- Input check
%
d = deface_define;

if ~exist('release_subdir', 'var')
    release_subdir = '';
end

% Check files in the working directory
fprintf('Checking files...\n');
err = false;
for k=1:length(id_list)
    t1_defaced_file = fullfile(work_root, id_list{k}, d.defaced_t1_filename);
    if exist(t1_defaced_file, 'file') ~= 2
        err = true;
        disp([t1_defaced_file ' not found.'])
    end
end
if err
    error('Check work_root file(s).');
end
fprintf('OK\n');

if ~exist(release_root, 'dir')
    mkdir(release_root);
end

for k=1:length(id_list)
    t1_defaced_file = fullfile(work_root, id_list{k}, d.defaced_t1_filename);
%    t1_defaced_file = fullfile(work_root, id_list{k}, '*.*'); % temporary copy all the files
    to_dir          = fullfile(release_root, id_list{k}, release_subdir);
    if exist(to_dir, 'dir') ~= 7
        mkdir(to_dir);
    end
    to_file = fullfile(to_dir, d.defaced_t1_filename);
    copyfile(t1_defaced_file, to_dir);
    fprintf('copied(%d/%d) : %s\n', k, length(id_list), to_file);
end
