function B_sarvas = vb_multi_sarvas( Xdipole, Qdipole, Xmeg, Qmeg )
% magnetic field of plural sarvas
% [usage]
%   B_sarvas = vb_multi_sarvas( Xdipole, Qdipole, Xmeg, Qmeg )
% [input]
%   Xdipole : coordinates of dipole current (NP x 3) NP: Number of Dipole
%   Qdipole : normal vectors of dipole current (NP x 3)
%      Xmeg : coordinates of sensor (Nmeg) Nmeg: Number of MEG sensor
%      Qmeg : orientations of sensor (Nmeg)
% [output]
%  B_sarvas : magnetic field of plural dipole currents at Xdipole
%           : observed at sensor Xmeg (NP x Nmeg)
% [note]
% 
% [update]
%   2006.07.06 (Sako) initial version
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

B_sarvas = zeros(size(Xdipole,1), size(Xmeg,1));
for meg = 1:size(Xmeg,1)
  B_sarvas(:,meg) = vb_sarvas_new(Xdipole, Qdipole, Xmeg(meg,:), Qmeg(meg,:));
end

return;
