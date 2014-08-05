function [EyeData]=AssignConditions(EyeData)

% assign to each data point the condition corresponding to the design Data
% for each segment

% go through each segment assigning conditions to each data point based on
% the design characteristics

global configData;
realConds=[];
for (j=1:size(configData.conditions,2))
    realConds=[realConds configData.conditions(j).realCondition];
    EyeData.samplesPerTrialPerCond(j)=0;
    EyeData.stimLengthPerCond(j)=NaN;
end

realConds=realConds';

for (i=1:size(EyeData.segment,2))
    
    % firstly make sure segment indices match
    
    if (EyeData.segment(i).realSegmentIndex~=EyeData.designData(i).realSegmentIndex)
        errordesc='Condition assignment mismatch between design file and data';
        uiwait(errordlg(errordesc));

        error(errordesc);
    end
    
    % load the corresponding design file
    designFileData=load(EyeData.designData(i).designFile);
    
    notPresent=setdiff(designFileData(:,1), realConds);
    if (~isempty(notPresent))
        errordesc='Condition present in design file not defined in design data';
        uiwait(errordlg(errordesc));
        error(errordesc);
    end
    
    EyeData.designData(i).blockConditions=designFileData(:,1);
    
    % load trial lengths and trial counts if present
    if (size(designFileData,2)>=3) 
        EyeData.designData(i).trialLengths=designFileData(:,2);
        EyeData.designData(i).numTrialsPerBlock=designFileData(:,3);
        if (size(designFileData,2)<4)
            if (isnan(EyeData.designData(i).stimLength)) % no stim length specified from analysis setup so use same as trial length
                EyeData.designData(i).stimLengths=designFileData(:,2);
            else % default stim length 
                stimLengths=ones(1,size(designFileData,1))*EyeData.designData(i).stimLength;
                EyeData.designData(i).stimLengths=stimLengths;
            end
        else % stim length was specified in design file so use that instead
            EyeData.designData(i).stimLengths=designFileData(:,4);
        end
    else
        % set them from defaults for this run
        trialLengths=ones(1,size(designFileData,1))*EyeData.designData(i).trialLength;
        numTrialsPerBlock=ones(1,size(designFileData,1))*EyeData.designData(i).numTrials;        
        EyeData.designData(i).trialLengths=trialLengths;
        EyeData.designData(i).numTrialsPerBlock=numTrialsPerBlock;
         if (isnan(EyeData.designData(i).stimLength)) % same as trial length
            EyeData.designData(i).stimLengths=trialLengths;
        else
            stimLengths=ones(1,size(designFileData,1))*EyeData.designData(i).stimLength;
            EyeData.designData(i).stimLengths=stimLengths;
        end

    end
    
    EyeData.segment(i).trialsPerCondition=struct('startIndex',[],'endIndex',[]);
    EyeData.segment(i).trialsPerCondition(configData.numConditions).startIndex=[];
    EyeData.segment(i).trialsPerCondition(configData.numConditions).endIndex=[];

    trialCount=zeros(configData.numConditions,1); % number of trials per condition

    startTime=0; 
    maxIndex=size(EyeData.segment(i).recordNo,1); % size of raw data
    
    sampleDiff=mean(diff(EyeData.segment(i).sampleTime));
    sampleDiff=sampleDiff*1000; % in ms
    sampleDiff=round(sampleDiff*1000)/1000; % to nearest ms.

    EyeData.segment(i).sampleDiff=sampleDiff;

    % calculate number of samples per trial per block given trial length
    
    numBlocks=size(EyeData.designData(i).blockConditions,1);

    % determine total number of samples per run
    totalSamples=0;

    for (j=1:numBlocks)
        
        samplesPerTrial(j)=ceil(EyeData.designData(i).trialLengths(j)/EyeData.segment(i).sampleDiff);
        samplesPerBlock(j)=samplesPerTrial(j)*EyeData.designData(i).numTrialsPerBlock(j);
        totalSamples=totalSamples+ samplesPerBlock(j);
        cond=EyeData.designData(i).blockConditions(j);

        % find index into configData.conditions
        realCondIndex=find([configData.conditions.realCondition]==cond); % since cond is an actual condition find the index associated with it (we need this since cond could be 0)
        if (EyeData.samplesPerTrialPerCond(realCondIndex)==0)
            EyeData.samplesPerTrialPerCond(realCondIndex)=samplesPerTrial(j);
            EyeData.trialLengthPerCond(realCondIndex)=EyeData.designData(i).trialLengths(j);
        else % check values match
            if (samplesPerTrial(j)~=EyeData.samplesPerTrialPerCond(realCondIndex))
                errordesc=sprintf('Two blocks of the same condition differ in trial length (samples per trial)');
               uiwait(errordlg(errordesc));
                error(errordesc);
            end
            if (EyeData.designData(i).trialLengths(j)~=EyeData.trialLengthPerCond(realCondIndex))
                errordesc=sprintf('Two blocks of the same condition differ in trial length (trial length)');
                uiwait(errordlg(errordesc));
                error(errordesc);
            end

        end
        
         if (isnan(EyeData.stimLengthPerCond(realCondIndex)))
            EyeData.stimLengthPerCond(realCondIndex)=EyeData.designData(i).stimLengths(j);
        else
            if (EyeData.stimLengthPerCond(realCondIndex)~=EyeData.designData(i).stimLengths(j))
                errordesc=sprintf('Two blocks of the same condition differ in stimulus length');
                uiwait(errordlg(errordesc));
                error(errordesc);
            end
            if (EyeData.stimLengthPerCond(realCondIndex)>EyeData.trialLengthPerCond(realCondIndex))
                errordesc=(sprintf('Stim length is greater than trial length in segment %d block %d',i,j));
                uiwait(errordlg(errordesc));
                error(errordesc);
            end

        end
                
    end

    if (totalSamples<maxIndex) % data needs to be truncated
        maxIndex=totalSamples;
    elseif (totalSamples>maxIndex) % data is shortened - this is an error
        errordesc=sprintf('Not enough samples present in run %d - data may have been truncated or design file might be in error',i);
        errordlg(errordesc);
        error(errordesc);
    end
    
    EyeData.segment(i).totalSamples=totalSamples; 
    
    startIndex=1;
    
    % allocate start and end positions for block
    for (j=1:size(EyeData.designData(i).blockConditions,1)) %
        condition=EyeData.designData(i).blockConditions(j); % determine condition (this is the real condition number
    

        endIndex=startIndex+samplesPerBlock(j);
        endIndex=endIndex-1;

        if (endIndex>maxIndex) % for some reason we've gone over the end of the file - this is an error
            errordesc=sprintf('Premature end of data on run %d block %d',i,j);
            uiwait(errordlg(errordesc));

            error(errordesc);
        end

        condIndex=find([configData.conditions.realCondition]==condition,1);

        if (size(condIndex,2)~=1)
            errordesc=sprintf('Error allocating condition to data on run %d block %d',i,j);
            uiwait(errordlg(errordesc));

            error(errordesc);
        end
        
        EyeData.segment(i).condition(startIndex:endIndex)=condIndex; % index 

        trialStartIndex=startIndex;
        trialEndIndex=trialStartIndex+samplesPerTrial(j);
        trialEndIndex=trialEndIndex-1;
        
        for (k=1:EyeData.designData(i).numTrialsPerBlock(j));
            trialCount(condIndex)=trialCount(condIndex)+1;
            EyeData.segment(i).trialsPerCondition(condIndex).startIndex(trialCount(condIndex))=trialStartIndex; % condition+1 because Matlab arrays start at 1 but condition could start at 0
            EyeData.segment(i).trialsPerCondition(condIndex).endIndex(trialCount(condIndex))=trialEndIndex;
            if (trialEndIndex==maxIndex)
                break;
            end
            
            if (k<EyeData.designData(i).numTrialsPerBlock(j)) % we don't need to do this for the last trial as we are moving to the next block 
                trialStartIndex=trialStartIndex+samplesPerTrial(j);
                trialEndIndex=trialEndIndex+samplesPerTrial(j);
                if (trialEndIndex>maxIndex)
                    errordesc=sprintf('Error allocating condition to data on run %d block %d',i,j);
                    uiwait(errordlg(errordesc));

                    error(errordesc);
                end
            end
            
        end
        startIndex=startIndex+samplesPerBlock(j);
    end
                
end


% determine total no. of trials per condition over all runs

for (i=1:size(configData.conditions,2))
    EyeData.trialsPerCondition(i)=0;
    for (j=1:size(EyeData.segment,2))
        EyeData.trialsPerCondition(i)=EyeData.trialsPerCondition(i)...
            +size(EyeData.segment(j).trialsPerCondition(i).startIndex,2);
    end
end


end 