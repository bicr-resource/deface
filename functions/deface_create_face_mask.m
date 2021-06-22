function deface_create_face_mask(org_file, defaced_file, gray_file, face_mask_file)
% make face mask image without including gray matter area.
% [Usage]
%    deface_create_face_mask(org_file, defaced_file, gray_file, face_mask_file);
% [Input]
%          org_file : T1 bias corrected image file.
%      defaced_file : T1 bias corrected defaced image file.
%         gray_file : gray matter file extracted from T1 image.
%    face_mask_file : <<output file>> face mask file,
%
% [Note]
%   org_file - defaced_file  = face mask made by mri_deface. (1)
%                 gray_file  = protection area.              (2)
%            face_mask_file  = (1) - (2)
%
% Copyright (C) 2018, ATR All Rights Reserved.

V1 = spm_vol(org_file);

% create smooth and fillled gray matter volume
gray_vol = spm_read_vols(spm_vol(gray_file));
gray_hdr = spm_vol(gray_file);
[Vx, Fx, xx, gray_vol] = vb_mask_to_surf_expand(gray_vol);

% save filled gray matter volume
[p, n, e] = fileparts(gray_file);
brain_mask_file = fullfile(p, [n, '_brain_mask' e]);
brain_mask_hdr  = gray_hdr;
brain_mask_hdr.fname = brain_mask_file;
spm_write_vol(brain_mask_hdr, gray_vol);

% difference between non-defaced and defaced = face
face_mask = (spm_read_vols(V1) - spm_read_vols(spm_vol(defaced_file)))~= 0;

% remove crossing area between filled gray matter area and mask.
ix = intersect(find(gray_vol(:) ~= 0), find(face_mask(:) ~= 0));
if ~isempty(ix)
    face_mask(ix) = 0;
end

% write face mask
face_mask_hdr = V1;
face_mask_hdr.fname   = face_mask_file;
face_mask_hdr.descrip = 'face mask';

spm_write_vol(face_mask_hdr, face_mask);
