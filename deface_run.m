function deface_run(work_root, id_list)
% Process defacing of T1 images(work_root/id_list/mprage.nii).
% [Usage]
%    deface_run(work_root, id_list);
%
% [Input]
%    work_root: working root directory.
%      id_list: List of subdirectories under work_root to be processed.
%               id_list = deface_get_id_list(id_file);
%                          or
%               id_list = {'sub1', 'sub2', ...};
%
% Copyright (C) 2018, ATR All Rights Reserved.

%
% --- Run processing
%
disp('Started deface process.');

d = deface_define;
if check_t1_file(work_root, id_list) == false
    disp('processing terminated.');
    return;
end

if d.parallel_computation == false
    %%%%%
    % run deface task by single cpu core
    for k=1:length(id_list)
        subj_dir = fullfile(work_root, id_list{k});
        t1_file  = fullfile(subj_dir, d.t1_filename);
        deface_process(t1_file);
    end
else
    %%%%%
    % run deface task by multiple cpu, host.

    % make deface command
    program_path = fileparts(which('deface_run'));
    log_path = fullfile(program_path, 'log');
    if exist(log_path, 'dir') ~= 7
        mkdir(log_path);
    end
    % create job file
    job_file = fullfile(log_path, ['command_', datestr(now, 30), '.txt']);
    fid = fopen(job_file, 'wt');
    if fid == -1
        error('Could not create job file.');
    end

    for k=1:length(id_list)
        subj_dir = fullfile(work_root, id_list{k});
        t1_file  = fullfile(subj_dir, d.t1_filename);
        matlab_bin   = fullfile(matlabroot, 'bin', 'matlab');
        job = [matlab_bin ' -singleCompThread -nodisplay -nosplash -r "cd ' program_path '; deface_process(''' t1_file '''); exit;"'];
        fprintf(fid, '%s\n', job);
    end
    fclose(fid);

    % create host file
    hosts_file  = fullfile(log_path, 'hosts.txt');
    fid = fopen(hosts_file, 'wt');
    for k=1:length(d.host)
        if strcmpi(d.host{k}, 'localhost')
            [a, real_host] = system('hostname');
            d.host{k} = real_host(1:end-1); % remove last \n
        end
        fprintf(fid, '%s\n', d.host{k});
    end
    fclose(fid);

    % Execution
    job_thrower = which('cpu_job_throw.sh');
    system([job_thrower, ' ', job_file, ' ', hosts_file]);
end

function result = check_t1_file(work_root, id_list)
% result : = true  : file exist.
%          = false : file not found.

result = true;

d = deface_define;
for k=1:length(id_list)
    subj_dir = fullfile(work_root, id_list{k});
    t1_file  = fullfile(subj_dir, d.t1_filename);
    if exist(t1_file, 'file') ~=2
        fprintf('%s not found.\n', t1_file);
        result = false;
    end
end

