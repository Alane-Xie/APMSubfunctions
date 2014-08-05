function [Lum] = LuminanceCal(AppendFile, DisplayName, manual, GammaTable)

%========================= LuminanceCal.m =================================
% Luminance calibration routine to display grey-scale and/or colour patches
% on screen. An alternative to PTB's CalibrateMonitorPhotometer.m, that
% allows easier normalization of gamma between two displays for binocular
% presentation.
%
% INPUTS:
%   AppendFile:     name of .mat file to append luminance data to
%   DisplayName:    String input used to specify display being calibrated 
%   Manual:         Next value, 0 = automated, 1 = keypress
%   GammaTable:     .mat file containing normalized gamma values for each grey level
%                   e.g.[Lum] = LuminanceCal('MRproj_L',1)
%
% REVISIONS:
% 12/03/2013 - Written by APM
% 14/03/2013 - Updated for RGB calibration
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%==========================================================================

if nargin < 1, AppendFile = []; end
if nargin < 2, DisplayName = 'Test'; end
if nargin < 3, manual = 1; end
if nargin < 4, GammaTable = []; end

if ~exist(AppendFile)
    D = 1;
elseif exist(AppendFile)
    load(AppendFile);
    D = numel(Lum)+1;
end
Lum(D).Time = datestr(now);

%======================== SET CALIBRATION PARAMETERS ======================
Lum(D).NoLevels = 4;                                            % How many pixel intensities to sample (2 - 256)                         
Lum(D).Levels = round(linspace(0,255,Lum(D).NoLevels));         % Which pixel intensities
Lum(D).SamplesPerLevel = 1;                                     % How many samples for each pixel intensity
Lum(D).GreyScale = 1;                                           % Present grey scale?
Lum(D).RGB = 0;                                                 % Present RGB also?
Lum(D).SampleOrder = repmat(Lum(D).Levels', [Lum(D).SamplesPerLevel, 1]);
Lum(D).SampleOrder = Lum(D).SampleOrder(randperm(length(Lum(D).SampleOrder)),:);
Lum(D).SampleDuration = 0.5;                                    % For automated calibration, how long should each sample display for (seconds)?
Lum(D).DisplayUpdate = 1;                                       % Print text update to display screen?
Lum(D).FullScreen = 1;
Lum(D).DisplayName = DisplayName;

%======================== DEFINE KEYBOARD INPUTS ==========================
KbName('UnifyKeyNames');
Key.Quit = KbName('Escape');
Key.Next = KbName('rightarrow');
Key.Previous = KbName('leftarrow');
Key.WaitTime = 0.3;
Key.LastPress = GetSecs;

%======================== OPEN ONSCREEN WINDOW(S) ========================= 
Stereo = 0;
Display = DisplaySettings(Stereo);
Display.Background = [128 128 128];
if Lum(D).FullScreen ~= 1
	Lum(D).DestRect = CenterRect(Display.Rect/2,Display.Rect);
else
    Lum(D).DestRect = Display.Rect;
end
try
[Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, Display.Background(1),Lum(D).DestRect,[],[], Display.Stereomode);
HideCursor;                                         
MaxLevel = Screen('ColorRange', Display.win);                   % Get white value (e.g. 255?)
WaitSecs(2);
LoadIdentityClut(Display.win);                                  % Load identity CLUT

Text.String = sprintf('Press any key to begin presentation.');
if manual == 1
    Text.String = [Text.String, '\n\nUse the arrow keys to advance to next sample.'];
end
DisplayText(Text, Display);
KbWait;
WaitSecs(Key.WaitTime);

%========================== BEGIN CALIBRATION =============================
Quit = 0; S = 1;
while S <= numel(Lum(D).SampleOrder)
    
    if Lum(D).DisplayUpdate == 1
        Lum(D).TimeRemaining = (numel(Lum(D).SampleOrder)-S+1)*Lum(D).SampleDuration;
        if numel(num2str(ceil(rem(Lum(D).TimeRemaining, 60)))) < 2
            TimeS = ['0', num2str(ceil(rem(Lum(D).TimeRemaining, 60)))];
        else
            TimeS = num2str(ceil(rem(Lum(D).TimeRemaining, 60)));
        end
        if manual == 1
            Text.String = sprintf('Current sample: %d / %d\nCurrent luminance = ? cd/m2\n[Input value and press Return]', S, numel(Lum(D).SampleOrder));
        elseif manual == 0
            Text.String = sprintf('Time remaining: %d:%s', floor(Lum(D).TimeRemaining/60),TimeS);
        end
        Text.Xpos = Display.Rect(1)+20;
        Text.Ypos = Display.Rect(4)-120;
        if Lum(D).SampleOrder(S) > 128
            Text.Colour = [0 0 0];
        else
            Text.Colour = [255 255 255];
        end
    end
    
    for Eye = 1:2
        currentbsuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);
        Screen('FillRect', Display.win, Lum(D).SampleOrder(S));
        if Lum(D).DisplayUpdate == 1
            DrawFormattedText(Display.win, Text.String, Text.Xpos, Text.Ypos, Text.Colour, []);
        end
    end
    [VBL FrameOnset] = Screen('Flip', Display.win);
    
    if manual == 0
        while GetSecs < FrameOnset+Lum(D).SampleDuration
            [keyIsDown,secs,keyCode] = KbCheck;                      	% Check keyboard for 'escape' press        
            if keyIsDown && secs > Key.LastPress+Key.WaitTime
                Key.LastPress = secs;
                if keyCode(Key.Quit) == 1                           	% Press Esc for abort
                    Quit = 1;
                    break;
                end
            end
        end
    elseif manual == 1
        Input = '?';
        while isstr(Input)
            Input = input('Input luminance measured for sample:');
        end
        Text.String = sprintf('Current sample: %d / %d\nCurrent luminance = %.2f cd/m2\n[Press right arrow for next sample]', S, numel(Lum(D).SampleOrder), Input);
        for Eye = 1:2
            currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);
            Screen('FillRect', Display.win, Lum(D).SampleOrder(S));
            DrawFormattedText(Display.win, Text.String, Text.Xpos, Text.Ypos, Text.Colour, []);
        end
        [VBL FrameOnset] = Screen('Flip', Display.win);
        NextSample = 0;
        while NextSample == 0
            [keyIsDown,secs,keyCode] = KbCheck;                         % Check keyboard for 'escape' press        
            if keyIsDown && secs > Key.LastPress+Key.WaitTime
                Key.LastPress = secs;
                if keyCode(Key.Quit)                                    % Press Esc for abort
                    Quit = 1;
                    break;
                elseif keyCode(Key.Next)
                    Lum(D).Measurement(S) = Input;
                    S = S+1;
                    NextSample = 1;
                elseif keyCode(Key.Previous) && S > 1
                    S = S-1;
                    NextSample = 1;
                end
            end
        end
    end
    if Quit == 1
        break;
    end
end

%========================== CLOSE WINDOW AND SAVE DATA ====================
RestoreCluts;               
Screen('CloseAll');
ShowCursor;
filename = sprintf('%s.mat',DisplayName);
try
    save(filename, 'Lum'); 
catch
    save;
    fprintf('Save failed! Your data were saved in ''Matlab.mat'' instead.');
end

% %======================== ANALYSE AND PLOT DATA ===========================
% load(filename);
% 
% h = figure;
% FigTitle = sprintf('%s luminance calibration (%s)', Lum(D).DisplayName, datestr(now));
% T = suptitle(FigTitle);
% 
% Results = sortrows([Lum(D).SampleOrder', Lum(D).Measurement'],1);
% Levels = unique(Results(:,1));
% Luminances = reshape(Results(:,2),[Lum(D).SamplesPerLevel,numel(Lum(D).Levels)]);
% MeanLuminances = mean(Luminances);
% 
% %============== SUBPLOT FOR RAW DATA
% f(1) = subplot(2,2,1);                                                          % Create subplot 
% if Lum(D).SamplesPerLevel > 1
%     SELuminances = std(Luminances)/sqrt(numel(Lum(D).SamplesPerLevel));
%     StdErrorUpper = MeanLuminances+SELuminances;
%     StdErrorLower = MeanLuminances-SELuminances;
%     shadedplot(Levels, StdErrorUpper, StdErrorLower, [0.5 0.5 0.5], 'k');
%     hold on;
% end
% plot(Levels, MeanLuminances, '*-k','LineWidth',2);
% hold on;
% set(gca, 'xlim',[0 255]);
% set(gca,'XTick', 0:20:255);
% xlabel('Pixel Intensity', 'FontSize', 14);                  % Add x- and y-axis titles
% ylabel('Luminance ', 'FontSize', 14);
% set(gca,'TickDir','out');
% Box off;
% 
% %============== NORMALIZE LUMINANCE
% f(2) = subplot(2,2,2);   
% MaxLuminance = MeanLuminances(end);
% MinLuminance = MeanLuminances(1);
% Range = range(MeanLuminances);
% NormLuminances = (MeanLuminances-MinLuminance)/Range;
% NormLevels = Levels/255;                                % or replace 255 with MaxLevel
% 
% 
% g = fittype('x^g');
% fittedmodel = fit(NormLevels',NormLuminances',g);
% displayGamma = fittedmodel.g;
% maxLevel = 255;
% gammaTable1 = ((([0:maxLevel]'/maxLevel))).^(1/fittedmodel.g); 
% 
% 
% 
% plot(Levels, NormLuminances, '*-k');
% hold on;
% set(gca, 'xlim',[0 255]);
% set(gca,'XTick', 0:20:255);
% xlabel('Pixel Intensity', 'FontSize', 14);                  % Add x- and y-axis titles
% ylabel('Normalized luminance ', 'FontSize', 14);
% set(gca,'TickDir','out');
% Box off;
% 
% 
% 
% 
% 
% 
% set(f,'fontsize',12);
% rect = Screen('rect', 1);
% set(gcf, 'position', rect);

catch
    RestoreCluts;
    Screen('CloseAll');
    ShowCursor;
    psychrethrow(psychlasterror);
    rethrow(lasterror);
end
end

