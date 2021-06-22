function	[XYZ] = vb_MNI_to_analyze(XYZmm,fname)
% change MNI-mm  coordinate to analyze Right-hand voxcel coord.
%   [XYZ] = vb_MNI_to_analyze(XYZmm,fname)
% --- Input
% XYZmm - mm-coordinates ( origin is defined by analyze file)
% fname - Standard brain image file 
% --- Output
% XYZ   - Analyze Right-hand voxcel-coordinates 
%
%%% Template file is neurological format (right handed spm).
% MNI T1 template file (voxcel size = 2 x 2 x 2 mm )
% \vbmeg\tool_box\atlas2vb\MNI_atlas_templates\MNI_T1.img
% 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Read image-header
[dim, vox, origin] = analyze_hdr_read(fname);
% origin in voxcel-space -> origin in MNI-mm space
origin = vox .* origin;

% XYZmm - mm-coordinates (origin is defined by 'origin')
% XYZ   - Analyze voxcel-coordinates 
%
% XYZmm(i,:) = [vox(i)*XYZ(i,:) - origin(i)]
% XYZ(i,:)   = ( XYZmm(i,:) + origin(i) )/vox(i)

XYZ(1,:) = round(( XYZmm(1,:) + origin(1) )/vox(1));
XYZ(2,:) = round(( XYZmm(2,:) + origin(2) )/vox(2));
XYZ(3,:) = round(( XYZmm(3,:) + origin(3) )/vox(3));


