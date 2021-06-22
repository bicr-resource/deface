function result = vb_is_invalid_coordinate(coord)
% check given coordinate is valid or not
% [usage]
%   result = vb_is_invalid_coordinate(coord)
% [input]
%    coord : <required> coordinate that you want to check
% [output]
%   result : <<boolean>>
%          :  true : invalid
%          :  false : valid
% [note]
%
% [history]
%   2007-04-13 (Sako) initial version
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)
FUNC_NAME = 'vb_is_invalid_coordinate';
if ~exist('coord', 'var')
  error('<%s> coord is a required parameter', FUNC_NAME);
end

% return value
result = false;

% arrange to [1 x N]
coord = vb_util_arrange_list(coord, 1);

for ic = 1:size(coord, 2)
  if isnan(coord(ic))
    result = true;
    return;
  end
end

return;
%%% END OF FILE %%%
