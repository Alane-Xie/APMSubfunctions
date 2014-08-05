function Movie = PlayMovie(StartTime)

if nargin < 1, StartTime = 0; end
MovieDir = 'Z:\USRlab\projects\murphya\PicTuning_PTB+QNX\Movies';


try
    Display = DisplaySettings(1);
    Display.Background = [0 0 0];
    Display.Imagingmode = [];
    HideCursor;
    KbName('UnifyKeyNames');
    Screen('Preference', 'VisualDebugLevel', 1);                        
    [Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, Display.Background,[],[],[], Display.Stereomode, [], Display.Imagingmode);


    MacaqueMovies = dir(MovieDir);
    MovieNumber = randi(numel(MacaqueMovies)-2)+2;
    movieFile = fullfile(MovieDir, MacaqueMovies(MovieNumber).name);
	[mov, Movie.duration, Movie.fps, Movie.width, Movie.height, Movie.count, Movie.AR]= Screen('OpenMovie', Display.win, movieFile); 
    StartTime = randi(Movie.duration/2);
    Screen('PlayMovie',mov,1);
    Screen('SetmovieTimeIndex',mov,StartTime,0);    
    
    Movie.Scale = 2;
    Movie.Rect = [0 0 Movie.width, Movie.height]*Movie.Scale;
    
    Movie.Rect = CenterRect(Movie.Rect, Display.Rect); 
   
    
    FrameOnset = GetSecs;
    EndMovie = 0;
    while EndMovie == 0
        MovieTex = Screen('GetMovieImage', Display.win, mov);
        for Eye = 1:2
            currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);
            Screen('DrawTexture', Display.win, MovieTex, [], Movie.Rect);
        end
    	[VBL FrameOnset(end+1)] = Screen('Flip', Display.win);
        Screen('Close', MovieTex);
        [keyIsDown,secs,keyCode] = KbCheck;                     % Check keyboard for 'escape' press        
        if keyIsDown && keyCode(KbName('Escape')) == 1       	% Press Esc for abort
            EndMovie = 1;
        end
    end
    Movie.EndTime = Screen('GetMovieTimeIndex', mov);
    Screen('CloseMovie',mov);
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