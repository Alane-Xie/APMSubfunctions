function varargout = UseGui(varargin)
% FRMUSEGUI M-file for frmusegui.fig
%      FRMUSEGUI, by itself, creates a new FRMUSEGUI or raises the existing
%      singleton*.
%
%      H = FRMUSEGUI returns the handle to a new FRMUSEGUI or the handle to
%      the existing singleton*.
%
%      FRMUSEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRMUSEGUI.M with the given input arguments.
%
%      FRMUSEGUI('Property','Value',...) creates a new FRMUSEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frmusegui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frmusegui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frmusegui

% Last Modified by GUIDE v2.5 09-Jul-2008 12:46:57
global configData;
global cancel;
cancel=false;
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UseGui_OpeningFcn, ...
                   'gui_OutputFcn',  @UseGui_OutputFcn, ...
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

% --- Executes just before frmusegui is made visible.
function UseGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frmusegui (see VARARGIN)
global configData;
% Choose default command line output for frmusegui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if (isfield(configData,'useGui'))
%    set(handles.chkFindBlinks,'value',configData.useGui.findBlinks);
    %set(handles.chkFindFix,'value',configData.useGui.findFix);
    set(handles.chkFindSaccs,'value',configData.useGui.findSaccs);
    set(handles.chkBlinkSummary','value',configData.useGui.dispBlinkSummary);
    set(handles.chkFixSummary','value',configData.useGui.dispFixSummary);
    set(handles.chkSaccSummary','value',configData.useGui.dispSaccSummary);
    %set(handles.chkExcludeFix','value',configData.useGui.excludeFix);
    set(handles.chkDriftCorrection','value',configData.useGui.doDriftCorrection);
    set(handles.chkDriftSummary','value',configData.useGui.dispDriftSummary);
end

% UIWAIT makes frmusegui wait for user response (see UIRESUME)
 uiwait(handles.frmUseGui);

% --- Outputs from this function are returned to the command line.
function varargout = UseGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global cancel;
varargout{1} = handles.frmUseGui;
varargout{2}=cancel;

% --- Executes on button press in chkFindBlinks.
function chkFindBlinks_Callback(hObject, eventdata, handles)
% hObject    handle to chkFindBlinks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkFindBlinks


% --- Executes on button press in chkFindFix.
function chkFindFix_Callback(hObject, eventdata, handles)
% hObject    handle to chkFindFix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkFindFix


% --- Executes on button press in chkFindSaccs.
function chkFindSaccs_Callback(hObject, eventdata, handles)
% hObject    handle to chkFindSaccs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkFindSaccs


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global configData;
global cancel;
cancel=false;
%configData.useGui.findBlinks=get(handles.chkFindBlinks,'value');
%configData.useGui.findFix=get(handles.chkFindFix,'value');
configData.useGui.findSaccs=get(handles.chkFindSaccs,'value');
configData.useGui.dispBlinkSummary=get(handles.chkBlinkSummary,'value');
configData.useGui.dispFixSummary=get(handles.chkFixSummary,'value');
configData.useGui.dispSaccSummary=get(handles.chkSaccSummary,'value');
%configData.useGui.excludeFix=get(handles.chkExcludeFix,'value');
configData.useGui.doDriftCorrection=get(handles.chkDriftCorrection,'value');
configData.useGui.dispDriftSummary=get(handles.chkDriftSummary,'value');
uiresume (handles.frmUseGui);

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cancel;
cancel=true;
uiresume(handles.frmUseGui);


% --- Executes on button press in chkBlinkSummary.
function chkBlinkSummary_Callback(hObject, eventdata, handles)
% hObject    handle to chkBlinkSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBlinkSummary


% --- Executes on button press in chkFixSummary.
function chkFixSummary_Callback(hObject, eventdata, handles)
% hObject    handle to chkFixSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkFixSummary


% --- Executes on button press in chkSaccSummary.
function chkSaccSummary_Callback(hObject, eventdata, handles)
% hObject    handle to chkSaccSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkSaccSummary


% --- Executes on button press in chkExcludeFix.
function chkExcludeFix_Callback(hObject, eventdata, handles)
% hObject    handle to chkExcludeFix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkExcludeFix




% --- Executes on button press in chkDriftCorrection.
function chkDriftCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to chkDriftCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkDriftCorrection


% --- Executes on button press in chkDriftSummary.
function chkDriftSummary_Callback(hObject, eventdata, handles)
% hObject    handle to chkDriftSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkDriftSummary


