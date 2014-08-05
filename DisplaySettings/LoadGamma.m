function LoadGamma(CLUT)

physicalDisplay = 1;
Display.ScreenID = 0;
[OriginalGammaTable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', Display.ScreenID);%, physicalDisplay);
save('OriginalSetup3CLUT.mat', 'OriginalGammaTable');

CLUT = 'NIH_Setup3_ASUS_V27.mat';
load(CLUT);

AllScreens = Screen('Screens');
Stereomode = 4;
Text.Size = 60;
Eye = {'Left buffer (0)','Right buffer (1)'};

%================== IDENTIFY LEFT/RIGHT SCREENS AND BUFFERS ===============
[win Rect] = Screen('OpenWindow',0, 128, [],[],[],Stereomode);
for s = 1:2
    Screen('SelectStereoDrawBuffer', win, s-1);     % 0 = left eye buffer; 1 = right eye buffer
    Screen('TextSize', win, Text.Size);  
    DrawFormattedText(win, Eye{s}, 'center', 'center', [0 0 0], []);
    Screen('LoadNormalizedGammaTable', AllScreens, inverseCLUT{s});
end
Screen('Flip',win);
KbWait;
sca;
    
%================================== LOAD CLUTS ============================

% for i=1:numel(Lum)
%     fprintf('CLUT %d for %s\n', i, Lum(i).DisplayName);
% end
% for Display = 1:2
%     Screen('SelectStereoDrawBuffer', AllScreens, Display-1);
%     Screen('LoadNormalizedGammaTable', AllScreens, inverseCLUT{Display});     % Load the original gamma table
% end