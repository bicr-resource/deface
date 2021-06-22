function [avw, Vspm] = vb_map_mask_image(analyzefile,mask_file,snfile)
% Transform anatomical label in standard space to an individual brain 
% -- Usage
% [B, Vspm] = vb_map_mask_image(analyzefile,mask_file,snfile)
%
% -- Input
% analyzefile   : Subject analyzefile file
% mask_file     : Mask image file 
% snfile        : Created by SPM normalization (Personal-> MNI-template). 
%                 The normalize transformation is contained.
% 
% -- Output
% avw.img  : Transformed mask image (SPM-right)
% avw.hdr.dime.dim(2:4)    : image dimension
% avw.hdr.dime.pixdim(2:4) : voxel size [mm]
% 
% Vspm{n}.xyz   : SPM-right-[m]-coordinate list
% Vspm{n}.label : region label
% -- Function required  
%  spm_dctmtx   :
%  vb_unsn         : back transformation   (by Gohda-san)
%
% --- NOTE 1 ----
% It is highly recommended to recalculate the normalize transformation by
% spm2 !!!
% --- NOTE 2 ----
% Flip can not be considered in this routine.
%
% 2007/06/09 Masa-aki Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Nmax = 100000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Don't modify %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
%%% Backward coordinate transformation 
%%%          from the template brain to a subject's brain  
%%% Template file is neurological format (right handed spm).

% Read mask image
% XYZmni    - 3 x n matrix of XYZ locations 
%             mm-coordinates in atlas-template (origin : MNI-space origin)
% avw.img   - 3D image data

load(mask_file,'avw', 'XYZmni','Indx');

N = length(Indx);

% MNI-coordinate for Indx{n}
%for n=1:N
%	XYZ{n} = XYZmni(:,Indx{n}.ix);
%end

% Extract mask region
mni_id = find(avw.img(:) ~= 0); 
Nmask  = length(mni_id);
Z = avw.img(mni_id);

% MNI-coordinates in atlas-template for brain region
XYZmni = XYZmni(:,mni_id);

fprintf('# of template points = %d\n',Nmask)
fprintf('--- Back transformation to subject-image \n');

% Back transformation to subject image
% pXYZ : SPM-right-[m]-coordinate in subject image 

sn = load(deblank(snfile)); 

% SPM-oordinate for Indx{n}
for n=1:N
	Vspm{n}.xyz   = vb_unsn( Indx{n}.xyz, sn)'*0.001;  
	Vspm{n}.F     = Indx{n}.F;
	Vspm{n}.label = Indx{n}.label;
end

if Nmask > Nmax,
	pXYZ = zeros(Nmask,3);
	Ndata = 0;
	while Ndata < Nmask
		n1 = Ndata + 1;
		n2 = Ndata + Nmax;
		if n2 > Nmask, n2 = Nmask; end;
		Ndata = n2;
		
		xyz = XYZmni(:,n1:n2);
		pXYZ(n1:n2,:) = vb_unsn(xyz,sn)'*0.001; 
	end
else
	pXYZ = vb_unsn(XYZmni,sn)'*0.001;  
end

fprintf('--- Mapping mask image to subject-brain \n');

[Vdim, Vsize] = analyze_hdr_read(analyzefile);

pXYZ  = vb_spm_right_to_analyze_right(pXYZ,Vdim,Vsize);

if Vsize(1)==1 & Vsize(2)==1 & Vsize(3)==1 ,
	[pXYZ, Z] = vb_make_upsample_vertex(pXYZ, Z);
end

B = vb_make_mask_from_vertex(Vdim, pXYZ, Z);

avw.hdr.dime.dim    = [4 Vdim(:)'  1];
avw.hdr.dime.pixdim = [1 Vsize(:)' 1];
avw.img  = B;

return
%
% if coordinate system is left-handed spm, flip x-direction coordinate
% pXYZ(:,1) = -pXYZ(:,1)  ;

% Find nearest point in atlas for each vertex 'V'
% [V]    = vb_load_cortex(brainfile);  % [m]
% [indx] = vb_find_nearest_point(pXYZ, V*1000);

%%%
%%% Map MNI-coordinate to individual's cortical surface
%%%
