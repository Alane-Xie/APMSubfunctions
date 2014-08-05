function varargout = GetDataFiles(varargin)
% GETDATAFILES M-file for GetDataFiles.fig
%      GETDATAFILES, by itself, creates a new GETDATAFILES or raises the existing
%      singleton*.
%
%      H = GETDATAFILES returns the handle to a new GETDATAFILES or the handle to
%      the existing singleton*.
%
%      GETDATAFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETDATAFILES.M with the given input arguments.
%
%      GETDATAFILES('Property','Value',...) creates a new GETDATAFILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetDataFiles_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetDataFiles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text3 to modify the response to help GetDataFiles

% Last Modified by GUIDE v2.5 08-Jul-2009 09:58:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetDataFiles_OpeningFcn, ...
                   'gui_OutputFcn',  @GetDataFiles_OutputFcn, ...
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


% --- Executes just before GetDataFiles is made visible.
function GetDataFiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GetDataFiles (see VARARGIN)

% Choose default command line output for GetDataFiles
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GetDataFiles wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GetDataFiles_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function txtDataFile_Callback(hObject, eventdata, handles)
% hObject    handle to txtDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDataFile as text3
%        str2double(get(hObject,'String')) returns contents of txtDataFile as a double


% --- Executes during object creation, after setting all properties.
function txtDataFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTrialLength_Callback(hObject, eventdata, handles)
% hObject    handle to txtTrialLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTrialLength as text3
%        str2double(get(hObject,'String')) returns contents of txtTrialLength as a double


% --- Executes during object creation, after setting all properties.
function txtTrialLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTrialLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNumTrials_Callback(hObject, eventdata, handles)
% hObject    handle to txtNumTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumTrials as text3
%        str2double(get(hObject,'String')) returns contents of txtNumTrials as a double


% --- Executes during object creation, after setting all properties.
function txtNumTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rdoEvent.
function rdoEvent_Callback(hObject, eventdata, handles)
% hObject    handle to rdoEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdoEvent
set(handles.txtNumTrials,'string','1');

% --- Executes on button press in rdoEvent.
function rdoBlock_Callback(hObject, eventdata, handles)
% hObject    handle to rdoEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdoEvent

    

% --- Executes on button press in chkUse.
function chkUse_Callback(hObject, eventdata, handles)
% hObject    handle to chkUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkUse




% --- Executes on button press in btnChooseDataFile.
function btnChooseDataFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnChooseDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global configData;
currDir=cd;

if (isfield(configData,'CRSFilePath'))
    cd(configData.CRSFilePath);
end    
[filename,path]=uigetfile({'*.daq','CRS Data files (*.daq)'},'Choose data file');

cd(currDir);

if (filename==0)
    return;
else
    set(handles.txtDataFile,'String',[path filename]);
end


% --- Executes on button press in btnTrialLengthAll.
function btnTrialLengthAll_Callback(hObject, eventdata, handles)
% hObject    handle to btnTrialLengthAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnNumTrialsAll.
function btnNumTrialsAll_Callback(hObject, eventdata, handles)
% hObject    handle to btnNumTrialsAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnFileAll.
function btnFileAll_Callback(hObject, eventdata, handles)
% hObject    handle to btnFileAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function txtDesignFile_Callback(hObject, eventdata, handles)
% hObject    handle to txtDesignFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDesignFile as text
%        str2double(get(hObject,'String')) returns contents of txtDesignFile as a double


% --- Executes during object creation, after setting all properties.
function txtDesignFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDesignFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnChooseDesignFile.
function btnChooseDesignFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnChooseDesignFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global configData;
currDir=cd;

if (isfield(configData,'CRSFilePath'))
    cd(configData.CRSFilePath);
end    
[filename,path]=uigetfile({'*.txt','Design files (*.txt)'},'Choose design file');

cd(currDir);

if (filename==0)
    return;
else
    set(handles.txtDesignFile,'String',[path filename]);
end


function txtCalibFile_Callback(hObject, eventdata, handles)
% hObject    handle to txtCalibFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCalibFile as text
%        str2double(get(hObject,'String')) returns contents of txtCalibFile as a double


% --- Executes during object creation, after setting all properties.
function txtCalibFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCalibFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnChooseCalibFile.
function btnChooseCalibFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnChooseCalibFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global configData;
currDir=cd;

if (isfield(configData,'CRSFilePath'))
    cd(configData.CRSFilePath);
end    
[filename,path]=uigetfile({'*.mat','CRS calibration files (*.mat)'},'Choose calibration file');

cd(currDir);

if (filename==0)
    return;
else
    set(handles.txtCalibFile,'String',[path filename]);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btnChooseDataFile.
function btnChooseDataFile_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btnChooseDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnAutoFile.
function btnAutoFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnAutoFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in chkUseDesign.
function chkUseDesign_Callback(hObject, eventdata, handles)
% hObject    handle to chkUseDesign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkUseDesign


% --- Executes on button press in btnDesignAll.
function btnDesignAll_Callback(hObject, eventdata, handles)
% hObject    handle to btnDesignAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtStimLength_Callback(hObject, eventdata, handles)
% hObject    handle to txtStimLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtStimLength as text
%        str2double(get(hObject,'String')) returns contents of txtStimLength as a double


% --- Executes during object creation, after setting all properties.
function txtStimLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtStimLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnStimLengthAll.
function btnStimLengthAll_Callback(hObject, eventdata, handles)
% hObject    handle to btnStimLengthAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
