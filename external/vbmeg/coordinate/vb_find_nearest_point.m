function	[Indx ,ddmin] = vb_find_nearest_point(Vold,Vnew,Rmax,Nstep,Mode,Disp)
% Find nearest points from set of vertex points
%  [Indx ,ddmin] = vb_find_nearest_point(Vold,Vnew,Rmax)
%  [Indx ,ddmin] = vb_find_nearest_point(Vold,Vnew,Rmax,Nstep,Mode,Disp)
% --- Input
% Vold  : Old vertex point (Nold x 3)
% Vnew  : New vertex point (Nnew x 3)
% Rmax  : First, nearest point is searched from slice with Rmax-width
%         For points with distance >= Rmax, 
%         nearest point is searched from all points in 'Vold'
% --- Optional input
% Nstep : Number of steps to divide Z-axis (default = 100)
% Mode  = 0, second search step is omitted
%         1, find nearest point from all points in 'Vold' (default)
% Disp  = 0 : No display output (default)
%         1 : waitbar display
%         2 : text message for search process
% --- Output
% Indx  : Old vertex index nearest to new vertex (Nnew x 1)
% ddmin : Distance to nearest point  (Nnew x 1)
%
%  M. Sato  2005-12-22
%  M. Sato  2006-2-3
%  M. Sato  2006-3-1
% 2011-06-20 taku-y
%  [minor] Progress message was added. 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('Nstep','var')|isempty(Nstep), Nstep = 100; end;
if ~exist('Disp','var'), Disp = 0; end;

% New model point number
Npoint  = size(Vnew,1);
Indx	= zeros(Npoint,1);	% Old vertex index list
ddmin	= zeros(Npoint,1);	% min distance
inew	= zeros(Npoint,1);

Nold    = size(Vold,1);
dd		= zeros(Nold,1);
iold	= zeros(Nold,1);
Vold2	= zeros(Nold,3);

% Slice definition
Zmax  = max(Vnew(:,3));
Zmin  = min(Vnew(:,3));
Zstep = (Zmax-Zmin)/Nstep;

if Zstep == 0
	Zstep = 0.001;
	Zlist = [Zmin , Zmin + Zstep/2];
	Nstep = 1;
else
	Zlist = Zmin:Zstep:Zmax;
	Zlist(Nstep+1) = Zmax + Zstep/2;
end

if ~exist('Rmax','var')|isempty(Rmax),  Rmax  = Zstep; end;

if Disp == 1,
  prg = 0;
  prg_all = Nstep;
  h = waitbar(0,'Nearest point search');
  vb_disp_nonl(sprintf('%3d %% processed',ceil(100*(prg/prg_all))));
end

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
	
	switch Disp
	case 1,
	   waitbar(n/Nstep);
           for ii=1:15; vb_disp_nonl(sprintf('\b')); end
           vb_disp_nonl(sprintf('%3d %% processed',ceil(100*(prg/prg_all))));
           prg = prg+1;
	case 2,
	   fprintf('Searching for %d vs %d points in %d-th slice \n',Nnew,Nold2,n)
	end
	
	if Nold2 == 0, ddmin(inew) = Rmax; continue; end;

	for i=1:Nnew,
		k	  = inew(i);			% New vertex index
		Vnew2 = Vnew( k,:);
		
		% Distance between new and old vertex
        dd	= (Vold2(:,1) - Vnew2(1)).^2 ...
            + (Vold2(:,2) - Vnew2(2)).^2 ...
            + (Vold2(:,3) - Vnew2(3)).^2;
            
		% Find nearest old vertex
	    [md,ix]  = min(dd); 
	    Indx(k)  = iold(ix); 	% Old vertex index for 'k'
	    ddmin(k) = md;  		% min distance
	end;

end

ddmin = sqrt(ddmin);

if Disp == 1, 
  close(h);
  drawnow;
  vb_disp_nonl(sprintf('\n'));
end

if exist('Mode','var') & Mode == 0; return; end;

% Find min distance is larger than Rmax
ixmax = find( ddmin >= Rmax | Indx == 0 );
Nmax  = length(ixmax);

if Nmax==0, return; end;

switch Disp
 case 1,
  fprintf('Searching large distance %d vs %d points\n',Nmax,Nold)
  h = waitbar(0,'Distant point search');
  prg = 0;
  prg_all = Nmax;
  vb_disp_nonl(sprintf('%3d %% processed',ceil(100*(prg/prg_all))));
 case 2,
  fprintf('Searching large distance %d vs %d points\n',Nmax,Nold)
end

% Find nearest point from all vertex
for i=1:Nmax,
	k	  = ixmax(i);			% New vertex index
	Vnew2 = Vnew( k,:);
	
	% Distance between new and old vertex
    dd	= (Vold(:,1) - Vnew2(1)).^2 ...
        + (Vold(:,2) - Vnew2(2)).^2 ...
        + (Vold(:,3) - Vnew2(3)).^2;
        
	% Find nearest old vertex
    [md,ix]  = min(dd); 
    Indx(k)  = ix; 	% Old vertex index for 'k'
    ddmin(k) = md;  %  min distance

    if Disp == 1, 
      waitbar(i/Nmax);
      for ii=1:15; vb_disp_nonl(sprintf('\b')); end
      vb_disp_nonl(sprintf('%3d %% processed',ceil(100*(prg/prg_all))));
      prg = prg+1;
    end
end

ddmin(ixmax) = sqrt(ddmin(ixmax));

if Disp == 1, 
  close(h);
  drawnow;
  vb_disp_nonl(sprintf('\n'));
end

clear inew dd iold Vold2

return;