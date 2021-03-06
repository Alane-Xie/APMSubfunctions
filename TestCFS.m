% TestCFS


Capture = 0;
Background = [127 127 127];
Display = DisplaySettings(1);
[Display.win, Display.Rect] = Screen('OpenWindow',Display.ScreenID, Background, Display.DoubleRect, [],[],Display.Stereomode);
Screen('BlendFunction', Display.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);         % Enable alpha channel

DCFS.FrameRate = 10;
DCFS.Duration = 5;                                      
DCFS.TextureSize = [15, 15];
DCFS.Color = 1;
DCFS.Background = Background;

StimRect = [0 0 DCFS.TextureSize]*Display.Pixels_per_deg(1);

Face = imread('Face.jpg');

Face = repmat(Face,[1,3,1]);

FaceTexture = Screen('MakeTexture',Display.win, Face);
FaceContrast = 0.5;
FaceSourceRect = StimRect;
FaceDestRect = [];
FacePixPerFrame = 10;

TextureWindow = DCFS.TextureSize*Display.Pixels_per_deg(1);
%========================= CREATE ALPHA CHANNEL MASK ======================
Stim.Background = Background(1);
Mask.Dim = TextureWindow+4;                                         % Mask will be 2 pixels larger than the stimulus window
Mask.ApRadius = (min(Mask.Dim)/2)-8;
Mask.Colour = Background(1);
Mask.Edge = 2;
MaskTex = GenerateAlphaMask(Mask, Display);
Mask.Rect = [0 0 Mask.Dim];                                        	% Mask size
Mask.DestRect = CenterRect(Mask.Rect, Display.Rect);               	% Destination for mask is centred in screen window

DCFStextures = GenerateDCFS(DCFS, Display,0);

StimDuration = 30;
StartTime = GetSecs;
while GetSecs < StartTime + StimDuration
    for f = 1:numel(DCFStextures)
        FaceSourceRect = FaceSourceRect+[FacePixPerFrame,0,FacePixPerFrame,0];
        if FaceSourceRect(3) > StimRect(3)*2;
            FaceSourceRect = StimRect;
        end
        for Eye = 1:2
            currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1); 
            if Eye == 2
                Screen('DrawTexture', Display.win, DCFStextures(f));
            elseif Eye == 1
                Screen('DrawTexture', Display.win, FaceTexture, FaceSourceRect,FaceDestRect,[],[],FaceContrast);
            end
            Screen('DrawTexture', Display.win, MaskTex, Mask.Rect, Mask.DestRect);     	% Apply Gaussian aperture mask
    %         Screen('FrameRect', Display.win, [255 255 255],CenterRect([0 0 10 10], Display.Rect),2);
        end
        Screen('Flip',Display.win);

        if Capture == 1
            imageArray{f} = Screen('GetImage',Display.win, Mask.DestRect);
        end
    end
end
sca;

if Capture == 1
    FileName = 'dCFS_behavioural.avi';
    daObj=VideoWriter(FileName);
    open(daObj); 
    for f = 1:numel(imageArray)
        writeVideo(daObj,imageArray{f});
    end
    close(daObj);   
end