
function groupData=ProcessGroupData(groupData)

global configData;

% process mean eye position over all subjects

%initialise xPosPerCondition

groupXPerCondition.X=[];

% check samples per trial per condition is the same across all subjects
% otherwise this won't work

for (i=1:size(groupData.session,2))
    for (j=1:configData.numConditions)
        samplesPerTrialPerCond(j,i)=groupData.session(i).EyeData.samplesPerTrialPerCond(j);
        trialLengthPerCond(j,i)=groupData.session(i).EyeData.trialLengthPerCond(j);
        stimLengthPerCond(j,i)=groupData.session(i).EyeData.stimLengthPerCond(j);

    end
end

% check the same values are present for each condition
for (i=1:configData.numConditions)
    if (size(unique(samplesPerTrialPerCond(i,:)),2)~=1)
        errordesc=sprintf('For condition %d, not all subjects have the same defined trial size (samples)',i);
        errordlg(errordesc);
        error(errodesc);
    end
    if (size(unique(trialLengthPerCond(i,:)),2)~=1)
        errordesc=sprintf('For condition %d, not all subjects have the same defined trial size (trial length)',i);
        errordlg(errordesc);
        error(errodesc);
    end
        if (size(unique(stimLengthPerCond(i,:)),2)~=1)
        errordesc=sprintf('For condition %d, not all subjects have the same defined stimulus length ',i);
        errordlg(errordesc);
        error(errodesc);
    end

end

% 
samplesPerTrialPerCond=samplesPerTrialPerCond(:,1)';
        
% initialise groupXPosPerCondition
for (i=1:configData.numConditions)
    for (k=1:samplesPerTrialPerCond(i))
        groupXPerCondition(i).XPositions(k).X=[];
    end
end

for (i=1:configData.numConditions)
    for (k=1:samplesPerTrialPerCond(i))
        groupXPerCondition(i).XPositions(k).X=[]; % awkward structure since there could be different lengths per condition
    end
end

% loop over all conditions
for (k=1:size(groupData.session,2))
    EyeData=groupData.session(k).EyeData;
    for (i=1:configData.numConditions)
        % loop over all segments
        for (j=1:size(EyeData.segment,2))
            if (EyeData.segment(j).include==true)
                % get trial start points for each trial in condition for this
                % segment
                trialStartIndices=EyeData.segment(j).trialsPerCondition(i).startIndex;
                % for each trial per condition construct array of positional data
                % over all segments
                for (k=1:EyeData.samplesPerTrialPerCond(i))
                    % reshape xPosPerCondition
                    if (isempty(groupXPerCondition(i).XPositions(k).X))
                        xData=[EyeData.segment(j).angleX(trialStartIndices+k-1)];
                        lengthxData=size(xData,1)*size(xData,2);
                        %reshape xData to 1 row lengthxData columns
                        xData=reshape(xData,1,lengthxData);
                        groupXPerCondition(i).XPositions(k).X=xData;
                    else
                        xData=[EyeData.segment(j).angleX(trialStartIndices+k-1)];
                        lengthxData=size(xData,1)*size(xData,2);
                        %reshape xData to 1 row lengthxData columns
                        xData=reshape(xData,1,lengthxData);
                        groupXPerCondition(i).XPositions(k).X=[groupXPerCondition(i).XPositions(k).X xData];
                    end
                end
            end
        end
    end
end

% loop over all conditions
for (i=1:configData.numConditions)
    meanXPos=[];
    for (j=1:samplesPerTrialPerCond(i))
        m=size(groupXPerCondition(i).XPositions(j).X,1);
        n=size(groupXPerCondition(i).XPositions(j).X,2);
        xPos=reshape(groupXPerCondition(i).XPositions(j).X,1,m*n); % make it linear 
        meanXPos(j)=nanmean(xPos);
    end
    meanXPerCondition(i).xPos=meanXPos;
end

groupData.eyePositions.meanXPerCondition=meanXPerCondition;

% process fixation positions
bins=[-10:0.5:10];

% collate all fixation positions over all subjects per condition
for (i=1:configData.numConditions)
    groupFixPerCondition(i).fix=[];
end

for (i=1:configData.numConditions)
    for (k=1:size(groupData.session,2))
        groupFixPerCondition(i).fix=[groupFixPerCondition(i).fix groupData.session(k).EyeData.fixationsPerCondition(i)];
    end
end
    
% bin positions for each point
 % bin the amplitudes by degree visual angle   
for (i=1:configData.numConditions)
    posCounts(i).X=histc([groupFixPerCondition(i).fix.meanX],bins);

    % calculate proportion
    total(i)=size([groupFixPerCondition(i).fix.meanX],2);
    posProps(i).X=posCounts(i).X/total(i);
end

groupData.fixSummary.positionData=posProps;

% process saccades over all subjects

conditions=configData.conditions;

groupAmpCounts=struct('X',[]);
groupAmpProps=struct('X',[]);
binsX=[-15:0.5:15];
groupSaccades=[];
groupSaccProps=[];


for (i=1:configData.numConditions)
    groupSaccades.perCondition(i).saccades=[];
end

% collate all saccade data over all subjects
for (i=1:size(conditions,2))
    for (j=1:size(groupData.session,2))
        EyeData=groupData.session(j).EyeData;
        if (isempty(groupSaccades.perCondition(i).saccades))
            groupSaccades.perCondition(i).saccades= EyeData.saccades.perCondition(i).Saccade;
        else
            groupSaccades.perCondition(i).saccades=[groupSaccades.perCondition(i).saccades EyeData.saccades.perCondition(i).Saccade];
        end
    end
end

for (i=1:size(conditions,2))
    % bin the amplitudes by degree visual angle   
    if (size(groupSaccades.perCondition(i).saccades,2>0))
        if (~isempty([groupSaccades.perCondition(i).saccades.saccAmpX]))
            groupAmpCounts(i).X=histc([groupSaccades.perCondition(i).saccades.saccAmpX],binsX);
            % calculate proportion
            totalAmps(i)=size(groupSaccades.perCondition(i).saccades,2);
            groupAmpProps(i).X=groupAmpCounts(i).X/totalAmps(i);
        else
            groupAmpProps(i).X=0;
        end
    else
        groupAmpProps(i).X=0;

    end
       
end

groupData.saccSummary.amplitudeData=groupAmpProps;

groupSaccCounts=[];
for (i=1:configData.numConditions)
    groupSaccCounts.perCondition(i).saccCounts=[];
end

for (i=1:configData.numConditions)
    for (j=1:size(groupData.session,2))
        if (isempty(groupSaccCounts.perCondition(i).saccCounts))
            groupSaccCounts.perCondition(i).saccCounts=groupData.session(j).EyeData.saccSummary.saccCounts(i);
        else
            groupSaccCounts.perCondition(i).saccCounts=[groupSaccCounts.perCondition(i).saccCounts groupData.session(j).EyeData.saccSummary.saccCounts(i)];
        end
    end
    groupData.saccades.perCondition(i).count=nansum(groupSaccCounts.perCondition(i).saccCounts);
end

for (i=1:configData.numConditions)        
    groupSaccProps(i)=nanmean(groupSaccCounts.perCondition(i).saccCounts);
    groupSaccPropsErr(i)=nanstd(groupSaccCounts.perCondition(i).saccCounts)/sqrt(size(groupData.session,2));
end

groupData.saccSummary.groupSaccProps=groupSaccProps;
groupData.saccSummary.groupSaccPropsErr=groupSaccPropsErr;


end