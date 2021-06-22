function [dmax,dmin] = vb_distance_brain_face(Vbrain,Vface)
% Distance between face and brain surface
%  [dmax,dmin] = vb_distance_brain_face(Vbrain,Vface)
%
% 2008-10-10 Masa-aki Sato
% 2008-11-4  Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% change to mm
Vface  = Vface  * 1000;
Vbrain = Vbrain * 1000;

Rmax  = 20; % Max radius in minimum distance search at 1st stage [mm]
Nstep = 30; % number of division in Z-axis for minimum distance search
Nskip = 10; % skip number for face vertex

%Zwid = 20;  % Z-length for search [mm]
%Ztop = 40;  % Z-length of upper face [mm]
%Zmax = 150; % Z-length of search area of face [mm]
%Zface = max(Vface(:,3));
%Zmax  = max(Vbrain(:,3));

Zmin  = min(Vbrain(:,3));

% Z-coordinate for max of brain Y-axis (front)
[Ymax, imax] = max(Vbrain(:,2));
Z1 = Vbrain(imax,3);
% Z-coordinate for min of brain Y-axis (back)
[Ymin, imin] = min(Vbrain(:,2));
Z2 = Vbrain(imin,3);

% Middel of Z-axis to separate up/low brain
Zmid = min(Z1,Z2);

% Select upper face
jx = find( Vface(:,3)  >= Zmid);
jx = jx(1:Nskip:end);

%fprintf('# of selected upper face vertex = %d\n',length(jx))

% Distance from upper face to brain surface
[indx ,dup] = vb_find_nearest_point(Vbrain,Vface(jx,:),Rmax,Nstep);

% Select lower face
jx = find( Vface(:,3)  < Zmid & Vface(:,3) >= Zmin);
jx = jx(1:Nskip:end);

%fprintf('# of selected lower face vertex = %d\n',length(jx))

% Distance from lower face to brain surface
[indx ,dlow] = vb_find_nearest_point(Vbrain,Vface(jx,:),Rmax,Nstep);

dmax = max(dup);
dmin = min( [dup ; dlow] );

return


%Zmid = min( Vbrain([ix1; ix2; ix3; ix4], 3))
%Zmid = min(Zmid, (Zup - Ztop)) - Zwid;
%
%Zstp = 1;
%
%Nz = ceil((Zup-Zmin)/Zstp);
%z  = fix((Vbrain(:,3) - Zmin)/Zstp);
%w  = zeros(Nz,1);
%
%% area in axial brain slice
%for n=1:Nz
%	ix = find( z==n );
%	if isempty(ix), continue; end;
%	
%	Xmax = max(Vbrain(ix,1));
%	Xmin = min(Vbrain(ix,1));
%	Ymax = max(Vbrain(ix,2));
%	Ymin = min(Vbrain(ix,2));
%	
%	w(n) = (Xmax - Xmin) * (Ymax - Ymin);
%end
%
%[wmax, imax] = max(w);
%Zmid = z(imax) * Zstp + Zmin
