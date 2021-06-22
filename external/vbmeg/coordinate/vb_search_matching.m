function	[trans_opt] = vb_search_matching(V0,Vref,trans_mat,Option)
% Find optimal transformation to fit two sets of markers
% [trans_opt] = vb_search_fit_coord(V0,Vref,trans_mat)
% --- Input
% V0     : Vivid vertex    : target points
% Vref   : MRI face vertex : reference points
% Option : Optimization setting
% trans_mat : Initial Rigid Body Transformation matrix
% --- Output
% trans_opt : optimal transformation to fit MRI face and vivid data
%
%  M. Sato  2006-2-3
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

NP  = size(Vref,1);
NP2 = size(V0,1);

if NP ~= NP2, 
	error('Number of marker points are different'); 
end

fprintf('Number of marker = %d\n',NP)

if isfield(Option,'Weight') & ~isempty(Option.Weight)
	Weight = Option.Weight; 
else
	Weight = ones(NP,1); 
end;

% Optimization setting
if isfield(Option,'MaxIter') & ~isempty(Option.MaxIter)
	MaxIter = Option.MaxIter; 
else
	MaxIter = 200; 
end;

if isfield(Option,'TolFun') & ~isempty(Option.TolFun)
	TolFun = Option.TolFun; 
else
	TolFun = 1.e-10; 
end;

OPTIONS = optimset( ...
                    'MaxIter', MaxIter, ...
                    'MaxFunEvals', 2*MaxIter,...
				    'TolX',    1e-6, ...
				    'TolFun',  TolFun, ...
					'display', 'iter', ...
					'GradObj', 'off' ...
				   ); 

% Coordinate Transform by Initial Rigid Body Transformation
if exist('trans_mat','var') & ~isempty(trans_mat)
	V0 = [V0  ones(size(V0,1),1)]*trans_mat;
else
	trans_mat = eye(4,3);
end

%
% --- Minimize the distance by MATLAB optimization
%
param_init = zeros(6,1);

if isfield(Option,'method') & ~isempty(Option.method)
	mode = Option.method;
else
	mode = vb_tool_check('Optimization');
	%	 = 0;	% Use 'fminsearch'
	%	 = 1;	% Use 'fminunc' in Optimization Toolbox
end

switch	mode
case	0
	[optparam, minval, exitflg, output]= ...
	    fminsearch(@vb_calc_matching, param_init, OPTIONS, V0, Vref, Weight);
case	1
	[optparam, minval, exitflg, output]= ...
		fminunc(@vb_calc_matching, param_init, OPTIONS, V0, Vref, Weight);
end

trans_opt = vb_rigid_trans_matrix(optparam);

trans_opt = [trans_mat [zeros(3,1); 1]] * trans_opt;

