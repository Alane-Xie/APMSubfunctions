function [cancel,blinkParams]=getBlinkParams(inBlinkParams)
% get parameters which are needed identify saccades
    valid=false;
    cancel=false;
    parameters = {...
        'maxBlinkThreshold','Time in milliseconds which constitutes the maximum period for a blink ','';...
        'minBlinkAmplitude','Minimum amplitude in degrees at which a change in position could be considered a blink','';...
        'postBlinkMinThreshold','Following a blink the minimum difference in degrees visual angle from before the blink which will exclude subsequent samples from the blink','';...
        'blinkWindow','Duration in milliseconds over which eye position is determined pre and post blink','';...
%        'postBlinkVelDuration','Duration in milliseconds after a blink during which position must be below threshold variation to end the blink','';...
        'postBlinkPosVariation','Following a blink the threshold of the std deviation of position to end the blink',''};

    nullstr=[char('''') char('''')];

    % initialise all values
    init=true;
    if nargin==0 
        init=false;
    elseif class(inBlinkParams)~='struct'
        init=false;
    elseif inBlinkParams.blinkParams~='blinkParams'
        init=false;
    else
        init=true;
    end

    if init==false
        for i=1:size(parameters,1)
            s=sprintf('blinkParams.%s=%s;',cell2mat(parameters(i,1)),nullstr);
            eval(s);
        end
    else
        for i=1:size(parameters,1)
            if (isfield(inBlinkParams,cell2mat(parameters(i,1))))
                s=sprintf('parameters{%d,3}=num2str(inBlinkParams.%s);',i,cell2mat(parameters(i,1)));
                eval(s);
            end
        end
    end

    while (valid~=true)
        result=inputdlg(parameters(:,2),'Blink detection parameters',1,parameters(:,3));

        if (isempty(result)) % user hit cancel or didn't enter anything
            if (~isempty(who('inBlinkParams')))
                blinkParams=inBlinkParams; % reset to what they were on start
            else
                blinkParams=[];
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
            uiwait(msgbox(err,'Blink detection parameters','modal'));
            continue;
        end

        % set parameters

        for i=1:size(parameters,1)
            s=sprintf('blinkParams.%s=%d;',cell2mat(parameters(i,1)),str2num(cell2mat(parameters(i,3))));
            eval(s);
        end
    
        % check blink parameters
        err='';

        if (blinkParams.maxBlinkThreshold<=0)
            err='Blink thresholds must be positive';
        end
    
        if (~isempty(err))
            uiwait(msgbox(err,'Blink detection parameters','modal'));
            valid=false;
        else
            valid=true;
        end
   
    end   

    blinkParams.blinkParams='blinkParams'; % use this as an identifier to make sure what we pass in is valid
    blinkParams.valid=true;
end
