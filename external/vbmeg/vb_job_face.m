function	[surf_face] = vb_job_face(imagefile,face_parm)
%
% Morfology operation for face extraction
% MRI��¤���������ɽ�̲��������
%
% ---- Input file name
% imagefile : Analyze 3D image file  (*.img)
% ---- output variable
% surf_face.V = vertex point in face  (SPM-Right-[m] coordinate)
% surf_face.F = patch index for face
% surf_face.face_parm   = parameter structure extracting face
%
% 2006/2/3  M.Sato
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)


if ~exist('imagefile','var')
	%%%% DEBUG Setting %%%%
	udir = [getenv('MATHOME') '/SBIdata-new/Retino-TY/'];
	imagefile = [udir  '3D.img'];
	facefile  = [udir  'TY.face.mat'];
end

% 
% ----- Usually, following setting need not be changed.
%       However, if extraction result is not good enough,
%       change the morphology operation by setting 'Radius' 

% Manual threshold value for face extraction
% �ҥ��ȥ���फ��μ�ư����ǤϤʤ�������ͤ����ꤹ���硢
% ���� 'Graylevel' ���� : Graylevel ����礭���ͤ���ĥܥ������Ƭ���Ȥ������
if ~exist('face_parm','var') | ~isfield(face_parm,'Graylevel')
	Graylevel = [];
	face_parm.Graylevel = Graylevel;
else
	Graylevel = face_parm.Graylevel;
end

% ---- Define order and size of dilation/erosion ----
%      Dilation/erosion are done consecutively according to Radius
%      ����ᡦ��Ω����� (���ե�����) �Ѵ��ν����Ⱦ�¤����
%
% Radius [mm] of Morfology operation
%   R > 0 : dilation
%   R < 0 : erosion
% Example of 'Radius'
%   Radius = [ -2 2 ]; 	   : remove small island in background
%   Radius = [ -2 2 6 -6]; : remove small island & fill holes
%       1. remove small island in background  (R = -2,  2)
%       2. fill holes inside the brain        (R =  6, -6)

% Default morphology setting parameter
if ~isfield(face_parm,'Radius')
	Radius = [ -2 2 2 2 2 -2 -2 -2];
	face_parm.Radius = Radius;
else
	Radius = face_parm.Radius;
end

% Subsampling step size [mm]
% 3D ���������Τ���δְ������ƥåץ�����
if ~isfield(face_parm,'step')
	step = 1;
	face_parm.step = step;
else
	step = face_parm.step;
end

% Prob. to detrmine Threshold value for face extraction
%       using Rayleigh distribution
%    : �طʥΥ���������Rayleighʬ�ۤ˴ޤޤ���Ƚ�Ǥ������ͳ�Ψ
%      �����ͤ��礭���ۤ����ͤ��礭���ʤ�
% Standard value: pmax = 0.998 or 0.999
if ~isfield(face_parm,'pmax')
	pmax = 0.998;	
	face_parm.pmax = pmax;
else
	pmax = face_parm.pmax;
end

%
% ---- Morfology operation for face extraction
%      MRI��¤���������ɽ�̲��������
%
[Fface, Vface] = vb_face_extract(imagefile , Radius, step, pmax, Graylevel);

%
% ---- Output data
%

surf_face.V = Vface;
surf_face.F = Fface;
surf_face.face_parm = face_parm;

Nmri = 3000;
[surf_face.F_reduce, surf_face.V_reduce] = ...
    reducepatch(Fface, Vface, 2 * Nmri);

return
%
% ---- END ----
%
vb_save(facefile,'surf_face','face_parm');

% ��ɽ��
figure;
vb_plot_surf(surf_face.V ,surf_face.F, [0.8 0.7 0.6],'none',1);
view([135, 15]);

