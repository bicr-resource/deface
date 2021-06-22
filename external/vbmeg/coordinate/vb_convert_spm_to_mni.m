function [XYZmni , XYZtal, dd] = vb_convert_spm_to_mni(V,snfile)
% Convert SPM-right-m to MNI-right-m & Talairach coordinate
% -- Usage
% [XYZmni , XYZtal, dd] = vb_convert_spm_to_mni(V,snfile)
%
% -- Input
%  V : SPM-right-m coordinate [Nveretex * 3]
% snfile  : spatial normalization file created by SPM 
%           The normalize transformation is contained.
% 
% -- Output
% XYZmni  :  MNI coordinate  (unit:m)       [Nveretex * 3]
% XYZtal  :  Talairach coordinate (unit:m)  [Nveretex * 3]
% dd      :  error distance between 'V' and points on the MNI coordinate
%
% Masa-aki Sato 2010-1-15
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);

% Generate MNI coordinate
% XYZmm - 3 x n matrix of XYZ locations 
%         mm-coordinates in MNI-space)
Xmax  =  100; % Max coordinate 
Xmin  = -100; % Min coordinate 
Xstep = 5;    % Step size

% Low resolution coordinate
[X,Y,Z] = ndgrid(Xmin:Xstep:Xmax);
XYZmni  = [X(:)'; Y(:)'; Z(:)'];

% High resolution coordinate
[X,Y,Z] = ndgrid(-2*Xstep:2*Xstep);
dXYZ  = [X(:)'; Y(:)'; Z(:)'];
Nnear = size(dXYZ,2);

%clear X Y Z

%fprintf('--- Back transformation to subject-image (1st)\n');

% Back transformation to subject image
sn = load(deblank(snfile)); 
%[pXYZmni,flip_flag] = vb_unsn_for_mask(XYZmni,sn);  
[pXYZmni] = vb_unsn(XYZmni,sn);  

XYZmni  = XYZmni';	% mm-coordinates in MNI-coordinate
pXYZmni = pXYZmni';	% mm-coordinates in subject image

%if flip_flag, 
%  XYZmni(:,1) = -1*XYZmni(:,1);
%end

%fprintf('--- Mapping MNI-coordinate onto a subject-brain  (1st)\n');

% Max radius for search in the 1st-step
Rmax = 10; 
% Find nearest point in MNI coordinate for each vertex 'V'
[indx, dd] = vb_find_nearest_point(pXYZmni, V*1000, Rmax, 100, 1, 1);
XYZ = XYZmni(indx,:);

% Generate MNI coordinate near target points
XYZmni = zeros(3,Npoint*Nnear);
nst = 0;

for n=1:Npoint
	XYZmni(:, nst+(1:Nnear)) = vb_repadd(dXYZ, XYZ(n,:)');
	nst = nst + Npoint;
end

%fprintf('--- Back transformation to subject-image (2st)\n');

% Back transformation to subject image
[pXYZmni] = vb_unsn(XYZmni,sn);  

XYZmni  = XYZmni';	% mm-coordinates in MNI-coordinate
pXYZmni = pXYZmni';	% mm-coordinates in subject image

%if flip_flag, 
%  XYZmni(:,1) = -1*XYZmni(:,1);
%end

%fprintf('--- Mapping MNI-coordinate onto a subject-brain (2st)\n');

% Max radius for search in the 2nd-step
Rmax = 2;
% Find nearest point in MNI coordinate for each vertex 'V'
[indx, dd] = vb_find_nearest_point(pXYZmni, V*1000, Rmax, 100, 1, 1);

% XYZmni : MNI-coordinate corresponding to V(:,1:3)
XYZmni = XYZmni(indx,:);

% mni2tal : MNI to Talairach coordinate transformation
XYZtal = mni2tal(XYZmni);

XYZtal = XYZtal/1000; % mm -> m
XYZmni = XYZmni/1000; % mm -> m
dd     = dd / 1000;   % mm -> m
