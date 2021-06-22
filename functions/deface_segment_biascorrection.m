function deface_segment_biascorrection(mri_file)
% Segment mri file using SPM5/8 function
%
% [Usage]
%    deface_segment_biascorrection(mri_file);
%
% [Input]
%    mri_file: NIfTI(.nii) or LAS analyze file(.img)
%
% [Output]
%    bias corrected file :  'm' + mri_file
%    gray matter file    :  'c1' + mri_file
%
% [Note]
%    SPM path should be added to MATLAB.
%    addpath(genpath(spm_path));
%
% Copyright (C) 2018, ATR All Rights Reserved.


%
% --- Previous check
%
spm = which('spm.m');
if isempty(spm)
    error('SPM path should be added to MATLAB.');
end
if nargin ~= 1
    error('Please check function usage.');
end
if exist(mri_file, 'file') ~= 2
    error('Specified file not found %s', mri_file);
end;

%
% --- Main Procedure
%

mri_file = [mri_file, ',1'];

% Segment(SPM5/8)
spm_dir = which('spm.m');
gray_file  = fullfile(spm_dir, 'tpm', 'grey.nii');
white_file = fullfile(spm_dir, 'tpm', 'white.nii');
csf_file   = fullfile(spm_dir, 'tpm', 'csf.nii');

opt.tmp      = str2mat(gray_file, white_file, csf_file);
opt.ngaus    = [2; 2; 2; 4];
opt.regtype  = 'mni';
opt.warpreg  = 1;
opt.warpco   = 25;
opt.biasreg  = 0.0001;
opt.biasfwhm = 60;
opt.samp     = 3;
opt.msk      = '';

res = spm_preproc(mri_file, opt);
sn  = spm_prep2sn(res);

% Create Graymatter and bias correction file.
output.GM  = [0 0 1];
output.WM  = [0 0 0];
output.CSF = [0 0 0];
output.biascor = 1;
output.cleanup = 0;
spm_preproc_write(sn, output);
