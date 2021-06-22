function p = deface_setpath
% Set MATLAB path of deface program.
%
% Copyright (C) 2018, ATR All Rights Reserved.

path_of_spm   = 'path_of_spm';



%
% --- no need to modify
%

fprintf('====================================\n');
fprintf('        deface program v 2.0        \n');
fprintf('====================================\n');

fprintf('setting path of SPM:');
if exist(path_of_spm, 'dir') ~= 7
    disp('check path_of_spm in deface_setpath.m');
    return;
end

% setup path of SPM
addpath(genpath(path_of_spm));

if isempty(which('spm.m'))
    disp('NG:SPM path not found.');
    return;
else
    disp('OK');
end

% setup path of deface program
fprintf('setting path of deface program:%s');
deface_program = fileparts(which('deface_setpath.m'));
addpath(genpath(deface_program));
if isempty(deface_program)
    disp('NG: deface program path not found.');
else
    disp('OK');
end

% setup permission
deface_cmd = which('mri_deface.');
system(['chmod 755 ' deface_cmd]);
cpu_jobthrow_dir = fileparts(which('cpu_job_throw.sh'));
system(['chmod 755 ' cpu_jobthrow_dir '/*.sh']);

disp('Ready to use deface program.');
