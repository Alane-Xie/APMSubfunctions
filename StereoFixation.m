function FixMarker = StereoFixation(Display, Fix, Stim)

%========================== StereoFixation.m ==============================
% Generates nonius line crosshair fixation markers and retuns an array of
% Psychtoolbox texture pointers.
%
% INPUTS:
%   Display:                stucture generated by DisplaySettings.m
%   Fix .Diameter           
%       .Size               
%       .NoniusLength       Length of nonius lines (pixels)
%   	.NoniusStart        
%       .Width              Line width (pixels)
%       .Lines    
%       .Rect
%       .BackgorundColour   RGB value for backgorund colour (default = [127 127 127]
%       .Backgorund         0 = transparent (alpha belnding required), 1 = filled circle
%
% OUTPUTS:
%   FixMarker{1}(1) = WHITE fixation marker with LEFT eye nonius lines
%   FixMarker{1}(2) = WHITE fixation marker with RIGHT eye nonius lines
%   FixMarker{2}(1) = BLACK fixation marker with LEFT eye nonius lines
%   FixMarker{2}(2) = BLACK fixation marker with RIGHT eye nonius lines
%
% 16/11/2011 - Written by Aidan Murphy (apm909@bham.ac.uk)
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%==========================================================================

if ~isfield(Fix, 'Size') && ~isfield(Display, 'Pixels_per_deg')
   fprintf('Insufficient input arguments to determine fixation size in pixels!\n'); 
end

%============================== SET DEFAULTS ==============================
if ~isfield(Fix, 'Size')                                                    % If fixation size parameters were not provided...
    Fix.Size = 0.5*Display.Pixels_per_deg;                                  % set fixation square side length (degrees)
    Fix.Width = 1.5;                                                        % set line width for fixation marker (pixels)
    Fix.NoniusLength = 0.375*Display.Pixels_per_deg;                        % set the length of nonius lines (degrees)
    Fix.NoniusStart = Fix.Size/2;                                           % set distance from centre of fixation for nonius lines to start
    Fix.Diameter = round(Fix.Size+(2*Fix.NoniusLength));                    % set diamater of fixation background aperture (degrees)
    Fix.Background = 0;                                                  	% Set default background to clear
end
Fix.BackgroundColour = [127 127 127];                                       % Set default background colour to grey
Fix.Colour{1} = [255 255 255];                                              % Set fixation marker 1 colour to white
Fix.Colour{2} = [0 0 0];                                                    % Set fixation marker 2 colour to black

%============================ GENERATE TEXTURES ===========================
Blank = ones(Fix.Diameter, Fix.Diameter, 4)*Fix.BackgroundColour(1);
Blank(:,:,4) = 0;                                                                                               % Create transparent background (alpha = 0)
Fix.Rect = [Fix.Diameter-Fix.Size, Fix.Diameter-Fix.Size, Fix.Diameter+Fix.Size, Fix.Diameter+Fix.Size]/2;     	% Draw fixation square
Fix.Lines{1} = [-Fix.NoniusLength-Fix.NoniusStart, -Fix.NoniusStart, 0, 0; 0, 0, -Fix.NoniusLength-Fix.NoniusStart, -Fix.NoniusStart]; 	% Draw nonius lines
Fix.Lines{2} = [Fix.NoniusLength+Fix.NoniusStart, Fix.NoniusStart, 0, 0; 0, 0, Fix.NoniusLength+Fix.NoniusStart, Fix.NoniusStart];
for i = 1:2                                                                                                     % For each fixation marker colour
    for Eye = 1:2                                                                                              	% For each eye
        FixMarker{i}(Eye) = Screen('MakeTexture', Display.win, Blank);    
        if Fix.Background == 1
            Screen('FillOval', FixMarker{i}(Eye), Fix.BackgroundColour, [0 0 Fix.Diameter Fix.Diameter]);       % Draw filled background circle
        end
        Screen('FrameRect', FixMarker{i}(Eye), Fix.Colour{i}, Fix.Rect, Fix.Width);                             % Draw inner square
        Screen('DrawLines', FixMarker{i}(Eye), Fix.Lines{Eye}, Fix.Width, Fix.Colour{i}, [Fix.Diameter/2, Fix.Diameter/2]);  
    end
end