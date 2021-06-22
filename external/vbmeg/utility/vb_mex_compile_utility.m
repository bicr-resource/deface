% Compile utility MEX function
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)
current = pwd;
p = vb_get_file_parts(which('vb_repadd.c'));
cd(p);
try
mex -v vb_repadd.c
mex -v vb_repmultiply.c
if ispc
    mex vb_CalcMD5.c
else
    mex CC=g++ vb_CalcMD5.c
end
catch
end
cd(current);
