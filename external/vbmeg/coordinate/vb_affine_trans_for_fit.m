function	A = vb_affine_trans_for_fit(X,Y,flag)
% Affine transformation matrix to fit X to Y 
%  A = vb_affine_trans_for_fit(X,Y)
%  A = vb_affine_trans_for_fit(X,Y,flag)
% --- Input
% X : 3D cordinate of N points [N x 3]
% Y : 3D cordinate of N points [N x 3]
% --- Optional input
% flag = 0 (affine transform) , 1 (Rigid transform)
% if flag=1, return rigid transformation (rotation + translation)
%    
% --- Output
% A : affine transformation matrix from X to Y [4 x 3]
% Xout = [X , ones(N,1)] * A
%      : affine transform of X such that Xout and Y becomes close each other
% 
% Masa-aki Sato 2008-2-27
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)


N = size(X,1);
if size(Y,1) ~= N, error('Data size error'); end;
if size(X,2) ~= 3 | size(Y,2) ~= 3 , error('Vector size error'); end;

X  = [X , ones(N,1)];
XX = X' * X;
YX = Y' * X;

% affine transformation matrix
A  = YX / XX;
A  = A';

if ~exist('flag','var') | flag==0, 
	return
end
% Rotation matrix
R = A(1:3,1:3);
R = vb_repmultiply(R , 1./sqrt(sum(R.^2,2)))

R(3,:) = [R(1,2)*R(2,3)-R(1,3)*R(2,2) , ...
          R(1,3)*R(2,1)-R(1,1)*R(2,3) , ...
          R(1,1)*R(2,2)-R(1,2)*R(2,1)];

R(3,:) = R(3,:)/sqrt(sum(R(3,:).^2));

R(1,:) = [R(2,2)*R(3,3)-R(2,3)*R(3,2) , ...
          R(2,3)*R(3,1)-R(2,1)*R(3,3) , ...
          R(2,1)*R(3,2)-R(2,2)*R(3,1)];

A(1:3,1:3) = R;

%Xout = X * A';
