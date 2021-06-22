function save_nii_ana(nii, fileprefix, old_RGB)
%  Save NIFTI dataset. Support both *.nii and *.hdr/*.img file extension.
%  If file extension is not provided, *.hdr/*.img will be used as default.
%  For *.hdr/*.img file, Analize format is used
%
%  Usage: save_nii_ana(nii, filename, [old_RGB])
%  
%  nii.hdr - struct with NIFTI header fields.
%  nii.img - 3D (or 4D) matrix of NIFTI data.
%  filename - NIFTI file name.
%
%  old_RGB    - an optional boolean variable to handle special RGB data 
%       sequence [R1 R2 ... G1 G2 ... B1 B2 ...] that is used only by 
%       AnalyzeDirect (Analyze Software). Since both NIfTI and Analyze
%       file format use RGB triple [R1 G1 B1 R2 G2 B2 ...] sequentially
%       for each voxel, this variable is set to FALSE by default. If you
%       would like the saved image only to be opened by AnalyzeDirect 
%       Software, set old_RGB to TRUE (or 1).
%  
%  Part of this file is copied and modified under GNU license from
%  MRI_TOOLBOX developed by CNSP in Flinders University, Australia
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%  - "old_RGB" related codes in "save_nii.m" are added by Mike Harms (2006.06.28) 
%
   
   if ~exist('nii','var') | isempty(nii) | ~isfield(nii,'hdr') | ...
	~isfield(nii,'img') | ~exist('fileprefix','var') | isempty(fileprefix)

      error('Usage: save_nii(nii, filename, [old_RGB])');
   end

   if ~exist('old_RGB','var'), old_RGB = 0; end
   
   filetype = 1;

   %  Note: fileprefix is actually the filename you want to save
   %   
   if findstr('.nii',fileprefix)
      filetype = 2;
      fileprefix = strrep(fileprefix,'.nii','');
   end
   
   if findstr('.hdr',fileprefix)
      fileprefix = strrep(fileprefix,'.hdr','');
   end
   
   if findstr('.img',fileprefix)
      fileprefix = strrep(fileprefix,'.img','');
   end
   
   write_nii(nii, filetype, fileprefix, old_RGB);

%    if filetype == 1
% 
%       %  So earlier versions of SPM can also open it with correct originator
%       %
%       M=[[diag(nii.hdr.dime.pixdim(2:4)) -[nii.hdr.hist.originator(1:3).*nii.hdr.dime.pixdim(2:4)]'];[0 0 0 1]];
%       save(fileprefix, 'M');
%    end
   
   return					% save_nii


%-----------------------------------------------------------------------------------
function write_nii(nii, filetype, fileprefix, old_RGB)

   hdr = nii.hdr;

   switch double(hdr.dime.datatype),
   case   1,
      hdr.dime.bitpix = int16(1 ); precision = 'ubit1';
   case   2,
      hdr.dime.bitpix = int16(8 ); precision = 'uint8';
   case   4,
      hdr.dime.bitpix = int16(16); precision = 'int16';
   case   8,
      hdr.dime.bitpix = int16(32); precision = 'int32';
   case  16,
      hdr.dime.bitpix = int16(32); precision = 'float32';
   case  32,
      hdr.dime.bitpix = int16(64); precision = 'float32';
   case  64,
      hdr.dime.bitpix = int16(64); precision = 'float64';
   case 128,
      hdr.dime.bitpix = int16(24); precision = 'uint8';
   case 256 
      hdr.dime.bitpix = int16(8 ); precision = 'int8';
   case 512 
      hdr.dime.bitpix = int16(16); precision = 'uint16';
   case 768 
      hdr.dime.bitpix = int16(32); precision = 'uint32';
   case 1024
      hdr.dime.bitpix = int16(64); precision = 'int64';
   case 1280
      hdr.dime.bitpix = int16(64); precision = 'uint64';
   case 1792,
      hdr.dime.bitpix = int16(128); precision = 'float64';
   otherwise
      error('This datatype is not supported');
   end
   
   hdr.dime.glmax = round(double(max(nii.img(:))));
   hdr.dime.glmin = round(double(min(nii.img(:))));
   
   if filetype == 2
      fid = fopen(sprintf('%s.nii',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.nii.',fileprefix);
         error(msg);
      end
      
      hdr.dime.vox_offset = 352;
      hdr.hist.magic = 'n+1';
      save_nii_hdr(hdr, fid);
   else
      fid = fopen(sprintf('%s.hdr',fileprefix),'w');
      
      if fid < 0,
         msg = sprintf('Cannot open file %s.hdr.',fileprefix);
         error(msg);
      end
      
      hdr.dime.vox_offset = 0;
      hdr.hist.magic = 'aaa';
      save_nii_ana_hdr(hdr, fid);
      
      fclose(fid);
      fid = fopen(sprintf('%s.img',fileprefix),'w');
   end

   ScanDim = double(hdr.dime.dim(5));		% t
   SliceDim = double(hdr.dime.dim(4));		% z
   RowDim   = double(hdr.dime.dim(3));		% y
   PixelDim = double(hdr.dime.dim(2));		% x
   SliceSz  = double(hdr.dime.pixdim(4));
   RowSz    = double(hdr.dime.pixdim(3));
   PixelSz  = double(hdr.dime.pixdim(2));
   
   x = 1:PixelDim;
   
   if filetype == 2
      skip_bytes = double(hdr.dime.vox_offset) - 348;
   else
      skip_bytes = 0;
   end

   if double(hdr.dime.datatype) == 128

      %  RGB planes are expected to be in the 4th dimension of nii.img
      %
      if(size(nii.img,4)~=3)
         error(['The NII structure does not appear to have 3 RGB color planes in the 4th dimension']);
      end

      if old_RGB
         nii.img = permute(nii.img, [1 2 4 3 5]);
      else
         nii.img = permute(nii.img, [4 1 2 3 5]);
      end
   end

   %  For complex float32 or complex float64, voxel values
   %  include [real, imag]
   %
   if hdr.dime.datatype == 32 | hdr.dime.datatype == 1792
      real_img = real(nii.img(:))';
      nii.img = imag(nii.img(:))';
      nii.img = [real_img; nii.img];
   end

   if skip_bytes
      fwrite(fid, ones(1,skip_bytes), 'uint8');
   end

   fwrite(fid, nii.img, precision);
%   fwrite(fid, nii.img, precision, skip_bytes);        % error using skip
   fclose(fid);

   return;					% write_nii

