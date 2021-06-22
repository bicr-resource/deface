function	[IX, DD] = vb_distance_to_neigbor(X,Y,Np)
% find NP neighbor points for each sensor position
%   [Xout, IX, DD] = vb_map_eeg_to_head(X,Y,BEM,dx,Np)
% X    : sensor coordinate            [NX x 3]
% Y    : vertex coordinate for search [NY x 3]
% Np   : Np points are searched for each sensor position
% 
% DD   : Distance from X(n,:) to neighbor vertex [NX x Np]
% IX   : Neighbor vertex index of Y for X(n,:)   [NX x Np]
%
% 2010-3-2  M. Sato 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Np','var'), Np = 3; end;

%  Dimension
NX = size(X,1);    % # of EEG sensor
IX = zeros(NX,Np);
DD = zeros(NX,Np);

for n=1:NX
	% Distance from X(n,:)
	dd = (Y(:,1)-X(n,1)).^2 + (Y(:,2)-X(n,2)).^2 + (Y(:,3)-X(n,3)).^2;
	
	% neighbor search
	[d, jx] = sort(dd);
	IX(n,:) = jx(1:Np)'; 
	DD(n,:) = sqrt(d(1:Np))';
	
end

