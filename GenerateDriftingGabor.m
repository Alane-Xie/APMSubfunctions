function [GaborTextures] = GenerateDriftingGabor(Gabor, Display, PTB, Capture)

%========================= GenerateDriftingGabor.m ========================
% 
% Optionally, drifiting Gabors can be encoded as movie files (.avi) or
% still images (.png) of each direction/ orientation.
%
% INPUTS:
%   Gabor.Speed:            drift speed (degrees/ second)
%   Gabor.CyclesPerDeg:     number of cycles of sinusoid per degree
%   Gabor.Sigma:            standard deviation of the Gaussian envelope (degrees)
%   Gabor.Dimensions:       dimensions of stimulus texture (degrees)
%   Gabor.Capture:          0 = return textrue; 1 = capture movie; 2 = capture still;
%   Gabor.Background:       RGB value (0-255) of background
%   Display:                Structure generated by DisplaySettings.m
%   PTB:                    0 = returns image matrix; 1 = returns PTB texture handle(s)
%   
%
% REVISIONS:
%   22/01/2014 - Written by APM
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - murphyap@mail.nih.gov
%  / __  ||  ___/ | |\   |\ \  Section on Cognitive Neurophysiology and Imaging
% /_/  |_||_|     |_| \__| \_\ National Institute of Mental Health
%==========================================================================
if nargin == 0
    Gabor.Background = [0.5 0.5 0.5]*255;                               	% background color (RGB)
end
if ~isfield(Gabor, 'Capture')
    Gabor.Capture = 0;   
end
if ~exist('Display','var')
    Display = DisplaySettings(0);
    Display.Pixels_per_deg = 44;                                            % Specify settings for display system
    Display.Refresh = 60;
end

if Gabor.Capture > 0 && ~isfield(Display,'win')
    [Display.win, Display.Rect] = Screen('OpenWindow',Display.ScreenID, Background, Display.Rect, [],[],Display.Stereomode);
    Screen('BlendFunction', Display.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);         % Enable alpha channel
end

%============= Set stimulus parameters
Gabor.Orientation = 270;                                                    % Orientation from vertical (degrees)
Gabor.Contrast = 1;
Gabor.Speed = 4*Display.Pixels_per_deg(1);                                  % (degrees per second)
Gabor.PixelsPerFrame = Gabor.Speed/Display.RefreshRate;
Gabor.CyclesPerDeg = 0.5;                                                   % 
Gabor.PixelsPerCycle = (1/Gabor.CyclesPerDeg)*Display.Pixels_per_deg(1);
Gabor.Totalframes = round(Gabor.PixelsPerCycle/Gabor.PixelsPerFrame)-1;
Gabor.Dimensions = round([10 10]*Display.Pixels_per_deg(1));                % (degrees)

%============== Generate Gaussian mask
Mask.Edge = 1;
Mask.ApRadius = (Gabor.Dimensions(1)/2)-2;
Mask.s = Mask.ApRadius/3;
Mask.Dim = Gabor.Dimensions;
Mask.Colour = Gabor.Background;
MaskTex = GenerateAlphaMask(Mask, [], 0);
MaskTex = (ones(size(MaskTex))*255)- MaskTex;
Mask.Rect = [0 0 Mask.Dim];                                                 % Mask size
Mask.DestRect = CenterRect(Mask.Rect, Display.Rect);                        % Destination for mask is centred in screen window

%============== Generate sine grating
Grating.Dim = Gabor.Dimensions+[Gabor.PixelsPerCycle,0];
Grating.CyclesPerDeg = Gabor.CyclesPerDeg;
Grating.Phase = 0;
GratingTexture = GenerateSineGrating(Grating, Display, 0);
GratingTexture = repmat(GratingTexture,[1,1,3]);

%============= Check appearance
% if Gabor.Capture == 0
%     figure('Color',Mask.Colour/255);
%     g = image(GratingTexture(:,1:Gabor.Dimensions(1),:)/255);
%     set(g,'alphadata',MaskTex/255);
%     axis equal tight;
%     axis off;
% elseif Gabor.Capture > 0
    if Gabor.Capture == 0
        Angles = Gabor.Orientation;
    elseif Gabor.Capture == 1
        Angles = 0:90:270;
    elseif Gabor.Capture == 2
        Angles = 0:45:135;
        Gabor.Totalframes = 1;
    end
    
    %============ Make movie
    for A = Angles
        Gabor.Orientation = A;
        for f = 1:Gabor.Totalframes+1
            x = 1+((f-1)*(Gabor.PixelsPerCycle/Gabor.Totalframes));
            g = GratingTexture(:,x:(x+Gabor.Dimensions(1)-1),:);
            g(:,:,4) = MaskTex(1:size(g,1),1:size(g,2));
            Grating = Screen('MakeTexture', Display.win, g);
            Screen('DrawTexture', Display.win, Grating, [], Mask.DestRect, Gabor.Orientation,[], Gabor.Contrast); 
            
%             Screen('DrawTexture', Display.win, MaskTex, Mask.Rect, Mask.DestRect);  
            
            if Gabor.Capture > 0
                Screen('Flip',Display.win);
                GaborTextures{f} = Screen('GetImage',Display.win, Mask.DestRect);
            end
            if PTB == 1
                GaborTextures{f} = Grating;
            end
        end

        if Gabor.Capture == 1
            FileName = sprintf('DriftingGabor_%ddeg.avi', Gabor.Orientation);
            daObj=VideoWriter(FileName);
            open(daObj); 
            for f = 1:Gabor.Totalframes
                writeVideo(daObj,GaborTextures{f});
            end
            close(daObj);   
        elseif Gabor.Capture == 2
            imwrite(GaborTextures{1}, ['Gabor_',num2str(Gabor.Orientation),'.png'],'png');
        end
    end
    if PTB == 0
        sca;
    end
% end