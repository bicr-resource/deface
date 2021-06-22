function	[B ,B1, B2] = vb_intersect_face_csf(Vhead,Fhead,V,F,R,step,Vdim,Vsize,DW)
% Make mask image for intersection of face and dilated CSF surfaces
%  [B ,B1, B2] = vb_intersect_face_csf(Vhead,Fhead,V,F,R,step,Vdim,Vsize,DW)
% Vhead : CSF surface vertex (SPM-right-m)
% Fhead : patch index
% V     : face vertex (SPM-right-m)
% F     : patch index
% R     : dilation radius [mm]
% step  : voxel size of mask image [mm]
% Vdim  : image dimension
% Vsize : image voxel size [mm]
% DW    : margin of mask image
% B(NX,NY,NZ)  : mask image for Scalp : intersection of B1 & B2
% B1(NX,NY,NZ) : mask image for CSF surface made by Vhead
% B2(NX,NY,NZ) : mask image for face surface made by V
%
% 2008-10-7 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

if nargin < 9, DW = 0; end;

Vhead = vb_spm_right_to_analyze_right_mm(Vhead, Vdim, Vsize);
V     = vb_spm_right_to_analyze_right_mm(V, Vdim, Vsize);

Vhead = Vhead + step*DW;
V     = V + step*DW;

Dim   = vb_mask_image_size(Vdim,Vsize,step) + 2*DW;

% Make mask image from CSF head surface
B1 = vb_surf_to_filled_mask(Vhead, Fhead, Dim, step);

if vb_matlab_version > 6,
	B1 = int8(B1);
end

% Make mask image from face surface
B2 = vb_face_to_mask(V, F, Dim, step);

if vb_matlab_version > 6,
	B2 = int8(B2);
end
%
% --- Dilate CSF surface
% 
B = vb_morphology_operation(B1, R, step);

% Make intersection image
if vb_matlab_version > 6,
	B  = B + B2;
	ix = find( B(:) > 1 );
	B  = zeros(Dim,'int8');
	B(ix) = 1;
else
	B  = double(B) + double(B2);
	ix = find( B(:) > 1 );
	B  = zeros(Dim);
	B(ix) = 1;
end

