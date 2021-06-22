function Jreduce = reduce_cortex(parm,Jindx,Reduce_ratio);
% �����٤򲼤�������������
% Make new cortex model with reduced resolution

% Jindx    : ��Ȥβ����٤����������ǥå���
% Jreduce  : �������������Υ���ǥå���
% Reduce_ratio : ����ǡ�����������ְ����Ȥ�����Ψ
Reduce_ratio = 1/2 : ����1/2 �˴ְ���

----------------------------------------------------
function	Iextract = fat_area(Jarea, R, nextIX, nextDD)
% Ⱦ�� R ����ζ�˵����ꥹ�Ȥ˲ä���
% Dilation according to surface-distance
% Iextract : ������ĺ���ꥹ��
% Jarea    : ĺ���ꥹ��
%   R      : ��˵����Ⱦ�� ( m )
R = 0.015  : ��������Ⱦ�� 15mm ���������ä���

function	Iextract = cut_area(Jarea, R, nextIX, nextDD)
% ��������Ⱦ�� R ����ζ�˵����ꥹ�Ȥ�����
% Erosion according to surface-distance
R = 0.015  : ��������Ⱦ�� 15mm �����������

function	Iextract = close_area(Jarea, R, nextIX, nextDD)
% �������
function	Iextract = open_area(Jarea, R, nextIX, nextDD)
% ��Ω������

function	Iextract = merge_area(Jarea, V)
% ʣ���ΰ�ι�ʻ
% Merge area
% Iextract : ������ĺ���ꥹ��
% Jarea{n} : ĺ���ꥹ��(���륢�쥤)

function	xxP = gauss_filter(parm,Rradius,Rmax,xxP,Iextract)
% Gauss filtering of fMRI activity

------------------------------------------
function	B = dilation_3d(B, R)
% Dilation : ��������Ⱦ�� R ����ζ�˵����ä���
% ��������������Ф��Ƥ����˵������Ԥ�

% B : 3D-�ޥ����ѥ�����
% R : ��˵����Ⱦ�� (�ܥ����륵�����򣱤Ȥ�������Ĺ��)
�ܥ�����ΰ��դΥ������� w (mm) �Ǥ���Ȥ�
Ⱦ�� r (mm) ���������ä��뤿��ˤ�
R = r/w

function	B = erosion_3d(B, R)
% Erosion : ��������Ⱦ�� R ����ζ�˵������
% ��������������Ф��Ƥ����˵������Ԥ�

function	B = closing_3d(B, R1, R2)
% �������
%		dilation_3d(B, R1)
%		erosion_3d( B, R2)

function	B = opening_3d(B, R1, R2)
% ��Ω������
%		erosion_3d( B, R1)
%		dilation_3d(B, R2)

