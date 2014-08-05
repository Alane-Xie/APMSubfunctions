% ResetGamma

load('OriginalGamma.mat');
AllScreens = Screen('Screens');
for s = 1:numel(AllScreens)
    Screen('LoadNormalizedGammaTable', AllScreens(s), OriginalGamma);     % Load the original gamma table
end