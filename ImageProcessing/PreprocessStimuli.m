function NewImages = PreprocessStimuli(Filenames, Filter, Scramble, Inversion, Save)

%=========================== PreprocessStimuli.m ==========================
% This function peforms processing of image files for use as experimental 
% stimuli. In addition to matching stimulus luminance intensities (mean or 
% histogram) to the stimulus set average using the SHINE Toolbox (Willenbockel
% et al., 2010) and optionally applying an aperture mask, control stimuli 
% can be created by shuffling, scrambling, or filtering the original images.
%
% INPUTS:
%   Filenames:  Full path containing image files (optional) 
%   Filter:     0 = none; 1 = Low pass; 2 = High pass;
%   Scramble:   0 = none; 1 = grid; 2 = Fourier;
%   Inversion:  0 = none; 1 = luminance and spatial;
%   Mask:       0 = none; 1 = circular; 2 = Gaussian; 3 = cosine edge;
%   PlotStyle: 	0 = none; 1 = plot original and normalized; 2 = plot normalized only
%   Save:       0 = don't save; 1 = save images; 2 = save summary figures; 
%   
%
% REQUIREMENTS:
%   SHINE Toolbox*: www.mapageweb.umontreal.ca/gosselif/shine.                  
%   hsl2rgb and rgb2hsl converters: http://www.mathworks.com/matlabcentral/fileexchange/20292-hsl2rgb-and-rgb2hsl-conversion
%   *lumMatch.m from SHINE toolbox requires editing to output images as double instead of uint8.
%
% REFERENCES:
%   Willenbockel V, Sadr J, Fiset D, Horne GO, Gosselin F, Tanaka JW (2010).
%       Controlling low-level image properties: the SHINE toolbox. Behav Res 
%       Methods, 42(3):671-84. doi: 10.3758/BRM.42.3.671.
%
% REVISIONS:
%   22/01/2014 - Written by APM
%   10/02/2014 - Filtering added
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - murphyap@mail.nih.gov
%  / __  ||  ___/ | |\   |\ \  Section on Cognitive Neurophysiology and Imaging
% /_/  |_||_|     |_| \__| \_\ National Institute of Mental Health
%==========================================================================
[t,comp] = system('hostname');
if strcmp(strtrim(comp),'Aidans-MacBook-Pro.local')
    DefaultImageDir = '/Volumes/APM_1/Stimuli/CFS_fMRI_experiment/';
else
%     DefaultImageDir = '/Volumes/USRLAB/projects/murphya/Stimuli/Eyes';
    DefaultImageDir = '/Volumes/APM_1/Stimuli/CFS_fMRI_experiment/';
    SHINEdir = '/Volumes/USRLAB/projects/murphya/Toolboxes/SHINEtoolbox';
    addpath(genpath(SHINEdir));
    addpath(genpath('/Volumes/USRLAB/projects/murphya/APMSubfunctions'));
end
cd(DefaultImageDir);

if nargin <= 1
    Filter = 0;                     % 0 = none; 1 = Low pass; 2 = High pass;
    Scramble = 0;                 	% 0 = no scramble; 1 = grid shuffled; 2 = Fourier scrambled;
    Inversion = 0;                  % 0 = no inversion; 1 = contrast polarity + spatial inversion; 2 = color inversion + spatial inversion
end
PlotStyle = 2;                      % 0 = no plot; 1 = plot original and normalized; 2 = plot normalized only; 3 = plot spectral frequency
IncludeBackground = 0;              % Include background in normalization calculations?
RequestedLuminance = [0.5, 0.2];    
RequestedSize = [];%[300, 300];     % Image size (w x h in pixels) 
SquareImages = 0;

Mask.On = 0;                    % Apply mask to images?
Mask.Edge = 2;                  % Cosine edge
Mask.Taper = 0.1;               % Cosine tapers over 10% of radius
Mask.Colour = [127 127 127];    % Mask color is mid grey
Fig.nX = 8;                     % Number of image columns
Fig.nY = 4;                     % Number of image rows

Format = 'png';  
switch Scramble
    case 0
        OutputFolderName = 'Processed';  
    case 1
        OutputFolderName = 'Scrambled';  
    case 2
        OutputFolderName = 'SpectralScrambled';
end
if Inversion == 1
    OutputFolderName = 'Inverted';
end
% if Scramble > 0
%     OutputFolderName = sprintf('%s_Scr%d', OutputFolderName, Scramble);
% end
% if Filter > 0
%     OutputFolderName = sprintf('%s_Filt%d', OutputFolderName, Filter);
% end


%======== SELECT IMAGES TO PROCESS
if nargin == 0
    FileTypes = {'*.png;*.bmp;*.jpg;', 'Image files (*.png, *.bmp, *.jpg)'; '*.gif','Animated gifs';'*.*', 'All files'};
    [Filenames, Pathnames, filterindex] = uigetfile(FileTypes, 'Select images to process', 'MultiSelect', 'on');
else
    for n = 1:numel(Filenames)
       	[Pathnames, Filename, Ext] = fileparts(Filenames{n});
        Filenames{n} = [Filename, Ext];
    end
end
Indx = regexp(Pathnames,filesep);
InputFolderName = Pathnames((Indx(end-1)+1):Indx(end)-1);

if ~iscell(Filenames)
    temp{1} = Filenames;
    clear Filenames;
    Filenames = temp;
end

%======== LOAD SELECTED IMAGES
for n = 1:numel(Filenames)
    [Img, Map, Alpha] = imread(fullfile(Pathnames, Filenames{n}));
    AlphaMask{n} = round(Alpha/255);
 	Orig_images{n} = imread(fullfile(Pathnames, Filenames{n}));
    ImageSizes(n,:) = size(Orig_images{n});
end


%======== CHECK IMAGE DIMENSIONS
Resize = [];
if isempty(RequestedSize)
    RequestedSize = mode(ImageSizes);
end
CorrectSize = strmatch(RequestedSize([1,2]), ImageSizes(:,[1,2]));
ImagesToResize = find(~ismember(1:numel(Filenames),CorrectSize));

if SquareImages == 1
    ImagesToCrop = find(ImageSizes(:,1)~=ImageSizes(:,2));
    if ~isempty(ImagesToResize)
        fprintf('The most common image size of the selected %d images is %d x %d pixels\n',numel(Orig_images),mode(ImageSizes(:,1)),mode(ImageSizes(:,2)));
        fprintf('The following image is not the same size\n as the majority of selected images: %s\n\n', Filenames{ImagesToResize});
        Ans = questdlg('How do you wish to proceed?','Image size problem!','Resize images','Exclude images','Quit','Resize images');
        if strcmp(Ans,'Resize images')
            for i = 1:numel(ImagesToResize)
                Orig_images{ImagesToResize(i)} = imresize(Orig_images{ImagesToResize(i)},RequestedSize);
                AlphaMask{ImagesToResize(i)} = imresize(AlphaMask{ImagesToResize(i)},RequestedSize);
            end
        elseif strcmp(Ans,'Exclude images')
            Orig_images(ImagesToResize) = [];
            Filenames(ImagesToResize) = [];
        else
            return;
        end
    end
    if ~isempty(ImagesToCrop)
        fprintf('Warning: the following image has different x and y dimensions: %s\n\n', Filenames{ImagesToCrop});
        return;
    end
end

%======== CREATE IMAGE MASK
if Mask.On == 1
    if ~isempty(RequestedSize)
        Mask.Dim = RequestedSize;
    else
        Mask.Dim = mode(ImageSizes(:,[1,2]));   
    end
   	Mask.ApRadius = floor(min(Mask.Dim)/2)-1;
    Mask.Taper = 0.2;
  	MaskTex = GenerateAlphaMask(Mask, [], 0);
    MaskTexInv = MaskTex/255;
    MaskTex = ones(size(MaskTex))-(MaskTex/255);
elseif Mask.On == 0
    MaskTex = [];
end

%======== CONVERT RGB TO HSL AND ISOLATE LUMINANCE CHANNEL
for n = 1:numel(Orig_images)
    hsl_images{n} = rgb2hsl(double(Orig_images{n})/255); 
 	LumChannels{n} = hsl_images{n}(:,:,3);
end

%======== PERFORM LUMINANCE NORMALIZATION
% CorrectedLum = SHINE(LumChannels);
MeanLum = [];
if IncludeBackground == 1
   MaskData = ceil(MaskTex);
elseif IncludeBackground == 0
   MaskData = AlphaMask; 
end
CorrectedLum = lumMatch(LumChannels, MaskData,RequestedLuminance);

%======== RECOMBINE HSL CHANNELS AND CONVERT BACK TO RGB
for n = 1:numel(Orig_images)
    if Inversion == 1
        CorrectedLum{n} = ones(size(CorrectedLum{n}))-CorrectedLum{n};
    end
    hsl_images{n}(:,:,3) = double(CorrectedLum{n});
    NewImages{n} = uint8(hsl2rgb(double(hsl_images{n}))*255);
end

%========================= SCRAMBLE IMAGE =================================
if Scramble == 1
    NoTiles = 20;
    ImSize = mode(ImageSizes(:,[1,2]));
    PixPerTile = ImSize([1,2])/NoTiles;
    for n = 1:numel(NewImages)
        NewImages{n}(:,:,4) = AlphaMask{n};
        [ScrambledImage,I,J] = randblock(NewImages{n},[PixPerTile(1),PixPerTile(2),size(NewImages{n},3)]);    % Scramble
        NewImages{n} = ScrambledImage(:,:,1:3);
        AlphaMask{n} = ScrambledImage(:,:,4);
    end
    
elseif Scramble == 2
    for n = 1:numel(NewImages)
%         NewImages{n}(:,:,1) = AlphaMask{n};
        Im = imread(fullfile(Pathnames, Filenames{n}),'BackgroundColor',[0.5 0.5 0.5]);
        Im = NewImages{n};
        Im(:,:,4) = AlphaMask{n};
        ImSize = size(Im);
        RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));      % generate random phase structure
        for layer = 1:ImSize(3)
            ImFourier(:,:,layer) = fft2(Im(:,:,layer));             % Fast-Fourier transform 
            Amp(:,:,layer) = abs(ImFourier(:,:,layer));             % amplitude spectrum
            Phase(:,:,layer) = angle(ImFourier(:,:,layer));         % phase spectrum
            Phase(:,:,layer) = Phase(:,:,layer) + RandomPhase;      % add random phase to original phase
%             Phase(:,:,layer) = RandomPhase;                         % OR replace original phase with random phase
            ScrambledImage(:,:,layer) = Amp(:,:,layer).*exp(sqrt(-1)*(Phase(:,:,layer)));       %combine Amp and Phase 
        end
        NewImages{n} = real(ifft2(ScrambledImage));               	% perform inverse Fourier & get rid of imaginery part in image (due to rounding error)
        
     	%======= Normalize Image to range 0:255
        Range = max(NewImages{n}(:)) - min(NewImages{n}(:));
        NewImages{n} = uint8( (NewImages{n} - min(NewImages{n}(:)))./Range*255 );
        AlphaMask{n} = NewImages{n}(:,:,4);
        NewImages{n}(:,:,4) = [];
        AlphaMask{n} = ones(size(NewImages{n}(:,:,1)));
        
        %======== PERFORM LUMINANCE NORMALIZATION... AGAIN!
        hsl_images{n} = rgb2hsl(double(NewImages{n})/255); 
        LumChannels{n} = hsl_images{n}(:,:,3);
    end
  	CorrectedLum = lumMatch(LumChannels, [],RequestedLuminance);
    for n = 1:numel(NewImages)
        hsl_images{n}(:,:,3) = double(CorrectedLum{n});
        NewImages{n} = uint8(hsl2rgb(double(hsl_images{n}))*255);
    end
        
end


%=========================== INVERT IMAGE =================================
if Inversion == 1
    for n = 1:numel(NewImages)
%         NewImages{n} = uint8((ones(size(NewImages{n}))*255)-double(NewImages{n}));
        NewImages{n} = flipdim(NewImages{n},1);
        AlphaMask{n} = flipdim(AlphaMask{n},1);
    end
end


%=========================== FILTER IMAGE =================================
if Filter > 0
    if Filter == 1
        CyclesPerImage = 6;
        hsize = round(ImSize([1,2])/CyclesPerImage);
        Sigma = 20;
        G = fspecial('gaussian',hsize,Sigma);                 	% Create the gaussian filter
    elseif Filter == 2
        CyclesPerImage = 24;
        HPalpha = 0.2;
%         G = fspecial('laplacian', HPalpha);
        G = [-1 -1 -1;-1 8 -1;-1 -1 -1];
    end
    
    for n = 1:numel(NewImages)
        NewImages{n} = imfilter(NewImages{n},G,'same');       	% Apply filter
    end
end


%======== APPLY GRADIATED IMAGE MASK
if Mask.On == 1
    for n = 1:numel(NewImages)
        for chn = 1:3
            NewImages{n}(:,:,chn) = (MaskTex.*double(NewImages{n}(:,:,chn))) + (MaskTexInv*Mask.Colour(chn));
        end
    end
end

%======== PLOT ORIGINAL AND/OR NORMALIZED IMAGES FOR INSPECTION
set(0,'Units','pixels');
Fig.ScreenSize = get(0,'ScreenSize');
Fig.WindowSize =[0 0 1600 700];
Fig.gap = 0.02;
Fig.marg_h = 0.02;
Fig.marg_w = 0.02;

FH(1) = figure('OuterPosition',Fig.ScreenSize,'Color',Mask.Colour/255);
i = 1;

if PlotStyle == 1
%     h = tight_subplot(Fig.nY, Fig.nX, Fig.gap, Fig.marg_h, Fig.marg_w);
    for n = 1:numel(NewImages)
        if i+2 > Fig.nY*Fig.nX
            FH(end+1) = figure('OuterPosition',Fig.WindowSize,'Color',Mask.Colour/255);
            i = 1;
        end
        
        h{n}(1) = subplot(Fig.nY,Fig.nX,i);
        Im{n}(1) = image(Orig_images{n});
        axis off equal tight;
        title(Filenames{n});

        h{n}(2) = subplot(Fig.nY,Fig.nX,i+1);
        Im{n}(2) = imagesc(LumChannels{n});
        axis off equal tight;

        h{n}(3) = subplot(Fig.nY,Fig.nX,i+2);
        Im{n}(3) = image(NewImages{n});
        axis off equal tight;
        i = i+3;

        linkaxes(h{n});
        alpha(Im{n},MaskTex);
    end
    
elseif PlotStyle == 2
    FigNo = 1;
    ha{1} = tight_subplot(Fig.nY, Fig.nX, Fig.gap, Fig.marg_h, Fig.marg_w);
    for n = 1:numel(NewImages)
        if rem(n,(Fig.nY*Fig.nX))==1 && n>1
            FigNo = FigNo+1;
            FH(end+1) = figure('OuterPosition',Fig.ScreenSize,'Color',Mask.Colour/255);
            ha{FigNo} = tight_subplot(Fig.nY, Fig.nX, Fig.gap, Fig.marg_h, Fig.marg_w);
            i = 1;
        end
        set(gcf, 'currentaxes', ha{FigNo}(i)); 
        h = image(double(NewImages{n}(:,:,1:3))/255);
        if IncludeBackground == 0
            alpha(h,double(AlphaMask{n}));
        end
        axis off equal tight;
%         title(Filenames{n});
        i = i+1;
    end
    delete(ha{FigNo}(n+1:end));        % Delete unused axes
    
elseif PlotStyle == 3
    
    DefaultImageDir = '/Volumes/APM_1/Stimuli/CFS_fMRI_experiment/';
    ImCats = {'Rhesus_fear/Processed','Rhesus_neutral/Processed','Objects/Processed'};
    for ImCat = 1:numel(ImCats)
        
        %======================= LOAD IMAGES ==============================
        cd(fullfile(DefaultImageDir,ImCats{ImCat}));
        Files = dir('*.png');
        for n = numel(Files):-1:1
            if strmatch('._',Files(n).name)
                Files(n) = [];
            end
        end
        for n = 1:numel(Files)
            [Img, Map, Alpha] = imread(Files(n).name);
            AlphaMask{n} = round(Alpha/255);
            Orig_images{n} = imread(Files(n).name);
            ImageSizes(n,:) = size(Orig_images{n});
        end
    
        %================== GET SPECTRAL INFORMATION ======================
        for n = 1:numel(Orig_images)
    %         I = rgb2gray(Orig_images{n});
            I = Orig_images{n};
            imspec = spectrumPlot(I,0);
            Fourier(:,:,n) = log10(imspec);
            avg(n,:) = sfPlot(I,0);
        end
        AverageSpectrum{ImCat} = mean(Fourier,3);
        RotSpecMean{ImCat} = mean(avg,1);
        RotSpecSEM{ImCat} = std(avg,1)/sqrt(size(avg,2));

        [xs ys] = size(Orig_images{1});
        f1 = -ys/2:ys/2-1;
        f2 = -xs/2:xs/2-1;

        if exist('F1','var')==1
            figure(F1);
        else
            F1 = figure;
        end
        subplot(1,2,1);
        x = 1:floor(min(xs,ys)/2);
        y1 = RotSpecMean{ImCat}-RotSpecSEM{ImCat};
        y2 = RotSpecMean{ImCat}+RotSpecSEM{ImCat};
        [ha hb hc] = shadedplot(x, y1, y2);
        hold on;
        set(ha(2),'FaceColor','b');
        set (gca, 'Xscale', 'log');
        set (gca, 'Yscale', 'log');
        grid off;
        xlabel('Spatial frequency (cycles/image)');
        ylabel('Energy');

     	if exist('F2','var')==1
            figure(F2);
        else
            F2 = figure;
        end
        subplot(1,numel(ImCats),ImCat);
        imagesc(f1,f2,log10(imspec)); 
        axis xy;
        title(ImCats{ImCat});
    
    end
        
   
end


%======= SAVE PROCESSED IMAGES
if ~exist('Save','var')
    SaveNotInput = 1;
    Ans = questdlg('Would you like to save copies of the processed images?');
    if strcmpi(Ans,'No') || strcmpi(Ans,'Cancel')
        Save = 0;
    else
       Save = 1; 
    end
else
    SaveNotInput = 0;
end
if Save > 0
    [success,msg,msgID] = mkdir(Pathnames, OutputFolderName);
    NewImageDir = fullfile(Pathnames, OutputFolderName);
    fprintf('Saving processed images to %s...\n', NewImageDir);
    for n = 1:numel(NewImages)
        progressbar(n/numel(NewImages));
        if min(AlphaMask{n}(:))<1
            imwrite(NewImages{n}, fullfile(NewImageDir,[Filenames{n}(1:end-4),Filenames{n}((end-3):end)]),Format,'Alpha',double(AlphaMask{n}),'Background',Mask.Colour/255);
        else
            imwrite(NewImages{n}, fullfile(NewImageDir,[Filenames{n}(1:end-4),Filenames{n}((end-3):end)]),Format);
        end
    end
end

%======= SAVE SUMMARY FIGURE WINDOWS
if SaveNotInput == 1 
    Ans = questdlg('Would you like to save summary figures of processed images?');
    if strcmpi(Ans,'No') || strcmpi(Ans,'Cancel')
        return;
    end
    Save = 2;
end
if Save == 2
    % [success,msg,msgID] = mkdir(Pathnames, 'Summary');
    % NewImageDir = fullfile(Pathnames, OutputFolderName);
    for n = 1:numel(FH)
    %     print(FH(n),'-dpng',sprintf('%s_%d.png', OutputFolderName,n));
        Filename = sprintf('%s_%s_%d.%s', InputFolderName,OutputFolderName,n,Format);
        Filename = fullfile(DefaultImageDir,'SummaryData',Filename);
        export_fig(Filename, ['-',Format], '-transparent','-nocrop');
    end
end