function blinkParams=ConfigBlinkParams

global configData;

% get saccade detection parameters
if (~isfield(configData,'blinkParams'))
    txt=sprintf('Blink parameters are currently not set.\nDo you want to load them from a file?');
    ret=QuestDlg(txt,'Load blink parameters','Yes','No','No');
    if (strcmp(ret,'Yes'))
        valid=false;
        while (valid==false)
            % give user an opportunity to load parameters from a file
            [filename pathname]=uigetfile({'*.mat','Blinks parameter file (*.mat)'},'Load blink parameters','blinkparams.mat');
            if (filename==0) % user cancelled just return
                return;
            else
                load ([pathname filename]);
                check=true;c
                if (isempty(who('blinkParams')))
                    check=false;
                elseif (~isfield(blinkParams,'blinkParams'))
                    check=false;
                elseif (blinkParams.valid~=true)
                    check=false;
                end

                if (check==false)
                    txt=sprintf('File does not contain valid blink detection parameters.\nPlease select the correct filename.');
                    uiwait(MsgBox(txt,'Invalid file','modal'));
                    continue;
                else
                    valid=true;
                end
            end
        end
        cancel=false;
        [cancel,blinkParams]=GetBlinkParams(blinkParams);
    else % don't load parameters allow user to input completely new set
        cancel=false;
        [cancel,blinkParams]=GetBlinkParams(); % no parameters provided
    end
else
    blinkParams=configData.blinkParams;
    cancel=false;
    [cancel,blinkParams]=GetBlinkParams(blinkParams);
end

if (cancel==true)
    return;
else
    if (blinkParams.valid==true)
        valid=false;
        while (valid==false)
            ret=QuestDlg('Save blink parameters to a file?','Save blink parameters','Yes','No','Yes');
            if (strcmp(ret,'Yes'))
                while (valid==false)
                    [filename pathname]=uiputfile({'*.mat','Blink parameter file (*.mat)'},'Save blink parameters','blinkparams.mat');
                    if (filename==0)
                        continue;
                    else
                        save ([pathname filename],'blinkParams');
                        valid=true;
                    end
                end
            else
                % don't save but just continue;
                valid=true;
            end
        end
        % set configData blink parameters 
        configData.blinkParams=blinkParams;
    else
        error('Blink parameters are invalid');
    end
end

end