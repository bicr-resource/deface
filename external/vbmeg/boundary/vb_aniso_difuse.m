function	v = vb_aniso_difuse(v,u,Nloop,c)
% anisotropic difusion
% v = vb_aniso_difuse(v,u,Nloop,c)
%
% 2005/2/5 M.Sato
%
% v : 平滑化するマスクパターン(白質・頭蓋内)
% u : v の相補パターン(灰白質・頭蓋)
% Nloop : 拡散回数
% c     : 拡散係数
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      異方性拡散緩和による境界面の平滑化
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N1, N2, N3]=size(v);

siz=[N1 N2 N3];

% 隣接点インデックスリストの作成

% West-East (X-axis) 隣接点インデックス
jw = 1:(N1-1);
je = 2:N1;
% North-South (Y-axis) 隣接点インデックス
jn = 1:(N2-1);
js = 2:N2;
% Up-Down (Z-axis) 隣接点インデックス
jd = 1:(N3-1);
ju = 2:N3;

% 256x256x256　はメモリーエラーになる
% メモリエラーを避けるため、2D-配列計算のループにする
% 2D-配列計算のループの方が3D-配列計算より高速
vw = zeros(N1-1, N2, 1);
vn = zeros(N1, N2-1, 1);
vd = zeros(N1, 1, N3-1);

% 異方性拡散緩和による境界面の平滑化

for n=1:Nloop,
	for k=1:N3,
		% West-east 
		vw   = ( v(je,:,k) - v(jw,:,k) ).*( u(je,:,k) + u(jw,:,k) )*0.5;
		v(jw,:,k) = v(jw,:,k) + c*vw;
		v(je,:,k) = v(je,:,k) - c*vw;
		% North-south
		vn   = ( v(:,js,k) - v(:,jn,k) ).*( u(:,js,k) + u(:,jn,k) )*0.5;
		v(:,jn,k) = v(:,jn,k) + c*vn;
		v(:,js,k) = v(:,js,k) - c*vn;
	end;
		
		% Doun-up
	for k=1:N2,
		vd   = ( v(:,k,ju) - v(:,k,jd) ).*( u(:,k,ju) + u(:,k,jd) )*0.5;
		v(:,k,jd) = v(:,k,jd) + c*vd;
		v(:,k,ju) = v(:,k,ju) - c*vd;
	end;
	
end;	


