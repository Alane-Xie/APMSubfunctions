function BorderSquares = StereoBackground(Display, StimSize, SquareSize, InnerBorder, Background)

%========================== StereoBackground.m ============================
% Generates and returns the handle to a PTB background texture consisting
% of black and white squares, which form a border around a centrally
% presented stereoscopic stimulus.  The same background should be presented
% to each eye in order to aid stable vergence.
%
% INPUTS:
%   Display         
%   StimSize        
%   InnerBorder     
%   Background      
%
% 27/10/11 - Aidan P Murphy (apm909@bham.ac.uk)
%==========================================================================

if nargin < 4
    InnerBorder = 2*Display.Pixels_per_deg;                                 % set the size of the inner border between the surrounding squares and the stimulus (degrees)
    SquareSize = 0.8*Display.Pixels_per_deg;                                % set the size of the surrounding squares (degrees^2)
    Background = 127;                                                       % Set default background colour to mid-grey
end

SquareDensity = 0.7;                                                        % Set default square density to 70%
SquaresPerSide = floor(Display.Rect(3:4)./([SquareSize SquareSize]*2));    	% Calculate how many squares can fit on the screen
OuterBorders(1) = (Display.Rect(3) - (SquaresPerSide(1)*SquareSize*2) + SquareSize)/2;
OuterBorders(2) = (Display.Rect(4) - (SquaresPerSide(2)*SquareSize*2) + SquareSize)/2;
SquareCornersX = [0:(SquareSize*2):(SquaresPerSide(1)*SquareSize*2)]+OuterBorders(1);
SquareCornersY = [0:(SquareSize*2):(SquaresPerSide(2)*SquareSize*2)]+OuterBorders(2);
NoSquareRect = [0 0 StimSize+([InnerBorder InnerBorder]*2)];
BorderRectCorners = nan(4,1);
ZeroRect = CenterRect(NoSquareRect, Display.Rect);
Square = 1;
for x = 1:numel(SquareCornersX)-1
    for y = 1:numel(SquareCornersY)-1
        if ~IsInRect(SquareCornersX(x),SquareCornersY(y),ZeroRect) && ~IsInRect(SquareCornersX(x)+SquareSize,SquareCornersY(y)+SquareSize,ZeroRect)...
                && ~IsInRect(SquareCornersX(x)+SquareSize,SquareCornersY(y),ZeroRect) && ~IsInRect(SquareCornersX(x),SquareCornersY(y)+SquareSize,ZeroRect) 
            BorderRectCorners(:,Square) = [SquareCornersX(x); SquareCornersY(y); SquareCornersX(x)+SquareSize; SquareCornersY(y)+SquareSize];
            Square = Square+1;
        end
    end
end
TotalSquares = (round(numel(BorderRectCorners(1,:))*SquareDensity));
AllSquares = randperm(numel(BorderRectCorners(1,:)));
SquareRects = BorderRectCorners(:,AllSquares(:,1:TotalSquares));
SquareCol = (randi(2, [TotalSquares,1])-1)*255; 
SquareColors = [SquareCol SquareCol SquareCol]';
BorderSquares = Screen('MakeTexture', Display.win, ones(Display.Rect(4), Display.Rect(3))*Background(1));       % Create a blank texture
Screen('FillRect', BorderSquares, SquareColors, SquareRects);                                                   % Draw border squares to texture