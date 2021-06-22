function [V, F] = vb_reduce_vertex(V,F,Reduce_ratio)
% Make new cortex model with reduced resolution
%  [V, F] = vb_reduce_vertex(V,F,Reduce_ratio)
% �����٤򲼤�������������
%
% Reduce_ratio = 1/Nrate < 1 : ������ο��� 1/Nrate �ˤʤ�
%              = Nreduce > 1 : ������ο��� Nreduce �ˤʤ�
%
% 2005-5-5  by M. Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% ĺ����ɸ V �򺸱���Ǿ��ʬ����
Ndipole  = size(V,1);
NdipoleL = F.NdipoleL ;
NdipoleR = Ndipole - NdipoleL ;

if Reduce_ratio > 1, 
	ReduceL = round(NdipoleL*Reduce_ratio*2/Ndipole);
	ReduceR = round(NdipoleR*Reduce_ratio*2/Ndipole);
else
	ReduceL = Reduce_ratio;
	ReduceR = Reduce_ratio;
end;

V0L = V(1:NdipoleL , :);
V0R = V((NdipoleL+1):Ndipole , :);
F0R = F.F3R	;
F0L = F.F3L	;
F0R = F0R - NdipoleL;

% --- Redeuce patchs

if NdipoleL > 0,
	[F3L,V3L] = reducepatch(F0L,V0L,ReduceL); 
else
	F3L = [];
	V3L = [];
end

NdipoleL = size(V3L,1);

if NdipoleR > 0,
	[F3R,V3R] = reducepatch(F0R,V0R,ReduceR);
	F3R = F3R + NdipoleL;
else
	F3R = [];
	V3R = [];
end

V = [ V3L; V3R ];

F.F3L	   = F3L;
F.F3R	   = F3R;
F.F3	   = [F3L; F3R];
F.NdipoleL = NdipoleL;
