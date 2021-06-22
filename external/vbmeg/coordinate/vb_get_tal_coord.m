function [XYZtal, XYZmm] = vb_get_tal_coord(index,xyzfile)
%  Transform cortex coordinate to Talairach coordinate
%  XYZtal = get_mni_coord(index,xyzfile)
%  [XYZtal, XYZmm] = vb_get_tal_coord(index,xyzfile)
% --- Input
% index   : Vertex index corresponding  'V(index,:)' in brainfile
% xyzfile : xyz-file produced by vb_script_atlas2vb.m
% --- Output
% XYZtal  : Talairach coordinate
% XYZmm   : MNI-space coordinate [mm]
%  Transform cortex coordinate 'V(index,:)' in brainfile
%     to Talairach coordinate & MNI-space coordinate
%  Before using this, you should run vb_script_atlas2vb.m
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

load(xyzfile, 'XYZmm','XYZtal');

XYZtal = XYZtal(index,:);	% Talairach coordinate
XYZmm  = XYZmm(index,:);	% MNI-space coordinate
