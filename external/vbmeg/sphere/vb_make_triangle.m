function	F = vb_make_triangle(Jlist)
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Jlist{n} : theta(n) に対応する点のインデックス

Ntheta = size(Jlist,1);
F = [];

for n=1:(Ntheta-1),
	jx1 = Jlist{n};
	jx2 = Jlist{n+1};
	N1	= length(jx1);
	N2	= length(jx2);
	ND	= N2-N1;

	if ND<0,
		% Swap jx1 and jx2
		jxx = jx1;
		NN	= N1;
		jx1 = jx2;
		jx2 = jxx;
		N1	= N2;
		N2	= NN;
		ND	= -ND;
	end;
	
	% Add (2*pi)-index
	jx1=[jx1 jx1(1)];
	jx2=[jx2 jx2(1)];
	
	if N1==1,
		% North or South pole
		ii = ones(1,N2);
		jj = 1:N2;
		F1 = [ jx1(ii); jx2(jj); jx2(jj+1)];
		F  = [ F, F1];
	elseif ND==0,
		% N1 = N2 case
		ii = 1:N1;
		F1 = [ jx1(ii); jx2(ii)  ; jx2(ii+1)];
		F2 = [ jx1(ii); jx1(ii+1); jx2(ii+1)];
		F  = [F , F1, F2 ];
	else
		% 交互にfix(N1/ND)とceil(N1/ND)の間隔で
		% 余分な三角形を配置する
		NS = [fix(N1/ND) , ceil(N1/ND)];
		nf = -1;

		N1 = N1+1; 
		N2 = N2+1;
		i  = 1; 
		j  = 1; 
		n  = 0 ;
		
		
		while i < N1,
			
			if n < ND,
				% 交互にfix(N1/ND)とceil(N1/ND)の間隔を使用
				NL = NS( (nf+1)/2 + 1 );
				nf = -nf;
				
				iz=(i+NL-1);
				if iz >= N1, 
					iz = N1-1; 
					NL = N1-i; 
				end;

				jz=(j+NL-1);
				if jz >= N2, 
					jz = N2-1; 
					NL = N2-j; 
					iz = i+NL-1;
				end;
				
				ii = i:iz;
				jj = j:jz;

				F1 = [ jx1(ii); jx2(jj)  ; jx2(jj+1)];
				F2 = [ jx1(ii); jx1(ii+1); jx2(jj+1)];
				F  = [F , F1, F2 ];

				i  = i+NL;
				j  = j+NL+1;
				n  = n+1;
				
				F3 = [ jx1(i); jx2(j-1); jx2(j)];
				F  = [F, F3];
			else
				ii=i:(N1-1);
				jj=j:(N2-1);
				
				F1 = [ jx1(ii); jx2(jj)  ; jx2(jj+1)];
				F2 = [ jx1(ii); jx1(ii+1); jx2(jj+1)];
				F  = [F , F1, F2 ];
				
				i  = N1;
				j  = N2;
			% if-ND-end
			end;
		% while-end
		end;
	% if-else-end
	end;
% theta-loop
end;

F = F';		
