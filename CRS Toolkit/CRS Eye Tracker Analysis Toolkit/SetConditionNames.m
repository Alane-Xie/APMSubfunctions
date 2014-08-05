function [cancel,conditions]=SetConditionNames(startAt)

% construct gui to set condition names

    global configData;
    global gui;
    
    cancel=false;
    container=NameConditions;
    conditions=[];
    numConds=configData.numConditions;
    
    if (isfield(configData,'conditions'))
        conditions=configData.conditions;
        if (~exist('startAt'))
            startAt=min([configData.conditions.realCondition]);
        else
            start=0;
        end
    end

    if (~exist('startAt'))
        startAt=0;
    end
    
    setupConditions(configData.numConditions,container,startAt);
    
    if (ishandle(container))
        movegui(container,'center');
        set(container,'visible','on');
        uiwait(container);
    end
    
    function btnOK_Callback(hObject, eventdata, handles)
        storeConditions;
    end

    function btnCancel_Callback(hObject, eventdata, handles)
        cancelDialog;
        return;
    end

    function storeConditions(hObject,eventData,handles)
        allvalid=true;
        % validate conditions - make sure each one has a name etc.
        conditions=[];
        for (i=1:numConds)
            conditions(i).name=get(gui(i).subhandles.txtCondition,'string');
            conditions(i).isFixation=get(gui(i).subhandles.chkFixation,'value');
            conditions(i).realCondition=str2num(get(gui(i).subhandles.txtRealCond,'string'));
            if (isempty(conditions(i).name))
                allvalid=false;
                break;
            elseif (strcmp(conditions(i).name,''))
                allvalid=false;
                break;
            end
        end
        
        % check all conditions
        if (allvalid==false)
            uiwait(MsgBox('One or more conditions have no name, please correct and try again','Errors detected','modal'));
            return;
        end
        if (ishandle(container))
            close(container);
            waitfor(container);
        end
    
    end

    function cancelDialog()
        conditions=[];
        if (ishandle(container))
            close(container)
            waitfor(container)
        end
        cancel=true;
        return;
    end

    function updateList
            %get number of conditions

    for (i=1:numConds)
        conditions(i).name=get(gui(i).subhandles.txtCondition,'string');
        conditions(i).realCondition=num2str(get(gui(i).subhandles.txtRealCond,'string'));
        conditions(i).isFixation=get(gui(i).subhandles.chkFixation,'value');
    end

    container=NameConditions;
    
    handles=guidata(container);
    numConds=get(handles.lstCondCount,'Value');
    condIndex=get(handles.lstStartAt,'Value');
    values=get(handles.lstStartAt,'string');
    startAt=values{condIndex};
    startAt=str2num(startAt);
    
    if (ishandle(container))
        close(container);
        waitfor(container);
    end

    container=NameConditions;
    setupConditions(numConds,container,startAt);

    end

    function lstCondCount_CallBack(hObject,eventData,handles)

        updateList;

    end
    function lstStartAt_CallBack(hObject,eventData,handles)

        updateList;

    end

    function setupConditions(numConditions,container,startAt)

    
    set(container,'visible','off');
    guiTemplate=GetCondition;
    set(guiTemplate,'units','pixels');
    guiExtent=get(guiTemplate,'position');
    set(guiTemplate,'visible','off');
    % set container size to n multiples of the gui we want to repeat
    set(container,'units','pixels');
    cntExtent=get(container,'position');
 
    offset=105; % number of pixels offset from the top of the container
    spacing=0; % spacing either side of the gui
    guiHeight=guiExtent(4);


    % setup container size in pixels
    set(container,'position',[cntExtent(1) cntExtent(2) cntExtent(3) ((guiHeight+(spacing*2))*numConditions)+offset]);
    cntExtent=get(container,'position');
    cntPixHeight=cntExtent(4);
    cntPixWidth=cntExtent(3);
    cntHandles=guidata(container);
    % set up number of conditions and populate list
    condNums={};
    firstCond=startAt;
    for (i=1:configData.limitParams.maxConditions)
        condNums(i)=cellstr(sprintf('%d',i));
    end
    startAtNums={};
    for (i=0:configData.limitParams.maxConditions)
        startAtNums(i+1)=cellstr(sprintf('%d',i));
    end
    set(cntHandles.lstCondCount,'string',condNums);
    set(cntHandles.lstStartAt,'string',startAtNums);

    gui=[];

    % because the subgui stuff requires using normalised coordinates we need to
    % convert from pixels to normalised to determine position for each sub gui
    set(container,'units','normalized');

    % work out proportions corresponding to pixels so we can set the correct
    % positions for each gui
    pixelHeight=1.0/cntPixHeight; % relative height for a single pixel based on size of container
    pixelWidth=1.0/cntPixWidth;
    set (cntHandles.pnlHeadings,'units','normalized');
    pnlExtent=get(cntHandles.pnlHeadings,'position');
    pnlY=pnlExtent(4)+(10*pixelHeight);
    
    set(cntHandles.pnlHeadings,'position',[pnlExtent(1) 1-pnlY pnlExtent(3) pnlExtent(4)]);
    % determine index for startAt
    tmp=get(cntHandles.lstStartAt,'string');
    values=char(tmp);
    values=str2num(values);
    index=find(values==startAt);
    set(cntHandles.lstStartAt,'value',index);
    
    startIndex=startAt;
    
    for (i=1:numConditions)

        guiTemplate=GetCondition;
        set(guiTemplate,'visible','off');
        gui(i).tag=sprintf('item_%d',i);

        % determine vertical position for gui

        % height is offset + height of all previous items + spacing between
        % each item
        ypix=cntPixHeight-offset; % subtract offset
        ypix=ypix - (guiHeight*(i-1)); % subtract heights of all previous gui's
        ypix=ypix -(spacing * 2 * (i-1)); % subtract spacing between each gui
        ypix=ypix - spacing;
        y=ypix*pixelHeight;
        gui(i).extent=[0.0 y]; % x,y, position keep width and height same as in original gui
        gui(i).handle=uisubgui(guiTemplate,container,gui(i).extent,gui(i).tag);
        gui(i).subhandles=guidata(gui(i).handle(1));
        set(gui(i).subhandles.lblCondNo,'string',num2str(i));
        if (i>size(conditions,2))
            conditions(i).name=sprintf('C%d',i-1);
            conditions(i).isFixation=0;
        end
        conditions(i).realCondition=startIndex;
        startIndex=startIndex+1;
        set(gui(i).subhandles.txtCondition,'string',conditions(i).name);
        set(gui(i).subhandles.txtRealCond,'string',num2str(conditions(i).realCondition));
        if (conditions(i).isFixation)
            set(gui(i).subhandles.chkFixation,'value',true);
        end
        
        close(guiTemplate);
    end
    
        

    set(cntHandles.btnOK,'units','pixels');
    set(cntHandles.btnCancel,'units','pixels');
    btnOKPos=get(cntHandles.btnOK,'position');
    btnCancelPos=get(cntHandles.btnOK,'position');
    btnOKx= 30 + btnCancelPos(3) + btnOKPos(3);
    btnOKx=btnOKx*pixelWidth;
    btnOKx=1.0-btnOKx;
    btnOKy=10;
    btnOKy=pixelHeight *btnOKy;
    btnCancely=btnOKy;
    btnCancelx=20 + btnCancelPos(3);
    btnCancelx=btnCancelx*pixelWidth;
    btnCancelx=1.0-btnCancelx;
    set(cntHandles.btnOK,'units','normalized');
    set(cntHandles.btnCancel,'units','normalized');
    set(cntHandles.lstCondCount','callback',@lstCondCount_CallBack);
    set(cntHandles.lstStartAt','callback',@lstStartAt_CallBack);
    set(cntHandles.btnOK,'position',[btnOKx btnOKy btnOKPos(3)*pixelWidth btnOKPos(4)*pixelHeight]);
    set(cntHandles.btnCancel,'position',[btnCancelx btnCancely btnCancelPos(3)*pixelWidth btnCancelPos(4)*pixelHeight]);

    set(cntHandles.btnOK,'callback',@btnOK_Callback);
    set(cntHandles.btnCancel,'callback',@btnCancel_Callback);
    
    set(cntHandles.lstCondCount,'value',numConditions); % only works because index is same as value here
 
    movegui(container,'center');
    set(container,'visible','on');
    uiwait(container);

    end

end
