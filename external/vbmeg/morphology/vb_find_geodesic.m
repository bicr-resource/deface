function [ID, DD] = vb_find_geodesic(Jstart, Jend, xxF, xxD ,Rmax)
% find minimum path along cortical surface
%   [ID, DD] = vb_find_geodesic(Jstart, Jend, xxF, xxD ,Rmax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        ��û��Υ��ϩõ��
% ���ܶ�˵���ꥹ��( xxF ) �Ȥ��ε�Υ( xxD ) ��Ȥä�
% ����˱�äƺ�û��Υ�ǳ��������齪���ޤǤη�ϩ��õ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
%   Jstart	: �������Υ���ǥå���
%   Jend	: �����Υ���ǥå���
%   xxF{i}  : ���ܶ�˵������ǥå���
%   xxD{i}  : ���ܶ�˵����Υ
%   Rmax	: õ������Ⱦ��
% OUTPUT
%   ID  : ��ϩ������ǥå���
%   DD	: ���ѵ�Υ
%
% Made by Masa-aki Sato on 2005-1-28
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���르�ꥺ�� �� �Ƕ�˵���ꥹ�Ȥ��Ѥ��� Tree õ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%������ʬ���Ȥ�롼�Ȥˤ���
%�����ƥ롼���������ܶ�˵���ν����������ꥹ�Ȥ���Ͽ����
%�����������ꥹ�Ȥ���Ǥ���ޤǤ˻��Ƥ��ʤ�����������������Ф���
%������ȯ������������ޤǤ����ѵ�Υ��׻�(��ϩ�˰�¸)
%������ȯ������������ޤǤκ�û���ѵ�Υ�����
%�������ѵ�Υ������Ⱦ�°���ˤ������򸫤Ĥ���
%�����嵭�����򿷤����롼�Ȥˤ��ƣ��������
%������������ã�����齪λ
%��������Ⱦ�°���ˤ��뿷�����롼�Ȥ�̵���ʤä��Ȥ��˽�λ

nextID  = Jstart; 	% ��˵������ǥå����ꥹ��
prevID  = 0; 		% 1���������Υ���ǥå����ꥹ��
nextDD	= 0;		% ��˵�����ѵ�Υ�ꥹ��
rootix	= Jstart;  	% �롼�ȤΥ���ǥå����ꥹ��
rootd	= 0;  		% �롼�Ȥ����ѵ�Υ�ꥹ��
itree	= 0;  		% tree number

while itree==0 | ~isempty(rootix),  
    itree	 = itree+1;
    nroot	 = size(rootix,1); % ����Υ롼������
    
    % ������ : ���ƤΥ롼�Ȥ����ܶ�˵��
    ixlist = []; % ���ܶ�˵������ǥå����ꥹ��
    jplist = []; % 1���������Υ���ǥå���
    ddlist = []; % ���ܶ�˵���ؤ����ѵ�Υ�ꥹ��
    
    for i=1:nroot, 
    	iroot  = rootix(i);	% �롼�ȤΥ���ǥå���
	    ixlist = [ixlist; xxF{iroot}]; 				% ���ܶ�˵������ǥå���
	    ddlist = [ddlist; xxD{iroot} + rootd(i) ];	% ���ܶ�˵���ؤ����ѵ�Υ
	    newnum = length(xxF{iroot});
	    jplist = [jplist; iroot(ones(newnum,1))];	% 1���������Υ���ǥå���
    end;
    
    % �������ιʤ����
    ixuniq = unique(ixlist);  			% ��ʣ����ǥå�������
    nextix = vb_setdiff2(ixuniq,nextID);  	% õ���ѤߤΥ���ǥå�������

    % õ������������ǥå���
    nextix = nextix(:);
    Nnext  = length(nextix);
    nextd  = zeros(Nnext,1);
    prevj  = zeros(Nnext,1);
    
    for i=1:Nnext,  % Loop of new dipoles
    	% ixlist ����� nextix(i) ������������ǥå��������
    	% Jstart ���� nextix(i) ��ʣ���η�ϩ���б�
        jx = find( nextix(i)==ixlist );
        
        % nextix(i) �ؤκ�û���ѵ�Υ��õ��
        [dmin ,jmin] = min(ddlist(jx)); 
        % ��û���ѵ�Υ
        nextd(i) = dmin;
        % 1���������Υ���ǥå���
        prevj(i) = jplist(jx(jmin));
    end
    
    % ��������ã�����������å�
    jfinal  = find(nextix == Jend);
    
    if isempty(jfinal)
	    % ����Ⱦ�°���θ�������õ��
	    okix	= find(nextd<Rmax); % ����Ⱦ�°���θ�������õ��
	    rootix	= nextix(okix);  	% ����Ⱦ�°���θ�����(����Υ롼����)
	    rootd	= nextd(okix);  	% ���κ�û���ѵ�Υ
	    prevj   = prevj(okix);		% 1���������Υ���ǥå���
	
	    % ��˵���ꥹ��
	    nextID = [nextID ; rootix ];% ��˵���ꥹ��
	    prevID = [prevID ; prevj ];	% 1���������Υ���ǥå���
	    nextDD = [nextDD ; rootd  ];% ��û���ѵ�Υ
	else
	    nextID = [nextID ; Jend ];% ��˵���ꥹ��
	    prevID = [prevID ; prevj(jfinal)];	% 1���������Υ���ǥå���
	    nextDD = [nextDD ; nextd(jfinal)];	% ��û���ѵ�Υ
	    break;
	end
end

ID = [];
DD = [];

Nend = length(nextID);
iend = Nend;
% Backtrack
% 1���������Υ���ǥå������Ȥ˽������鳫�����ط�ϩõ��

for n=1:Nend
	ID    = [ID; nextID(iend)];
	DD    = [DD; nextDD(iend)];
	jpre  = prevID(iend);
	
	if jpre == 0, break; end;
	
	iend  = find( jpre == nextID );
end	

ID = flipud(ID);
DD = flipud(DD);
