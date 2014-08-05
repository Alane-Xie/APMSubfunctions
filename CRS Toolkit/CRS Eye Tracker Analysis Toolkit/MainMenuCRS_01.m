function varargout = MainMenuCRS(varargin)
% MAINMENUCRS M-file for MainMenuCRS.fig
%      MAINMENUCRS, by itself, creates a new MAINMENUCRS or raises the existing
%      singleton*.
%
%      H = MAINMENUCRS returns the handle to a new MAINMENUCRS or the handle to
%      the existing singleton*.
%
%      MAINMENUCRS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINMENUCRS.M with the given input arguments.
%
%      MAINMENUCRS('Property','Value',...) creates a new MAINMENUCRS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainMenuCRS_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainMenuCRS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainMenuCRS

% Last Modified by GUIDE v2.5 04-Mar-2009 10:09:39
global configData;

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainMenuCRS_OpeningFcn, ...
                   'gui_OutputFcn',  @MainMenuCRS_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before MainMenuCRS is made visible.
function MainMenuCRS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainMenuCRS (see VARARGIN)

% Choose default command line output for MainMenuCRS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainMenuCRS wait for user response (see UIRESUME)
% uiwait(handles.main);


% --- Outputs from this function are returned to the command line.
function varargout = MainMenuCRS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function mnuOpenOutput_Callback(hObject, eventdata, handles)
% hObject    handle to mnuOpenOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuSaveOutput_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSaveOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuQuit_Callback(hObject, eventdata, handles)
% hObject    handle to mnuQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuSaccParams_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSaccParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ConfigSaccadeParams;

% --------------------------------------------------------------------
function mnuFixParams_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFixParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ConfigFixParams;

% --------------------------------------------------------------------
function mnuBlinkParams_Callback(hObject, eventdata, handles)
% hObject    handle to mnuBlinkParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ConfigBlinkParams;

function mnuLimitParams_Callback(hObject, eventdata, handles)
% hObject    handle to mnuBlinkParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ConfigLimitParams;
% --------------------------------------------------------------------
function mnuRunFull_Callback(hObject, eventdata, handles)
% hObject    handle to mnuRunFull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check if all parameters etc. have been loaded and we have a file to
% process
global configData;


if (~isfield(configData,'limitParams'))
    ConfigLimitParams;
    if (~isfield(configData,'limitParams'))
        return;
    end
end

if (~isfield(configData,'CRSParams'))
    ConfigCRSParams;
    if (~isfield(configData,'CRSParams'))
        return;
    end
    
end

if (~isfield(configData,'saccParams'))
    ConfigSaccadeParams;
    if (~isfield(configData,'saccParams'))
        return;
    end
    
end

if (~isfield(configData,'fixParams'))
    ConfigFixParams;
    if (~isfield(configData,'fixParams'))
        return;
    end
    
end

if (~isfield(configData,'blinkParams'))
    ConfigBlinkParams;
    if (~isfield(configData,'blinkParams'))
        return;
    end
end

EyeData=[];
if (isfield(configData,'designData'))
    configData=rmfield(configData,'designData');
end
if (isfield(configData,'conditions'))
    configData=rmfield(configData,'conditions');
end

condNums={};
for (i=1:configData.limitParams.maxConditions);
    condNums(i)=cellstr(sprintf('%d',i));
end


[numConditions,OK]=listdlg('liststring',condNums,'promptstring','Please set number of conditions.','SelectionMode','single','listsize',[200 150]);
if (OK==0)
    return;
else
    configData.numConditions=numConditions;
end

[cancel,conditions]=SetConditionNames(0);
if (cancel==true)
    return;
else
    configData.conditions=conditions;
    configData.numConditions=size(conditions,2);
end

runNums={};
for (i=1:configData.limitParams.maxRuns);
    runNums(i)=cellstr(sprintf('%d',i));
end

% get how many runs to analyse from the user for each session
[segmentCount,OK]=listdlg('liststring',runNums,'promptstring','Please set number of data files.','SelectionMode','single','listsize',[200 150]);
if (OK==0)
    return;
else
    configData.segmentCount=segmentCount;
end

[cancel,designData,segmentCount]=SetupAnalysis(configData.segmentCount);

if (cancel==true)
    return;
else
    EyeData.designData=designData; % update design file parameters
    configData.designData=designData; % maintain a copy in the globally access variable as well
end

% process raw data
EyeData=ProcessCRSData(EyeData);
if (cancel==true)
    return;
end

% assign conditions to data
EyeData=AssignConditions(EyeData);


if (~isfield(configData,'useGui'))
%    configData.useGui.findBlinks=false;
    configData.useGui.findFix=false;
    configData.useGui.findSaccs=false;
    configData.useGui.dispBlinkSummary=true;
    configData.useGui.dispFixSummary=true;
    configData.useGui.dispSaccSummary=true;
    %configData.useGui.excludeFix=false;
    configData.useGui.doDriftCorrection=true;
    configData.useGui.dispDriftSummary=false;
end

configData.useGui.skipInter=false; %cheat cheat cheat.

[h,cancel]=useGui;
if (ishandle(h))
    close(h);
    waitfor(h);
end
if (cancel==true)
    return;
end

wb=[];


%{
if (configData.useGui.findBlinks==false)
    wb=waitbar(1,'Identifying blinks...');
end
% find blinks
for (i=1:size(EyeData.segment,2))
    [EyeData,cancel]=FindBlinks(EyeData,configData.blinkParams,i);
    if (cancel)
        return;
    end
end
if (ishandle(wb))
    close(wb)
    waitfor(wb);
end
%}
% calculate velocity data from position data
wb=waitbar(1,'Processing data...');
EyeData=CalcVelocityData(EyeData);
if (ishandle(wb))
    close(wb)
    waitfor(wb);
end

if (configData.useGui.findSaccs==false)
    wb=waitbar(1,'Identifying saccades and blinks...');
end

%find saccades
for (i=1:size(EyeData.segment,2))
    
    EyeData=TruncateOnStimLength(EyeData,i);
%    if (configData.useGui.excludeFix==1)
%        [EyeData,cancel]=FindSaccadesExclFix(EyeData,configData.saccParams,configData.blinkParams,i);
%    else
        [EyeData,cancel]=FindSaccades(EyeData,configData.saccParams,configData.blinkParams,i);
%    end
    
    if (cancel)
        if (ishandle(wb))
            close(wb)
            waitfor(wb);
        end
        return;
    end
end

if (ishandle(wb))
    close(wb)
    waitfor(wb);
end

if (configData.useGui.findFix==false)
    wb=waitbar(1,'Identifying fixations...');
end

% find fixations
if (isfield(EyeData,'hasFixations')==false)
    for (i=1:size(EyeData.segment,2))
        EyeData=FindFixations(EyeData,configData.fixParams,configData.blinkParams,i);
    end
end
if (ishandle(wb))
    close(wb)
    waitfor(wb);
end

[cancel,EyeData]=selectResults(size(EyeData.segment,2),EyeData);

if (cancel==true)
    return;
end

% do drift correction
if (configData.useGui.doDriftCorrection==1)
    EyeData=DoDriftCorrection(EyeData);
end

EyeData=ProcessSaccades(EyeData);
EyeData=ProcessFixations(EyeData);
EyeData=ProcessEyePosition(EyeData);

f=figure;
set(f,'units','pixels');
set(f,'position',[50 25 1000 925]);
col=get(f,'color');

PlotFixations(EyeData,f);
PlotSaccades(EyeData,f);
PlotMeanEyePositions(EyeData,f);

%msg=sprintf('Results for %s (%s)',configData.ASLFileName,txt);
%uicontrol('Style','Text','string',msg,'units','pixels','position',[50,875,1000,50],'horizontalalignment','center','fontsize',14,'backgroundcolor',col);

uiwait(f);
if (ishandle(f))
    close(f);
    waitfor(f);
end

saveData=questdlg('Save data to a file?','Save Data','Yes','No','Cancel','Cancel');
if (strcmp(saveData,'Yes')==true)
    valid=false;
    while (valid==false)
        [filename pathname]=uiputfile({'*.mat','CRS Eye tracking data file'},'Save CRS eye tracking analysis','');
        if (filename==0)
            continue;
        else
            save ([pathname filename],'EyeData');
            valid=true;
        end
    end
end

% --------------------------------------------------------------------
function mnuFile_Callback(hObject, eventdata, handles)
% hObject    handle to mnuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuConfig_Callback(hObject, eventdata, handles)
% hObject    handle to mnuConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuRun_Callback(hObject, eventdata, handles)
% hObject    handle to mnuRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------

% --------------------------------------------------------------------
function mnuNameConditions_Callback(hObject, eventdata, handles)
% hObject    handle to mnuNameConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global configData;

if (~isfield(configData,'numConditions'))
    condNums={};
    for (i=1:configData.limitParams.maxConditions);
        condNums(i)=cellstr(sprintf('%d',i));
    end

    [numConditions,OK]=listdlg('liststring',condNums,'promptstring','Please set number of conditions.','SelectionMode','single','listsize',[200 150]);
    if (OK==0)
        return;
    else
        configData.numConditions=numConditions;
    end
end

[cancel,conditions]=SetConditionNames;
if (cancel==true)
    return;
else
    configData.conditions=conditions;
    configData.numConditions=size(conditions,2);
end

% --------------------------------------------------------------------
function mnuPlotRunPos_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlotRunPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global configData;

[tempEyeData,cancel]=GetDataToPlot();

if (cancel==true)
    return;
end

for (i=1:size(tempEyeData.segment,2))

    f=figure;

    set(f,'units','pixels');
    set(f,'position',[20 50 1200 425]);

    plot(tempEyeData.segment(i).sampleTime,tempEyeData.segment(i).angleX,'-');

    title(sprintf('X positional data for run %d', tempEyeData.segment(i).realSegmentIndex));
    xlabel('Time/s');
    ylabel('Angular position/degrees');

    uiwait(f);
    if(ishandle(f))
    close(f);
    waitfor(f);
end

end


% --------------------------------------------------------------------
function mnuPlotSeqWindow_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlotSeqWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global configData;

[tempEyeData,cancel]=GetDataToPlot;

if (cancel==true)
    return;
end

tempEyeData=CalcVelocityData(tempEyeData);

if (cancel==true)
    return;
end

%{
%removeBlinks=questdlg('Remove blinks automatically first?','Remove blinks','Yes','No','Cancel','Cancel');
%if (strcmp(removeBlinks,'Cancel')==true)
%    return;
%end

%if (strcmp(removeBlinks,'Yes')==true)
%    cancel=false;
    
    if (isfield(configData,'blinkParams'))
        [cancel,tempBlinkParams]=GetBlinkParams(configData.blinkParams);
    else
        [cancel,tempBlinkParams]=GetBlinkParams();
    end

    if (cancel==true)
        return;
    end

   tempEyeData=FindBlinks(tempEyeData, tempBlinkParams,1, false)
end
%}

% plot specific sequence 

valid=false;
cancel=false;

parameters = {...
    'Time Window','Time window in seconds','';...
    'Start Time','Start time in seconds since start',''};

result=inputdlg(parameters(:,2),'Parameters',1,parameters(:,3));

if (isempty(result))
    return;
end

timeWindow=str2num(cell2mat(result(1)));
startTime=str2num(cell2mat(result(2)));

startIndex=min(find([tempEyeData.segment(1).sampleTime]-startTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 
maxIndex=tempEyeData.segment(1).numRecords;

f=figure;
clf(f);
set(f,'position',[100,100,900,800]);

while (startIndex<maxIndex)

    if (~ishandle(f))
        return;
    end
    
    startTime=tempEyeData.segment(1).sampleTime(startIndex);
    endTime=startTime+timeWindow;
    endIndex=min(find([tempEyeData.segment(1).sampleTime]-endTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 

    if (endIndex>maxIndex)
        endIndex=maxIndex;
    end
    velocityMaxScale=max(tempEyeData.segment(1).velX(startIndex:endIndex));
    velocityMinScale=min(tempEyeData.segment(1).velX(startIndex:endIndex));
    % plot from start to end sequence
    figure(f);
    
    % determine indices for start and end times
    plotVelocity(tempEyeData,1,startIndex,endIndex,velocityMaxScale,velocityMinScale,1,2);
    plotPosition(tempEyeData,1,startIndex,endIndex,2,2);
    
    subplot(2,1,1);
    legend('x velocity');%,'x velocity','y velocity');
    subplot(2,1,2);
    legend('x position');

    set(f,'KeyPressFcn',@handleKeyPress);
    uiwait(f)
    startIndex=endIndex+1;
    
    
end

if (ishandle(f))
    close(f);
    waitfor(f);
end
    

% --------------------------------------------------------------------
function mnuPlotRunVel_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlotRunVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[tempEyeData,cancel]=GetDataToPlot();

if (cancel==true)
    return;
end

tempEyeData=CalcVelocityData(tempEyeData);

for (i=1:size(tempEyeData.segment,2))

    f=figure;

    set(f,'units','pixels');
    set(f,'position',[20 450 1200 425]);

    plot(tempEyeData.segment(i).velTime,tempEyeData.segment(i).velX','-');

    title(sprintf('X velocity data for run %d', tempEyeData.segment(i).realSegmentIndex));
    xlabel('Time/s');
    ylabel('Velocity/degrees per seconds');

    uiwait(f);
    if (ishandle(f))
        close(f);
        waitfor(f);
    end
end

% --------------------------------------------------------------------
function mnuRunFullMulti_Callback(hObject, eventdata, handles)
% hObject    handle to mnuRunFullMulti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%global groupData;

% get multiple data sets to run

% hObject    handle to mnuRunFull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check if all parameters etc. have been loaded and we have a file to
% process

global configData;

global groupData;

if (~isfield(configData,'limitParams'))
    ConfigLimitParams;
    if (~isfield(configData,'limitParams'))
        return;
    end
end

if (~isfield(configData,'CRSParams'))
    ConfigCRSParams;
    if (~isfield(configData,'CRSParams'))
        return;
    end
    
end

if (~isfield(configData,'saccParams'))
    ConfigSaccadeParams;
    if (~isfield(configData,'saccParams'))
        return;
    end
    
end

if (~isfield(configData,'fixParams'))
    ConfigFixParams;
    if (~isfield(configData,'fixParams'))
        return;
    end
    
end

if (~isfield(configData,'blinkParams'))
    ConfigBlinkParams;
    if (~isfield(configData,'blinkParams'))
        return;
    end
end


if (~isfield(configData,'limitParams'))
    ConfigLimitParams;
    if (~isfield(configData,'limitParams'))
        return;
    end
end

EyeData=[];
if (isfield(configData,'designData'))
    configData=rmfield(configData,'designData');
end
if (isfield(configData,'conditions'))
    configData=rmfield(configData,'conditions');
end

condNums={};
for (i=1:configData.limitParams.maxConditions);
    condNums(i)=cellstr(sprintf('%d',i));
end

if (~isfield(configData,'numConditions'))
    [numConditions,OK]=listdlg('liststring',condNums,'promptstring','Please set number of conditions.','SelectionMode','single','listsize',[200 150]);
    if (OK==0)
        return;
    else
        configData.numConditions=numConditions;
    end
end

if (~isfield(configData,'conditions'))
    [cancel,conditions]=SetConditionNames(0);
    if (cancel==true)
        return;
    else
        configData.conditions=conditions;
        configData.numConditions=size(conditions,2);
    end

end
% get number of session to analyse from the user

sessionNums={};
for (i=1:configData.limitParams.maxSessions);
    sessionNums(i)=cellstr(sprintf('%d',i));
end

[sessionCount,OK]=listdlg('liststring',sessionNums,'promptstring','Please set number of sessions to analyse.','SelectionMode','single','listsize',[250 150]);
if (OK==0)
    return;
end

groupData=[];
for (i=1:sessionCount)
% get how many runs to analyse from the user for each session
    runNums={};
    for (j=1:configData.limitParams.maxRuns);
        runNums(j)=cellstr(sprintf('%d',j));
    end

    [segmentCount,OK]=listdlg('liststring',runNums,'promptstring',sprintf('Please set number of data files for session %d',i),'SelectionMode','single','listsize',[250 150]);
    if (OK==0)
        return;
    else
        groupData.session(i).segmentCount=segmentCount;
    end
    
    [cancel,designData]=SetupAnalysis(groupData.session(i).segmentCount);
    if (cancel==true)
        return;
    end
    
    groupData.session(i).EyeData.designData=designData; % update design file parameters
end


for (i=1:size(groupData.session,2))
    % process raw data
    groupData.session(i).EyeData=ProcessCRSData(groupData.session(i).EyeData,i);
    if (cancel==true)
        return;
    end
end

for (i=1:size(groupData.session,2))
    % assign conditions to data
    groupData.session(i).EyeData=AssignConditions(groupData.session(i).EyeData);
end



configData.useGui.findBlinks=false;
configData.useGui.findFix=false;
configData.useGui.findSaccs=false;
configData.useGui.dispBlinkSummary=false;
configData.useGui.dispFixSummary=false;
configData.useGui.dispSaccSummary=false;
configData.useGui.excludeFix=true;
configData.useGui.doDriftCorrection=true;
configData.useGui.dispDriftSummary=false;

configData.useGui.skipInter=false; %cheat cheat cheat

wb=[];
for (j=1:size(groupData.session,2))
    txt=sprintf('Processing session %d',j);
    wb=waitbar(1,txt);

%     % find blinks
%     for (i=1:size(groupData.session(j).EyeData.segment,2))
%         [groupData.session(j).EyeData,cancel]=FindBlinks(groupData.session(j).EyeData,...
%             configData.blinkParams,i);
%         if (cancel)
%             return;
%         end
%     end

    % do drift correction


        
    % calculate velocity data from position data
    for (i=1:size(groupData.session(j).EyeData.segment,2))
        groupData.session(j).EyeData=CalcVelocityData(groupData.session(j).EyeData);
    end

    %find saccades
    for (i=1:size(groupData.session(j).EyeData.segment,2))
        groupData.session(j).EyeData=TruncateOnStimLength(groupData.session(j).EyeData,i);
        [groupData.session(j).EyeData,cancel]=FindSaccades(groupData.session(j).EyeData,...
            configData.saccParams,configData.blinkParams,i);
        if (cancel)
            return;
        end
    end

    % find fixations
    for (i=1:size(groupData.session(j).EyeData.segment,2))
        groupData.session(j).EyeData=FindFixations(groupData.session(j).EyeData,...
            configData.fixParams,configData.blinkParams,i);
    end

    if (ishandle(wb))
        close(wb);
        waitfor(wb);
    end

end



for (j=1:size(groupData.session,2))
    [cancel,groupData.session(j).EyeData]=selectResults...
        (size(groupData.session(j).EyeData.segment,2),groupData.session(j).EyeData);
end

if (cancel==true)
    return;
end

for (j=1:size(groupData.session,2))

    if (configData.useGui.doDriftCorrection==1)
        groupData.session(j).EyeData=DoDriftCorrection(groupData.session(j).EyeData);
    end
end

for (i=1:size(groupData.session,2))
    groupData.session(i).EyeData=ProcessSaccades(groupData.session(i).EyeData);
    groupData.session(i).EyeData=ProcessFixations(groupData.session(i).EyeData);
    groupData.session(i).EyeData=ProcessEyePosition(groupData.session(i).EyeData);
end
    
groupData=ProcessGroupData(groupData);

f=figure;
set(f,'units','pixels');
set(f,'position',[50 25 1000 925]);
col=get(f,'color');
PlotGroupData(groupData,f);

%msg=sprintf('Results for %s (%s)',configData.ASLFileName,txt);
%uicontrol('Style','Text','string',msg,'units','pixels','position',[50,875,1000,50],'horizontalalignment','center','fontsize',14,'backgroundcolor',col);

uiwait(f);
if (ishandle(f))
    close(f);
    waitfor(f);
end

saveData=questdlg('Save group data to a file?','Save Group Data','Yes','No','Cancel','Cancel');
if (strcmp(saveData,'Yes')==true)
    valid=false;
    while (valid==false)
        [filename pathname]=uiputfile({'*.mat','CRS Eye tracking data file( group data)'},'Save CRS eye tracking group analysis','');
        if (filename==0)
            continue;
        else
            save ([pathname filename],'groupData');
            valid=true;
        end
    end
end


function [tempEyeData,cancel]=GetDataToPlot()

% here we only plot one run at a time

global configData;
tempEyeData=[];
cancel=false;

[cancel,CRSFile,calibFile]=GetCRSDataFile(fileparts(mfilename()));
if (cancel==true)
    return;
end

if (~isfield(configData,'CRSParams'))
    txt=sprintf('CRS parameters are currently not set.\nDo you want to load them from a file?');
    ret=QuestDlg(txt,'Load CRS conversion parameters','Yes','No','No');
    if (strcmp(ret,'Yes'))
        valid=false;
        while (valid==false)
            % give user an opportunity to load parameters from a file
            [filename pathname]=uigetfile({'*.mat','CRS parameter file (*.mat)'},'Load CRS parameters','crsparams.mat');
            if (filename==0) % user cancelled just return
                return;
            else
                load ([pathname filename]);
                check=true;
                if (isempty(who('CRSParams')))
                    check=false;
                elseif (~isfield(CRSParams,'CRSParams'))
                    check=false;
                elseif (CRSParams.valid~=true)
                    check=false;
                end

                if (check==false)
                    txt=sprintf('File does not contain valid CRS parameters.\nPlease select the correct filename.');
                    uiwait(MsgBox(txt,'Invalid file','modal'));
                    continue;
                else
                    valid=true;
                end
            end
        end
        cancel=false;
        [cancel,CRSParams]=GetCRSParams(CRSParams);
    else % don't load parameters allow user to input completely new set
        cancel=false;
        [cancel,CRSParams]=GetCRSParams(); % no parameters provided
    end
else
    CRSParams=configData.CRSParams;
    [cancel,CRSParams]=GetCRSParams(CRSParams);
end

if (cancel==true)
    return;
end

% process raw data so we can plot it
CRSsegment=ProcessCRSFile(CRSFile,calibFile,CRSParams);
CRSsegment.realSegmentIndex=1;
if (cancel==true)
    return;
end

tempEyeData.segment(1)=CRSsegment;

% --------------------------------------------------------------------
function mnuPlotSeq_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlotSeq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global configData;

[tempEyeData,cancel]=GetDataToPlot;

if (cancel==true)
    return;
end

tempEyeData=CalcVelocityData(tempEyeData);

if (cancel==true)
    return;
end

% plot specific sequence 

valid=false;
cancel=false;

parameters = {...
    'Start Time','Time at which to start plot sequence in seconds','';...
    'End Time','Time at which to end plot sequence in seconds',''};

result=inputdlg(parameters(:,2),'Parameters',1,parameters(:,3));

if (isempty(result))
    return;
end

startTime=str2num(cell2mat(result(1)));
endTime=str2num(cell2mat(result(2)));

seqStartIndex=min(find([tempEyeData.segment(1).sampleTime]-startTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 
seqEndIndex=min(find([tempEyeData.segment(1).sampleTime]-endTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 

velocityMaxScale=max(tempEyeData.segment(1).velX(seqStartIndex:seqEndIndex));
velocityMinScale=min(tempEyeData.segment(1).velX(seqStartIndex:seqEndIndex));
% plot from start to end sequence
f=figure;
clf(f);
set(f,'position',[100,100,900,800]);

% determine indices for start and end times
plotVelocity(tempEyeData,1,seqStartIndex,seqEndIndex,velocityMaxScale,velocityMinScale,1,2);
plotPosition(tempEyeData,1,seqStartIndex,seqEndIndex,2,2);
    
subplot(2,1,1);
legend('x velocity');%,'x velocity','y velocity');
subplot(2,1,2);
legend('x position');

uiwait(f)
if (ishandle(f))
    close(f);
    waitfor(f);
end



% --------------------------------------------------------------------
function mnuPlot_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function handleKeyPress(src,event)

    if (event.Key=='space')
        uiresume;
    end


% --------------------------------------------------------------------
function mnuPlotPosNoBlinks_Callback(hObject, eventdata, handles)
% hObject    handle to mnuPlotPosNoBlinks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuCRSParams_Callback(hObject, eventdata, handles)
% hObject    handle to mnuCRSParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ConfigCRSParams;


% --------------------------------------------------------------------
function mnu__Callback(hObject, eventdata, handles)
% hObject    handle to mnuLimitParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


