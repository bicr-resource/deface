function	Rout = get_transform_axis(RS)
% Get permutation matrix from rotation matrix
%  Rout = get_transform_axis(RS)
% RS   : rotation + flip + scaling [3 x 3]
% Rout : transform matrix corresponding to axis permutation + flip + scaling

% R  = [ex; ey; ez] : rotation matrix 
% RS = diag(ss) * R = diag(ss) * [ex; ey; ez] : rotation matrix with scaling
% X_to = X * RS

% RS * RS' = diag(ss.^2)
% ss = sqrt( diag( RS * RS' ) )

% Get scaling factor
% RS = diag(ss) * R = [sx*ex; sy*ey; sz*ez ]
ss = sqrt( sum( RS.^2, 2 ) );

% Get Rotation matrix corresponding to permutation with flip
% each element is (plus/minus) ones and zeros
R = zeros(3,3);

[tmp, ix] = max(abs(RS), [], 2);

for i = 1:3
   R(i, ix(i)) = sign(RS(i, ix(i)) );
end

Rout = diag(ss) * R;
