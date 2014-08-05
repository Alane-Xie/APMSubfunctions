function [cancel,designData]=SetupAnalysis(runCount,EyeData)
% construct gui to choose which runs to include in analysis and to specify
% parameters for each run

    global configData;

    cancel=false;
    designData=[];
    container=Container;
    set(container,'visible','off');
    guiTemplate=GetDesignFile;
    set(guiTemplate,'units','pixels');
    guiExtent=get(guiTemplate,'position');
    set(guiTemplate,'visible','off');
    % set container size to n multiples of the gui we want to repeat
    set(container,'units','pixels');
    cntExtent=get(container,'position');
    width=guiExtent(3);
    offset=85; % number of pixels offset from the top of the container
    spacing=0; % spacing either side of the gui
    guiHeight=guiExtent(4);
    
    % setup container size in pixels
    set(container,'position',[cntExtent(1) cntExtent(2) width ((guiHeight+(spacing*2))*runCount)+offset]);
    cntExtent=get(container,'position');
    cntPixHeight=cntExtent(4);
    cntPixWidth=cntExtent(3);
    cntHandles=guidata(container);

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


    for (i=1:runCount)
        guiTemplate=GetDesignFile;
        %set(guiTemplate,'visible','off');
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
        set(gui(i).subhandles.txtNumber,'String',num2str(i));
        set(gui(i).subhandles.btnNumTrialsAll,'callback',@setAllNumTrials);
        set(gui(i).subhandles.btnTrialLengthAll,'callback',@setAllTrialLength);
        set(gui(i).subhandles.btnFileAll,'callback',@setAllDesignFile);
        close(guiTemplate);
    end

    % populate data if it exists
    if (isfield(configData,'designData') && ~isempty(configData.designData)) % populate form with pre-existing details
        for(i=1:size(configData.designData,2))
            index=configData.designData(i).realSegmentIndex;
            set(gui(index).subhandles.txtFileName,'string',configData.designData(i).designFile);
            if (configData.designData(i).designType=='B')
                set(gui(index).subhandles.rdoBlock,'Value',1);
            else
                set(gui(index).subhandles.rdoEvent,'Value',1);
            end
            set(gui(index).subhandles.txtNumTrials,'string',num2str(configData.designData(i).numTrials));
            set(gui(index).subhandles.txtTrialLength,'string',num2str(configData.designData(i).trialLength));
            set(gui(index).subhandles.chkUse,'Value',1);
        end
    end
     


    % set callback on the OK button to validate results and store
    set(cntHandles.btnOK,'callback',@btnOK_Callback);
    set(cntHandles.btnCancel,'callback',@btnCancel_Callback);
    set(cntHandles.btnAll,'callback',@selectAll);
    set(cntHandles.btnNone,'callback',@selectNone);
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
    
    set(cntHandles.btnOK,'position',[btnOKx btnOKy btnOKPos(3)*pixelWidth btnOKPos(4)*pixelHeight]);
    set(cntHandles.btnCancel,'position',[btnCancelx btnCancely btnCancelPos(3)*pixelWidth btnCancelPos(4)*pixelHeight]);
%    set(container.handles.btnOK,'position',[1.0 - ((btnOKPos(3) + (spacing*2) + btnCancelPos(3))*pixelWidth) (btnOKPos(4)+spacing*2)*pixelHeight btnOKPos(3) btnOKPos(4)]);
%    set(container.handles.btnCancel,'position',[1.0 - ((btnCancelPos(3) + spacing )*pixelWidth) (btnCancelPos(4)+spacing*2)*pixelHeight btnCancelPos(3) btnCancelPos(4)]);
    % nested functions

    movegui(container,'center');
    set(container,'visible','on');
    
    function btnOK_Callback(hObject, eventdata, handles)
        storeConfig();
    end

    function btnCancel_Callback(hObject, eventdata, handles)
        cancelDialog;
        return;
    end

    function storeConfig(hObject,eventData,handles)
        allvalid=true;
        designData=[];
        index=0;
        for (i=1:runCount)
            use=get(gui(i).subhandles.chkUse,'value');
            if (use)
                if (validate(gui(i).subhandles)==false)
                    allvalid=false;
                else
                   index=index+1;
                   designData(index).realSegmentIndex=i;
                   designData(index).designFile=get(gui(i).subhandles.txtFileName,'string');
                    if (get(gui(i).subhandles.rdoBlock,'value')==1)
                        designData(index).designType='B';
                    else
                        designData(index).designType='E';
                    end
                    designData(index).numTrials=str2num(get(gui(i).subhandles.txtNumTrials,'string'));
                    designData(index).trialLength=str2num(get(gui(i).subhandles.txtTrialLength,'string'));
                end
            end
        end
        if (index==0)
            uiwait(MsgBox('No runs have been selected, please select one or more runs to analyse','No runs selected','modal'));
            return;
        end
        
        if allvalid==false
            uiwait(MsgBox('One or more errors have been detected, please correct errors and try again','Errors detected','modal'));
            return;
        else
            %everything is OK so we can close this gui and return
            uiresume(container);
            return;
        end
    
    end

    function cancelDialog()
        designData=[];
        uiresume(container);
        cancel=true;
        return;
    end

    
    function setAllDesignFile(hObject,eventData,handles)
        
        % get the value from this text box
        handles=guidata(hObject);
        thisFile=get(handles.txtFileName,'string');
        
        for (i=1:runCount)
            set(gui(i).subhandles.txtFileName,'string',thisFile);
        end
    end
    function setAllNumTrials(hObject,eventData,handles)
        
        % get the value from this text box
        handles=guidata(hObject);
        thisNum=get(handles.txtNumTrials,'string');
        
        for (i=1:runCount)
            set(gui(i).subhandles.txtNumTrials,'string',thisNum);
        end
    end

    function setAllTrialLength(hObject,eventData,handles)
        % get the value from this text box
        handles=guidata(hObject);
        thisLength=get(handles.txtTrialLength,'string');
        
        for (i=1:runCount)
            set(gui(i).subhandles.txtTrialLength,'string',thisLength);
        end
        
    end

    function selectAll(hObject,eventData,handles)
        
        for (i=1:runCount)
            set(gui(i).subhandles.chkUse,'Value',1);
        end
        
    end

    function selectNone(hObject,eventData,handles)

            for (i=1:runCount)
            set(gui(i).subhandles.chkUse,'Value',0);
        end

    end
        
    uiwait(container);
    if (ishandle(container))
        close(container);
    end
    
    waitfor(container);
    drawnow;
    return;
end

function valid=validate(parentGUI)

% check sensible values have been entered into the dialog
    valid=true;
    filename=get(parentGUI.txtFileName,'string');
    file=dir(filename);
    set(parentGUI.txtError,'string','');
    if (size(file,1)==0) % file does not exist
        set(parentGUI.txtError,'string','Filename does not exist or is invalid');
        valid=false;
        return;
    end
    
    numTrials=str2num(get(parentGUI.txtNumTrials,'string'));
    if (isempty(numTrials) || numTrials<=0)
        set(parentGUI.txtError,'string','Invalid number of trials specified (for event-related specify 1 trial per block)');
        valid=false;
        return;
    end
    
    trialLength=str2num(get(parentGUI.txtTrialLength,'string'));
    if (isempty(trialLength) || trialLength<=0)
        set(parentGUI.txtError,'string','Invalid trial length specified');
        valid=false;
        return;
    end
end