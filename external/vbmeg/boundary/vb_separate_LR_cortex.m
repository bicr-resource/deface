function	[V,F,xx] = vb_separate_LR_cortex(vert,face)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

[Fall, Vall] = vb_separate_surf(face,vert);
% Vall{n} : vertex of n-th connected surface
% Fall{n} : patch index of n-th connected surface

V1 = Vall{1};
V2 = Vall{2};
F1 = Fall{1};
F2 = Fall{2};

% normal vector
[xx1 ,F1] = vb_out_normal_vect(V1,F1);
[xx2 ,F2] = vb_out_normal_vect(V2,F2);

N1 = size(V1,1);
N2 = size(V2,1);

x1 = mean(V1);
x2 = mean(V2);

if x1(1) < x2(1),
	% V1 is left
	V  = [V1 ; V2];
	xx = [xx1; xx2];
	
	F.F3L = F1;
	F.F3R = F2 + N1;
	F.F3  = [F1 ; F2 + N1];
	F.NdipoleL = N1;
else
	% V2 is left
	V  = [V2 ; V1];
	xx = [xx2; xx1];
	
	F.F3L = F2;
	F.F3R = F1 + N2;
	F.F3  = [F2 ; F1 + N2];
	F.NdipoleL = N2;
end
