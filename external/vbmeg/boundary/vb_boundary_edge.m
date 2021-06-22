function	[Vlist] = vb_boundary_edge(F,V)
%  extract boundary edge from surface patch index
% [Vlist] = vb_boundary_edge(F,V)
% --- Input 
%  V    : surface vertex [Nvertex x 3]
%  F    : triangle patch index for surface [Npatch x 3]
% --- Output
% Vlist : boundary vertex list [cell array]
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

DEBUG = 0;
%Jedge = [9 2; 9 1; 1 10; 1 2 ; 2 9; 3 4; 2 1];

% Edge index
Jedge = [F(:,1), F(:,2); F(:,2), F(:,3);F(:,3), F(:,1)];

% Jedge(:,1) <= Jedge(:,2)
jx = find(Jedge(:,1) > Jedge(:,2));
jj = Jedge(jx,1);
Jedge(jx,1) = Jedge(jx,2);
Jedge(jx,2) = jj;

% Sort rows
Jedge = sortrows(Jedge);
Nedge = size(Jedge,1);
Jdiff = Jedge(1:Nedge-1,:) - Jedge(2:Nedge,:);

% find duplicate edge : Jedge(ix,:) = Jedge(ix+1,:)
ix = find( sum(abs(Jdiff),2) == 0 );

% Boundary edge appeares once in edge list 'Jedge'
% Exclude duplicate edges
Id = ones(Nedge,1);
Id(ix)   = 0;
Id(ix+1) = 0;

jx = find(Id > 0);

% index list for boudary edge
Fedge = Jedge(jx,:);

if DEBUG == 1
	NL = size(Fedge,1);
	
	for n=1:NL
		plot3(V(Fedge(n,:),1),V(Fedge(n,:),2),V(Fedge(n,:),3),'r-')
		hold on
	end
end

Vlist = [];
Flist = [];
Nline = 0;

% Make vertex index list for boundary closed loop
% and triangle index to close surface
while ~isempty(Fedge)
	% make closed loop index list
	[ID, Fedge] = vb_close_line(Fedge);
	Nline = Nline + 1;
	Vlist{Nline} = ID;
end

if DEBUG == 1
	for n=1:Nline
		ID = Vlist{n};
		plot3(V(ID,1),V(ID,2),V(ID,3),'r-')
		hold on
		plot3(V([ID(1) ID(n)],1),V([ID(1) ID(n)],2),V([ID(1) ID(n)],3),'r-')
	end
end

return


return
