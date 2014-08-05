function Anaglyph = SideBySideToAnaglyph(ImageFile, EyeOrder)


% Open side-by-side stereographic image and render as anaglyph
%   
% INPUTS:
%   ImageFile:      full path of original side-by-side stereogram to convert
%   EyeOrder:       1 = wall-eyed; 2 = cross-eyed;
%   AnaglyphMode:   1 = optimized; 2 = color; 3 = half color

EyeOrder = 2;
Save = 0;  
Display = 1;
AnaglyphMode = 1;

if exist(ImageFile,'var')~= 2
    ImageDir = '/Volumes/APM_1/Stimuli/3D_photos';
    ImageFile = 'Animals_03.jpg';
    ImageFile = fullfile(ImageDir, ImageFile);
end
[img, cmap] = imread(ImageFile);

HalfWidth = size(img,2)/2;
if EyeOrder == 1
    img1 = img(:,1:HalfWidth,:);
    img2 = img(:,(HalfWidth+1):end,:);
elseif EyeOrder == 2
  	img2 = img(:,1:HalfWidth,:);
    img1 = img(:,(HalfWidth+1):end,:);
end

Anaglyph = mkAnaglyph(img1,img2,AnaglyphMode,Display,Save);