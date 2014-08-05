function [Display] = DisplaySettings(Stereo)

%======================== DisplaySettings.m ===============================
% Sets appropriate Psychtoolbox display parameters for the current testing 
% environment, which is determined based on whether the computer ID is 
% recognized.  Display settings are printed to the command window and 
% returned in the structure 'Display'.
%
% SUPPORTED ENVIRONMENTS
%       1 = OFFICE PCs (DEFAULT)
%       2 = HAPLOSCOPE (Hills Building, Room 3.13a)
%       3 = SCANNER STIM 1 (Birmingham University Imaging Centre)  
%       4 = PORTABLE STEREOSCOPE (Hills Building, Room 3.14)
%       5 = MACs
%       6 = CUBICLE 3 STIM S3/ S4 (NeuroImaging Facility, NIMH)
%
% INPUTS
%   Stereo: 0 = Monocular presentation (default).
%           1 = Optimal stereo presentation.  Display will return the 
%               correct choice of stereomode for the testing environment detected.
%           2 = Force dual screen simulation.  Display will simulate a
%               dual screen presentation environment.
%
% OUTPUTS
%       Environment: Detected computer (from supported environments)
%                 D: viewing distance (metres)
%          ScreenID: PTB screen index
%        Stereomode: PTB stereomode
%       Imagingmode: PTB imaging pipeline mode
%              Rect: Screen resolution as PTB rect (pixels)
%        Dimensions: Physical screen dimensions (centimetres)
%            Mirror: Image inversion flag
%       RefreshRate: Display refresh rate (Hz)
%       MultiSample: Global anti-aliasing (defaults to off)
%            Centre: X and Y coordinates of screen centre (pixels)
%       AspectRatio: (W:H proportion)
%      Pixels_per_m: [W,H]
%    Pixels_per_deg: [W,H]
%    Metres_per_deg: 
%              CLUT: ,mat file containing look-up table for linearized gamma
%
% REVISIONS
% 18/06/2011 - Created by Aidan Murphy (apm909@bham.ac.uk)
% 28/10/2011 - Updated for BUIC horizontal span presentation mode
% 22/12/2011 - Updated for displays with non-isotropic pixel dimmensions
% 19/10/2012 - Updated for NIF cubicle 3 binocular setup & MR scanner
% 19/06/2013 - Updated for automatic CLUT loading
% 28/06/2013 - Get IP address via Java
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%==========================================================================

if nargin == 0
    Stereo = 0;
end

%========================= PERFORM SYESTEM CHECKS =========================
Settings.MATLAB = version;                                              % Check MATLAB version and release date
Settings.Bits = computer('arch');                                       % Check 32 or 64-bit
Settings.PTB = PsychtoolboxVersion;                                     % Check Psychtoolbox installation and get version
Settings.OpenGL = opengl('data');                                       % Check graphics card and adapters and check OpenGL version
Settings.Versions = ver;                                                % Check availability of MATLAB toolboxes
Settings.OS = computer;                                                 % Check operating system
[t, Settings.CompName] = system('hostname');                            % Get x-platform computer name
Settings.CompName = getHostName(java.net.InetAddress.getLocalHost());	% Get x-platform computer name (requires Java)
if IsWin
    Settings.SID = get(com.sun.security.auth.module.NTSystem,'DomainSID');  % Check Windows Security Identifier to confirm PC identity
    Settings.CompName = getenv('computername');                             % Get Windows PC name
    address = java.net.InetAddress.getLocalHost;
    Settings.IPaddress = char(address.getHostAddress);
end
if str2num(Settings.OpenGL.Version(1:3)) < 1.5                  % Check what version of OpenGL is available
    fprintf(['DISPLAY: OpenGL version %s does not support vertex buffer objects (VBO)!\n',...
        'You must use display lists instead, but this will reduce performance.\n'], num2str(Settings.OpenGL.Version));
end
Display.Settings = Settings;
AssertOpenGL;                                                   % Check that the script is running in OpenGL Psychtoolbox, otherwise abort
InitializeMatlabOpenGL;                                         % Initialize OpenGL 3D rendering support

fprintf('\n     ___  ______  __   __');
fprintf('\n    /   ||  __  \\|  \\ |  \\    APM SUBFUNCTIONS');
fprintf('\n   / /| || |__/ /|   \\|   \\   Aidan P. Murphy - apm909@bham.ac.uk');
fprintf('\n  / __  ||  ___/ | |\\   |\\ \\  Binocular Vision Lab');
fprintf('\n /_/  |_||_|     |_| \\__| \\_\\ University of Birmingham\n');

fprintf('\n============== SYSTEM CONFIGURATION SUMMARY ================\n\n');
fprintf('DISPLAY: Computer ID............. %s\n', char(Settings.CompName));
fprintf('DISPLAY: MATLAB version.......... %s\n', Settings.MATLAB);
fprintf('DISPLAY: MATLAB bits............. %s\n', Settings.Bits);
fprintf('DISPLAY: PsychToolbox version.... %s\n', Settings.PTB);
fprintf('DISPLAY: Graphics hardware....... %s\n', Settings.OpenGL.Renderer);
fprintf('DISPLAY: OpenGL version.......... %s\n', Settings.OpenGL.Version);
try
    [Settings.UserMem Settings.SystemMem] = memory;             % Check system memory if possible
    fprintf('DISPLAY: Available memory........ %.2f GB\n', Settings.UserMem.MemAvailableAllArrays/10^9);
end

Screens = Screen('Screens');                                 	% Get logical display numbers
for i = 1:numel(Screens)                                    	% For each logical display...
    Monitor(i).Coordinates = Screen('Rect', Screens(i));    	% Get screen resolution
    Monitor(i).Resolution = Monitor(i).Coordinates(3:4)-Monitor(i).Coordinates(1:2);
end

%====================== DETERMINE TESTING ENVIRONMENT  ====================
if strcmp(Settings.CompName, 'PSYCHL-AEW-04')                   % WELCHMAN LAB OFFICE PC
    Display.Environment = 1;
    Display.Dimensions = [37.6 30.4];                               % Samsung SyncMaster 913B (w x h cm)
elseif strcmp(Settings.CompName, 'nimh-01851466-m.nih.gov')... 	% LEOPOLD LAB OFFICE iMAC
    || strcmp(Settings.CompName, 'mh0175276macdt.nih.gov')
    Display.Environment = 1;
    Display.Dimensions = [43.5 27.4];                               
elseif strcmp(Settings.CompName, 'PSG-ZK-16')                   % COMPACT LAB PC
    Display.Environment = 1;
    Display.Dimensions = [33, 52];                                  % Samsung SyncMaster 2493HM (w x h cm)
elseif strcmp(Settings.CompName, 'PSG-AEW-02')                  % OLD HAPLOSCOPE PC
    Display.Environment = 2;                                    
elseif strcmp(Settings.CompName, 'BUIC-STIM-1')               	% BUIC STIM 1 PC
    Display.Environment = 3;                                    
elseif strcmp(Settings.CompName, 'PSG-AEW-TMS')                 % TMS HAPLOSCOPE PC
    Display.Environment = 4;  
elseif strcmp(Settings.CompName, 'PSYCHL-AEW-HSCP')             % NEW HAPLOSCOPE PC
    Display.Environment = 5;
elseif strcmp(Settings.CompName, 'AIDANSLAPTOP-PC')            	% HOME PC
    Display.Environment = 1;    
    Display.Dimensions = [47.4, 29.8];                              % Set physical monitor dimensions w x h of Samsung SyncMaster 2233RZ (cm)
elseif strcmpi(Settings.CompName, 'STIM_S3')...                 % NIF cubicle 3 stereo setup
 	|| strcmp(Settings.CompName, 'STIM_S4')...
    || strcmp(Settings.CompName, 'USER-PC')
    Display.Environment = 6;       
elseif strcmpi(Settings.CompName, 'StimMR_Scan')...                 % NIF MRI scanner display
    || strcmpi(Settings.CompName,'STEREO_STIM')
    Display.Environment = 7;
else
    fprintf(['DISPLAY: Unrecognized computer name!  Defaulting to mode single screen mode.\n', ...
    'DISPLAY: Please update DisplaySettings.m to include details for %s\n'], char(Settings.CompName));
    Display.Environment = 1;
end

%================ SET DISPLAY PARAMETERS FOR DETECTED ENVIRONMENT =========
switch Display.Environment
    case 1                                              % OFFICE PC
        Display.D = 0.5;                                        % Set viewing distance (metres)
        Display.ScreenID = max(Screen('Screens'));              % Display on monitor 2 if available...
        Display.Stereomode = 6;                                 % run in red-green anaglyph mode
        Display.Imagingmode = [];                               % Set imagingmode to disable the imaging pipeline
        Display.Rect = Screen('rect', Display.ScreenID);        % Get the screen resolution (pixels)
        Display.Mirror = 0;                                     % Do not enable mirroring
        Screenscope = 0;                                     	% Set to 1 for use with a Screenscope stereoscope
        if Screenscope == 1                             % SCREENSCOPE STEREOSCOPE (for office use)
            Display.Stereomode = 4;                             % run in dual-display span
            Display.Rect(3) = Display.Rect(3)/2;                % Half screen width in order to fit 2 screens on 1
        end
        
    case 2                                              % HAPLOSCOPE (Hills Building, Room 3.13a)
        Display.D = 0.5;                                        % Set viewing distance (metres)
        Display.ScreenID = 2;                                   % display on both CRT monitors
        Display.Stereomode = 4;                                 % run in dual-display stereo mode
        Display.Dimensions = [36.0225 27.0169];                 % set physical monitor dimensions w x h of ViewSonic P225f CRTs (cm)
        Display.Rect = [0 0 1600 1200];                         % Get the screen resolution (pixels)
        Display.Imagingmode = kPsychNeedFastBackingStore;       % Set imagingmode to enable the imaging pipeline
        Display.Mirror = 1;                                     % Set inversion (mirroring) to on
        
    case 3                                              % SCANNER STIM 1 (Birmingham University Imaging Centre)     
        Display.D = 0.67;                                      	% Set viewing distance (metres)
        Display.ScreenID = 0;                                   % display on both projectors in horizontal span
        Display.Rect = Screen('rect', Display.ScreenID);        % Get the screen resolution of both monitors (pixels)
        Display.Rect(3) = Display.Rect(3)/2;                    % Halve the width to get width of a single screen
        Display.Stereomode = 4;                                 % run in dual-display stereo mode
        Display.Imagingmode = [];                               % Set imagingmode to disable the imaging pipeline
        Display.Dimensions = [52.5 41.6];                       % set physical monitor dimensions w x h (centimetres)
        Display.Mirror = 1;                                     % Set inversion (mirroring) to on
        
    case 4                                              % LCD STEREOSCOPE (Hills Building, Room 3.13)
        Display.D = 0.51;                                       % Set viewing distance (metres)
        Display.ScreenID = 0;                                   % display on both CRT monitors
        Display.Dimensions = [47.4, 29.8];                    	% Set physical monitor dimensions w x h of Samsung SyncMaster 2233RZ (cm)
        Display.Stereomode = 4;                                 % run in dual-display stereo mode
        Display.Rect = Screen('rect',1);                        % get single monitor resolution (1600 x 1050)
        Display.Imagingmode = [];                               % Set imagingmode to disable the imaging pipeline
        Display.Mirror = 1;                                     % Set inversion (mirroring) to on
        
    case 5                                              % NEW HAPLOSCOPE PC (Hills Building, Room 3.13a)
        Display.D = 0.5;                                        % Set viewing distance (metres)
        Display.ScreenID = 0;                                   % display on both CRT monitors
        Display.Stereomode = 4;                               	% run in dual-display stereo mode
        Display.Dimensions = [36.0225 27.0169];                 % set physical monitor dimensions w x h of ViewSonic P225f CRTs (cm)
        Display.Rect = [0 0 1600 1200];                         % Get the screen resolution (pixels)
        Display.Imagingmode = [];                               % Set imagingmode to disable the imaging pipeline
        Display.Mirror = 1;                                     % Set inversion (mirroring) to on
        
 	case 6                                              % SCNI CUBICLE 3 STEREOSCOPE (NIMH)
        Display.D = 0.78;                                       % Set viewing distance (metres)
        Display.ScreenID = 0;                                   % display on both projectors in horizontal span
    	Display.Rect = Screen('rect', max(Screen('Screens')));  % Get the screen resolution of a single monitors (pixels)
        Display.DoubleRect = Screen('rect', 0);                 % Get the screen resolution of both monitors in horizintal span
        Display.Stereomode = 4;                                 % run in dual-display stereo mode
%         Display.ScreenDimensions = [44.8 33.5];                	% set screen dimensions w x h of ASUS (centimetres)
        Display.Dimensions = [59.8 33.5];                       % set physical monitor dimensions w x h of ASUS VG278H LCDs (centimetres)
%         Display.Scale = Display.ScreenDimensions(1)/Display.Dimensions(1);
%         Display.DestRect = CenterRect(Display.Rect.*[1 1 Display.Scale 1],Display.Rect);
        Display.Mirror = 1;                                     % Set inversion (mirroring) to on
%         Display.Dimensions = Display.ScreenDimensions;
        Display.CLUT = 'NIH_Setup3_ASUS_V27.mat';     
        if strcmpi(Settings.CompName, 'STIM_S3')
            Display.Rect(3) = Display.Rect(3)/2;
        end
        
    case 7                                              % NIF 4.7T PROJECTORS
        Display.Rect = Screen('rect', max(Screen('Screens')));  % Get the screen resolution of a single monitors (pixels)
        if Display.Rect == [0 0 1280 1024];                     % For standard resolution...
            Display.Dimensions = [19.5, 16.0];                  % display width x height (cm)
        elseif Display.Rect == [0 0 1920 1080];                 % For HD 1080p resolution...
            Display.Dimensions = [25.2, 14.5];                  % display width x height (cm)
        elseif Display.Rect == [0 0 1920 1200];  
            Display.Dimensions = [25.2, 16.0]; 
        else
            error('The current display resolution is not supported by %s!\n', mfilename);
        end
        Display.D = 0.44;                                   	% viewing distance
        Display.ScreenID = 0;                                   % display on both projectors in horizontal span
        Display.DoubleRect = Screen('rect', 0);                 % Get the screen resolution of both monitors in horizintal span
        Display.Stereomode = 4;                                 % run in dual-display stereo mode
        Display.Mirror = 0;
        Display.Mirror = 1;                                     % Set inversion (mirroring) to on
        Display.CLUT = 'NIH_Setup3_ASUS_V27.mat';                
end

if Stereo == 0                                                              % If stereo presentation was not requested...
     Display.Stereomode = 0;                                                % Select monocular presentation
     Display.ScreenID = max(Screen('Screens'));                             % Only use one monitor
elseif Stereo == 2
     Display.Stereomode = 4;
     Display.ScreenID = min(Screen('Screens'));                         
end
Display.RefreshRate = Screen('NominalFramerate', Display.ScreenID);         % Get the monitor refresh rate (Hz)
if str2double(Settings.PTB(1)) >= 3                                         % For more recent versions of PTB...
    if ismac                                                                % Check is running on OS X...
        if Display.RefreshRate == 0                                         % If running on OS X and refresh rate of 0Hz is reported...
            Display.RefreshRate = 60;                                   	% Assume refresh rate of 60Hz
        end
        if Display.Stereomode == 4                                          % If running on OS X and dual view stereomode is requested...
            Display.Stereomode = 10;
        end
    end
end
Display.MultiSample = 0;                                                    % Set to higher values (2,4,6,8) for improved anti-aliasing        
Display.Centre = [Display.Rect(3), Display.Rect(4)]/2;                      % Calculate the centre of the screen (x, y)
Display.AspectRatio = Display.Rect(3)/Display.Rect(4);                      % Calculate the screen's aspect ration at current resolution
Display.Pixels_per_m = [Display.Rect(3)/Display.Dimensions(1), Display.Rect(4)/Display.Dimensions(2)]*100;  % Calculate number of pixels per metre
Display.Pixels_per_deg = (Display.Pixels_per_m*Display.D*tand(0.5))*2;      % Calculate pixles per degree
Display.Pixels_per_deg(1) = mean(Display.Pixels_per_deg);
Display.Metres_per_deg = tand(1)*Display.D;                                 % Calculate the number of metres per degree of visual angle
[Display.PTBDimensions(1), Display.PTBDimensions(2)] = Screen('DisplaySize', Display.ScreenID);     % Get PTB's estimate of screen dimensions

fprintf('\n============== DISPLAY SETTINGS SUMMARY ====================\n\n');
fprintf('DISPLAY: PTB screen selected..... %d\n', Display.ScreenID);
fprintf('DISPLAY: Screen resolution....... %d x %d\n', Display.Rect(3),Display.Rect(4));
fprintf('DISPLAY: Screen refresh rate..... %d Hz\n', Display.RefreshRate);
switch Display.Stereomode
    case 0
    	fprintf('DISPLAY: Stereomode.............. 0 = monocular presentation.\n');
    case 4
        fprintf('DISPLAY: Stereomode.............. 4 = dual screen stereo presentation.\n');
    case 6
        fprintf('DISPLAY: Stereomode.............. 6 = red-green anaglyph presentation.\n');
    case 8
        fprintf('DISPLAY: Stereomode.............. 8 = red-blue anaglyph presentation.\n');
    case 10
        fprintf('DISPLAY: Stereomode.............. 10 = horizontal span stereo presentation (OSX/ Win7).\n');
end
switch Display.Mirror
    case 0
         fprintf('DISPLAY: Mirror mode............. OFF\n\n');
    case 1
         fprintf('DISPLAY: Mirror mode............. ON\n\n');
end