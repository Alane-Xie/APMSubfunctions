function [] = CapturePointLight(MovieFile,PointNames)

%========================= CapturePointLight.m ============================
% This function operates as a GUI that allows you to manually capture
% biological motion data for the creation of point-light figures from a 
% movie clip. After loading the selected movie, you will be asked how many 
% points you wish to track, and asked to name each point. You will then be 
% prompted to click on each point in each frame. All point coordinates are
% saved in a .txt file in the 'data3d' format (Van Boxtel & Lu, 2013).
% These can be reloaded into CapturePointLight.m or processed and rendered
% using the Biomotion Toolbox.
%
% INPUTS (optional):
%   MovieFile:      Full path of movie clip to load
%   PointNames:     Cell array of strings containing name for each point
%
% REQUIREMENTS:
%   mmread.m by Micah Richert  http://www.mathworks.com/matlabcentral/fileexchange/8028-mmread
%   Biomotion Toolbox:         http://www.jeroenvanboxtel.com/software/BioMotionToolbox.php
%
% REFERENCES:
%   Shipley TF& Brumberg JS (2005). Markerless motion-capture for point-light 
%       displays. 
%   Van Boxtel JJA & Lu H (2013). A biological motion toolbox for reading, 
%       displaying, and manipulating motion capture data in research settings.
%
% REVISIONS:
%   13/12/2013 - Written by APM
%   27/01/2014 - Adapted for biological motion clip creation
%   28/01/2014 - GUI added + compatibility with Biomotion Toolbox added
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - murphyap@mail.nih.gov
%  / __  ||  ___/ | |\   |\ \  Section on Cognitive Neurophysiology and Imaging
% /_/  |_||_|     |_| \__| \_\ National Institute of Mental Health
%==========================================================================
global PL Inputs Mov Info Command;

addpath(genpath('mmread'));
% MovieFile = '..\..\Stimuli\Monkey_walk_01.avi';

%% ========================== OPEN MOVIE FILE =============================
if ~exist('MovieFile','var')
    DefaultPath = '/Volumes/USRLAB/projects/murphya/Stimuli/Movies';
    FileFormats = {'*.avi', 'AVI movie';'*.mov','MOV movie';'*mp4','MPEG-4';'*wmv','Windows Media Video';'*.*', 'All file types'};
    [filename, pathname, filterindex] = uigetfile(FileFormats, 'Select movie file', DefaultPath);
    MovieFile = fullfile(pathname, filename);
end
[Filepath Filename Fileext] = fileparts(MovieFile);
Mov.Filename = Filename;
Mov.Filepath = Filepath;
PL.MovieCapture = 0;
Mov.Method = 1;
Mov.FrameRate = 30;
Mov.StartTime = 0;
Mov.NoFrames = 70;                                                      % How many frames to base the clip on
Mov.FrameOne = max([1,round(Mov.StartTime*Mov.FrameRate)]);             % Specify which frames to import

switch Mov.Method
    case 1      %========= mmread.m
        Mov.FrameRange = Mov.FrameOne:(Mov.FrameOne+Mov.NoFrames);  	% Specify which frames to read  
        Mov.FrameRange = [];                                            % Load all frames
        video = mmread(MovieFile, Mov.FrameRange,[],[],true);           % read movie
        for f = 1:Mov.NoFrames
            Mov.Frames(:,:,:,f) = video.frames(f).cdata;
        end
        Mov.TotalFrames = video.nrFramesTotal;                          % Get the number of frames in the selected movie file
        Mov.FrameRate = round(video.rate);
        Mov.FrameDim = [video.width, video.height];
        Mov.Duration = Mov.NoFrames/Mov.FrameRate;
        
    case 2      %========= videoreader.m
        Mov.FrameRange = [Mov.FrameOne, Mov.FrameOne+Mov.NoFrames];  	% Specify first and last frame to read  
        readerobj = VideoReader(MovieFile);                            	% Construct a multimedia reader object
        Mov.Frames = read(readerobj,Mov.FrameRange);                    % Read in all video frames
        Mov.TotalFrames = get(readerobj, 'numberOfFrames');             % Get the number of frames in the selected movie file
        Mov.FrameRate = get(readerobj, 'FrameRate');                    %      
        Mov.FrameDim = [readerobj.Width, readerobj.Height];             % 
        Mov.Duration = Mov.NoFrames/Mov.FrameRate;
        
    case 3      %========= avireader
        
        
        
end
            
if ~exist('PointNames','var')
    PL.PointNames = {'Left Wrist','Left Elbow','Left Shoulder','Left Ankle','Left Knee','Left Hip',...
                    'Right Wrist','Right Elbow','Right Shoulder','Right Ankle','Right Knee','Right Hip',...
                    'Neck','Head','Tail tip','Tail middle','Tail base'};
    
    answer = inputdlg('How many points are you tracking?','Point light animator',1,{'1'});
    PL.NoPoints = str2num(answer{1});
    for n = 1:PL.NoPoints
       PL.PointNames{n} = inputdlg(sprintf('Please provide a name for point %d:',n),'Point light animator',1,{'e.g. Right hand'});
    end
end


%% =========================== OPEN GUI CONTROLS ==========================

%=========== Set default parameters
PL.Mov = Mov;
PL.Background = [0.5 0.5 0.5];
PL.CurrentFrame = 1;    
PL.CurrentPoint = 1;
PL.FramesVisible = 1;
PL.TrajectoryOn = 0;
PL.Zoom = 0;
PL.PointConfirmed = [0 1 0];
PL.PointUnconfirmed = [1 0 0];
PL.PointConfirmedSize = 16;
PL.PointUnconfirmedSize = 12;
PL.UIfontsize = 14;
PL.Coordinates = cell(1,Mov.NoFrames);
for f = 1:Mov.NoFrames
    PL.Coordinates{f} = nan(PL.NoPoints,2);     % Preallocate matrix with nans
    PL.Coordinates{f}(:,3) = 0;                 % Z-coordinate defaults to zero
end

%=========== Open figure window
PL.ScreenSize = get(0,'ScreenSize')*0.95;                            % Set figure window size to 95% of full screen
PL.fh = figure('units','pixels','position',PL.ScreenSize,'menubar','none','Color',[0.5 0.5 0.5],'name','Point Light Capture');
set(PL.fh,'KeyPressFcn',{@Keypress});                               % Set figure callback for keyboard presses
set(PL.fh,'pointer','fullcrosshair');                               % Set pointer to crosshair style
PL.axesPos = [360 20 PL.ScreenSize(3)-380 PL.ScreenSize(4)-60];     % Set axes positions to avoid overlap with GUI panels
PL.axes = axes('units','pixels','position', PL.axesPos);            % Set axes position in pixels

Borders = 20;
PanelWidth = 280;
PL.GUIPanelRect{1} = [Borders, PL.ScreenSize(4)-Borders-220, PanelWidth, 160];
PL.GUIPanelRect{2} = [Borders, PL.ScreenSize(4)-(2*Borders)-220-220, PanelWidth, 220];
PL.GUIPanelRect{3} = [Borders, PL.ScreenSize(4)-(3*Borders)-220-220-160, PanelWidth, 160];

%========== GUI command pannel
Command.BoxPos = PL.GUIPanelRect{3};
Command.LabelDim = [100 25];
Command.InputLabels = {'Add point','Play','Frame vis','Zoom','Save','Load'};
Command.InputStyles = {'pushbutton','pushbutton', 'pushbutton', 'pushbutton','pushbutton', 'pushbutton'};
Command.handle = uibuttongroup('Title','Commands','FontSize',PL.UIfontsize+2,'BackgroundColor',PL.Background,'Units','pixels','Position',Command.BoxPos);
for i = 1:numel(Command.InputLabels)
    Pos = numel(Command.InputLabels)-(i);
    if i <= 4
        Command.InputPos{i} = [10, -50+Pos*(Command.LabelDim(2)+5),Command.LabelDim];
        Command.InputPos{i+4} = Command.InputPos{i}+[120 0 0 0];
    end
    Command.InputHandle(i) = uicontrol('Style',Command.InputStyles{i},'String',Command.InputLabels{i},'HorizontalAlignment','Left','pos',Command.InputPos{i},'parent',Command.handle,'Callback',{@CommandSelect,i});
end
    
    
%=========== GUI navigation panel
Inputs.BoxPos = PL.GUIPanelRect{2};
Inputs.LabelDim = [100 25];
Inputs.Labels = {'Selected:','Frame #:','Time:','Point #:','Point tag:', 'Update?'};
Inputs.LabelStyles = {'Text','Text','Text','Text','Text','Text'};
Inputs.InputStyles = {'Text','Edit','Edit','Edit','Edit','pushbutton'};
Inputs.InputData = {'X = NaN, Y = NaN',num2str(PL.CurrentFrame),num2str(PL.CurrentFrame*(1/Mov.FrameRate)),num2str(PL.CurrentPoint),PL.PointNames{PL.CurrentPoint},'OK'};
Inputs.handle = uibuttongroup('Title','Navigation','FontSize',PL.UIfontsize+2,'BackgroundColor',PL.Background,'Units','pixels','Position',Inputs.BoxPos);
for i = 1:numel(Inputs.Labels)
    Pos = numel(Inputs.Labels)-(i);
    Inputs.LabelPos{i} = [10, 10+Pos*(Inputs.LabelDim(2)+5),Inputs.LabelDim];
    Inputs.InputPos{i} = Inputs.LabelPos{i}+[100 0 50 0];
    Inputs.LabelHandle(i) = uicontrol('Style',Inputs.LabelStyles{i},'String',Inputs.Labels{i},'HorizontalAlignment','Left','pos',Inputs.LabelPos{i},'parent',Inputs.handle);
    Inputs.InputHandle(i) = uicontrol('Style',Inputs.InputStyles{i},'String',Inputs.InputData{i},'HorizontalAlignment','Left','pos',Inputs.InputPos{i},'parent',Inputs.handle,'Callback',{@InputsSelect,i});
end
set(Inputs.LabelHandle, 'FontSize',PL.UIfontsize,'BackgroundColor',PL.Background);
set(Inputs.InputHandle(2:end),'FontSize',PL.UIfontsize,'BackgroundColor',PL.Background+0.2);
set(Inputs.InputHandle(1),'FontSize',PL.UIfontsize,'BackgroundColor',PL.Background);


%=========== Add a slider below movie frame to control frame selection
Inputs.Slider.Step = [1/Mov.NoFrames, 10/Mov.NoFrames];
Inputs.Slider.Pos = [PL.axesPos([1,2,3]),PL.axesPos(2)+15];
Inputs.SliderHandle = uicontrol('Style','slider','SliderStep',Inputs.Slider.Step,'HorizontalAlignment','Left','pos',Inputs.Slider.Pos,'Callback',{@InputsSelect,numel(Inputs.Labels)+1});


%========== GUI information panel
Info.BoxPos = PL.GUIPanelRect{1};
Info.LabelDim = [100 25];
Info.Labels = {'Movie file:','Frames:','Duration (s):','Frame rate:','Resolution:'};
Info.InputData = {[Filename Fileext],num2str(Mov.NoFrames),num2str(Mov.Duration), num2str(Mov.FrameRate), [num2str(Mov.FrameDim(1)),' x ',num2str(Mov.FrameDim(2))]};
Info.handle = uibuttongroup('Title','Information','FontSize',PL.UIfontsize+2,'BackgroundColor',PL.Background,'Units','pixels','Position',Info.BoxPos);
for i = 1:numel(Info.Labels)
    Pos = numel(Info.Labels)-(i);
    Info.LabelPos{i} = [10, 10+Pos*(Info.LabelDim(2)),Info.LabelDim];
    Info.InputPos{i} = Info.LabelPos{i}+[100 0 50 0];
    Info.LabelHandle(i) = uicontrol('Style','Text','String',Info.Labels{i},'HorizontalAlignment','Left','pos',Info.LabelPos{i},'parent',Info.handle);
    Info.InputHandle(i) = uicontrol('Style','Text','String',Info.InputData{i},'HorizontalAlignment','Left','pos',Info.InputPos{i},'parent',Info.handle,'Callback',{@InfoSelect,i});
end
set(Info.LabelHandle, 'FontSize',PL.UIfontsize,'BackgroundColor',PL.Background);
set(Info.InputHandle, 'FontSize',PL.UIfontsize, 'BackgroundColor',PL.Background);





%% ============== DISPLAY CURRENT FRAME AND RECORD POINTS =================
PL.Im = image(Mov.Frames(:,:,:,PL.CurrentFrame));
hold on;
PL.xLimits = get(PL.axes, 'xlim');
PL.yLimits = get(PL.axes, 'ylim');
axis equal tight off;% xy;
set(gcf, 'WindowButtonDownFcn', @getCoordinates);
set(gcf, 'Pointer', 'crosshair');                   % Optional
pan off                                             % Panning will interfere with this code    
    


%% =============== GENERATE AND CAPTURE POINT LIGHT MOVIE =================


% Filter point trajectories

% Apply translations to maintain static center-of-mass

% Render

% Capture


% [im1,map] = frame2im(mov(10));           % Grab specified frame
% imwrite(im1,map,'clockFrame1.bmp');


end


%% ==================== SUBFUNCTIONS AND CALLBACKS ========================

%================= PLOT MARKER AT MOUSE SELECTED COORDINATES ==============
function getCoordinates(src, event)
global PL Inputs Mov
    handles = guidata(src);
    cursorPoint = get(PL.axes, 'CurrentPoint');
    PL.curX = cursorPoint(1,1);
    PL.curY = cursorPoint(1,2);
    if (PL.curX > min(PL.xLimits) && PL.curX < max(PL.xLimits) && PL.curY > min(PL.yLimits) && PL.curY < max(PL.yLimits))
        try
            delete(PL.PointHandle(PL.CurrentPoint));
        end
        CurrentPos = sprintf('X = %.0f, Y = %.0f', PL.curX, PL.curY);
        PL.PointHandle(PL.CurrentPoint) = plot(PL.curX, PL.curY,'.','Color',PL.PointUnconfirmed,'MarkerSize',PL.PointUnconfirmedSize);
    else
        CurrentPos = sprintf('-');
    end
    title(CurrentPos, 'FontWeight','Bold','FontSize',18);
    set(Inputs.InputHandle(1),'string',CurrentPos);
end

%========================== DRAW CIRCULAR PATCH ===========================
function h = FillCircle(x,y,N,r,c,alpha)
    THETA = linspace(0,2*pi,N);
    RHO=ones(1,N)*r;
    [X,Y] = pol2cart(THETA,RHO);
    X=X+x;
    Y=Y+y;
    h = fill(X,Y,c,'EdgeColor','none');
    alpha(h, alpha);
end

%========================== UPDATE FRAME IMAGE ============================
function UpdateFrame
    global PL Inputs Mov
    try
        delete(PL.Im);                                       	% Delete previous movie frame
        delete(PL.PointHandle);                                 % Delete previously visible points
    end
    if PL.FramesVisible == 1
        PL.Im = image(Mov.Frames(:,:,:,PL.CurrentFrame));      	% Draw new frame
    end
    hold on;                                                    
    axis equal tight off;                                       % Set axis properties
    pan off;                                                    % Turn pan off
    set(PL.axes, 'xlim', PL.xLimits);                           % Set axis limits
    set(PL.axes, 'ylim', PL.yLimits);
    for p = 1:PL.NoPoints                                       % For all points...
        if p <= numel(PL.Coordinates{PL.CurrentFrame}(:,1))     % ...within range...
            if ~isempty(PL.Coordinates{PL.CurrentFrame}(p,:))  	% If coordinates have been saved...
                PL.PointHandle(p) = plot(PL.Coordinates{PL.CurrentFrame}(p,1),PL.Coordinates{PL.CurrentFrame}(p,2),'.','Color',PL.PointConfirmed,'MarkerSize',PL.PointConfirmedSize);
            end
        end
    end
end

%========================= READ KEYBOARD INPUT ============================
function Keypress(hObj, Evnt)
    global PL Inputs Mov
    switch Evnt.Key
        case 'leftarrow'
            if PL.CurrentFrame > 1
                PL.CurrentFrame = PL.CurrentFrame-1;
                PL.CurrentTime = PL.CurrentFrame/Mov.FrameRate;
                set(Inputs.InputHandle(2), 'string', num2str(PL.CurrentFrame));
                set(Inputs.InputHandle(3), 'string', num2str(PL.CurrentTime));
                set(Inputs.SliderHandle, 'value', PL.CurrentFrame/Mov.NoFrames);
                UpdateFrame;
        	else
                beep;
            end
        case 'rightarrow'
            if PL.CurrentFrame < Mov.NoFrames
                PL.CurrentFrame = PL.CurrentFrame+1;
             	PL.CurrentTime = PL.CurrentFrame/Mov.FrameRate;
                set(Inputs.InputHandle(2), 'string', num2str(PL.CurrentFrame));
                set(Inputs.InputHandle(3), 'string', num2str(PL.CurrentTime));
                set(Inputs.SliderHandle, 'value', PL.CurrentFrame/Mov.NoFrames);
                UpdateFrame;
            else
                beep;
            end
        case 'uparrow'
            Handle = PL.PointHandle(PL.CurrentPoint);
            if get(Handle,'Color') == PL.PointUnconfirmed
                set(Handle,'Color',PL.PointConfirmed,'MarkerSize',PL.PointConfirmedSize);
                PL.Coordinates{PL.CurrentFrame}(PL.CurrentPoint,:) = [PL.curX, PL.curY];
            end
            
        case 'downarrow'
            Handle = PL.PointHandle(PL.CurrentPoint);
            if get(Handle,'Color') == PL.PointConfirmed
                set(Handle,'Color',PL.PointUnconfirmed,'MarkerSize',PL.PointUnconfirmedSize);
                PL.Coordinates{PL.CurrentFrame}(PL.CurrentPoint,:) = [];
            end   
            
        otherwise
            
    end

end

%======================= READ GUI CONTROL PANEL INPUT =====================
function InputsSelect(hObj, Evnt, Indx)
    global PL Inputs Mov

    
    switch Indx
        case 1      %================= coordinate selection
            
            
        case 2      %================= frame number
            PL.CurrentFrame = str2double(get(hObj,'String'));
            PL.CurrentTime = PL.CurrentFrame/Mov.FrameRate;
            set(Inputs.InputHandle(3), 'string', num2str(PL.CurrentTime));
            UpdateFrame;
            set(Inputs.SliderHandle, 'value', PL.CurrentFrame/Mov.NoFrames);
            
        case 3      %================= Select time
            PL.CurrentTime = str2double(get(hObj,'String'));
            PL.CurrentFrame = round(PL.CurrentTime*Mov.FrameRate);
            set(Inputs.InputHandle(2), 'string', num2str(PL.CurrentFrame));
            UpdateFrame;
            set(Inputs.SliderHandle, 'value', PL.CurrentFrame/Mov.NoFrames);
            
        case 4      %================= Select point number
            PL.CurrentPoint = str2double(get(hObj,'String'));
            if PL.CurrentPoint <= numel(PL.PointNames)
                set(Inputs.InputHandle(5), 'string', PL.PointNames{PL.CurrentPoint});
            else
                set(Inputs.InputHandle(5), 'string', '...?');
            end
            UpdateFrame;
            
        case 5      %================= Enter point name
            PL.PointNames{PL.CurrentPoint} = get(hObj,'String');
            if PL.CurrentPoint > PL.NoPoints
                PL.NoPoints = PL.CurrentPoint;
            end

        case 6      %================= Update coordinates
         	Handle = PL.PointHandle(PL.CurrentPoint);
            if get(Handle,'Color') == PL.PointUnconfirmed
                PL.Coordinates{PL.CurrentFrame}(PL.CurrentPoint,:) = [PL.curX, PL.curY];
                set(PL.PointHandle(PL.CurrentPoint),'Color',PL.PointConfirmed,'MarkerSize',PL.PointConfirmedSize);
            elseif get(Handle,'Color') == PL.PointConfirmed
                set(Handle,'Color',PL.PointUnconfirmed,'MarkerSize',PL.PointUnconfirmedSize);
                PL.Coordinates{PL.CurrentFrame}(PL.CurrentPoint,:) = [];
            end
        
        case 7      %================= Slider
            SliderPos = get(hObj,'Value');
            PL.CurrentFrame = max([1, round(SliderPos*Mov.NoFrames)]);
            PL.CurrentTime = PL.CurrentFrame/Mov.FrameRate;
            set(Inputs.InputHandle(2), 'string', num2str(PL.CurrentFrame));
         	set(Inputs.InputHandle(3), 'string', num2str(PL.CurrentTime));
            UpdateFrame;
            
    end

end

%======================= READ GUI CONTROL PANEL INPUT =====================
function CommandSelect(hObj, Evnt, Indx)
    global PL Inputs Command Mov
    switch Indx
        case 1      %================= Add new point
            PL.NoPoints = PL.NoPoints+1;
            PL.CurrentPoint = PL.NoPoints;
            set(Inputs.InputHandle(3), 'string', num2str(PL.CurrentPoint));
            set(Inputs.InputHandle(4), 'string', '...?');
            
        case 2      %================= Play movie with points
            
            if PL.MovieCapture > 0 
                ExportFilename = fullfile(Mov.Filepath, [Mov.Filename,'_PL.avi']);
                if PL.MovieCapture == 1
                    vidObj = VideoWriter(ExportFilename);
                    open(vidObj);
                end
            end
            for f = 1:Mov.NoFrames
                PL.CurrentFrame = f;
                PL.CurrentTime = PL.CurrentFrame/Mov.FrameRate;
                set(Inputs.InputHandle(2), 'string', num2str(PL.CurrentFrame));
                set(Inputs.InputHandle(3), 'string', num2str(PL.CurrentTime));
                set(Inputs.SliderHandle, 'value', PL.CurrentFrame/Mov.NoFrames);
                cla;
                UpdateFrame;
                if PL.MovieCapture == 2 
                    M(f) = getframe(PL.axes);
                elseif PL.MovieCapture == 1
                    writeVideo(vidObj, getframe(PL.axes));
                end
              	drawnow;
            end
            if PL.MovieCapture == 2
                movie2avi(M, ExportFilename, 'compression','None', 'fps',Mov.FrameRate);
            elseif PL.MovieCapture == 1
             	close(vidObj);
            end
            
       	case 3
            PL.FramesVisible = ~PL.FramesVisible;
            UpdateFrame;
            
        case 4      %================= Zoom view
            PL.Zoom = ~PL.Zoom;
            if PL.Zoom == 1
                PL.OriginalLims = [PL.xLimits, PL.yLimits];
                rect = getrect(PL.axes);                                % Allow user to select rectange to zoom on
                if ~isnan(rect)
                    PL.xLimits = rect([1,3]);
                    PL.yLimits = rect([2 4]);
                    set(PL.axes, 'XLim', PL.xLimits, 'YLim', PL.yLimits);
                end
            elseif PL.Zoom == 0
                PL.xLimits = PL.OriginalLims([1,2]);
                PL.yLimits = PL.OriginalLims([3,4]);
                set(PL.axes, 'XLim', PL.xLimits, 'YLim', PL.yLimits);
            end
            
        case 5      %================= Save data
            DefaultFilename = fullfile(Mov.Filepath,[Mov.Filename,'_data3d.txt']);
            [filename, pathname] = uiputfile('.txt','Save coordinates as:',DefaultFilename);
            Filename = fullfile(pathname, filename);
            for f = 1:numel(PL.Coordinates)
                for p = 1:PL.NoPoints
                    for d = 1:3
                        Matrix(3*(f-1)+d,p) = PL.Coordinates{f}(p,d);
                    end
                end
            end
            dlmwrite(Filename,Matrix,' ');
 

        case 6     %================= Load data
            [filename, pathname, filterindex] = uigetfile('*data3d.txt','Load coordinates from:', Mov.Filepath);
            Filename = fullfile(pathname, filename);
            Matrix = dlmread(Filename,' ');
            PL.NoPoints = size(Matrix,2);
            PL.Coordinates = cell(1,size(Matrix,1)/3);
            for f = 1:numel(PL.Coordinates)
                for p = 1:PL.NoPoints
                    for d = 1:3
                        PL.Coordinates{f}(p,d) = Matrix(3*(f-1)+d,p);
                    end
                end
            end
    end
end