function	B = vb_dipole_magnetic(x0,J0,X,Q)
% Lead field matrix for dipole current (Biot-Savart)
%   B = vb_dipole_magnetic(x0,J0,X,Q)
%
% INPUT
%   Dipole current source
%   x0 : current dipole position   ( NP x 3 )
%   J0 : current dipole moment     ( NP x 3 )
%   MEG sensor
%   X : sensor position            ( NS x 3 )
%   Q : sensor orientation         ( NS x 3 )
% OUTPUT
%   B : Lead field matrix          ( NP x NS )
%
%   NP : # of dipole points
%   NS : # of MEG sensor
%
% Biot-Savart's law
% ÁÐ¶Ë»Ò¼§¾ì·×»»
% x0 ¤ÎÁÐ¶Ë»Ò J0 ¤¬ ´ÑÂ¬ÅÀ X ¤Ëºî¤ë¼§¾ì¤Î Q Êý¸þ¼Í±Æ
% B = Q*(J0 x Xd)/|Xd|^3 , Xd = X - x0
%
%  Ver-1.0 2004-12-22 Made by M. Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NP = size(x0,1);
NS = size(X,1);

B  = zeros(NP,NS);

if NP >= NS
	for n=1:NS
		Xn = X(n,:);
		Qn = Q(n,:);
		QQ = Qn(ones(NP,1),:);
		Xd = Xn(ones(NP,1),:) - x0;
		Rx = sqrt(sum( Xd.^2, 2 )).^3;
			
		% ³°ÀÑ·×»» JJ x Xd
		JB = [ J0(:,2).*Xd(:,3) - J0(:,3).*Xd(:,2), ...
			   J0(:,3).*Xd(:,1) - J0(:,1).*Xd(:,3), ...
			   J0(:,1).*Xd(:,2) - J0(:,2).*Xd(:,1)];
			
		B(:,n) = sum( JB.*QQ, 2 )./Rx;
	end;
else
	for n=1:NP
		Jn = J0(n,:);
		xn = x0(n,:);
		JJ = Jn(ones(NS,1),:);
		Xd = X - xn(ones(NS,1),:);
		Rx = sqrt(sum( Xd.^2, 2 )).^3;
			
		% ³°ÀÑ·×»» JJ x Xd
		JB = [ JJ(:,2).*Xd(:,3) - JJ(:,3).*Xd(:,2), ...
			   JJ(:,3).*Xd(:,1) - JJ(:,1).*Xd(:,3), ...
			   JJ(:,1).*Xd(:,2) - JJ(:,2).*Xd(:,1)];
			
		B(n,:) = (sum( JB.*Q, 2 )./Rx)';
	end;
end;

B  = (10^-7) * B;
