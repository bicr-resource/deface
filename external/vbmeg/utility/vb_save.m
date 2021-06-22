function [result] = vb_save(varargin)
% Save variables into mat-file by MATLAB version 6 format. (Append mode)
%   vb_save(filename, 'V', 'XX', ... )
% [IN]  varargin : variable name string. (varargin{1} = filename)
% [OUT] result   : SUCCESS or FAILURE;
% 
% Example:
%  vb_save(filename, 'V', 'XX', ... )
% Memo:
%  if specified file already exists, variable will be appended to the file.
%   @see vbmeg.m where "vbmeg_saving_version" is set
% History:
%   ****-**-** (****) initial version
%   2009-07-06 (Sako) changed specification of the default version
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

global vbmeg_saving_version

result = FAILURE;

if nargin <= 1, return; end

% extension change to '.mat'
file_name = varargin{1};

% [PATH, NAME, EXT] = fileparts(file_name);
[PATH, NAME, EXT] = vb_get_file_parts(file_name);
if ~isempty(PATH) && ~exist(PATH, 'dir')
    vb_mkdir(PATH);
    vb_disp(['Create directory: ' PATH]);
end

EXT = '.mat';
file_name = fullfile(PATH, [NAME, EXT]);

num_variable = length(varargin)-1;

compatible_option = vbmeg_saving_version;

% check file existance on caller workspace
exist_command = ['exist(''' file_name ''', ''file'')'];
if evalin('caller', exist_command)
    append_mode = '-append';
else
    append_mode = '';
end

% make save command string
save_command = ...
            ['save ' file_name, ' ', ...
                     append_mode ' ', ...
                     compatible_option];
for k=1:num_variable
    save_command = [save_command ' ' varargin{k+1}];
end

% execute save command on caller workspace.
evalin('caller', save_command);

result = SUCCESS;
