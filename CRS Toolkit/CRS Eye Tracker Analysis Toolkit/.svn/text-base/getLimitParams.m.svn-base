function [cancel,limitParams]=getLimitParams(inLimitParams)
% get parameters which set limits on conditions, runs and sessions etc.

valid=false;
cancel=false;

    parameters = {...
        'maxConditions','Maximum number of conditions','';...
        'maxRuns','Maxium number of runs to analyse','';...
        'maxSessions','Maximum number of sessions for multi-subject',''};

    nullstr=[char('''') char('''')];

    % initialise all values
    init=true;
    if nargin==0 
        init=false;
    elseif class(inLimitParams)~='struct'
        init=false;
    elseif inLimitParams.LimitParams~='LimitParams'
        init=false;
    else
        init=true;
    end

    if init==false
        for i=1:size(parameters,1)
            s=sprintf('limitParams.%s=%s;',cell2mat(parameters(i,1)),nullstr);
            eval(s);
        end
    else
        for i=1:size(parameters,1)
            if (isfield(inLimitParams,cell2mat(parameters(i,1))))
                s=sprintf('parameters{%d,3}=num2str(inLimitParams.%s);',i,cell2mat(parameters(i,1)));
                eval(s);
            end
        end
    end

    while (valid~=true)
        result=inputdlg(parameters(:,2),'Limit parameters',1,parameters(:,3));

        if (isempty(result)) % user hit cancel or didn't enter anything
            if (~isempty(who('inLimitParams')))
                limitParams=inLimitParams; % reset to what they were on start
            else
                limitParams=[];
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
            uiwait(msgbox(err,'Limit parameters','modal'));
        end
    end 

    % set parameters

    for i=1:size(parameters,1)
        s=sprintf('limitParams.%s=%d;',cell2mat(parameters(i,1)),str2num(cell2mat(parameters(i,3))));
        eval(s);
    end

    limitParams.LimitParams='limitParams'; % use this as an identifier to make sure what we pass in is valid

    limitParams.valid=true;
end
