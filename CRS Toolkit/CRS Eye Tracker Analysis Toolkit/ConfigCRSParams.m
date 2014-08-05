function ConfigCRSParams

global configData;

% get saccade detection parameters
if (~isfield(configData,'CRSParams'))
    txt=sprintf('CRS conversion parameters are currently not set.\nDo you want to load them from a file?');
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
                    txt=sprintf('File does not contain valid CRS conversion parameters.\nPlease select the correct filename.');
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
    cancel=false;
    [cancel,CRSParams]=GetCRSParams(CRSParams);
end

if (cancel==true)
    return;
else
    if (CRSParams.valid==true)
        valid=false;
        while (valid==false)
            ret=QuestDlg('Save CRS conversion parameters to a file?','Save CRS parameters','Yes','No','Yes');
            if (strcmp(ret,'Yes'))
                while (valid==false)
                    [filename pathname]=uiputfile({'*.mat','CRS parameter file (*.mat)'},'Save CRS parameters','crsparams.mat');
                    if (filename==0)
                        continue;
                    else
                        save ([pathname filename],'CRSParams');
                        valid=true;
                    end
                end
            else
                % don't save but just continue;
                valid=true;
            end
        end
        
        % set configData ASL parameters 
        configData.CRSParams=CRSParams;
    else
        error('CRS parameters are invalid');
    end
end

end