function j = nii_jaccard(im1, im2, binarize, im1inten, im2inten);
%computes Jaccard Similarity Index
%http://en.wikipedia.org/wiki/Jaccard_index
% input
%  im1: image
%  im2: image
%  binarize [optional]: if true Tanimoto's Similarity is computed 
% output
%  j: Jaccard Index (intersection vs union)
%j =nii_jaccard('c1head_1.nii','mask_gray.nii')

if nargin <1 %no im1
 im1 = spm_select(1,'image','Select 1st image');
end;
if nargin <2 %no im2
 im2 = spm_select(1,'image','Select 2nd image');
end;
if nargin <3 %no binarize
 binarize = false;
end;

if ischar(im1), im1 = spm_vol(im1); end;
if ischar(im2), im2 = spm_vol(im2); end;

i1 = spm_read_vols(im1);
i2 = spm_read_vols(im2);

if nargin > 3 %filter im1
    i1 = i1 == im1inten;
    i1 = uint8(i1);
    fprintf('A total of %d voxels in %s have an intensity of %f\n',sum(i1(:)), im1.fname, im1inten);
end;
	
if nargin > 4 %filter im2
    i2 = i2 == im2inten;
    i2 = uint8(i2);

    fprintf('A total of %d voxels in %s have an intensity of %f\n',sum(i2(:)), im2.fname, im2inten);
end;

if binarize
    m=max(i1(:));
    i1 = i1/m;
    i1 = round(i1);
    m=max(i2(:));
    i2 = i2/m;
    i2 = round(i2);
end;

inter = 0;
union = 0;
for i=1:size(i1,3),
        p1       = double(i1(:,:,i));
        p2       = double(i2(:,:,i));
        a= max(p1,p2);
        union = union + sum(a(:));
        a= min(p1,p2);
        inter = inter + sum(a(:));
end;

j = inter/union;
 fprintf('Jaccard of %s and %s is %f\n',im1.fname, im2.fname, j);

