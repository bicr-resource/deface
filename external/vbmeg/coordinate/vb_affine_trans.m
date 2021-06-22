function Xout = vb_affine_trans(X, trans_mat, nflag)
% Apply affine transformation to 'X'
%  Xout = vb_affine_trans(X, trans_mat, nflag)
% --- Input
% X         : 3D-coordinate to be transformed (Nx3 vector)
% trans_mat : affine transformation matrix (4 x 3 or 4 x 4)
%      Xout = [X 1] * trans_mat(:,1:3)
% nflag = 1 : X is normal vector and only rotation is applied
% --- Output
% Xout     : transformed coordinate   (Nx3 vector)
% Xout = [X  1]*trans_mat(:,1:3);
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 3, nflag = 0; end;

switch	nflag
case	0
	Xout = [X  ones(size(X,1),1)]*trans_mat(:,1:3);
case	1
	Xout = X*trans_mat(1:3,1:3);
end
