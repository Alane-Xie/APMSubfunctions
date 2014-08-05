function [cancel,CRSParams]=getCRSParams(inCRSParams)
% get parameters which are needed to process data from CRS eye tracker

valid=false;
cancel=false;

    parameters = {...
        'downsampleRate','Rate to downsample raw data to (e.g. 100Hz etc','';...
        'highPassFrequency','High pass filter frequency','';...
        'lowPassFrequency','Low pass filter frequency',''};

    nullstr=[char('''') char('''')];

    % initialise all values
    init=true;
    if nargin==0 
        init=false;
    elseif class(inCRSParams)~='struct'
        init=false;
    elseif inCRSParams.CRSParams~='CRSParams'
        init=false;
    else
        init=true;
    end

    if init==false
        for i=1:size(parameters,1)
            s=sprintf('CRSParams.%s=%s;',cell2mat(parameters(i,1)),nullstr);
            eval(s);
        end
    else
        for i=1:size(parameters,1)
            if (isfield(inCRSParams,cell2mat(parameters(i,1))))
                s=sprintf('parameters{%d,3}=num2str(inCRSParams.%s);',i,cell2mat(parameters(i,1)));
                eval(s);
            end
        end
    end

    while (valid~=true)
        result=inputdlg(parameters(:,2),'CRS eye tracker parameters',1,parameters(:,3));

        if (isempty(result)) % user hit cancel or didn't enter anything
            if (~isempty(who('inCRSParams')))
                CRSParams=inCRSParams; % reset to what they were on start
            else
                CRSParams=[];
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
            uiwait(msgbox(err,'CRS eye tracker parameters','modal'));
        end
    end 

    % set parameters

    for i=1:size(parameters,1)
        s=sprintf('CRSParams.%s=%d;',cell2mat(parameters(i,1)),str2num(cell2mat(parameters(i,3))));
        eval(s);
    end

    CRSParams.CRSParams='CRSParams'; % use this as an identifier to make sure what we pass in is valid

    CRSParams.valid=true;
end
