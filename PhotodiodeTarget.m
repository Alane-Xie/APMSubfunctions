function Target = PhotodiodeTarget(Display, Target)

%=========================== PhotodiodeTarget.m ===========================
% Draws a high luminance circular target in one corner of the screen, to be
% presented at stimulus onset. This allows a photdiode attached to the
% corresponding area of the screen to accurately measure stimulus onset
% time. If a PTB window is not already open, then nothing is drawn but the
% paramaters for the target are returned in the structure Target.
%
% INPUTS
%   Display             structure containing display settings (see DisplaySettings.m)
%   Target.Diameter     size of target (m) [default is 0.02]
%   Target.Position     1 = bottom left corner; 2 = bottom right corner
%   Target.Color        
%
% HISTORY
% 01/11/12 - Written by Aidan Murphy (apm909@bham.ac.uk)
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - murphyap@mail.nih.gov
%  / __  ||  ___/ | |\   |\ \  Section of Cognitive Neurophysiology and Imaging
% /_/  |_||_|     |_| \__| \_\ National Institutes of Mental Health
%
%==========================================================================
if nargin<2, Target=struct('Position',1);end                                        % Set target position to bottom left corner

if ~isfield(Target, 'Diameter'),Target.Diameter = 0.02*Display.Pixels_per_m(1);end 	% Set target size (converted to pixels)
if ~isfield(Target, 'Color'), Target.Color = [255 255 255]; end                   	% Set target color to white
if Target.Position == 1
    Target.Rect = [Display.Rect(1),Display.Rect(4)-Target.Diameter, Display.Rect(1)+Target.Diameter, Display.Rect(4)];
elseif Target.Position == 2
    Target.Rect = [Display.Rect(3)-Target.Diameter,Display.Rect(4)-Target.Diameter, Display.Rect(3), Display.Rect(4)];
end
if isfield(Display, 'win'), Screen('FillOval', Display.win, Target.Color, Target.Rect); end