function	W = vb_interpolate3_weight(pos_new,pos_base)
% calculate weight matrix to interporate sensor data
%  W = vb_interpolate3_weight(pos_new,pos_base)
%  pos_new  : sensor position to interporate data  [Nnew  x 3]
%  pos_base : sensor position of reference data    [Nbase x 3]
%  W : sparse weight matrix for interpolation      [Nnew  x Nbase]
% 
%  data_new = W * data_base;
%  data_base(n,t) : data corresponding to pos_base(n,:)             [Nnew  x T]
%  data_new(m,t)  : interporated data corresponding to pos_new(m,:) [Nbase x T]
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Nbase = size(pos_base,1);
Nnew  = size(pos_new,1);

% find Np neighbor points for pos_new
Np = 3;
[indx, dd] = vb_distance_to_neigbor(pos_new,pos_base,Np);
% indx(n,:) : Index of pos_base for neighbor position of pos_new(n,:) 
% dd(n,:)   : Distance from pos_new(n,:) to neighbor position in pos_base

% Weight factor for linear interpolation using 3 neighbor points
weight = vb_linear_interpolate3(dd);
inext = repmat((1:Nnew)', [1 3]);

W = sparse( inext(:) , indx(:) , weight(:) , Nnew, Nbase) ;

%for n = 1:Nnew
%	data_new(n,:) = weight(n,:) * data_base(indx(n,:), :);
%end
