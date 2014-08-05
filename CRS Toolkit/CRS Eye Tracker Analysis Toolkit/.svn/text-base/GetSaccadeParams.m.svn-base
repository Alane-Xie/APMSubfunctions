function [cancel,saccParams]=getSaccadeParams(inSaccParams)
% get parameters which are needed identify saccades
    valid=false;
    cancel=false;
    parameters = {...
        'velThreshold','Velocity threshold in degrees/sec to identify a saccade or blink','';...
        'ampThreshold','Amplitude threshold in degrees ','';...
        'durThreshold','Minimum duration threshold in milliseconds for a saccade','';...
        'maxPeakVelocity','Peak velocity above which eye movements are not classified as saccades)','';...
        'saccSequenceExtraTime','When displaying a detected saccade how long in milliseconds to display before and after the sequence','';...
        'saccMainSeqPctCheck','Percentage approximation to main sequence which could denote a saccade if inspected visually','';...
        'saccMainSeqPercent','Percentage approximation to main sequence which constitutes a saccade without checking',''};

    nullstr=[char('''') char('''')];

    % initialise all values
    init=true;
    if nargin==0 
        init=false;
    elseif class(inSaccParams)~='struct'
        init=false;
    elseif inSaccParams.saccParams~='saccParams'
        init=false;
    else
        init=true;
    end

    if init==false
        for i=1:size(parameters,1)
            s=sprintf('saccParams.%s=%s;',cell2mat(parameters(i,1)),nullstr);
            eval(s);
        end
    else
        for i=1:size(parameters,1)

            if (isfield(inSaccParams,cell2mat(parameters(i,1))))
                s=sprintf('parameters{%d,3}=num2str(inSaccParams.%s);',i,cell2mat(parameters(i,1)));
                eval(s);
            end
        end
    end

    while (valid~=true)
        result=inputdlg(parameters(:,2),'Saccade detection parameters',1,parameters(:,3));

        if (isempty(result)) % user hit cancel or didn't enter anything
            if (~isempty(who('inSaccParams')))
                saccParams=inSaccParams; % reset to what they were on start
            else
                saccParams=[];
            end
            cancel=true;
            return;
        else
            parameters(:,3)=result;
        end

        % determine if any parameters are not numbers - if so data is invalid

        valid=true;
        for k=1:size(parameters(:,1))
            if isempty(str2num(cell2mat(parameters(k,3))))
                valid=false;
                break;
            end
        end
        if valid==false
            err='One or more values are not valid - please enter all values.';
            uiwait(msgbox(err,'Saccade detection parameters','modal'));
        end
    end 

    % set parameters

    for i=1:size(parameters,1)
        s=sprintf('saccParams.%s=%d;',cell2mat(parameters(i,1)),str2num(cell2mat(parameters(i,3))));
        eval(s);
    end
    saccParams.valid=true;
    saccParams.saccParams='saccParams'; % use this as an identifier to make sure what we pass in is valid
    
end
