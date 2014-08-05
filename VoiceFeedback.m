function Success = VoiceFeedback(myString) 

% e.g. VoiceFeedback('Holy shit. I'm awesome. . . I'm so awesome') 

if IsWin
    a = actxserver('SAPI.SpVoice.1'); 
    try
        voicestr = 'Name = LH Michael';             % Default voice for Windows XP
        a.Voice = a.GetVoices(voicestr).Item(0); 
    catch
        voicestr = 'Name = Microsoft Anna';         % Default voice for Windows 7
        a.Voice = a.GetVoices(voicestr).Item(0); 
    end
    a.Speak(myString); 
    a.delete
    Success = 1;
else
    Success = 0;
end
