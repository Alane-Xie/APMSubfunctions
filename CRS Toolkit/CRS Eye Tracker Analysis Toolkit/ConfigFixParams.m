function ConfigFixParams

global configData;

% get saccade detection parameters
if (~isfield(configData,'fixParams'))
    txt=sprintf('Fixation parameters are currently not set.\nDo you want to load them from a file?');
    ret=QuestDlg(txt,'Load fixation parameters','Yes','No','No');
    if (strcmp(ret,'Yes'))
        valid=false;
        while (valid==false)
            % give user an opportunity to load parameters from a file
            [filename pathname]=uigetfile({'*.mat','Fixation parameter file (*.mat)'},'Load fixation parameters','fixparams.mat');
            if (filename==0) % user cancelled just return
                return;
            else
                load ([pathname filename]);
                check=true;
                if (isempty(who('fixParams')))
                    check=false;
                elseif (~isfield(fixParams,'fixParams'))
                    check=false;
                elseif (fixParams.valid~=true)
                    check=false;
                end

                if (check==false)
                    txt=sprintf('File does not contain valid fixation detection parameters.\nPlease select the correct filename.');
                    uiwait(MsgBox(txt,'Invalid file','modal'));
                    continue;
                else
                    valid=true;
                end
            end
        end
        cancel=false;
        [cancel,fixParams]=GetFixParams(fixParams);
    else % don't load parameters allow user to input completely new set
        cancel=false;
        [cancel,fixParams]=GetFixParams(); % no parameters provided
    end
else
    fixParams=configData.fixParams;
    cancel=false;
    [cancel,fixParams]=GetFixParams(fixParams);
end

if (cancel==true)
    return;
else
    if (fixParams.valid==true)
        valid=false;
        while (valid==false)
            ret=QuestDlg('Save fixation parameters to a file?','Save fixation parameters','Yes','No','Yes');
            if (strcmp(ret,'Yes'))
                while (valid==false)
                    [filename pathname]=uiputfile({'*.mat','Fixation parameter file (*.mat)'},'Save fixation parameters','fixparams.mat');
                    if (filename==0)
                        continue;
                    else
                        save ([pathname filename],'fixParams');
                        valid=true;
                    end
                end
            else
                % don't save but just continue;
                valid=true;
            end
        end
        % set configData fixation parameters 
        configData.fixParams=fixParams;
    else
        error('Fixation parameters are invalid');
    end
end
end
