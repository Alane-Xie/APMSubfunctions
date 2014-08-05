function [CalWin] = EyeLinkCalibration2(ReturnWin, CalRect, Mirrored, DualScreen)
% [CalWin] = EyeLinkCalibration2(ReturnWin, CalRect, Mirrored, DualScreen)

%========================== EYELINK CALIBRATION ===========================
% Performs a calibration of the SR Research EyeLink using target information
% provided by the host PC, displayed on the display PC via Psychtoolbox.
%
% For Windows, install necessary eyelink.dll in PTB directory
% Download: http://www.psychtoolbox.org/eyelinktoolbox/downloads/EyelinkToolbox144.zip 
% Copy EyelinkToolbox144\EyelinkToolbox\EyelinkBasic\eyelink.dll to
% Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkBasic\Eyelink.dll
%
% INPUTS:   ReturnWin:      0 = close PTB window, 1 = return PTB window handle in CalWin
%           CalRect:        PTB rect coordinates of area to display calibration targets in
%           Mirrored:       0 = no mirroring required, 1 = mirroring required
%           DualScreen:     0 = single display, 1 = dual screen display
%           
% DEPENDENCIES:
%   Psychtoolbox v3 (including EyeLinkToolbox)
%   eyelink.dll
%   APMSubfunctions\DisplaySettings.m
%
% REFERENCES:
% Cornelissen FW, Peters EM, Palmer J (2002).  The Eyelink Toolbox: Eye tracking
%       with MATLAB and the Psychophysics Toolbox.  Behaviour Research Methods,
%       34(4): 613-617. DOI: 10.3758/BF03195489
% Brainard DH (1997) The Psychophysics Toolbox. Spat Vis 10:433-436.
% Pelli DG (1997) The VideoToolbox software for visual psychophysics: 
%       transforming numbers into movies. Spat Vis 10:437-442.
%
% REVISIONS:
% 10/12/10: Created apm909@bham.ac.uk
% 29/02/12: updated to use internal 'EyelinkDoTrackerSetup.m' routine (APM)
%==========================================================================

%====================== CHECK INPUTS AND SET DEFAULTS =====================
if nargin < 2                                                       % If ReturnWin input was not provided...
    ReturnWin = 0;                                                  % Do not keep PTB window open afterward
    CalRect = NaN;
end
if (~exist('DualScreen','var'))
    DualScreen = 0;
end
if (~exist('Mirrored','var'))
    Mirrored = 0;
end

BackgroundColour = [127 127 127];                                           % Background defaults to mid-grey
% CalRect = [500 100 1180 1000];                                            % define the rectangle to present calibration inside


PsychImaging('PrepareConfiguration');                                       % Prepare setup of PTB imaging pipeline
if DualScreen == 1
    CloneScreen = 2;
    PsychImaging('AddTask', 'General', 'MirrorDisplayTo2ndOutputHead', CloneScreen);  % clone screen 1 output to screen 2
end
if Mirrored == 1
    PsychImaging('AddTask', 'AllViews', 'FlipHorizontal');                  
end


%=========================== OPEN A PTB3 WINDOW ===========================
OpenWin = Screen('Windows');                                        % Check if a PTB3 window is currently open
if numel(OpenWin)>0                                                 % If a PTB window is currently open...
    CalWin = OpenWin(1);                                            % Use that window for calibration
    Rect = Screen('rect', CalWin);                                  % Get screen rect dimensions
elseif numel(OpenWin) == 0                                        	% If a PTB window is not currently open...
    HideCursor;                                                     % Hide cursor
    ListenChar(2);                                                  % supress keyboard input to command window
    warning off all;                                                % Turn Matlab warnings off
    Display = DisplaySettings(1);                                	% Get display settings
    Screen('Preference', 'VisualDebugLevel', 1);                	% Make initial screen black instead of white
    [CalWin, Rect] = PsychImaging('OpenWindow', Display.ScreenID, BackgroundColour, [], [],2);
% 	[CalWin, Rect] = Screen('OpenWindow', Display.ScreenID, BackgroundColour, [], [], 2, Display.Stereomode , [], []);   
end
if isnan(CalRect)
    CalRect = Rect;
end

%=========================== SETUP EYELINK ================================
el = EyelinkInitDefaults();                                      	% Initilaize EyeLink without providing a window handle
if ~EyelinkInit(0)
    fprintf('Error initialising eyelink');
    Cleanup;                                                        % cleanup function
    return;
end
Eyelink('Command', 'screen_pixel_coords = %d %d %d %d',CalRect(1),CalRect(2),CalRect(3)-1,CalRect(4)-1);    % Present targets within CalRect
el.window = CalWin;                                                 % Draw full screen window (Rect)

el.backgroundcolour = BackgroundColour;     
el.foregroundcolour = [255 255 255];   
el.msgfontcolour = [0 0 0];
el.imgtitlecolour = [0 0 0];
el.calibrationtargetcolour =  [255 69 0];

EyelinkDoTrackerSetup(el, 'c');                                  	% Do tracker setup
status = EyelinkDoDriftCorrection(el);                              % Do drift correction
if(status~=1)
    Cleanup;
    return;
end

if ReturnWin == 0                                       % If keeping the PTB window open was not requested
    Screen('Close', CalWin);                           	% Close PTB window 
    ListenChar(0);                                      % Restore keyboard output
    ShowCursor;                                         % Show cursor
    CalWin = NaN;                                       % Do not return a window handle
end
end

function Cleanup
Eyelink('Stoprecording');   % stop recording eye-movements
Eyelink('CloseFile');       % close data file
Waitsecs(1.0);              % give tracker time to execute commands
Eyelink('Shutdown');        % shut down tracker
sca;                        % Close PTB window 
ListenChar(0);              % Restore keyboard output
ShowCursor;                 % Show cursor
end