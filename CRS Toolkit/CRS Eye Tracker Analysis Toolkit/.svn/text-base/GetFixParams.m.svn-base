function [cancel,fixParams]=getFixParams(inFixParams)
% get parameters which are needed identify saccades
    valid=false;
    cancel=false;
    parameters = {...
        'fixBoundary1','Standard deviation of visual angle for threshold of temporary fixation position ','';...
        'fixTimeWindow','Fixation time window for identifying temporary fixation position in milliseconds','';...
        'fixBoundary2','First chance maximum distance in degrees below which a point is identified as part of a fixation','';...
        'fixTimeThreshold','Maximum amount of time in milliseconds which consitutes the end of a fixation if no further points which qualify as part of a fixation are identified.','';...
        'fixBoundary3','Second chance maximum distance in degrees below which a point is still identified as a fixation','';...
        'fixDuration','Total minimum duration in millseconds which constitutes a fixation ',''};
    

    nullstr=[char('''') char('''')];

    % initialise all values
    init=true;
    if nargin==0 
        init=false;
    elseif class(inFixParams)~='struct'
        init=false;
    elseif inFixParams.fixParams~='fixParams'
        init=false;
    else
        init=true;
    end

    if init==false
        for i=1:size(parameters,1)
            s=sprintf('fixParams.%s=%s;',cell2mat(parameters(i,1)),nullstr);
            eval(s);
        end
    else
        
        for i=1:size(parameters,1)
            if (isfield(inFixParams,cell2mat(parameters(i,1))))
                s=sprintf('parameters{%d,3}=num2str(inFixParams.%s);',i,cell2mat(parameters(i,1)));
                eval(s);
            end
        end
    end

    while (valid~=true)
        result=inputdlg(parameters(:,2),'Fixation detection parameters',1,parameters(:,3));

        if (isempty(result)) % user hit cancel or didn't enter anything
            if (~isempty(who('inFixParams')))
                fixParams=inFixParams; % reset to what they were on start
            else
               fixParams=[];
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
            uiwait(msgbox(err,'Fixation detection parameters','modal'));
            continue;
        end

        % set parameters

        for i=1:size(parameters,1)
            s=sprintf('fixParams.%s=%d;',cell2mat(parameters(i,1)),str2num(cell2mat(parameters(i,3))));
            eval(s);
        end
        
        valid=true;
   
    end   

    fixParams.fixParams='fixParams'; % use this as an identifier to make sure what we pass in is valid
    fixParams.valid=true;
end
