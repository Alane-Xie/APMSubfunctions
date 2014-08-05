function varargout = GetCondition(varargin)
% GETCONDITION M-file for GetCondition.fig
%      GETCONDITION, by itself, creates a new GETCONDITION or raises the existing
%      singleton*.
%
%      H = GETCONDITION returns the handle to a new GETCONDITION or the handle to
%      the existing singleton*.
%
%      GETCONDITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETCONDITION.M with the given input arguments.
%
%      GETCONDITION('Property','Value',...) creates a new GETCONDITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetCondition_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetCondition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GetCondition

% Last Modified by GUIDE v2.5 08-Jul-2009 09:55:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetCondition_OpeningFcn, ...
                   'gui_OutputFcn',  @GetCondition_OutputFcn, ...
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


% --- Executes just before GetCondition is made visible.
function GetCondition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GetCondition (see VARARGIN)

% Choose default command line output for GetCondition
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GetCondition wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GetCondition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function txtCondition_Callback(hObject, eventdata, handles)
% hObject    handle to txtCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCondition as text
%        str2double(get(hObject,'String')) returns contents of txtCondition as a double


% --- Executes during object creation, after setting all properties.
function txtCondition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFixation.
function chkFixation_Callback(hObject, eventdata, handles)
% hObject    handle to chkFixation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkFixation



function txtRealCond_Callback(hObject, eventdata, handles)
% hObject    handle to txtRealCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRealCond as text
%        str2double(get(hObject,'String')) returns contents of txtRealCond as a double


% --- Executes during object creation, after setting all properties.
function txtRealCond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRealCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
