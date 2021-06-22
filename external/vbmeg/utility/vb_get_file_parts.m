function [fpath, fname, fext] = vb_get_file_parts(file)
% return path, name, extension, and version of file
% [usage]
%   [path, name, ext] = vb_get_file_parts(file)
% [input]
%    file : <optional> file name ['']
% [output]
%   fpath : file path
%   fname : file name
%    fext : file extension
% [note]
%   fileparts wrapping function
% [history]
%   2007-06-18 (Sako) initial version
%   2010-10-08 (rhayashi) removed 4th argument(fver)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% --- CHECK ARGUMENTS --- %
if ~exist('file', 'var') || length(file) == 0
  % set empty string
  file = '';
end

[fpath, fname, fext] = fileparts(file);
return;

%%% END OF FILE %%%
