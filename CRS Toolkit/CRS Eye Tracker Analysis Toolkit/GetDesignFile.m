function varargout = GetDesignFile(varargin)
% GETDESIGNFILE M-file for GetDesignFile.fig
%      GETDESIGNFILE, by itself, creates a new GETDESIGNFILE or raises the existing
%      singleton*.
%
%      H = GETDESIGNFILE returns the handle to a new GETDESIGNFILE or the handle to
%      the existing singleton*.
%
%      GETDESIGNFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETDESIGNFILE.M with the given input arguments.
%
%      GETDESIGNFILE('Property','Value',...) creates a new GETDESIGNFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetDesignFile_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetDesignFile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text3 to modify the response to help GetDesignFile

% Last Modified by GUIDE v2.5 28-Jul-2008 12:06:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetDesignFile_OpeningFcn, ...
                   'gui_OutputFcn',  @GetDesignFile_OutputFcn, ...
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


% --- Executes just before GetDesignFile is made visible.
function GetDesignFile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GetDesignFile (see VARARGIN)

% Choose default command line output for GetDesignFile
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GetDesignFile wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GetDesignFile_OutputFcn(hObject, eventdata, handles) 
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





function txtFileName_Callback(hObject, eventdata, handles)
% hObject    handle to txtFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFileName as text3
%        str2double(get(hObject,'String')) returns contents of txtFileName as a double


% --- Executes during object creation, after setting all properties.
function txtFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFileName (see GCBO)
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




% --- Executes on button press in btnChooseFile.
function btnChooseFile_Callback(hObject, eventdata, handles)
% hObject    handle to btnChooseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global configData;
currDir=cd;

if (isfield(configData,'ASLFilePath'))
    cd(configData.ASLFilePath);
end    
[filename,path]=uigetfile({'*.txt','text files (*.txt)';'*.mat','mat files (*.mat)'},'Choose design file');

cd(currDir);

if (filename==0)
    return;
else
    set(handles.txtFileName,'String',[path filename]);
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




% --- Executes on button press in chkUseFile.
function chkUseFile_Callback(hObject, eventdata, handles)
% hObject    handle to chkUseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkUseFile


