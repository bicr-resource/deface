function	[Vinx, Nall, ix_rest] = vb_connected_vertex(Vindx,F)
% extract connected vertex index
%  [Vinx, Nall, ix_rest] = vb_connected_vertex(Vindx,F)
% --- Input
% Vindx : vertex index list for search
% F     : patch index list
% --- Output
% Vinx{n} : vertex index of n-th connected surface
% Nall(n) : # of points for n-th connected surface
% ix_rest : disconnected points
%
% Ver 1.0  by M. Sato  2006-11-11
%
% �ݥꥴ���ǥ��Ϣ���̤���Ф�
% �ݥꥴ���ǥ�λ�����ˡ���θ����򳰸�����·����
%
% �� ���르�ꥺ�� 
%�������� ����ĺ���ꥹ�Ȥ˴ؤ���롼��
%�������� ����ĺ���ꥹ�Ȥ���롼��ĺ��������
%�����롼������̤�������ܻ����̤�õ��
%�������ܻ����̤��������ǽ�ĺ����ޤ��Τ�õ��
%����������ĺ�����¤�����·����
%���������̤Τ⤦��Ĥ�ĺ���򺣲�κǽ�ĺ���ˤ���
%��������ĺ���ꥹ�Ȥ˸�������ꤷ���դ�ĺ�����ɲä���
%����̤�����̤��ĤäƤ���У������
%����̤�����μ���ĺ�����ĤäƤ���У������
%�������ꤷ������ĺ���ꥹ�Ȥ򿷤�������ꥹ�Ȥˤ��ƣ������
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

Npoint = max([F(:); Vindx(:)]);  % ĺ����

% 'Vindx'��ޤ�ѥå��Τߤ���Ф�
F = vb_patch_select(Vindx,F,Npoint);

Npoint = max([F(:); Vindx(:)]);  % ĺ����
Npatch = size(F,1);  	% �����̿�

Plist = zeros(Npoint,2);	% ���� ����ĺ���ꥹ��
Vlist = zeros(Npoint,2);	% �������� ����ĺ���ꥹ��
Vflg  = zeros(Npoint,1);	% ĺ�������Ѥߥե饰
Fflg  = zeros(Npatch,1);	% �����̽����Ѥߥե饰
FF	  = zeros(Npatch,3);	% �����̥���ǥå���

% 'Vindx'�ʳ������
Vflg(:) = -1;

% 'Vindx'��̤�����ˤ���
Vflg(Vindx) = 0;

% ���ܻ����̥���ǥå����ꥹ�Ȥκ���
% xxF{n} : ĺ�� n �����ܤ����̤�ĺ���ֹ�����ֹ�
xxF  = vb_neighbor_index(zeros(Npoint,1),F);

% �롼�ȥ���ǥå���
nextID = [];

for j = 1:length(Vindx)
	root = Vindx(j);
	nextID = xxF{root};
 	if ~isempty(nextID),  break; end;
end

if isempty(nextID), 
	ix_rest = Vindx;
	Vinx = [];
	Nall = 0;
	Fall = [];
	return
end

Plist(1,:) = [root, nextID(1,1)];

Nsurf = 1;
Nall  = [];

while 1,
	
	Nlist =1;% ���� ����ĺ����
	Nroot =0;% �����Ѥ�ĺ����
	
	while Nlist > 0,
	
		Nedge = 0;% �������� ����ĺ����
		
		% ����ĺ���˴ؤ���롼��
		for n=1:Nlist,
		    % root ����ǥå����� next ����ǥå����ι���
		    root = Plist(n,1);
		    next = Plist(n,2);
			
			% root ������������ǥå����ꥹ��
			nextID = xxF{root}; 	
		    
		    % �������ꥹ��
		    nlist1 = nextID(:,1); 	% �������ꥹ��1
		    nlist2 = nextID(:,2); 	% �������ꥹ��2
		    flist  = nextID(:,3); 	% ���ܻ����̥ꥹ��
		    
		    % ̤�������̥���ǥå�����õ��
		    nextix = find( Fflg(flist) == 0 );
		    
		    if isempty(nextix), 
		    	continue;
		    end;
		    
		    % ̤�����̤Υ���ǥå����ꥹ��
		    nlist1 = nlist1(nextix);
		    nlist2 = nlist2(nextix);
		    flist  = flist(nextix);
		    
		    Nnext  = length(nextix);
		    Nnew   = Nnext;
		
		    % root �����ܤ���̤�����̥롼��
		    for i=1:Nnext, 
		    	% nlist1/2 ����ǡ����������ĺ�� next ��ޤ��̤�õ��
		        jx1  = find( nlist1==next );
		        jx2  = find( nlist2==next );
		        
		        if ~isempty(jx1),
			       	nold  = next;
		        	jj	  = jx1(1);	    % next ��ޤ��̤Υꥹ�����ֹ�
		        	fid   = flist(jj);  % next ��ޤ��̤����ֹ�
		        	next  = nlist2(jj); % �����̤Τ⤦��Ĥλ�����ĺ��
	
		        	% �������� ����ĺ���ꥹ�Ȥ��ɲ�
		        	Nedge = Nedge + 1;
		        	Vlist(Nedge,:) = [next nold];
			        % ������ĺ������ǥå����������ؤ�
			        FF(fid,:) = [root, nold, next];
			        % �����̤�����Ѥߥꥹ�Ȥ������
			        Fflg(fid) = 1;
					% ����ĺ��������Ѥߤˤ���(���ֹ�����)
					Vflg([root, nold, next]) = Nsurf;
			        
			        % �����̤������̥ꥹ�Ȥ�����
			        inew   = [1:(jj-1),(jj+1):Nnew];
			        flist  = flist(inew);
			        nlist1 = nlist1(inew);
			        nlist2 = nlist2(inew);
			        Nnew   = Nnew-1;
		        elseif ~isempty(jx2),
			       	nold  = next;
		        	jj	  = jx2(1);	    % next ��ޤ��̤Υꥹ�����ֹ�
		        	fid   = flist(jj);  % next ��ޤ��̤����ֹ�
		        	next  = nlist1(jj); % �����̤Τ⤦��Ĥλ�����ĺ��
	
		        	% �������� ����ĺ���ꥹ�Ȥ��ɲ�
		        	Nedge = Nedge + 1;
		        	Vlist(Nedge,:) = [next nold];
			        % ������ĺ������ǥå����������ؤ�
			        FF(fid,:) = [root, nold, next];
			        % �����̤�����Ѥߥꥹ�Ȥ������
			        Fflg(fid) = 1;
					% ����ĺ��������Ѥߤˤ���(���ֹ�����)
					Vflg([root, nold, next]) = Nsurf;
			        
			        % �����̤������̥ꥹ�Ȥ�����
			        inew   = [1:(jj-1),(jj+1):Nnew];
			        flist  = flist(inew);
			        nlist1 = nlist1(inew);
			        nlist2 = nlist2(inew);
			        Nnew   = Nnew-1;
		        end;
		    end
		    % END- (root) �����ܤ���̤�����̥롼�� 
		    
		end;
		% END-����ĺ���˴ؤ���롼��
		
		% ���� ����ĺ���ꥹ�Ȥι���
		Nlist = Nedge;
		Plist(1:Nedge,:) = Vlist(1:Nedge,:);
	
	end
	% --- END of connected surface search ---
	
	% �����Ѥߤ�ĺ����
	Nall(Nsurf) = sum(Vflg == Nsurf);
	
	% ̤������ĺ������Ф�
	ix_rest = find(Vflg == 0);

	if isempty(ix_rest), break; end;
	
	Plist = zeros(Npoint,2);	% ���� ����ĺ���ꥹ��
	Vlist = zeros(Npoint,2);	% �������� ����ĺ���ꥹ��
	
	% �롼�ȥ���ǥå���
	seedJJ = [];
	
	for jj = 1:length(ix_rest)
		seedID = ix_rest(jj);
		seedJJ = xxF{seedID};
	 	if ~isempty(seedJJ),  break; end;
	 end

	if isempty(seedJJ), break; end;
	
	Plist(1,:) = [seedID, seedJJ(1,1)];
	
	Nsurf = Nsurf + 1;
end

inxf = find(Fflg == 1);
FF	 = FF(inxf,:);

% ̤������ĺ������Ф�
ix_rest = find(Vflg == 0);
ix_rest = ix_rest';

% �礭���̤ν���¤��ؤ�
[Nall , id]= sort( -Nall );

Vinx = cell(Nsurf,1);

for n=1:Nsurf
	% id(n)-���ܤ��̤�ĺ������Ф�
	indx = find( Vflg == id(n) );
	Vinx{n} = indx';
	Nall(n) = length(indx);
end

return


