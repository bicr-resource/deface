function [coord] = vb_valid_coordinate_filter_decode(filt_spec)
% do posterior work for some works that require only valid coordinates
% [usage]
%   [coord] = vb_valid_coordinate_filter_decode(file_spec)
% [input]
%   filt_spec : <required> filtering specifications 
%             :  that is basically made by "encoding"
%             :  - valid_coord : valid coordinates
%             :                : matrix:[Npoint x Ndimension]
%             :  - org_size : original size of coordinates [Npoint x Ndim]
%             :             : e.g. [10000 3]
%             :  - v_coord_idx : index of valid coord in original[N x 1]
% [output]
%       coord : its size is the same as the original coordinate
% [note]
%
% [history]
%   2007-04-18 (Sako) initial version
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% --- CHECK ARGUMENTS --- %
if ~exist('filt_spec', 'var') filt_spec = []; end
[filt_spec] = inner_check_arguments(filt_spec);

% --- MAIN PROCEDURE --------------------------------------------------------- %
%
Npoints = filt_spec.org_size(1);
coord   = repmat(INVALID_COORDINATE_3D, [Npoints, 1]); % Npoints x invalid_coordinate_3d
coord(filt_spec.v_coord_idx, :) = filt_spec.valid_coord;
%
% --- END OF MAIN PROCEDURE -------------------------------------------------- %

% --- INNER FUNCTIONS -------------------------------------------------------- %
%
function [filt_spec] = inner_check_arguments(filt_spec)
if isempty(filt_spec)
  error('filt_spec is a required parameter');
end

if ~isfield(filt_spec, 'valid_coord') ...
    || ~isfield(filt_spec, 'org_size') ...
    || ~isfield(filt_spec, 'v_coord_idx')
  error('incomplete filt_spec');
end

% check consistency between fields
n_vp1 = size(filt_spec.valid_coord, 1);
n_vp2 = size(filt_spec.v_coord_idx, 1);
n_org = filt_spec.org_size(1);
if n_vp1 ~= n_vp2
  error('%s : lengths of valid_coord and v_coord_idx are different', ...
    'invalid filt_spec');
end

if n_org < n_vp1
  error('%s : length of original data is shorter than valid one', ...
    'invalid filt_spec');
end
%
% --- END OF INNER FUNCTIONS ------------------------------------------------- %

%%% END OF FILE %%%
