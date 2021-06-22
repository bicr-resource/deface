function	c = vb_cross2(a,b)
% Fast calculation of cross product
% c = vb_cross2(a,b)
% c = a x b
% a, b , c : N x 3 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

c = [a(:,2).*b(:,3)-a(:,3).*b(:,2), ...
     a(:,3).*b(:,1)-a(:,1).*b(:,3), ...
     a(:,1).*b(:,2)-a(:,2).*b(:,1)];
