% DotTest

Display = DisplaySettings(1);
Display.Rect = Screen('rect',Display.ScreenID);     
Display.Rect = Display.Rect/2;       % For debugging, decrease onscreen window size

% Screen('BlendFunction', Display.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);         % Enable alpha channel
%     Screen('BlendFunction', Display.win);
[Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, [128 128 128],Display.Rect,[],[], Display.Stereomode);

Screen('BlendFunction', Display.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 

DotType = 1;
DotsPos = [randi(Display.Rect(3),[1,100]); randi(Display.Rect(4),[1,100])];
Screen('DrawDots', Display.win, DotsPos, 10, [255 255 255],[], DotType);
Screen('Flip', Display.win);
KbWait;
sca;