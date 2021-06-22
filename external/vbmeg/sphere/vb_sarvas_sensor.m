function	B = vb_sarvas_sensor(P, Q, R, S)
% Magnetic field at MEG sensors for one dipole 
%     in spherical brain model (Sarvas Eq.)
% B = vb_sarvas_sensor(P, Q, R, S)
%
% INPUT
%   Dipole current source
%   P : current dipole position   ( 1 x 3 )
%   Q : current dipole moment     ( 1 x 3 )
%   MEG sensor
%   R : sensor position       ( NS x 3 )
%   S : sensor orientation    ( NS x 3 )
% OUTPUT
%   B : Lead field matrix         ( NS x 1 )
%
%   NS : # of sensor
% 
%  2006-12-15 Made by M. Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Dipole position vector
P1 = P(1);
P2 = P(2);
P3 = P(3);

% Dipole moment vector
Q1 = Q(1);
Q2 = Q(2);
Q3 = Q(3);

% Sensor position vector
R1 = R(:,1);
R2 = R(:,2);
R3 = R(:,3);

% Difference from dipole to sensor : (NS x 3)
dP = [(R1-P1), (R2-P2), (R3-P3)];

% Square norm    :  (NS x 1)
dd = sum(dP.^2, 2);
d  = sqrt(dd);
rr = sum(R.^2,2);
r  = sqrt(rr);

% Inner product  : (NS x 3) * ( 3 x 1 ) = (NS x 1)
dr = sum( dP .* R , 2);
pr = R * P(:);

% Cross product (Q x P) : (3 x 1)
QP = [Q2.*P3-Q3.*P2; ...
      Q3.*P1-Q1.*P3; ...
      Q1.*P2-Q2.*P1  ];

% Denominator of magnetic potencial  (NS x 1)
f  = dd .* r + d .* dr ;

% ( Gradient of 'f' ) * S
df = (d + dd./r).* sum(R.*S,2)  + ( d + 2*r + dr./d ).* sum(dP.*S,2);

% Magnetic field for sensor orientation vector 'S'
B  = (S*QP)./f - (R*QP).*df./(f.^2);
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
