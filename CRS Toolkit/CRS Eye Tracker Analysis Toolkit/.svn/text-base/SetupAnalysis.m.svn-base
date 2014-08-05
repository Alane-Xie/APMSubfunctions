function [cancel,designData,runCount]=SetupAnalysis(runCount,inDesignData)
% construct gui to choose which runs to include in analysis and to specify
% parameters for each run

global configData;
global gui;
designData=[];

    cancel=true;
    designData=[];
    container=Container;

    setupDisplay(runCount,container);
    if (ishandle(container))
        close(container);
        waitfor(container);
    end
    
    return;
    
    function setupDisplay(runCount,container)
    
    set(container,'visible','off');
    guiTemplate=GetDataFiles;
    set(guiTemplate,'units','pixels');
    guiExtent=get(guiTemplate,'position');
    set(guiTemplate,'visible','off');
    % set container size to n multiples of the gui we want to repeat
    set(container,'units','pixels');
    cntExtent=get(container,'position');
 
    offset=140; % number of pixels offset from the top of the container
    spacing=0; % spacing either side of the gui
    guiHeight=guiExtent(4);

    
    % setup container size in pixels
    set(container,'position',[cntExtent(1) cntExtent(2) cntExtent(3) ((guiHeight+(spacing*2))*runCount)+offset]);
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
    set(cntHandles.lstNumRuns,'value',runCount);


    for (i=1:runCount)
        %set(guiTemplate,'visible','off');
        guiTemplate=GetDataFiles;

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
        set(gui(i).subhandles.txtNumber,'string',num2str(i));
        set(gui(i).subhandles.btnTrialLengthAll,'callback',@setAllTrialLength);
        set(gui(i).subhandles.btnNumTrialsAll,'callback',@setAllNumTrials);
        set(gui(i).subhandles.btnAutoFile,'callback',@setFilesAuto);
        set(gui(i).subhandles.btnDesignAll,'callback',@setAllFromDesign);
        set(gui(i).subhandles.btnStimLengthAll,'callback',@setAllStimLength);

        
        close(guiTemplate);
    end
        

    if (exist('inDesignData')==1)
        for(i=1:size(inDesignData,2))
            index=inDesignData(i).realSegmentIndex;
            if (index>runCount)
                break;
            end
            
            set(gui(index).subhandles.txtDataFile,'string',inDesignData(i).dataFile);
            set(gui(index).subhandles.txtDesignFile,'string',inDesignData(i).designFile);
            set(gui(index).subhandles.txtCalibFile,'string',inDesignData(i).calibFile);

            if (inDesignData(i).designType=='B')
                set(gui(index).subhandles.rdoBlock,'Value',1);
            else
                set(gui(index).subhandles.rdoEvent,'Value',1);
            end
            
            if (inDesignData(i).trialParamsFromDesign==false)
                set(gui(index).subhandles.txtTrialLength,'string',num2str(inDesignData(i).trialLength));
                set(gui(index).subhandles.txtNumTrials,'string',num2str(inDesignData(i).numTrials));
                set(gui(index).subhandles.chkUseDesign,'value',0);
            else
                set(gui(index).subhandles.chkUseDesign,'value',1);
            end
            if (~isnan(inDesignData(i).stimLength))
                set(gui(index).subhandles.txtStimLength,'string',num2str(inDesignData(i).stimLength));
            end


        end
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
    set(cntHandles.btnOK,'position',[btnOKx btnOKy btnOKPos(3)*pixelWidth btnOKPos(4)*pixelHeight]);
    set(cntHandles.btnCancel,'position',[btnCancelx btnCancely btnCancelPos(3)*pixelWidth btnCancelPos(4)*pixelHeight]);
    set(cntHandles.btnOK,'callback',@btnOK_Callback);
    set(cntHandles.btnCancel,'callback',@btnCancel_Callback);  
    set(cntHandles.lstNumRuns','callback',@lstNumRuns_CallBack);
    
    
    movegui(container,'center');
    set(container,'visible','on');
    uiwait(container);

    end

    function lstNumRuns_CallBack(hObject,eventData,handles)
    
    %get number of runs
   
    values=get(hObject,'string');
    index=get(hObject,'value');
    runCount=values{index};
    runCount=str2num(runCount);

    if (ishandle(container))
        close(container);
        waitfor(container);
    end

    container=Container;
    setupDisplay(runCount,container);

    end

    
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
            if (validate(gui(i).subhandles)==false)
                allvalid=false;
            else

            index=index+1;
            designData(index).realSegmentIndex=i;
            designData(index).designFile=get(gui(i).subhandles.txtDesignFile,'string');
            designData(index).dataFile=get(gui(i).subhandles.txtDataFile,'string');
            designData(index).calibFile=get(gui(i).subhandles.txtCalibFile,'string');

            if (get(gui(i).subhandles.rdoBlock,'value')==1)
                designData(index).designType='B';
            else
                designData(index).designType='E';
            end
            if (get(gui(i).subhandles.chkUseDesign,'value')==0)
                designData(index).trialLength=str2num(get(gui(i).subhandles.txtTrialLength,'string'));
                designData(index).numTrials=str2num(get(gui(i).subhandles.txtNumTrials,'string'));
                designData(index).trialParamsFromDesign=false;
            else
                designData(index).trialParamsFromDesign=true;
            end

            stimLength=get(gui(i).subhandles.txtStimLength,'string');
            if (~isempty(stimLength))
                designData(index).stimLength=str2num(stimLength);
            else
                if (designData(index).trialParamsFromDesign==false)
                    designData(index).stimLength=designData(index).trialLength;
                else
                    designData(index).stimLength=NaN; % need to set this when we assign conditions based on the design file
                end
            end

        end
            
    end

    if allvalid==false
            uiwait(MsgBox('One or more errors have been detected, please correct errors and try again','Errors detected','modal'));
            return;
        else
            %everything is OK so we can close this gui and return
            uiresume(container);
            cancel=false;
            return;
        end
    
    end

    function cancelDialog()
        designData=[];
        uiresume(container);
        cancel=true;
        return;
    end

    function setFilesAuto(hObject,eventData,handles)
        handles=guiData(hObject);
        
        thisDataFile=get(handles.txtDataFile,'string');
        
        thisIndex=get(handles.txtNumber,'string');
        thisIndex=str2num(thisIndex);
        
        [path,name,ext]=fileparts(thisDataFile);
        if (strcmp(path,'')) % not valid path so assume nothing entered so we do nothing
            return;
        end
        
        % set calibration and design files for this run 
        set(handles.txtCalibFile,'string',[path '\' name '.mat']);
        set(handles.txtDesignFile,'string',[path '\' name '.txt']);
        autoIncr=false;
        % determine if there are numbers in the name - only look for one
        % sequence of numbers any more and its too difficult
        [start finish]=regexp(name,'\d*');
        if (~isempty(start)) && (~isempty(finish))
            start=start(length(start));
            finish=finish(length(finish));
            number=name(start:finish);
            if (isnumeric(str2num(number)) && isinteger(int8(number)))
                number=str2num(number);
                prefix=name(1:start-1);
                suffix=name(finish+1:size(name,2));

                % try to autocomplete the rest of the filenames
                if ((runCount-thisIndex)>1)
                    txt=sprintf('The number ''%d'' was detected in the filename - do you want to autoincrement this number?',number);
                    ret=QuestDlg(txt,'Autoincrement','Yes','No','No');
                    if (strcmp(ret,'Yes'))
                        autoIncr=true;
                    else
                        autoIncr=false;
                    end
                end
            end
        end
        
        for (i=thisIndex+1:runCount)
            if (autoIncr==true)
                num=num2str(number+i-1);
                name=[prefix num suffix];
            end
            set(gui(i).subhandles.txtDataFile,'string',[path '\' name ext]);
            set(gui(i).subhandles.txtCalibFile,'string',[path '\' name '.mat']);
            set(gui(i).subhandles.txtDesignFile,'string',[path '\' name '.txt']);
        end
    end

            
    function setAllDesignFile(hObject,eventData,handles)
        
        % get the value from this text box
        handles=guidata(hObject);
        thisFile=get(handles.txtFileName,'string');
        handles=guiData(hObject);

        thisIndex=get(handles.txtNumber,'string');
        thisIndex=str2num(thisIndex);
         
        [path,name,ext]=fileparts(thisFile);
        if (strcmp(path,'')) % not valid path so assume nothing entered so we do nothing
            return;
        end
        
        autoIncr=false;
        % determine if there are numbers in the name - only look for one
        % sequence of numbers any more and its too difficult
        [start finish]=regexp(name,'\d*');
        if (~isempty(start)) && (~isempty(finish))
            if (size(start,2)==1) % only one number sequence
                number=name(start:finish);
                if (isnumeric(str2num(number)) && isinteger(int8(number)))
                    number=str2num(number);
                    prefix=name(1:start-1);
                    suffix=name(finish+1:size(name,2));
                    
                    % try to autocomplete the rest of the filenames
                    txt=sprintf('The number ''%d'' was detected in the filename - do you want to autoincrement this number?',number);
                    ret=QuestDlg(txt,'Autoincrement','Yes','No','No');
                    
                    if (strcmp(ret,'Yes'))
                        autoIncr=true;
                    else
                        autoIncr=false;
                    end
                end
            end
        end
        
        for (i=thisIndex+1:runCount)
            if (autoIncr==true)
                num=num2str(number+i-1);
                name=[prefix num suffix];
            end
            set(gui(i).subhandles.txtFileName,'string',[path '\' name ext]);
        end
    end

    function setAllFromDesign(hObject,eventData,handles)
        handles=guidata(hObject);
        thisVal=get(handles.chkUseDesign,'value');
        
        for (i=1:runCount)
            set(gui(i).subhandles.chkUseDesign,'value',thisVal);
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
    function setAllStimLength(hObject,eventData,handles)
        
        % get the value from this text box
        handles=guidata(hObject);
        thisNum=get(handles.txtStimLength,'string');
        
        for (i=1:runCount)
            set(gui(i).subhandles.txtStimLength,'string',thisNum);
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
        
end

function valid=validate(parentGUI)

% check sensible values have been entered into the dialog
    valid=true;
    filename=get(parentGUI.txtDataFile,'string');
    file=dir(filename);
    set(parentGUI.txtError,'string','');
    if (size(file,1)==0) % file does not exist
        set(parentGUI.txtError,'string','Data file does not exist or is invalid');
        valid=false;
        return;
    end
%{
    filename=get(parentGUI.txtDesignFile,'string');
    file=dir(filename);
    set(parentGUI.txtError,'string','');
    if (size(file,1)==0) % file does not exist
        set(parentGUI.txtError,'string','Design file does not exist or is invalid');
        valid=false;
        return;
    end
%}
    filename=get(parentGUI.txtCalibFile,'string');
    file=dir(filename);
    set(parentGUI.txtError,'string','');
    if (size(file,1)==0) % file does not exist
        set(parentGUI.txtError,'string','Calibration file does not exist or is invalid');
        valid=false;
        return;
    end

    if (get(parentGUI.chkUseDesign,'value')==0) % only validate if we don't get parameters from design file
        numTrials=str2num(get(parentGUI.txtNumTrials,'string'));
        if (isempty(numTrials) || numTrials<=0)
            set(parentGUI.txtError,'string','Invalid number of trials specified (for event-related specify 1 trial per block)');
            valid=false;
            return;
        end
    end

    if (get(parentGUI.chkUseDesign,'value')==0)
        trialLength=str2num(get(parentGUI.txtTrialLength,'string'));
        if (isempty(trialLength) || trialLength<=0)
            set(parentGUI.txtError,'string','Invalid trial length specified');
            valid=false;
            return;
        end
    end
end