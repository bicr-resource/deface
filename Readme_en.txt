This program removes the subject's face from the MRI structure image (NIfTI format: .nii).
This is written in MATLAB and internally uses SPM8 and mri_deface.

Tested environment:
* MATLAB 2013a
* Linux 64bit system.

===============
Installation
===============
1.This program
  Unzip this file to your directory(=$PROGRAM_DIR).
2.SPM8
  Please download SPM8 from
  https://www.fil.ion.ucl.ac.uk/spm/software/spm8/
  and set the path in $PROGRAM_DIR/deface_setpath.m
  path_of_spm   = 'path_of_spm8';
  (NOTICE: it does not work well with SPM12, so be sure to use SPM8.)
3.mri_deface
  Please downolad mri_deface from
  https://surfer.nmr.mgh.harvard.edu/fswiki/mri_deface
  and store the downloaded files in the following location.
    $PROGRAM/external/mri_deface-v1.22-Linux64/mri_deface
                                              /face.gca
                                              /talairach_mixed_with_skull.gca

  NOTE: Downloaded files need to be renamed or unzipped in this way.
  mv mri_deface_linux mri_deface
  gunzip talairach_mixed_with_skull.gca.gz
  gunzip face.gca.gz

=================
Deface operation
=================
1.Launch MATLAB.(We tested it by MATLAB r2013b.)
2.Change current directory to $PROGRAM_DIR and run the deface_set_path.m
  cd($PROGRAM_DIR);
  deface_setpath;
3.Run the deface function. (see Directory structure and Example data and script)
  deface_run(root, id_list)
  root    : root directory of data directory.
  id_list : cell string array like  = {'sub1', 'sub2' ...};
4.Creating deface report as PPTX file.
  deface_export_result_as_pptx(root, id_list, output_pptx_file);

============================================
Directory structure.
============================================
files should be prepared in the following directory structure.

MRI image(s):
$root/id_list{n}/mprage.nii

===========================
Example data and script
===========================
Data:
/home/NCD/subject  (= $root)
            /sub-01/mprage.nii  ( = id_list{1})
            /sub-02/mprage.nii  ( = id_list{2})

Sample script:
root       = '/home/NCD/subject';
id_list    = {'sub-01', 'sub-02'};
deface_run(root, id_list);

Result:
/home/NCD/subject/sub-01/defaced_mprage.nii
/home/NCD/subject/sub-02/defaced_mprage.nii

To make id_list, deface_get_id_from_dir.m can be helpful for your operation.

Report:
You can also create reports.

deface_export_result_as_pptx(root, id_list, './result.pptxÅf);
Now putting result... (1/2)
Now putting result... (2/2)
PPTX file created : ./result.pptx

=============================
Advanced feature
=============================
* Multicore computation:
This setting enables the feature to process multiple subjects simultaneously on the local host. It consumes a lot of CPU cores.
$PROGRAM_DIR/deface_define.m
d.pararrel_computation = 1;

* Multiple host computation(Experimental feature):
This setting enables multiple remote hosts to process subjects simltaneously.
It is necessary to set up beforehand so that a password is not required for SSH connection.
https://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id

Then, you can use multiple hosts.
$PROGRAM_DIR/deface_define.m
d.host = {'cbi-node01', 'cbi-node02'}; % multiple hosts

NOTE: Due to the number of SSH connections, it is better to keep it to three hosts.

