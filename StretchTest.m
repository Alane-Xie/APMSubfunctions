
% stretch test

Display = DisplaySettings(1);

% ScaledWidth = Display.Rect(3)*(Display.ScreenDimensions(1)/Display.Dimensions(1));
% DestRect = CenterRect([0 0 ScaledWidth Display.Rect(4)],Display.Rect);
Display.Rect = Screen('Rect',Display.ScreenID);

Display.Background = 125;
[Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, Display.Background,Display.Rect,[],[], Display.Stereomode, []);

Tex = zeros(Display.Rect(4),Display.Rect(3));
Texture = Screen('MakeTexture', Display.win, Tex);
Screen('FillOval', Texture, [255 255 255], [200 200 300 300]);
for Eye = 1:2
    currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);
    Screen('DrawTexture', Display.win, Texture, [], Display.DestRect);
end
Screen('Flip', Display.win);
KbWait;
sca;