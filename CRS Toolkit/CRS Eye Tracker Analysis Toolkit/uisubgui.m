function himport=uisubgui(hsource,hdest,varargin)

%UISUBGUI - Creates a Sub-Gui from an existing gui.
%Created By Lior Cohen 18-Sep-2004 (lior_chn@yahoo.com)

%   HIMPORT=UISUBGUI(HSOURCE,HDEST)
%   Imports a GUI with a handle HSOURCE into a new figure/gui with the handle HDEST.
%   HIMPORT are the handles of the imported objects. 
%   The Subgui handles are moved to HDSET handles as a substructure named by the subgui tag. 
%
%   HIMPORT=UISUBGUI(HSOURCE,HDEST,POS)
%   POS is the new normalized posion of the gui in the HDEST. Can be in the regular
%   [X,Y,W,H] form or just [X,Y] (W,H stays as the source). 
%   
%   HIMPORT=UISUBGUI(HSOURCE,HDEST,SUBGUI_TAG)
%   SUBGUI_TAG is the tag of the subgui, if not requested an automatic 
%   tag is set (subgui_1..N). the handles of the imported gui will be saved as a 
%   substructure with this tag name, under handles.   
%   
%   HIMPORT=UISUBGUI(HSOURCE,HDEST,POS,SUBGUI_TAG)
%   Combination of the above two options.
%
%   IMPORTANT - This function is using a special guidata function,
%   thus will work only with the regular guidata guis.
%   The special guidta must be in the search path.

%Arguments handling
if nargin==2
    req_pos=0;
    subgui_tag=find_sub_gui(hdest);
elseif nargin==3 & isnumeric(varargin{1}) & (length(varargin{1})==2 | length(varargin{1})==4)
    req_pos=varargin{1};
    subgui_tag=find_sub_gui(hdest);
elseif nargin==3 & isstr(varargin{1})
    req_pos=0;
    subgui_tag=varargin{1};
elseif nargin==4 & isnumeric(varargin{1}) & (length(varargin{1})==2 | length(varargin{1})==4) & isstr(varargin{2})
    req_pos=varargin{1};
    subgui_tag=varargin{2};
else
    error('Wrong Input Arguments');
end
%
%Checking if the function use the special version guidata.
tmp=which('guidata');
if strcmp([matlabroot,'\toolbox\matlab\uitools\guidata.m'],tmp)
    error('The called guidata is the original Matlab guidata. The uisubgui may not function right. Please insert the supplied guidata to the search path.');
end
%
child=get(hsource,'children');
if isempty(child)
    error('HSOURCE does not have graphic objects to import');
end
%Importing the source gui to the destination gui
set(child,'parent',hdest);
%
%Adding the token '::subgui_tag::' for subgui identification
himport=findall(child);
tags=get(himport,'tag');
tags=strcat(['::',subgui_tag,'::'],tags);
set(himport,{'tag'},tags);
%
%Tranffering the handles of the imported gui into the new gui
source_handles=guidata(hsource);
source_handles=rmfield(source_handles,get(hsource,'tag'));
source_handles=rmfield(source_handles,'output');
guidata(child(1),source_handles);
%
%Setting the position
if any(req_pos)
  gui_position(hsource,hdest,child,req_pos);  
end

%----------------------------------------
function gui_position(hsource,hdest,child,req_pos)
%
%Normalized current position of the imported gui in the hdest (before the
%remapping)
units=get([hsource,hdest],'units');
set([hsource,hdest],'units','pixels');
pos=get([hsource,hdest],'position');
set([hsource,hdest],{'units'},units);
cur_pos=[0,0,pos{1}([3,4])./pos{2}([3,4])];
%
%Tanslating the required posiion to normalized units
dest_pos=get(hdest,'position');
if length(req_pos)==2
    req_pos=[req_pos,cur_pos([3,4])];
end   
%
types=get(child,'type');
can_be_remap= (~ismember(types,{'uimenu','uicontextmenu'}));
remapfig(cur_pos,req_pos,hdest,child(can_be_remap));
% 

%----------------------------------------
function subgui_N=find_sub_gui(hdest)

handles=guidata(hdest);
if isempty(handles) subgui_N='subgui_1'; return; end

field=fieldnames(handles);
[start,fisnish,token]=regexp(field,'subgui_(\d*)');
%
i=~(cellfun('isempty',token));
if ~i subgui_N='subgui_1'; return; end

field=field(i);
token=token(i);

for i=1:length(field)
    f=field{i};
    t=token{i};
    if iscell(t) ix=t{:};   else    ix=t;   end
    N(i,:)=str2num(f(ix(1):ix(2)));
end
subgui_N=['subgui_',num2str(max(N))];