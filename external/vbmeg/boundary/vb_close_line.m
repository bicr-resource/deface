function	[ID, Fnew] = vb_close_line(FL)
% make ordered vertex list for closed loop
% [ID, Frest] = vb_close_line(FL)
% FL : edge index list
% FL(n,1:2) : two vertex index for n-th edge
% ID : vertex index list for closed loop
% Frest : remaining edge index list unused for ID
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NL = size(FL,1);

% Vertex list
Ix = unique(FL(:));
NV = length(Ix);
NN = max(Ix);

% edge index table for each vertex
% FL(n,1)  , FL(n,2)   : two vertex index for n-th edge
% Tbl(id,1), Tbl(id,2) : two edge index for id-th vertex
Tbl  = zeros(NN,2);
Vflg = zeros(NN,1);

for n= 1:NL
	id = FL(n,1);
	Vflg(id) = Vflg(id) + 1;
	
	Tbl(id,Vflg(id)) = n;

	id = FL(n,2);
	Vflg(id) = Vflg(id) + 1;
	
	Tbl(id,Vflg(id)) = n;
end

List = zeros(NV,1);
Vflg = zeros(NN,1);
Fflg = zeros(NL,1);

id  = Ix(1);	% vertex id

for n=1:NV
	Vflg(id) = 1;
	List(n)  = id;
	
	% edge index for id-th vertex 
	Fid1 = Tbl(id,1);
	Fid2 = Tbl(id,2);
	
	% check the edge is already used or not
	if Fid1 > 0 & Fflg(Fid1) == 0,
		Fid = Fid1;
	elseif Fid2 > 0 & Fflg(Fid2) == 0,
		Fid = Fid2;
	else
		break;
	end
	
	Fflg(Fid) = 1;
	
	% vertex index for Fid-th edge
	id1 = FL(Fid,1);
	id2 = FL(Fid,2);
	
	% check the vertex is already used or not
	if Vflg(id1) == 0,
		id = id1;
	elseif Vflg(id2) == 0,
		id = id2;
	else
		break;
	end
	
end

% ordered vertex list
ID = List(1:n);

% find unused edge 
ix = find( Fflg == 0 );

Fnew = FL(ix,:);

return
