function [abort] = TimerDisplay(t, Haplo, Text, movie)

%========================== TimerDisplay.m ================================
% 
% Plays a countdown from 't' seconds (displayed in MM:SS format) and an 
% animated icon while displaying 'text'.  Can optionally be exported as 
% an .avi movie.  Quits if user presses Escape key during countdown.
%
%==========================================================================

HarrisonSettings = 1;
if nargin == 0
    t = 10;
    Haplo = 0;
end
if nargin < 3
    Text = sprintf('Testing text\n\n display');
end
if nargin < 4
    movie = 0;
end
if movie == 1
    movieFile = 'LoadingMov.avi';
end

TextLines = numel(strread(Text,'%s','delimiter','\n'));
TextSpace = 30*TextLines;

%======================== ICON SETTINGS ===================================
OuterRadius = 140;
InnerRadius = 100;
LineWidth = 5; 
Background = [127, 127, 127];
Baseline = 10;
DegPerFrame = 4;
TotalFrames = (360/DegPerFrame)-1;                  

Tics = 60;                                          % Set the number of tics on clock
Angles = 0:(360/Tics):360-(360/Tics);               
LineXY = zeros(2, Tics*2);
LineXY(1,1:2:end) = sind(Angles)*InnerRadius;       % Inner X coordinates
LineXY(2,1:2:end) = cosd(Angles)*InnerRadius;       % Inner Y coordinates
LineXY(1,2:2:end) = sind(Angles)*OuterRadius;       % Outer X coordinates
LineXY(2,2:2:end) = cosd(Angles)*OuterRadius;       % Outer Y coordinates
LineColours = repmat([255; 255; 255; 10],1,2*Tics); % Set default line colour
TextColour = [255 255 255 255];                     % Set text colour
swapTextDirection = [];                             % For mirrored text?


%========================= SETUP SCREEN ===================================
if Haplo == 1                                       % If experiment is running on HAPLOSCOPE...
    ScreenID = 2;                                   % display on both CRT monitors
    Stereomode = 4;                                 % run in dual-display stereo mode
    ScreenSize = [36.0225 27.0169];                 % set physical monitor dimensions w x h (centimetres)
    Rect = [0 0 1600 1200];                         % Get the screen resolution (pixels)
    imagingmode = kPsychNeedFastBackingStore;       % Set imagingmode to enable the imaging pipeline
    MirrorText = 1;                                 % flip text horizontally to read correctly
    mirror = -1;                                    % Set inversion (mirroring) of movement direction
elseif Haplo >= 2                                   
    Rect = Screen('rect', 1);                       % Get the screen resolution of a single monitor (pixels)
    Stereomode = 4;                                 % run in dual-display stereo mode
    imagingmode = [];                               % Set imagingmode to disable the imaging pipeline
    ScreenSize = [37.6 30.4];                       % set physical monitor dimensions w x h (centimetres)
    if Haplo == 3                                   % If SIMULATING haploscope display on 2 monitors...
        ScreenID = 0;                               % display on both LCD monitors
        MirrorText = 1;                             % flip text horizontally to read correctly
        mirror = -1;                                % Set inversion (mirroring) of movement direction
    elseif Haplo == 2                               % If viewing a single monitor through a SCREENSCOPE...
        ScreenID = max(Screen('Screens'));          % Display on monitor 2 if available...
        MirrorText = 0;                             % Set mirror mode to 'off'
        mirror = 1;                                 % Do not mirror graphics
        Rect(3) = Rect(3)/2;                        % Half screen width in order to fit 2 screens on 1
    end
elseif Haplo == 0                                   % If experiment is running in office...
    ScreenID = max(Screen('Screens'));              % Display on monitor 2 if available...
    Stereomode = 6;                                 % run in red-green anaglyph mode
    imagingmode = [];                               % Set imagingmode to disable the imaging pipeline
    Rect = Screen('rect', ScreenID);                % Get the screen resolution (pixels)
    if HarrisonSettings ~= 1
        ScreenSize = [37.6 30.4];                   % set physical dimensions w x h (centimetres) of Samsung SyncMaster 913B
    elseif HarrisonSettings == 1
        ScreenSize = [33, 52];                      % set physical dimensions h x w (cm) of Samsung SyncMaster 2493HM
    end
    MirrorText = 0;                                 % Set mirror mode to 'off'
    mirror = 1;                                     % Do not mirror graphics
end

Screen('Preference', 'VisualDebugLevel', 1);                    % Make initial screen black instead of white
[TimerWin , Rect] = Screen('OpenWindow', ScreenID, Background, [],[],[], Stereomode);
Centre = Rect(3:4)/2;
CaptureRect = [-OuterRadius, -OuterRadius, OuterRadius, OuterRadius];
Screen('BlendFunction', TimerWin, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('TextFont', TimerWin, 'Arial');
Screen('TextSize', TimerWin, 32);

%======================== MOVIE CAPTURE SETTINGS ==========================
MovieRect = [Centre(1)-OuterRadius, Centre(2)-OuterRadius, Centre(1)+OuterRadius, Centre(2)+OuterRadius+10];
if movie == 1
    aviobj = avifile(movieFile,'compression','None');       % Create new .avi file
elseif movie == 2
    vidObj = VideoWriter('LoadingAnimation.avi');           % Create new video object
    vidObj.FrameRate = 60;                                  % Set the frame rate
    open(vidObj);
elseif movie == 3
    moviePtr = Screen('CreateMovie', TimerWin, movieFile, (MovieRect(3)-MovieRect(1)), (MovieRect(4)-MovieRect(2)));
end

%========================== PRESENT COUNT DOWN ============================
abort = 0;
Start = GetSecs;
while GetSecs < Start+t && abort ~= 1
    frame =1; highlight=Angles;
    while frame < TotalFrames && abort ~= 1
        Time = t-(GetSecs-Start);
        if numel(num2str(ceil(rem(Time, 60)))) < 2
            TimerSS = ['0', num2str(ceil(rem(Time, 60)))];
        else
            TimerSS = num2str(ceil(rem(Time, 60)));
        end
        if ceil(rem(Time, 60))<0
            TimerSS = '00';
        end
        Timer = sprintf('0%.0f:%s', floor(abs(Time/60)), TimerSS);
        highlight = highlight + DegPerFrame;
        LineColours(4,1:2:end) = Baseline + (255-Baseline)*((sind(highlight)+1)/2);
        LineColours(4,2:2:end) = Baseline + (255-Baseline)*((sind(highlight)+1)/2);
        TextColour(4) = LineColours(4,1);
        
        currentbuffer = Screen('SelectStereoDrawBuffer', TimerWin, 0);       % Draw to screen 0
        Screen('DrawLines', TimerWin, LineXY, LineWidth, LineColours, Centre);
        [nx, ny, textbounds]= DrawFormattedText(TimerWin, 'Please wait', 'center', Centre(2)+OuterRadius+20, TextColour, [], [], [], []);
        Screen('FillOval', TimerWin, Background, [Centre-InnerRadius, Centre+InnerRadius]);
        [nx, ny, textbounds]= DrawFormattedText(TimerWin, Timer, 'center', 'center', [255 255 255], [], [], [], []);
        [nx, ny, textbounds]= DrawFormattedText(TimerWin, Text, 50, 100, [0 0 0]);
        
        currentbuffer = Screen('SelectStereoDrawBuffer', TimerWin, 1);       % Draw to screen 1
        Screen('DrawLines', TimerWin, LineXY, LineWidth, LineColours, Centre);
        [nx, ny, textbounds]= DrawFormattedText(TimerWin, 'Please wait', 'center', Centre(2)+OuterRadius+20, TextColour, [], [], [], []);
        Screen('FillOval', TimerWin, Background, [Centre-InnerRadius, Centre+InnerRadius]);
        [nx, ny, textbounds]= DrawFormattedText(TimerWin, Timer, 'center', 'center', [255 255 255], [], [], [], []);
        [nx, ny, textbounds]= DrawFormattedText(TimerWin, Text, 50, 100, [0 0 0]);
        
        Screen(TimerWin, 'Flip');   
        Frame(:,:,:,frame) = Screen('GetImage', TimerWin, CaptureRect);      % Capture current PTB texture as movie frame
        
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;                % check for keypress
        if keyIsDown && keyCode(27)                                     % if escape is pressed
            abort = 1;                                                    
        end
        if movie == 1
            Frame(frame) = getframe;
            aviobj = addframe(aviobj,Frame(frame));     % Add frame to .avi file
        elseif movie == 2
            Frame(frame) = getframe;
            writeVideo(vidObj,Frame(frame));
        elseif movie == 3
            Screen('AddFrameToMovie', TimerWin, MovieRect);
        end
    %     imwrite(Frame(frame), strcat('framename', num2str(frame),'.png'), 'png');       % save image as PNG file
        frame = frame+1;
    end
end

if movie == 1
    aviobj = close(aviobj);                         % Close avi object
elseif movie == 2
    close(vidObj);
elseif movie == 3
    Screen('FinalizeMovie', moviePtr);
end


screen('Close', TimerWin);
