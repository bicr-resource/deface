function   avw = change_orient_analyze(avw, orient_now, flip_sw)
%  Change orientation of analyze file image
%    avw = change_orient_analyze(avw, orient_now)
%    avw = change_orient_analyze(avw, orient_now, flip_sw)
% --- Input/output
% avw.hdr - a struct with image data parameters.
% avw.img - a 3D matrix of image data (double precision).
% orient_now : orient number of current image
% flip_sw : RAS or LAS switch
%         = -1 : LAS [default]
%         = +1 : RAS
% --- orient_now
% orient_now   = [orient_now_x  orient_now_y  orient_now_z]
% orient_now_x : current x-axis orient number defined below
% orient_now_y : current y-axis orient number defined below
% orient_now_z : current z-axis orient number defined below
% --- orient number
% Left to Right           1 [R]  % Right to Left          -1 [L]
% Posterior to Anterior   2 [A]  % Anterior to Posterior  -2 [P]
% Inferior to Superior    3 [S]  % Superior to Inferior   -3 [I]
%
% --- orient
%   'orient_now' us transformed to 'orient' in the program
% orient : axis dim to get RAS coordinate
%        = [orient_x  orient_y  orient_z]
% orient_x : Left to Right axis dim of current image
% orient_y : Posterior to Anterior axis dim of current image
% orient_z : Inferior  to Superior  axis dim of current image
%            current image axis dim is [+-1/+-2/+-3] for [+-x/+-y/+-z]
% --- Example
% - 現在の座標軸の方向
% orient_now = [2 -3  1]; % x+: A , y+: I , z+: R   : AIR
% - RAS座標へ置換
% orient     = [3  1 -2]; % z -> X, x -> Y, -y -> Z : RAS
%  --- Permutation of axis
% img_RAS(j3,j1,j2) = img_now(j1,j2,j3)
%  --- Flip axis
% img_RAS = img_RAS(:,:,N3:-1:1)
%
% Made by Masa-aki Sato 2008-02-17

% avw = avw_img_read(fname);

if ~exist('orient_now','var'), orient_now = [2 -3 1]; end;
if ~exist('flip_sw','var'), flip_sw = -1; end; 

orient = zeros(1,3);

% Convert 'orient_now' to 'orient'
for j=1:3
	ix = find( abs(orient_now) == j );
	orient(j) = ix * sign(orient_now(ix));
end

% Left/Right flip switch
orient(1) = orient(1)*flip_sw;

fprintf('Orient = [%d  %d  %d]\n', orient)

%
%  --- Change orientation of image
% 
avw = change_orient_ras(avw , orient);

return
% --- sform transform
% i = 0 .. dim[1]-1
% j = 0 .. dim[2]-1
% k = 0 .. dim[3]-1
% x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
% y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
% z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
% --- matrix form
% [x ; y ; z] = R * [i ; j ; k] + T

% No flip case
% x = i + T1 (i=0:N1-1)
%   = ii + X0 (ii=1:N1, X0=T1-1)
% Flip case
% x = -i + T1 (i=0:N1-1)
% ii= N1 - i (ii=1:N1)
% x = ii + X0 (ii=1:N1, X0=T1-N1)

%dim = avw.hdr.dime.dim(2:4)
%pixdim = avw.hdr.dime.pixdim(2:4)

% DIM     = avw.hdr.dime.dim(2:4)           % 画像サイズ
% VOX     = avw.hdr.dime.pixdim(2:4)        % voxelサイズ
% TYPE    = avw.hdr.dime.datatype           % data type
% ORIGIN  = avw.hdr.hist.originator(1:3)    % 画像の原点
