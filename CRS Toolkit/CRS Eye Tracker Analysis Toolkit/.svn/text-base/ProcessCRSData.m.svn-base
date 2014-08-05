function EyeData = ProcessCRSdata(EyeData,session)

    % load CRS data and process accordingly

    % output is a structure containing the relevant data required for analysis 
    global configData;
    if (isfield(EyeData,'segment'))
        EyeData=rmfield(EyeData,'segment');
    end
    
    % load and process data from each run
    for (i=1:size(EyeData.designData,2))
        [path name ext]=fileparts(EyeData.designData(i).dataFile);
            if (exist('session'))
                txt=sprintf('Process data from session %d - %s',session,[name ext]);
            else
                txt=sprintf('Process data from %s',[name ext]);
            end
        wb=waitbar(1,' ');
        ch=get(wb,'children');
        title=get(ch,'title');
        set(title,'Interpreter','none');
        waitbar(1,wb,txt);
        procEyeData=processCRSfile(EyeData.designData(i).dataFile,EyeData.designData(i).calibFile,configData.CRSParams);
        procEyeData.realSegmentIndex=i;
        EyeData.segment(i)=procEyeData;
        close(wb);
        waitfor(wb);
    end
%    svr.delete;
    
end

