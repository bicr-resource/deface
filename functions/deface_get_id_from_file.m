function id_list = deface_get_id_from_file(id_file, prefix)
% read a text file containing a list of IDs.
%
% [Usage]
%    id_list = deface_get_id_from_file(id_file [,prefix]);
%
% [Input]
%    id_file : text file containing a list of IDs.
%     prefix : (optional)prefix string.
%               e.g. if you specify prefix='SMA'
%                    Subdirectories starting with 'SMA' are listed.

% [Output]
%    id_list : list of IDs.
%
% Copyright (C) 2018, ATR All Rights Reserved.

%
% --- Previous check
%
if ~exist('id_file', 'var')
    error('id_file is a required parameter.');
end
if ~exist('prefix', 'var')
    prefix = '';
end

%
% --- Main Procedure
%
fid = fopen(id_file, 'rt');
if fid == -1
    error('Cannot open file : %s', id_file);
end

id_list = cell(0);

while ~feof(fid)
    l = fgetl(fid);
    id_list{length(id_list)+1, 1} = l;
end
fclose(fid);

% prefix process
if ~isempty(prefix)
    ix = strmatch(prefix, id_list);
    if isempty(ix)
        id_list = [];
    else
        id_list = id_list(ix);
    end
end
