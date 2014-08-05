function EyeData=TruncateOnStimLength(EyeData,segmentIndex)

% NaN out data on each trial after stimulus has been displayed

% loop through all trials in a segment by condition
for (i=1:size(EyeData.segment(segmentIndex).trialsPerCondition,2))

    if (EyeData.stimLengthPerCond(i)~=EyeData.trialLengthPerCond(i)) % stim length for this condition is not the same as trial length

        for (j=1:size(EyeData.segment(segmentIndex).trialsPerCondition(i).startIndex,2))
            startTrialIndex=EyeData.segment(segmentIndex).trialsPerCondition(i).startIndex(j);
            startTime=EyeData.segment(segmentIndex).sampleTime(startTrialIndex);
            endTime=startTime+(EyeData.stimLengthPerCond(i)/1000); % convert to seconds
            endStimIndex=min(find([EyeData.segment(segmentIndex).sampleTime]-endTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 
            endStimIndex=endStimIndex+1; % start one sample after the end of the stimulus
            endTrialIndex=EyeData.segment(segmentIndex).trialsPerCondition(i).endIndex(j);
            % NaN out velocity for everything from endStimIndex+1 to endTrialIndex;
            EyeData.segment(segmentIndex).velX(endStimIndex:endTrialIndex)=NaN;
            EyeData.segment(segmentIndex).tagType(endStimIndex:endTrialIndex)='N'; 
            EyeData.segment(segmentIndex).angleX(endStimIndex:endTrialIndex)=NaN;
        end
    end
end

% check by plotting velocity data
%{
f=figure;

plot(EyeData.segment(segmentIndex).velTime,EyeData.segment(segmentIndex).velVector)
uiwait;
if (ishandle(f))
    close(f);
    waitfor(f);
end
%}
end