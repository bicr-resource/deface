function   B = vb_face_to_mask(V,F,DIM,vsize,zmin,plot_mode,zindx)
% Make mask from face vertex
%  B = vb_face_to_mask(V,F,DIM)
%  B = vb_face_to_mask(V,F,DIM,vsize,zmin)
%  B = vb_face_to_mask(V,F,DIM,vsize,zmin,plot_mode,zindx)
% --- Input
% V     : face vertex
% F     : patch index
% DIM = [NX, NY, NZ] : Dimension of mask image
% --- Optional Input
% vsize : voxcel size
% zmin  : minimum value for mask in z-axis
% plot_mode, zindx
% --- Output
% B     : Output mask image
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if ~exist('vsize','var'), vsize = 2; end;
if ~exist('plot_mode','var'), plot_mode = 0; end;
if ~exist('zmin','var'),  
	zmin = [];
else
	zmin = ceil(zmin/vsize);
end;

tic
%fprintf('surface to mask\n')

if isempty(zmin)
	% Make surface closed
	[F,V] = vb_close_surf(F,V);
	
	% Make mask image from CSF head surface
	B = vb_surf_to_filled_mask(V, F, DIM, vsize);
else
	% dmin    : minimum length for edge
	dmin  = vsize/2;
	
	B = vb_surf_to_mask(V,F,vsize,dmin,DIM);
	
	% voxcel value for filled voxcel
	filval = 1;
	level  = 0.5;
	
	% Scaling by voxcel size
	V = V/vsize;
	% Start point for filling in
	zmid  = (max(V(:,3)) + min(V(:,3)))/2;
	ix = find( ( V(:,3) >= (zmid - 5) )&( V(:,3) <= (zmid + 5) ) );
	Vcenter = round(mean(V(ix,:),1));
	
	if plot_mode > 0
		zindx = Vcenter(3);
		vb_plot_slice( B, V, zindx, 1, [1 1]);
		hold on
		plot(Vcenter(2),Vcenter(1),'ro')
	end
	
	% Set mask value at zmin to stop filling outside
	B(:,:,zmin) = 1;
	
	fprintf('face flood fill\n')
	
	B = vb_flood_fill_3d(B, Vcenter, filval, level);
	
	% Remove mask for lower than zmin
	B(:,:,1:zmin) = 0;
end

vb_ptime(toc)

if plot_mode > 1
	zindx = (min(V(:,3)):20:max(V(:,3)));
	zindx = ceil(zindx);
	vb_plot_slice( B, V, zindx, 1);
end
