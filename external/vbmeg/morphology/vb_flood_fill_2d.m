function	[V, Vflag] = vb_flood_fill_2d(V,start,fillval,level)
% ����'level'��꾮�����ͤ���ĥܥ������'fillval'���ɤ�Ĥ֤�
% V      : 2D ���᡼��
% V(x,y) : ��(x,y)�ˤ������� ( x=1:NX, y=1:NY )
%
% start  : ����롼�ȥ���ǥå���
% fillval: �ɤ�Ĥ֤��� > level
% level  : ����
%
% 2005-1-18  M. Sato 
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% Vflag  : �ɤ�Ĥ֤��줿�ܥ�����Υޥ����ѥ�����

% ����ĺ������֤�é�äƤ������
% �� ���르�ꥺ�� 
%��������ĺ���ꥹ�Ȥ˴ؤ���롼��
%��������ĺ���˴ؤ���롼��
%��������ĺ����̤��������ĺ�����Ф������
%������������ĺ���ꥹ�Ȥ˽�������ĺ�����ɲä���
%����̤�����μ���ĺ�����ĤäƤ���У������
%������������ĺ���ꥹ�Ȥ����ĺ���ꥹ�Ȥˤ��ƣ������

if nargin<3, fillval=1; end;
if nargin<4, level=1; end;
if fillval < level, 
	error('level value is larger than fill value\n')
end

[NX,NY] = size(V);

NN	  = NX*NY;
D	  = 2;

% Vflag(x,y) = 1 : (x,y) �Ͻ����Ѥ�
Vflag = zeros(NX,NY);	% ĺ�������Ѥߥե饰
Plist = zeros(NN,D);	% ����ĺ������ǥå���
Vlist = zeros(NN,D);	% ���� ĺ������ǥå���
Nroot = size(start,1);	% ����ĺ����

Nlist = 0; % ���� ĺ�����ν����

% ����롼�ȥ���ǥå����Υ����å�
for n=1:Nroot,
    % root ����ǥå���
    root = start(n,:); 
	
	if root(1)<1 | root(1)>NX | root(2)<1 | root(2)>NY,
		continue;
	end
	
	if	V(root(1),root(2)) < level,
		V(root(1),root(2)) 	   = fillval;
		Vflag(root(1),root(2)) = 1;
		Nlist          = Nlist + 1;
		Vlist(Nlist,:) = root ;
	end;
end

% �롼�ȥ���ǥå����ν����
Nroot = Nlist;
Plist(1:Nroot,:) = Vlist(1:Nroot,:);

% ����ĺ���ꥹ�Ȥ˴ؤ���롼��
while Nroot > 0,

    Nlist = 0; % ���� ĺ�����ν����

	% ����ĺ���˴ؤ���롼��
	for n=1:Nroot,
	    % root ����ǥå����ι���
	    root = Plist(n,:); 
		
		% root �������� (x+1,y)
		next = [root(1)+1, root(2)];
		
		if root(1) < NX ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,
			
			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
		% root �������� (x-1,y)
		next = [root(1)-1, root(2)];
		
		if root(1) > 1 ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,

			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
		% root �������� (x,y+1)
		next = [root(1), root(2) + 1];
		
		if root(2) < NY ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,

			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
		% root �������� (x,y-1)
		next = [root(1), root(2) - 1];
		
		if root(2) > 1 ...
			& Vflag(next(1),next(2))==0 ...
			& V(next(1),next(2)) < level,

			V(next(1),next(2)) 	   = fillval;
			Vflag(next(1),next(2)) = 1;
			Nlist          = Nlist + 1;
			Vlist(Nlist,:) = next ;
		end;
	    
	end;
	% END-����ĺ���˴ؤ���롼��
	
	% ���� ����ĺ���ꥹ�Ȥι���
    Nroot = Nlist;
	Plist(1:Nroot,:) = Vlist(1:Nroot,:);
	
end

