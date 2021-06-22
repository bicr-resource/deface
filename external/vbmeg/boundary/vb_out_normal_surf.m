function  [Fnew, Vnew, xxn, indx, ix_miss] = vb_out_normal_surf(F,V,normal_mode)
% extract connected surface & make normal vector outward
%  [Fnew, Vnew, xxn, indx, ix_miss] = vb_out_normal_surf(F,V)
% --- Input
% V : vertex of surface
% F : patch index
% normal_mode
% --- Output
% normal_mode = 0
%   Vnew : vertex coordinate for connected surface
%   Fnew : patch index for connected surface
%   xxn  : normal vector for connected surface points 'Vnew'
%   indx : original vertex index of connected vertex points
%   ix_miss : original vertex index of disconnected vertex points
% normal_mode = 1 (Default)
%   Vnew = V
%   Fnew : patch index for connected surface
%   xxn  : normal vector for 'V'
%          xxn(n,:) = 0, if V(n,:) is disconnected point
%   indx : vertex index of connected vertex points
%   ix_miss : vertex index of disconnected vertex points
%
% M. Sato  2006-7-20
%
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

if ~exist('normal_mode','var'), normal_mode = 1; end;

seedID=1;

Npoint = size(V,1);  	% ĺ����
Npatch = size(F,1);  	% �����̿�

xxn   = zeros(Npoint,3);	% ˡ��

Plist = zeros(Npoint,2);	% ���� ����ĺ���ꥹ��
Vlist = zeros(Npoint,2);	% �������� ����ĺ���ꥹ��
Vflg  = zeros(Npoint,1);	% ĺ�������Ѥߥե饰
Fflg  = zeros(Npatch,1);	% �����̽����Ѥߥե饰
FF	  = zeros(Npatch,3);	% �����̥���ǥå���

% ����������ǥå����ꥹ�Ȥκ���
xxF  = vb_neighbor_index(V,F);

% �롼�ȥ���ǥå���
Plist(1,:) = [seedID, xxF{seedID}(1,1)];

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
				% ����ĺ��������Ѥߤˤ���
				Vflg([root, nold, next]) = 1;
		        
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
				% ����ĺ��������Ѥߤˤ���
				Vflg([root, nold, next]) = 1;
		        
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

% �����Ѥߤ�ĺ���Ȼ����̤���Ф�
indx = find(Vflg == 1);
inxf = find(Fflg == 1);
Fnew = FF(inxf,:);

% ̤������ĺ���Ȼ����̤���Ф�
ix_miss = find(Vflg == 0);

switch	normal_mode
case	0
	%  Vnew : connected surface vertex
	%  xxn  : normal vector for 'Vnew'
	[Vnew, Fnew] = vb_trans_index( V, Fnew, indx);
	% outward normal vector
	[xxn , Fnew] = vb_out_normal_vect(Vnew,Fnew);
case	1
	%  Vnew = V
	%  xxn(n,:) = 0, if V(n,:) is disconnected point
	Vnew = V;
	% outward normal vector
	[xxn , Fnew] = vb_out_normal_vect(Vnew,Fnew);
	xxn(ix_miss,:) = 0;
end

%fprintf('New version\n')
