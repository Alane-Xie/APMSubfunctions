function CreateRDS

% This function creates an anaglyph random-dot stereogram of any black and 
% white image selected, where black pixels of the original image are 
% converted to uncrossed disparities, while white pixels remain in the 
% plane of the screen.
%
% 2011-03-25    Created by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

[ImageFile, ImagePath] = uigetfile('*.png', 'Select image file to convert');
% ImageFile = '3DV-bw2.png';
if ImageFile == 0
    return;
end
filename = [ImagePath, ImageFile(1:end-4),'_RDS.png'];          % Create filename to save RDS as
ImageFile = [ImagePath, ImageFile];
disparity = 0.25;                                               % Set maximum disparity (degrees)
D = 50;                                                         % Set viewing distance (from screen/ print)
Stereomode = 6;                                                 % Set anaglyph colours (6 = red-green, 7 = green-red, 8 = cyan-red, 9 = red-cyan)
% NewGamma = 'Samsung2493HMgamma.mat';                            % Specify name of gamma table to load, or leave blank
BackgroundBrightness = 60*(256/100);                            % Specify background contrast (%)
DotDensity = 0.3;                                              % Specify dot density (dots per pixel squared)

%========================= SETUP DISPLAY ==================================
ScreenID = max(Screen('Screens'));                              % In multi-screen displays, use monitor 2
Rect = Screen('rect', ScreenID);                                % Get the screen resolution (pixels)
RefreshRate = Screen('FrameRate', ScreenID);                    % Get the monitor refresh rate (Hz)
multiSample = 0;      
SetRGgains = 0;
if SetRGgains == 1
    imagingmode = kPsychNeedFastBackingStore;                   % Set imagingmode to enable the imaging pipeline
else
    imagingmode = [];
end
ScreenSize = [37.6 30.4];                                       % set physical dimensions w x h (centimetres) of Samsung SyncMaster 913B
MirrorText = 0;                                                 % Set mirror mode to 'off'
Mirror = 1;                                                     % Do not mirror graphics
width = Rect(3);                                                % Get screen width (pixels)
height = Rect(4);                                               % Get screen height (pixels)                     
Centre = Rect(3:4)/2;                                           % Calculate the centre of the screen (x, y)
pix_per_cm = mean([width/ScreenSize(1), height/ScreenSize(2)]); % Calculate number of pixels per cm
pix_per_deg = (pix_per_cm*D*tand(0.5))*2;                       % Calculate pixles per degree
HideCursor;                                                     % Hide mouse pointer
Background = [127 127 127];                                     % Set background colour
disparity = disparity*pix_per_deg;                              % Convert disparity from degrees to pixels

%===================== OPEN WINDOW AND APPLY GAMMA TABLE ==================
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 1);                                            % Make initial screen black instead of white
[win, Rect] = Screen('OpenWindow', ScreenID, Background,[],[],[], Stereomode, multiSample, imagingmode);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);                     % Turn alpha chanel on
if exist('NewGamma')
    [OriginalGamma, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', win);    % Get current gamma table
    save('OriginalGamma', 'OriginalGamma');                                             % Save original gamma table to .mat file
    load(NewGamma);                                                                     % Load the gamma table variable from .mat file
    NewGamma(:,3) = OriginalGamma(:,3);                                                 % For R-G anaglyph, keep original blue channel settings
    Screen('LoadNormalizedGammaTable', win, NewGamma);                                  % Load the gamma table
end

%===================== LOAD IMAGE AND CALCULATE DISPARITIES ===============
[BWimage,Lmap] = imread(ImageFile);                                         % Load black and white image 
ImageDim = size(BWimage);                                                   % Get image dimensions
if ImageDim(1)> height 
    Scale = height/ImageDim(1);
    BWimage = imresize(BWimage, Scale);                                         % Resize image
    ImageDim = size(BWimage);  
end
if ImageDim(2)> width
    Scale = width/ImageDim(2);
    BWimage = imresize(BWimage, Scale);                                         % Resize image
    ImageDim = size(BWimage);                                                   % Get new image dimensions
end
StimSize = [ImageDim(2) ImageDim(1)];
StimArea = ImageDim(1)*ImageDim(2);
CaptureRect = [Centre-StimSize/2, Centre+StimSize/2 ];                      % Define the on screen area to capture 
NoDots = round(DotDensity*StimArea);                                        % Calculate the total number of random dots

DotColor = round(rand(NoDots,1))*256;                                       % Randomize black and white dots
DotColor = [DotColor DotColor DotColor];
DotPosL = [(rand(1, NoDots)*StimSize(1)); (rand(1, NoDots)*StimSize(2))];   % Create random dot positions across entire image area
DotSize = 1;                                                                % Specify dot size (pixels)                                           
DotType = 2;                                                                % Specify dot type (2 = antialiased circular dots)

for Dot = 1:NoDots
    if BWimage(ceil(DotPosL(2,Dot)),ceil(DotPosL(1,Dot)),1) >127            % If pixel is white (background)
        DotPosR(:,Dot) = DotPosL(:,Dot);                                    % Left eye and right eye image are the same
        DotColor(Dot,:) = (DotColor(Dot,:)/256)*BackgroundBrightness;       % Decrease brightness by specified amount
    elseif BWimage(ceil(DotPosL(2,Dot)),ceil(DotPosL(1,Dot)),1) <= 127      % If pixel is black
        DotPosL(:,Dot) = DotPosL(:,Dot)+[disparity/2; 0];                   % Move left eye dot to the right
        DotPosR(:,Dot) = DotPosL(:,Dot)-[disparity; 0];                     % Move right eye dot to the left
    end
    DotPosL(:,Dot) = DotPosL(:,Dot)-[StimSize(1)/2; StimSize(2)/2];         
    DotPosR(:,Dot) = DotPosR(:,Dot)-[StimSize(1)/2; StimSize(2)/2];         
end


%========================= ADD FIXATION MARKER ============================
FixColour = [255 255 255 255];                                                      % set fixation marker colour
FixSize = 0.7*pix_per_deg;                                                      % set fixation marker width (pixels)
FixWidth = 3;                                                                   % set line width for fixation marker (pixels)
NoniusLength = FixSize;                                                         % set the length of nonius lines (pixels)
NoniusStart = FixSize/2;                                                        % set distance from centre for nonius lines to start
FixDiameter = (NoniusStart+NoniusLength)*2;                                     % set diamater of fixation background
FixTextureL = Screen('MakeTexture', win, zeros(FixDiameter, FixDiameter, 4));    % Create transparent background (alpha = 0)
FixTextureR = Screen('MakeTexture', win, zeros(FixDiameter, FixDiameter, 4));  


FixRect = [FixDiameter/2-FixSize, FixDiameter/2-FixSize, FixDiameter/2+FixSize, FixDiameter/2+FixSize];         % Draw fixation square
Screen('FrameRect', FixTextureL, FixColour, FixRect, FixWidth);
Screen('FrameRect', FixTextureR, FixColour, FixRect, FixWidth);
FixLlines = [-NoniusLength-NoniusStart, -NoniusStart, 0, 0; 0, 0, -NoniusLength-NoniusStart, -NoniusStart];     % Draw nonius lines
FixRlines = [NoniusLength+NoniusStart, NoniusStart, 0, 0; 0, 0, NoniusLength+NoniusStart, NoniusStart];
Screen('DrawLines', FixTextureL, FixLlines, FixWidth, FixColour, [FixDiameter/2, FixDiameter/2]);       
Screen('DrawLines', FixTextureR, FixRlines, FixWidth, FixColour, [FixDiameter/2, FixDiameter/2]); 


Screen('SelectStereoDrawBuffer', win, 0);                                   % Select the left eye buffer
Screen('DrawDots', win, DotPosL, DotSize, DotColor', Centre, DotType);      % Draw left eye dots
% Screen('DrawTexture', win, FixTextureL);                                    % Draw fixation marker
Screen('SelectStereoDrawBuffer', win, 1);                                   % Select the right eye buffer
Screen('DrawDots', win, DotPosR, DotSize, DotColor', Centre, DotType);      % Draw right eye dots
% Screen('DrawTexture', win, FixTextureR);                                     % Draw fixation marker
Stereogram = Screen('GetImage', win, CaptureRect, 'backBuffer');            % Capture image
Screen('Flip', win);                                                        % Flip image to screen
KbWait;                                                                     % Wait for key press before continuing
if exist('NewGamma')
    Screen('LoadNormalizedGammaTable', win, OriginalGamma);                 % Load the original gamma table
end
Screen('CloseAll');
showcursor;

imshow(Stereogram);                                                         % Show the captured image as a figure
imwrite(Stereogram, filename,'png');                                        % Save the image 
