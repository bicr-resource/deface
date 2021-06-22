function id_list = deface_get_id_from_dir(root_dir, prefix)
% get subdirectory list under root_dir.
% [Usage]
%    id_list = deface_get_id_from_dir(root_dir);
% [Input]
%    root_dir : data root directory.
%      prefix : (optional)prefix string.
%                e.g. if you specify prefix='SMA'
%                     Subdirectories starting with 'SMA' are listed.
%                              
% [Output]
%     id_list : list of subdirectories under root_dir
%
% Copyright (C) 2018, ATR All Rights Reserved.

%
% --- Previous check
%
if ~exist('root_dir', 'var')
    error('root_dir is a required parameter.');
end
if ~exist('prefix', 'var')
    prefix = '';
end

%
% --- Main Procedure
%
d = dir(root_dir);
id_list = cell(0);
for k=1:length(d)
    if (strcmp(d(k).name, '.') || strcmp(d(k).name, '..') || d(k).isdir == false)
        % skip
    else
        id_list{length(id_list)+1, 1} =  d(k).name;
    end    
end

% prefix process
if ~isempty(prefix)
    ix = strmatch(prefix, id_list);
    if isempty(ix)
        id_list = [];
    else
        id_list = id_list(ix);
    end
end

    
