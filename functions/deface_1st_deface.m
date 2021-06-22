function deface_1st_deface(mri_file, defaced_file)
% run mri deface command.
%
% [Usage]
%    deface_make_deface_command(mri_file, defaced_file);
%
% [Input]
%        mri_file : mri filename.           (input file)
%    defaced_file : defaced mri filename.   (output file)
%
% [Output]
%    none
%
% Copyright (C) 2018, ATR All Rights Reserved.

tool_path = fileparts(which('mri_deface.'));
exe_path  = fullfile(tool_path, 'mri_deface');
tool_sub1 = fullfile(tool_path, 'talairach_mixed_with_skull.gca');
tool_sub2 = fullfile(tool_path, 'face.gca');

command = [exe_path, ' ', mri_file, ' ', tool_sub1, ' ', tool_sub2 ' ' defaced_file];
system(command);
