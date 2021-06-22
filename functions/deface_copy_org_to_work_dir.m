function deface_copy_org_to_work_dir(org_root, id_list, work_root, org_subdir)
% copy original T1 file(org_root/id_list{n}/org_subdir/mprage.nii) to wor_root/id_list{k}.
% [Usage]
%    deface_copy_org_to_work_dir(org_root, id_list, work_root, org_subdir);
% [Input]
%     org_root : original data directory.
%      id_list : List of subdirectories under org_root to be copied. {Nx1}
%    work_root : working root directory.
%   org_subdir : (optional)
%                 if there is a subdirectory under subject directory,
%                 e.g. org_root/subj1/t1/mprage.nii
%                 set 't1' to this value.
%
% Copyright (C) 2018, ATR All Rights Reserved.

%
% --- Input check
%
if ~exist('org_subdir', 'var')
    org_subdir = '';
end


%
% --- Copy org_root to work_root
%
d = deface_define;

% Check routine
fprintf('Checking original files...');
err = false;
for k=1:length(id_list)
    t1_file = fullfile(org_root, id_list{k}, org_subdir, d.t1_filename);
    if exist(t1_file, 'file') ~= 2
        err = true;
        disp([t1_file ' not found.'])
    end
end
if err
    error('Check input file(s).');
end
fprintf('OK\n');

if ~exist(work_root, 'dir')
    mkdir(work_root);
end
for k=1:length(id_list)
    t1_file = fullfile(org_root, id_list{k}, org_subdir, d.t1_filename);
    to_dir  = fullfile(work_root, id_list{k});
    if exist(to_dir, 'dir') ~= 7
        mkdir(to_dir);
    end
    if ~exist(fullfile(to_dir, d.t1_filename), 'file')
        copyfile(t1_file, to_dir);
        to_file = fullfile(to_dir, d.t1_filename);
        fprintf('copied(%d/%d):%s \n', k, length(id_list), to_file);
    end
end
