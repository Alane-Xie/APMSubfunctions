function GridTexture = CalGrid(Display)

%=============================== CalGrid.m ================================
% Presents a uniform grid of approximately 1cm squares across the whole 
% screen, to allow calibration of physical display size using the monitor 
% control keys.
%
%==========================================================================

Background = [0 0 0];
LineWidth = 2;
LineColor{1} = [255 255 255];
LineColor{2} = [255 0 0];

try
    if nargin < 1
        Display = DisplaySettings(1);
        [Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, Background(1),Display.Rect,[],[], Display.Stereomode);
    end
    Pixels_per_cm = round(mean(Display.Pixels_per_m)/100);

    OuterGridSize = floor(Display.Rect/Pixels_per_cm)-[0 0 1 1];
    OuterGrid = OuterGridSize*Pixels_per_cm;
    OuterGrid = CenterRect(OuterGrid, Display.Rect);

    GridX = OuterGrid(1):Pixels_per_cm:OuterGrid(3);
    GridY = OuterGrid(2):Pixels_per_cm:OuterGrid(4);
    Xmid = GridX(ceil(numel(GridX)/2));
    Ymid = GridY(ceil(numel(GridY)/2));
    Ymidline = [Xmid,Xmid;0,Display.Rect(4)];
    Xmidline = [0,Display.Rect(3);Ymid,Ymid];

  	XY(1,:) = reshape([GridX; GridX],[1,numel(GridX)*2]); 
    XY(2,:) = repmat([GridY(1),GridY(end)],[1,numel(GridX)]);
    
    
    GridTexture = Screen('MakeTexture', Display.win, ones(Display.Rect([4,3]))*Background(1));

    Screen('DrawLines', GridTexture, XY, LineWidth, LineColor{1});
    clear XY;
    XY(2,:) = reshape([GridY; GridY],[1,numel(GridY)*2]); 
    XY(1,:) = repmat([GridX(1),GridX(end)],[1,numel(GridY)]);
    Screen('DrawLines', GridTexture, XY, LineWidth, LineColor{1});
    Screen('DrawLines', GridTexture, [Ymidline, Xmidline], LineWidth, LineColor{2});
    Screen('FrameRect', GridTexture, LineColor{2}, CenterRect(Display.Rect/2,Display.Rect), LineWidth*2);
    for Eye = 1:2
        currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1); 
        Screen('DrawTexture', Display.win, GridTexture);
    end
    Screen('Flip',Display.win);
    KbWait;
    sca;
catch
    sca
    rethrow(lasterror)
end