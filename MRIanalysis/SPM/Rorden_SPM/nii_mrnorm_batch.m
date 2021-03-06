function nii_mrnorm_batch;
%demo of aging toolbox
dir = '/Users/rorden/tut'; %location of images
ext = '.nii'; %file extension either .hdr or .nii
%next: list of anatomical, pathological and lesion images
%T1 = cellstr(strvcat('AS_T1','BF_T1','BS_T1','DC_T1','DV_T1','FJ_T1','HB_T1','JA_T1','JC_T1','JE_T1','JJ_T1','JY_T1','KS_T1','LM_T1','LO_T1','LT_T1','MA_T1','MB_T1','MB2_T1','MC_T1','MC2_T1','MK_T1','MW_T1','PM_T1','RH_T1','SF_T1','TH_T1','WC_T1','WG_T1'));
%T2 = cellstr(strvcat('AS_flair','BF_T2','BS_flair','DC_T2','DV_flair','FJ_T2','HB_flair','JA_T2','JC_flair','JE_flair','JJ_flair','JY_T2','KS_T2','LM_T2','LO_T2','LT_T2','MA_T2','MB_flair','MB2_T2','MC_T2','MC2_T2','MK_T2','MW_T2','PM_T2','RH_T2','SF_T2','TH_flair','WC_flair','WG_T2'));
%Ls = cellstr(strvcat('AS_LESION','BF_LESION','BS_LESION','DC_LESION','DV_LESION','FJ_LESION','HB_LESION','JA_LESION','JC_LESION','JE_LESION','JJ_LESION','JY_LESION','KS_LESION','LM_LESION','LO_LESION','LT_LESIOIN','MA_LESION','MB_LESION','MB2_LESION','MC_LESION','MC2_LESION','MK_LESION','MW_LESION','PM_LESION','RH_LESION','SF_LESION','TH_LESION','WC_LESION','WG_LESION'));

T1 = cellstr(strvcat('AS_T1'));
T2 = cellstr(strvcat('AS_flair'));
Ls = cellstr(strvcat('AS_LESION'));
%next: list of anatomical scans from healthy controls
%hT1 = cellstr(strvcat('h1','h2','h3','h4','h5','h6','h7','h8','h9','h10','h11'));
hT1 = cellstr(strvcat('h1'));

%%%%%%%NO NEED TO EDIT BEYOND THIS POINT %%%%%%
disp('SPM must be running to execute this script (run spm from matlab command line)');
n = size(T1,1);
if ((n ~= size(T2,1)) ||  (n ~= size(Ls,1)))
    disp('Unequal numbers of images');
    return;
end;    

%step 1: pre process patient scans
% step 1a: normalize all patient scans
for i=1:n   
    T1i = fullfile(dir,[deblank(T1{i}) ext]); %anatomical image
    T2i = fullfile(dir,[deblank(T2{i}) ext]); %pathological image
    Lsi = fullfile(dir,[deblank(Ls{i}) ext]); %lesion image
    fprintf('Unified segmentation of %s, job %d/%d\n', T1i, i, n);
    %function nii_mrnorm (T1,lesion,T2, UseSCTemplates, vox, bb, DeleteIntermediateImages, ssthresh, cleanup);
%    aging_mrnorm (T1i,Lsi,T2i, true, [1 1 1],[-78 -112 -50; 78 76 85], false, 0.005, 2);  
end; %for i : each image
%step 1b: mirror all normalized lesions - these have the extension 'wsr':
%'w'arped [normalized] 's'moothed and 'r'ealigned from T2 to T1 space
for i=1:n   
    Lsi = fullfile(dir,['wsr' deblank(Ls{i}) ext]); %anatomical image
    fprintf('flipping %s, job %d/%d\n', Lsi, i, n);
%    nii_fliplr(Lsi);
end;


%step 2: normalize all healthy controls
hn = size(hT1,1);
for i=1:hn   
    T1i = fullfile(dir,[deblank(hT1{i}) ext]); %anatomical image
    fprintf('Unified segmentation of %s, job %d/%d\n', T1i, i, hn);
    aging_mrnorm (T1i,'','', true, [1 1 1],[-78 -112 -50; 78 76 85], false, 0.005, 2);  
end; %for i : each image

return;

%step 3: compute gray matter for each patient for each lesion and mirror
mn = zeros(n+hn,n+n  );%rows: each patient and each control, columns: each lesion and mirror lesion
%step 3a: for patients
% select wc1 'w'arped (normalized) 'c1' gray matter
for i=1:n   
    GMi = fullfile(dir,['wc1' deblank(T1{i}) ext]); %anatomical image
    fprintf('computing lesion volume for patient %s, job %d/%d\n', GMi, i, n);
    for j=1:n
        Maski = fullfile(dir,['wsr' deblank(Ls{j}) ext]);
        mn(i,j) = nii_maskedmeansub (GMi, Maski);
    end; %for j: each lesion map
    for j=1:n
        Maski = fullfile(dir,['RLwsr' deblank(Ls{j}) ext]);
        mn(i,n+j) = nii_maskedmeansub (GMi, Maski);
    end; %for j: each flippedlesion map    
end; %for i: each patient
%step 3b: as step 3a, for controls....
for i=1:hn   
    GMi = fullfile(dir,['wc1' deblank(hT1{i}) ext]); %anatomical image
    fprintf('computing lesion volume for healthy control %s, job %d/%d\n', GMi, i, hn);
    for j=1:n
        Maski = fullfile(dir,['wsr' deblank(Ls{j}) ext]);
        mn(n+i,j) = nii_maskedmeansub (GMi, Maski);
    end; %for j: each lesion map
    for j=1:n
        Maski = fullfile(dir,['RLwsr' deblank(Ls{j}) ext]);
        mn(n+i,n+j) = nii_maskedmeansub (GMi, Maski);
    end; %for j: each flippedlesion map   
end; %for i: each control
dlmwrite('results.tab',mn,'-append', 'delimiter', '\t');

function [result] = nii_maskedmeansub (Img, Mask);
% Average intensity for all voxels in Img that are nonzero in Mask
%  Img = Input image (typically continuous) 
%  Mask = Masking region of interest (typically binary))
% Example
%   nii_maskedmeansub('c1T1.nii','IPS.nii');
hdr = spm_vol(deblank(Img));
i = spm_read_vols(hdr);
hdr = spm_vol(deblank(Mask));
m = spm_read_vols(hdr);
result = mean(i(m ~= 0));

