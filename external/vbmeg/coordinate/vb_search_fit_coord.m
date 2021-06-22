function	[trans_opt] = vb_search_fit_coord(V0,Vref,trans_mat,Option)
% Find optimal transformation to fit MRI face and vivid data
% [trans_opt] = vb_search_fit_coord(V0,Vref,trans_mat,Option)
% --- Input
% V0     : Vivid vertex    : target points
% Vref   : MRI face vertex : reference points
% trans_mat : Initial Rigid Body Transformation matrix
% Option : Optimization setting
% --- Output
% trans_opt : optimal transformation to fit MRI face and vivid data
%
%  M. Sato  2006-5-22
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V0,1);

fprintf('Number of reference points = %d\n',size(Vref,1))
fprintf('Number of target points    = %d\n',Npoint)

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

% Rmax = Minimun distance search radius
if isfield(Option,'Rmax') & ~isempty(Option.Rmax)
	parm.Rmax = Option.Rmax; 
else
	parm.Rmax = 0.003; % = 3 [mm]
end;

% Npos = # of head points
if isfield(Option,'Npos') & ~isempty(Option.Npos)
	parm.Npos = Option.Npos; 
else
	parm.Npos = 0;
end;

% pos_rate  = distance weight for head points 
% scan_rate = distance weight for scaned face points
if isfield(Option,'pos_rate') & ~isempty(Option.pos_rate)
	parm.pos_rate = Option.pos_rate; 
else
	parm.pos_rate = 1;
end;
if isfield(Option,'scan_rate') & ~isempty(Option.scan_rate)
	parm.scan_rate = Option.scan_rate; 
else
	parm.scan_rate = 1.0;  
end;

% Search method
if isfield(Option,'method') & ~isempty(Option.method)
	mode = Option.method;
else
	mode = vb_tool_check('Optimization');
	%	 = 0;	% Use 'fminsearch'
	%	 = 1;	% Use 'fminunc' in Optimization Toolbox
end

param_init = zeros(6,1);

switch	mode
case	0
	% Nelder-Mead Simplex Method 
	[optparam, minval, exitflg, output]= ...
	    fminsearch(@vb_calc_fitting, param_init, OPTIONS, V0, Vref, parm);
case	1
	% Unconstrained optimization 
	[optparam, minval, exitflg, output]= ...
		fminunc(@vb_calc_fitting, param_init, OPTIONS, V0, Vref, parm);
case	2
	% Optimization in bounded region
	[optparam, minval, exitflg, output]= ...
		fmincon(@vb_calc_fitting, param_init, ...
		  [],[],[],[], Option.low, Option.up, [], OPTIONS, V0, Vref, parm);
end

trans_opt = vb_rigid_trans_matrix(optparam);

trans_opt = [trans_mat [zeros(3,1); 1]] * trans_opt;

