function ConfigSaccadeParams

global configData;

% get saccade detection parameters
if (~isfield(configData,'saccParams'))
    txt=sprintf('Saccade parameters are currently not set.\nDo you want to load them from a file?');
    ret=QuestDlg(txt,'Load saccade parameters','Yes','No','No');
    if (strcmp(ret,'Yes'))
        valid=false;
        while (valid==false)
            % give user an opportunity to load parameters from a file
            [filename pathname]=uigetfile({'*.mat','Saccade parameter file (*.mat)'},'Load saccade parameters','saccparams.mat');
            if (filename==0) % user cancelled just return
                return;
            else
                load ([pathname filename]);
                check=true;
                if (isempty(who('saccParams')))
                    check=false;
                elseif (~isfield(saccParams,'saccParams'))
                    check=false;
                elseif (saccParams.valid~=true)
                    check=false;
                end

                if (check==false)
                    txt=sprintf('File does not contain valid saccade detection parameters.\nPlease select the correct filename.');
                    uiwait(MsgBox(txt,'Invalid file','modal'));
                    continue;
                else
                    valid=true;
                end
            end
        end
        cancel=false;
        [cancel,saccParams]=getSaccadeParams(saccParams);
    else % don't load parameters allow user to input completely new set
        cancel=false;
        [cancel,saccParams]=getSaccadeParams(); % no parameters provided
    end
else
    saccParams=configData.saccParams;
    cancel=false;
    [cancel,saccParams]=getSaccadeParams(saccParams);
end

if (cancel==true)
    return;
else
    if (saccParams.valid==true)
        valid=false;
        while (valid==false)
            ret=QuestDlg('Save saccade parameters to a file?','Save saccade parameters','Yes','No','Yes');
            if (strcmp(ret,'Yes'))
                while (valid==false)
                    [filename pathname]=uiputfile({'*.mat','Saccade parameter file (*.mat)'},'Save saccade parameters','saccparams.mat');
                    if (filename==0)
                        continue;
                    else
                        save ([pathname filename],'saccParams');
                        valid=true;
                    end
                end
            else
                % don't save but just continue;
                valid=true;
            end
        end
        % set configData saccade parameters 
        configData.saccParams=saccParams;
    else
        error('Saccade parameters are invalid');
    end
end
end
