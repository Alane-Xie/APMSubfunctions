function DisplayText(Text, Display)
% DisplayText(Text, Display)

%========================= DisplayText.m ==================================
% Displays text provided in the input string 'Text.Text', on the screen with
% settings specified by structures 'Text' and 'Display'. See 'DisplaySettings.m' 
% for information on generating the Display sturcture. 
%
% INPUTS:
%   Text.String     Text string (string)
%   Text.Font       Text font name (string)
%   Text.Size       Text font size (double)
%   Text.Colour     Text color (RGB)
%
% Created by Aidan Murphy (apm909@bham.ac.uk)
% 16/11/2011 - Optimized for mirror and stereo modes on older PTB (3.0.8)
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%==========================================================================

if nargin < 2, help DisplayText; end 
if ischar(Text), String = Text; clear Text; Text.String = String; end
if ~isfield(Text,'Font'), Text.Font = 'Arial'; end
if ~isfield(Text,'Size'), Text.Size = 36; end
if ~isfield(Text,'Colour'), Text.Colour = [0 0 0]; end
if isfield(Display,'Background')
    if Display.Background(1) == 0
        Text.Colour = [255 255 255];
    end
end 

if Display.Stereomode ~= 0
    Eyes = 2;
elseif Display.Stereomode == 0
    Eyes = 1;
end
Screen('TextFont', Display.win, Text.Font);                                 % Set text font
Screen('TextSize', Display.win, Text.Size);                                 % Set text size
for Eye = 1:Eyes
    currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);  	% Draw to screen
    DrawFormattedText(Display.win, Text.String, 'center', 'center', Text.Colour, []);% Draw text
end
array2Flip = Screen('GetImage', Display.win, Display.Rect, 'backBuffer'); 	% Get image from backbuffer
if Display.Mirror == 1
    arraySize = size(array2Flip);
    FlippedArray = array2Flip(:,arraySize(2):-1:1,:);                     	% mirror image left-right
    TextTexture = Screen('MakeTexture', Display.win, FlippedArray);       	% Save mirrored text as a texture
else
    TextTexture = Screen('MakeTexture', Display.win, array2Flip);
end
for Eye = 1:Eyes
    currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);  	% Draw to screen 0
    Screen('DrawTexture',Display.win,TextTexture);
end
Screen('DrawingFinished',Display.win, 2);                                   % Drawing is finished
Screen('Flip',Display.win,[],[],[],1);                                      % Flip to all screens
return