function	B = vb_sarvas_new(P, Q, R, S)
% B = vb_sarvas_new(P, Q, R, S)
% Magnetic field for multiple dipoles at a single MEG sensor
%     in spherical brain model (Sarvas Eq.)
%
% INPUT
%   Dipole current source
%   P : current dipole position   ( NP x 3 )
%   Q : current dipole moment     ( NP x 3 )
%   MEG sensor
%   R : one of sensor position    ( 1 x 3 ) or ( 3 x 1 )
%   S : its sensor orientation    ( 1 x 3 ) or ( 3 x 1 )
% OUTPUT
%   B : Lead field matrix         ( NP x 1 )
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%   NP : # of dipole points
% 
%  2004-12-15 Made by M. Sato

% Dipole position vector
P1 = P(:,1);
P2 = P(:,2);
P3 = P(:,3);

% Dipole moment vector
Q1 = Q(:,1);
Q2 = Q(:,2);
Q3 = Q(:,3);

% Sensor position vector
R  = R(:);
R1 = R(1);
R2 = R(2);
R3 = R(3);

% Sensor orientation vector
S  = S(:);

% Difference from dipole to sensor : (NP x 3)
dP = [(R1-P1), (R2-P2), (R3-P3)];

% Square norm    :  (NP x 1)
dd = sum(dP.^2, 2);
d  = sqrt(dd);
rr = sum(R.^2);
r  = sqrt(rr);

% Inner product  : (NP x 3) * ( 3 x 1 ) = (NP x 1)
dr = dP*R;
pr =  P*R;

% Cross product (Q x P) : (NP x 3)
QP = [Q2.*P3-Q3.*P2, ...
      Q3.*P1-Q1.*P3, ...
      Q1.*P2-Q2.*P1  ];

% Denominator of magnetic potencial
f  = dd .* r + d .* dr ;

% ( Gradient of 'f' ) * S
df = (d + dd./r).* (R'*S)  + ( d + 2*r + dr./d ).* (dP*S);

% Magnetic field for sensor orientation vector 'S'
B  = (QP*S)./f - (QP*R).*df./(f.^2);
B  = (10^-7) * B;

return
% END of program

%% Execution speed comparison with repmat
%  Time
%  0.23   dP = [(R1-P1), (R2-P2), (R3-P3)];  
%
%% This code is faster than the following repmat code for large data
%% since no memory allocation is needed 
% ( R1, R2, R3 are scalars)
%
%  0.36   R  = repmat(R',[size(P,1) 1]);  
%  0.17   dP = R - P;  
