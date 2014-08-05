function ConfigLimitParams

global configData;

% get limit parameters
if (~isfield(configData,'limitParams'))
    txt=sprintf('Limit parameters are currently not set.\nDo you want to load them from a file?');
    ret=QuestDlg(txt,'Load limit parameters','Yes','No','No');
    if (strcmp(ret,'Yes'))
        valid=false;
        while (valid==false)
            % give user an opportunity to load parameters from a file
            [filename pathname]=uigetfile({'*.mat','Limit parameter file (*.mat)'},'Load limit parameters','limitparams.mat');
            if (filename==0) % user cancelled just return
                return;
            else
                load ([pathname filename]);
                check=true;
                if (isempty(who('limitParams')))
                    check=false;
                elseif (~isfield(limitParams,'LimitParams'))
                    check=false;
                elseif (limitParams.valid~=true)
                    check=false;
                end

                if (check==false)
                    txt=sprintf('File does not contain valid limit parameters.\nPlease select the correct filename.');
                    uiwait(MsgBox(txt,'Invalid file','modal'));
                    continue;
                else
                    valid=true;
                end
            end
        end
        cancel=false;
        [cancel,limitParams]=GetLimitParams(limitParams);
    else % don't load parameters allow user to input completely new set
        cancel=false;
        [cancel,limitParams]=GetLimitParams(); % no parameters provided
    end
else
    limitParams=configData.limitParams;
    cancel=false;
    [cancel,limitParams]=GetLimitParams(limitParams);
end

if (cancel==true)
    return;
else
    if (limitParams.valid==true)
        valid=false;
        while (valid==false)
            ret=QuestDlg('Save limit parameters to a file?','Save limit parameters','Yes','No','Yes');
            if (strcmp(ret,'Yes'))
                while (valid==false)
                    [filename pathname]=uiputfile({'*.mat','Limit parameter file (*.mat)'},'Save limit parameters','limitparams.mat');
                    if (filename==0)
                        continue;
                    else
                        save ([pathname filename],'limitParams');
                        valid=true;
                    end
                end
            else
                % don't save but just continue;
                valid=true;
            end
        end
        
        % set configData ASL parameters 
        configData.limitParams=limitParams;
    else
        error('Limit parameters are invalid');
    end
end

end