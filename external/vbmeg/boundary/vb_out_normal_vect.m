function	[xxn ,F] = vb_out_normal_vect(V,F)
% normal vector
%  [xxn ,F] = vb_out_normal_vect(V,F)
% --- Input
% V : vertex of surface
% F : patch index
% --- Output
% xxn : normal vector
% F : patch index
%
%
% Ver 1.0  by M. Sato  2004-2-10
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%
%------  三角面の法線計算 -------
%
Nnew = size(V,1);

% 三角面の法線計算
xxf  = vb_triangle_normal(V,F);
% 頂点の法線計算
xxn  = vb_vertex_normal(V,F,xxf);

% 全点の重心を中心にした時の外向きベクトル
Vsum = sum(V ,1)/Nnew;
Vc	 = V-Vsum(ones(Nnew,1),:);
% 全点の重心を中心にした時の各三角面の重心
Vxx  = (Vc(F(:,1),:) + Vc(F(:,2),:) + Vc(F(:,3),:))/3;

% 外向きベクトルと同じ向きの法線の数
Nsum = sum( sum(xxf.*Vxx ,2) > 0 );

% 三角面数
Npatch = size(F,1);  	

% 法線の向きが外向きと逆の場合は法線の向きを逆にする
if Nsum < (Npatch/2),
	xxn    = - xxn;
	F2	   = F(:,2);
	F(:,2) = F(:,3);
	F(:,3) = F2;
end;

return
