function Movie = PlayMovie2(MovieDuration, MovieDir, MovieDims, MovieEye)

%============================== PlayMovie.m ===============================
% Randomly selects a movie from the specified directory 'MovieDir', and plays
% a continuous clip lasting for the duration specified by 'MovieDuration' 
% (seconds), beginning from a random starting point.
%
% INPUTS:
%   MovieDuration:  duration of playback (seconds). 0 = play full movie.
%   MovieDir:       directory containing movie files (.avi/.mov/.mp4)
%   MovieDims:      movie dimensions [width, height] (degrees) 
%   MovieEye:   	which eye to present to when in stereo (0=L; 1=R; 2=both)
%
% REQUIREMENTS:
%   APMsubfunctions directory
%   Movie directory
%
% REVISIONS:
% 11/14/2012 - Written.
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - murphyap@mail.nih.gov
%  / __  ||  ___/ | |\   |\ \  Section on Cognitive Neurophysiology and Imaging
% /_/  |_||_|     |_| \__| \_\ NIMH
%==========================================================================
Movie.Show3D = 0;
Streaming = 1;

%====================== Set default parameters
if nargin < 1, MovieDuration = 0; end                               % Playback duration defaults to full movie
if nargin < 2                                                       % Default movie directories
    if IsWin
        MovieDir = 'C:\Users\lab\Desktop\Movies\MonkeyThieves'; 
%         MovieDir = 'C:\Users\lab\Desktop\Movies\RussMoviesWMV';
%         MovieDir = 'C:\Users\lab\Desktop\Movies\LubekWMV';
        if Streaming == 1
            PsychHomeDir('.cache');    % Make sure a cache directory for buffering exists
            Movie.File = 'http://video.ted.com/talk/podcast/2013/None/ElonMusk_2013.mp4';
            Movie.File = 'http://download.ted.com/talks/DanDennett_2003.mp4';
            blocking = 0;
            preloadsecs = 10;
        else
            preloadsecs = []; 
        end
        pixelFormat = 5;
        Stereo = 1;
        if Movie.Show3D == 1
            MovieDir = fullfile(MovieDir, '3DMovies');
        end
    elseif ismac
        MovieDir = '/Volumes/APM909_B/MonkeyThieves_Series1';
        Stereo = 0;
%         Screen('Preference', 'OverrideMultimediaEngine', 1);        % Use GStreamer instead of Quicktime
    %     Screen('Preference', 'DefaultVideocaptureEngine', 3);
    end
end
if nargin < 3, MovieDims = [15 15]; end                             % Movie dimensions default to fullscreen
if nargin < 4, MovieEye = 2; end                                    % Movie presentation defaults to binocular
Movie.WidthDeg = MovieDims(1);                                      % Specify movie width (deg)
Movie.MaintainAR = 0;                                               
Movie.FullScreen = 1;
Movie.Mirror = 0;
Movie.Volume = 0.25;

try
    %====================== Open PTB window
    Display = DisplaySettings(Stereo);
    Display.Background = [0 0 0];%[128 128 128];
    Display.Imagingmode = [];                       
    HideCursor;
    KbName('UnifyKeyNames');
    Screen('Preference', 'VisualDebugLevel', 1);     
    Display.Rect = Screen('Rect',Display.ScreenID);
    [Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, Display.Background,Display.Rect,[],[], Display.Stereomode, [], Display.Imagingmode);

    %====================== Open movie file
    MacaqueMovies = dir(MovieDir);
    MovieNumber = Randi(numel(MacaqueMovies)-3)+3;
    if Streaming ~= 1
        Movie.File = fullfile(MovieDir, MacaqueMovies(MovieNumber).name);
    end
    Movie.Format = Movie.File([end-5, end-4]);
	[mov, Movie.TotalDuration, Movie.fps, Movie.width, Movie.height, Movie.count, Movie.AR]= Screen('OpenMovie', Display.win, Movie.File, [], preloadsecs, [], pixelFormat);
    Movie.SourceRect{2} = [0 0 Movie.width, Movie.height];
    if MovieDuration == 0
        StartTime = 1;
        MovieDuration = Movie.TotalDuration;
    elseif MovieDuration > 0
        StartTime = randi(Movie.TotalDuration-MovieDuration);
    end
    Screen('PlayMovie',mov,1,[],Movie.Volume);
    Screen('SetmovieTimeIndex',mov,StartTime,1); 
    
    if Movie.MaintainAR == 0
        if Movie.FullScreen == 1
            Movie.DestRect = Display.Rect;
        elseif Movie.FullScreen == 0
            Movie.DestRect = [0 0 MovieDims]*Display.Pixels_per_deg(1);
        end
    elseif Movie.MaintainAR == 1
        if Movie.FullScreen == 1
            Movie.WidthDeg = Display.Rect(3);
        else
            Movie.WidthDeg = MovieDims(1)*Display.Pixels_per_deg(1);
        end
        Movie.DestRect = (Movie.SourceRect{2}/Movie.width)*Movie.WidthDeg;
    end
    if ~isempty(find(Movie.DestRect > Display.Rect))
        Movie.DestRect = Movie.DestRect*min(Display.Rect([3, 4])./Movie.Rect([3, 4]));
        fprintf('Requested movie size > screen size! Defaulting to maximum size.\n');
    end
    Movie.DestRect = CenterRect(Movie.DestRect, Display.Rect);
    if Movie.Show3D == 1
        if strcmpi(Movie.Format, 'LR')          % Horizontal split screen
            Movie.SourceRect{1} = Movie.SourceRect{2}./[1 1 2 1];
            Movie.SourceRect{2} = Movie.SourceRect{1}+[Movie.SourceRect{1}(3),0, Movie.SourceRect{1}(3),0];     
        elseif strcmpi(Movie.Format, 'RL')          
            Movie.SourceRect{2} = Movie.SourceRect{2}./[1 1 2 1];
            Movie.SourceRect{1} = Movie.SourceRect{2}+[Movie.SourceRect{2}(3),0, Movie.SourceRect{2}(3),0];  
        elseif strcmpi(Movie.Format, 'TB')      % Vertical split screen
            Movie.SourceRect{1} = Movie.SourceRect{2}./[1 1 1 2];
            Movie.SourceRect{2} = Movie.SourceRect{1}+[0,Movie.SourceRect{1}(4),0, Movie.SourceRect{1}(4)];
        else
            fprintf('\nERROR: 3D movie format must be specified in filename!\n');
        end
    else
        Movie.SourceRect{1} = Movie.SourceRect{2};
    end
    
    if Movie.Mirror == 1
        SourceRect = Movie.SourceRect{1}.*[1 1 2 1];
    end
    
%     Cube.DepthRange = [-0.5 0.5];
%     Cube.BlankRect = Movie.DestRect;
%     [BackgroundTextures, GL] = BackgroundCubes(Display, Cube);
    
    %===================== Play movie
    FrameOnset = GetSecs;
    EndMovie = 0;
    while EndMovie == 0
        MovieTex = Screen('GetMovieImage', Display.win, mov, 1);
        if Movie.Mirror == 1
            Screen('DrawTexture', Display.win, MovieTex, Movie.SourceRect{1}, Movie.SourceRect{1});
            array2Flip = Screen('GetImage', Display.win, SourceRect, 'backBuffer');
            FlippedArray = array2Flip(:,end:-1:1,:);
            MovieTex = Screen('MakeTexture', Display.win, FlippedArray); 
            Screen('FillRect',Display.win, Display.Background);
            for Eye = 1:2
                currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);
                Screen('DrawTexture', Display.win, MovieTex, SourceRect, Movie.DestRect);
            end
        else
            for Eye = 1:2
                currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);
%                 Screen('DrawTexture', Display.win, BackgroundTextures(Eye));
                Screen('DrawTexture', Display.win, MovieTex, Movie.SourceRect{Eye}, Movie.DestRect);
            end
        end
    	[VBL FrameOnset(end+1)] = Screen('Flip', Display.win);
        Screen('Close', MovieTex);
        [keyIsDown,secs,keyCode] = KbCheck;                     % Check keyboard for 'escape' press        
        if keyIsDown && keyCode(KbName('Escape')) == 1       	% Press Esc for abort
            EndMovie = 1;
        end
    end
    sca
    
    %===================== Clean up
    Movie.EndTime = Screen('GetMovieTimeIndex', mov);
    Screen('CloseMovie', mov);
    sca;
    ShowCursor;
    
    Frametimes = diff(FrameOnset);
    meanFrameRate = mean(Frametimes(2:end))*1000;
    semFrameRate = (std(Frametimes(2:end))*1000)/sqrt(numel(Frametimes(2:end)));
    fprintf('Frames shown............%.0f\n', numel(Frametimes));
    fprintf('Mean frame duration.....%.0f ms +/- %.0f ms\n', meanFrameRate, semFrameRate);
    fprintf('Max frame duration......%.0f ms\n', max(Frametimes)*1000);
catch
    sca
    rethrow(lasterror);
end