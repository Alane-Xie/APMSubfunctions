function nii_dilate(wi, ndilate);
%dilate binary volume
if nargin <1 %no gray
 wi = spm_select(1,'image','Select volume to dilate');
end;
if nargin <2 %no gray
    ndilate = 1; %1=basic, 2=thorough
end;

if ischar(wi), wi = spm_vol(wi); end;

w = spm_read_vols(wi)*255;


kx=[0.5 1 0.5];
ky=[0.5 1 0.5];
kz=[0.5 1 0.5];
mn = min(w(:));
for j=1:ndilate,
    spm_conv_vol(w,w,kx,ky,kz,-[1 1 1]);
end;
cont = w;
w((cont == mn)) = 0;
w((cont ~= mn)) = 1;

[pth,nam,ext]=fileparts(wi.fname);
wi.fname = fullfile(pth,['d',  nam, ext]);
spm_write_vol(wi,w);
