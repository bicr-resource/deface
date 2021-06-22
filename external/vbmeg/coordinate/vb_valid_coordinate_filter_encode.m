function [filt_spec] = vb_valid_coordinate_filter_encode(coord)
% do prior work for some works that require only valid coordinates
% [usage]
%   [filt_spec] = vb_valid_coordinate_filter_encode(coord)
% [input]
%       coord : <required> coordinate
% [output]
%   filt_spec : filtering specifications
%             :  - valid_coord : valid coordinates
%             :  - org_size : original size of coordinates [Npoint x Ndim]
%             :  - v_coord_idx : index of valid coord in original[N x 1]
% [note]
%
% [history]
%   2007-04-18 (Sako) initial version
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% --- CHECK ARGUMENTS --- %
if ~exist('coord', 'var') coord = []; end
[coord] = inner_check_arguments(coord);

% --- MAIN PROCEDURE --------------------------------------------------------- %
%
org_size = size(coord); % [Npoints x Ndimension]
Npoints = org_size(1);

valid_coord = [];
v_coord_idx = [];

tmp_idx = [];

for ip = 1:Npoints
  if ~vb_is_invalid_coordinate(coord(ip,:))
    valid_coord = [valid_coord; coord(ip,:)];
    v_coord_idx = [v_coord_idx; ip];
  else
    tmp_idx = [tmp_idx; ip];
  end
end

filt_spec.valid_coord = valid_coord;
filt_spec.org_size    = org_size;
filt_spec.v_coord_idx = v_coord_idx;

%
% --- END OF MAIN PROCEDURE -------------------------------------------------- %

% --- INNER FUNCTIONS -------------------------------------------------------- %
%
function [coord] = inner_check_arguments(coord)
if isempty(coord)
  error('coord is a required parameter');
end
%
% --- END OF INNER FUNCTIONS ------------------------------------------------- %

%%% END OF FILE %%%
