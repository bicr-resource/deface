function	[Fall, Vall, Nall, Vinx] = vb_separate_surf(F,V,seedID)
% extract each connected surface
%  [Fall, Vall, Nall, Vinx] = vb_separate_surf(F,V)
% --- Input
% V : vertex of surface
% F : patch index
% --- Output
% Vall{n} : vertex of n-th connected surface
% Fall{n} : patch index of n-th connected surface
% Nall(n) : # of points for n-th connected surface
% Vinx{n} : original vertex index of n-th connected surface
%
% Ver 1.0  by M. Sato  2006-6-4
%  M. Sato  2008-1-16 changed start index
% Ver 2.0
%  M. Sato  2008-7-26 changed algorithm
%     seedID is not used (remained for old version compatibility)
% �ݥꥴ���ǥ��Ϣ���̤���Ф�
%
% �� ���르�ꥺ�� 
%��������ĺ���ꥹ�Ȥ˴ؤ���롼��
%��������ĺ���ꥹ�Ȥ���롼��ĺ��������
%�����롼������̤�������ܻ����̤�õ��
%�������ܻ�����ĺ����Ϣ��ĺ���ꥹ�Ȥȸ��� ����ĺ���ꥹ�Ȥ˲ä���
%����̤�����μ���ĺ�����ĤäƤ���У������
%�������� ����ĺ���ꥹ�Ȥ򿷤�������ĺ���ꥹ�Ȥˤ��ƣ������
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = size(V,1);
Npatch = size(F,1);  	% �����̿�

Plist = zeros(Npoint,1);	% ����ĺ���ꥹ��
Vlist = zeros(Npoint,1);	% ĺ���ꥹ��

Vflg  = zeros(Npoint,1);	% ĺ�������Ѥߥե饰
Fflg  = zeros(Npatch,1);	% �����̽����Ѥߥե饰

% Vertex index inside surface 'F'
Vindx = unique(F(:));

% Discard vertex outside 'F'
Vflg(:) = -1;
Vflg(Vindx) = 0;

% ���ܻ����̥���ǥå����ꥹ�Ȥκ���
% xxF{n} : ĺ�� n �����ܤ����̤�ĺ���ֹ�����ֹ�
xxF  = vb_neighbor_index(V,F);

% �롼�ȥ���ǥå���
seedID = Vindx(1);
Plist(1) = [seedID];

Nsurf = 1;
Nall  = [];
Vflg(seedID) = Nsurf;
Nlist = 1;% ���� ����ĺ����
Ntotal = 0;

while 1,
	
	while Nlist > 0,
		Vlist(:) = 0;	% ����ĺ���ꥹ��
		
		% ����ĺ���˴ؤ���롼��
		for n=1:Nlist,
		    % root ����ǥå����ι���
		    root = Plist(n);
			
			% root ������������ǥå����ꥹ��
			nextID = xxF{root}; 	
		    
		    % �������ꥹ��
		    nlist1 = nextID(:,1); 	% �������ꥹ��1
		    nlist2 = nextID(:,2); 	% �������ꥹ��2
		    flist  = nextID(:,3); 	% ���ܻ����̥ꥹ��
		    
		    % ̤�������̥���ǥå�����õ��
		    nextix = find( Fflg(flist) == 0 );
		    
		    if isempty(nextix), continue;  end;
		    
		    % ̤�����̤Υ���ǥå����ꥹ��
		    nlist1 = nlist1(nextix);
		    nlist2 = nlist2(nextix);
		    flist  = flist(nextix);
		    
		    Fflg(flist) = Nsurf;
		    Vlist(nlist1) = 1;
		    Vlist(nlist2) = 1;
		    
		end;
		% END-����ĺ���˴ؤ���롼��
		
		% Next root index
		ix = find(Vlist == 1 & Vflg == 0);
		
		Nlist = length(ix);
		if Nlist == 0, break; end;
		
		% ���� ����ĺ���ꥹ�Ȥι���
		Plist(1:Nlist) = ix;
		Vflg(ix) = Nsurf;
		Ntotal = Ntotal + Nlist;
	end
	% --- END of connected surface search ---
	
	% �����Ѥߤ�ĺ����
	ix = find(Vflg == Nsurf);
	Nall(Nsurf) = length(ix);
	
	% ̤������ĺ������Ф�
	ix_rest = find(Vflg == 0);
	Nrest = length(ix_rest);
	
	fprintf('Nsurf= %d, N= %d, Ntotal=%d, Nrest=%d\n', ...
	        Nsurf,Nall(Nsurf),Ntotal,Nrest)

	if isempty(ix_rest), break; end;
	
	Nlist = 1;
	Nsurf = Nsurf + 1;
	seedID = ix_rest(1);
	Plist(1) = seedID;
	Vflg(seedID) = Nsurf;
end

% �礭���̤ν���¤��ؤ�
[Nall , id]= sort( -Nall );

Vinx = cell(Nsurf,1);
Vall = cell(Nsurf,1);
Fall = cell(Nsurf,1);

for n=1:Nsurf
	% id(n)-���ܤ��̤�ĺ������Ф�
	indx = find( Vflg == id(n) );
	[Vnew, Fnew] = vb_trans_index( V, F, indx);
	Nall(n) = length(indx);
	Vinx{n} = indx;
	Vall{n} = Vnew;
	Fall{n} = Fnew;
end

return


