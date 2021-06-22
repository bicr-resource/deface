function	BB = vb_upsample_3d(B)
% upsampling by two
%
% B : 3D-image
%
% Copyright (C) 2011, ATR All Rights Reserved.
% License : New BSD License(see VBMEG_LICENSE.txt)

% �ǡ����η����֤���
% upsampling step
step = 2;

[N1,N2,N3] = size(B);
N1 = N1*step;
N2 = N2*step;
N3 = N3*step;

BB = zeros(N1,N2,N3);

% �ǡ����η����֤�
% upsampling
BB(1:step:N1,1:step:N2,1:step:N3) = B;
BB(2:step:N1,1:step:N2,1:step:N3) = B;
BB(1:step:N1,2:step:N2,1:step:N3) = B;
BB(2:step:N1,2:step:N2,1:step:N3) = B;

BB(1:step:N1,1:step:N2,2:step:N3) = B;
BB(2:step:N1,1:step:N2,2:step:N3) = B;
BB(1:step:N1,2:step:N2,2:step:N3) = B;
BB(2:step:N1,2:step:N2,2:step:N3) = B;

return

% neighbor index list for boundary detection
% (X-axis) ����������ǥå���
j1d = 1:step:(N1-1);
j1u = 2:step:N1;
% (Y-axis) ����������ǥå���
j2d = 1:step:(N2-1);
j2u = 2:step:N2;

% ���庸���岼��ư����ʿ�Ѳ�
for zz = 1:N3
	B(j1d, : , zz ) = B(j1d, : , zz ) + B(j1u, : , zz );
end

for zz = 1:N3
	B( : ,j2d, zz ) = B( : ,j2d, zz ) + B( : ,j2u, zz );
end

for zz = 1:(N3-1)
	B(:,:,zz) = B(:,:,zz) + B(:,:,zz+1);
end



