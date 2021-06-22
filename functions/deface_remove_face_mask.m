function deface_remove_face_mask(org_file, mask_file, defaced_file)
% Remove face from T1 file.
% [Usage]
%    deface_remove_face_mask(org_file, mask_file, defaced_file);
%
% [Input]
%        org_file : T1 image file.
%       mask_file : mask file.
%    defaced_file : defaced T1 image file.
%
% Copyright (C) 2018, ATR All Rights Reserved.

org_hdr  = spm_vol(org_file);
mask_vol = spm_read_vols(spm_vol(mask_file));

defaced_vol = spm_read_vols(org_hdr);
defaced_vol(find(mask_vol ~= 0)) = 0;

org_hdr.fname = defaced_file;
org_hdr.descrip = 'defaced';

spm_write_vol(org_hdr, defaced_vol);

