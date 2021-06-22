function	[ddsum, ddmin] = vb_distance_min3d(Vold, Vnew, Rmax, Zstep)
% Average minimum distance from set of points {Vnew} to set of points {Vold}
%
%  [ddsum, ddmin] = vb_distance_min3d(Vold, Vnew, Rmax, Zstep)
% --- Input
% Vnew      : New vertex point
% Vold      : Old vertex point
% Rmax      : Max radius for point search
% Zstep     : Step size to divide Z-axis
% --- Output
% ddmin(n) = Min distance from Vnew(n) to point set {Vold}
% ddsum    = sum_n ddmin(n)/Nnew
%
%  M. Sato  2006-2-3
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Zstep','var') | isempty(Zstep), Zstep = 0.002; end; % [m]

% New model point number
Npoint  = size(Vnew,1);
ddmin	= zeros(Npoint,1);	% min distance
inew	= zeros(Npoint,1);

Nold    = size(Vold,1);
dd		= zeros(Nold,1);
iold	= zeros(Nold,1);
Vold2	= zeros(Nold,3);

% Slice definition
Zmax  = max(Vnew(:,3));
Zmin  = min(Vnew(:,3));
Nstep = ceil((Zmax-Zmin)/Zstep);

if Nstep == 0,
	Nstep = 1;
	Zlist = [Zmax , Zmax + Zstep/2];
else
	Zstep = (Zmax-Zmin)/Nstep;
	Zlist = Zmin:Zstep:Zmax;
	Zlist(Nstep+1) = Zmax + Zstep/2;
end

if ~exist('Rmax','var') | isempty(Rmax),  Rmax  = 0.003; end; % [m]

% Find nearest point from slice region
% Loop for slices in z-direction
for n=1:Nstep,
	% Find vertex points in this slice
	inew  = find( Vnew(:,3) >= Zlist(n) ...
	            & Vnew(:,3) <  Zlist(n+1) );
	iold  = find( Vold(:,3) >= (Zlist(n)   - Rmax) ...
	            & Vold(:,3) <  (Zlist(n+1) + Rmax) );

	Nnew  = length(inew);
	Nold2 = length(iold);
	Vold2 = Vold(iold,:);
	
%	fprintf('Searching for %d vs %d points in %d-th slice \n',Nnew,Nold2,n)

	if Nold2 == 0, ddmin(inew) = Rmax; continue; end;
	
	for i=1:Nnew,
		k	  = inew(i);			% New vertex index
		Vnew2 = Vnew( k,:);
		
		% Distance between new and old vertex
        dd	= (Vold2(:,1) - Vnew2(1)).^2 ...
            + (Vold2(:,2) - Vnew2(2)).^2 ...
            + (Vold2(:,3) - Vnew2(3)).^2;
            
		% Find nearest old vertex
	    ddmin(k)  = min(dd); 
	end;

end

% Find min distance is larger than Rmax
ixmax = find( ddmin >= Rmax );

Nmax  = length(ixmax);

%fprintf('Searching large distance %d vs %d points\n',Nmax,Nold)

% Find nearest point from all vertex
for i=1:Nmax,
	k	  = ixmax(i);			% New vertex index
	Vnew2 = Vnew( k,:);
	
	% Distance between new and old vertex
    dd	= (Vold(:,1) - Vnew2(1)).^2 ...
        + (Vold(:,2) - Vnew2(2)).^2 ...
        + (Vold(:,3) - Vnew2(3)).^2;
        
	% Find nearest old vertex
    ddmin(k)  = min(dd); 
end;

ddsum = sum(ddmin)/Npoint;
