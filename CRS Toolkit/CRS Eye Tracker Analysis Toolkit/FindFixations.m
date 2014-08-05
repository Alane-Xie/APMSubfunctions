function EyeData=FindFixations(EyeData,fixParams,blinkParams,segmentIndex)

%find fixations according to specific criteria

% this follows the algorithm defined in the ASL 6000 EyeNal manual version
% 1.41 19/01/07

%parameters 
% EyeData
% fixation parameters
% blink parameters to eliminate blinks and loss of signal from fixation
% data
% index of segment to process
global configData;

startIndex=1; 
windowSize=fixParams.fixTimeWindow/1000; %convert milliseconds to seconds
%maxIndex=size(EyeData.segment(segmentIndex).recordNo(:),1); % size of raw data
maxIndex=EyeData.segment(segmentIndex).totalSamples;
fixations=[];
fixIndex=1;
fixCount=0;
f=-1;
if (configData.useGui.findFix==true)
    f=figure;
end

while (startIndex<maxIndex)
    
    fixationIndices=[]; % reset fixation indices
    
    % stage 1
    
    % get chunk of data which encompasses windowSize in duration starting
    % from startIndex - truncate window at loss of signal and exclude
    % positions which denote a blink
    
    startTime=EyeData.segment(segmentIndex).sampleTime(startIndex);
    endTime=startTime+windowSize;
    endIndex=min(find([EyeData.segment(segmentIndex).sampleTime]-endTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 
    
    if (isempty(endIndex)) 
        endIndex=maxIndex;
    end
    
    if (endIndex>maxIndex)
        endIndex=maxIndex;
    end
    
    % find any blinks in the data - blinks are still considered as part of
    % a fixation unless duration goes above maxBlinkThreshold which
    % constitutes loss of signal and any fixation is terminated - detection
    % of fixations continues after signal is resumed
    
    % if there is any loss of signal truncate the window
    
    findBlinks=true;
    
    excludeBlinkIndices=[];
    blinkStart=startIndex; % initialise blinkStart to beginning of window
    offset=1;
    while (findBlinks==true)
        
        offset=blinkStart;

        % check for loss of signal - truncate the window before the loss of
        % signal occurs
        lossStart=find(EyeData.segment(segmentIndex).tagType(startIndex:endIndex)=='L');
        if (~isempty(lossStart))
            lossStart=lossStart+startIndex-1;
            endIndex=lossStart-1;
            continue;
        end
        
        % check for saccade - truncate window before a saccade 
        
        saccStart=find(EyeData.segment(segmentIndex).tagType(startIndex:endIndex)=='S');
        if (~isempty(saccStart))
            saccStart=saccStart+startIndex-1;
            endIndex=saccStart-1;
            continue;
        end

        blinkStart=find(EyeData.segment(segmentIndex).tagType(blinkStart:endIndex)=='B',1);

        
        if (~isempty(blinkStart) ) % start of a blink
            % find real offset into data
            
            % nextBlinkStart is offset from blinkStart
            if (offset==1)
                blinkStart=blinkStart+startIndex-1; % find offset into real data
            else
                blinkStart=blinkStart+offset-1;
            end
            
            % find end of blink no matter where it is in the data
            blinkEnd=find(EyeData.segment(segmentIndex).tagType(blinkStart:maxIndex)~='B',1);
            
            if (isempty(blinkEnd))
                % blink goes over the end of the whole data so only analyse up to
                % start of the blink
                endIndex=blinkStart-1;
                break;
            else
                blinkEnd=blinkStart+blinkEnd-1; % get real position
                blinkEnd=blinkEnd-1; % because end of blink denotes when pupil diameter changes from 0 real end blink is one index back
               

                % look for NaN in the data
%                 findNaN=find(isnan(EyeData.segment(segmentIndex).pupilDiam(blinkStart+1:maxIndex)),1);
%                 if (~isempty(findNaN))
%     
%                     findNaN=blinkStart+findNaN-1; % get real position of NaN
%                 
%                     if (findNaN<blinkEnd)
%                         blinkEnd=findNaN-1;
%                     end
%                 end

                % get duration of blink
                blinkDur=EyeData.segment(segmentIndex).sampleTime(blinkEnd) - EyeData.segment(segmentIndex).sampleTime(blinkStart);
                if (blinkDur>blinkParams.maxBlinkThreshold)
                    % constitutes loss of signal and hence end of any fixation so only analyse up to the
                    % start of the blink
                    endIndex=blinkStart-1;
                    findBlinks=false;
                    break;
                else
                    if (blinkEnd > endIndex) % blink goes past end of the window
                        % extend the window to cover all values up to the end of the
                        % blink anyway - include one non blink value at the end
                        % otherwise the blink will never be closed!
                        endIndex=blinkEnd+1;
                        continue;
                    else
                        % exclude blink indices in the window
                        excludeBlinkIndices=[excludeBlinkIndices (blinkStart:blinkEnd)];
                        % look for next blink
                        blinkStart=blinkEnd+1; % search for next blink from here on
                        continue;

                    end
                end
            end
            
        else
            findBlinks=false; % no more blinks so we can look for fixations
            break;
        end
    end
        
    dataIndices=[startIndex:endIndex];
    
    % from the time window get all real indices which contain non-zero pupil
    % diameter
    validData=dataIndices(find((~ismember(dataIndices,excludeBlinkIndices))));
    
    if (isempty(validData)) % nothing in the window is valid as a fixation so we don't create any fixations
        startIndex=startIndex+1; % move window up by one point
        continue;
    end
    
    % get the data in this time window which is not a blink
    windowX=EyeData.segment(segmentIndex).angleX(validData);
    
    % first criterion
    % determine standard deviation over all samples in window 
    
    windowDevX=std(windowX);
    
    if (windowDevX > fixParams.fixBoundary1 )
        startIndex=startIndex+1; % move window up by one sample point
        continue; 
    end

    % define temporary fixation as the mean position over the time window
    tempFix.x=mean(windowX);
    tempFix.startIndex=startIndex;
    tempFix.endIndex=endIndex;
    
    % Stage 2
    
    % now we expand the window sample point by point skipping any points with a
    % pupil diameter of 0 or tagType of 'B' or 'L'

    % refTime=EyeData.segment(segmentIndex).sampleTime(endIndex);
    timeOutTime=0;
    maxTimeOutTime=fixParams.fixTimeThreshold/1000;
    
    % Stage 2 finishes when consecutive samples which do not pass the
    % criterion constitute a time period greater than the maxTimeOutTime
    
    fixationIndices=[validData];

    testIndices=[];
    
    while (timeOutTime< maxTimeOutTime) 
    
        foundBlink=true;
        endFixation=false;
        
        while (endFixation==false)
            endIndex=endIndex+1; % go to next point
            % check if it is part of a blink or loss of signal
            % for blinks carry on, for loss of signal truncate the fixation
            % at the point before it
            if (endIndex>maxIndex)
                endIndex=maxIndex;
                endFixation=true;
                break;
            end
            
            if (EyeData.segment(segmentIndex).tagType(endIndex)=='L')
                endIndex=endIndex-1;
                endFixation=true;
                break;
                % check for a saccade - break fixation at a saccade as well
            elseif (EyeData.segment(segmentIndex).tagType(endIndex)=='S')
                    endIndex=endIndex-1;
                    endFixation=true;
                    break;
            else % no loss of signal and not a blink or a saccade
                if (EyeData.segment(segmentIndex).tagType(endIndex)=='B') % part of a blink
                    % exclude blink
                    excludeBlinkIndices=[excludeBlinkIndices endIndex];

                    % for now we don't end a fixation at a blink - this may
                    % change however
                    
%                 blinkTime=blinkTime+(EyeData.segment(segmentIndex).sampleTime(endIndex)-refTime);
%                 refTime=EyeData.segment(segmentIndex).sampleTime(endIndex) % update refTime
%                 if blinkTime > blinkParams.maxBlinkThreshold %loss of signal end fixation before the blink
%                     endIndex=max(fixationIndices);
%                     endFixation=true;
%                     break;
%                 else
%                     % zero found but duration of consecutive zero's is less
%                     % than maxBlinkThreshold so for the moment just
%                     % continue
%                     continue;
%                 end
                else % next position is valid so check difference between fixation mean and next position
                    
                    nextX=EyeData.segment(segmentIndex).angleX(endIndex);
                    diffX=abs(tempFix.x-nextX); 
        
        
                    if (diffX <= fixParams.fixBoundary2 ) 
                        fixationIndices=[fixationIndices endIndex]; % include point in fixation
                        timeOutTime=0; % fixation continues and we discount any previously rejected positions
                        
                        % check any testIndices to see if they are within
                        % criterion 3 from the temporary fixation
                        
                        for (i=testIndices)
                            tryFixX=EyeData.segment(segmentIndex).angleX(i);
        
                            diffX=abs(tempFix.x-tryFixX);

                            if (diffX <=fixParams.fixBoundary3)
                                fixationIndices=[fixationIndices i];
                            end
                        end
                        testIndices=setdiff(testIndices,fixationIndices);
                    else
                        testIndices=[testIndices endIndex];
                        if (endIndex<maxIndex)
                            timeOutTime=timeOutTime+(EyeData.segment(segmentIndex).sampleTime(endIndex+1)-EyeData.segment(segmentIndex).sampleTime(endIndex));
                            if (timeOutTime>=maxTimeOutTime)
                                break;
                            end
                        else 
                            endFixation=true;
                        end
                            
                    end
                end
            end
        end

        if (endFixation==true)
            break;
        end
        
    end
    
    if (timeOutTime>=maxTimeOutTime)
    % stage 3 - we have n consecutive samples which do not pass stage 2
    % check if the mean of these samples is within boundary2 of the
    % temporary fixation
        meanLastChanceX=mean(EyeData.segment(segmentIndex).angleX(testIndices));

        lastdiffX=abs(tempFix.x-meanLastChanceX);

        if (lastdiffX<=fixParams.fixBoundary2 )
            % include indices
            fixationIndices=[fixationIndices testIndices];
        end
    end
    
    fixationIndices=sort(fixationIndices);
    
    %dedupe fixation indices
    dedupeFilter=[min(fixationIndices):max(fixationIndices)];
    fixationIndices=intersect(fixationIndices,dedupeFilter);
    
    fixDuration=EyeData.segment(segmentIndex).sampleTime(max(fixationIndices))-EyeData.segment(segmentIndex).sampleTime(min(fixationIndices));
    fixDuration=fixDuration*1000; % in milliseconds

    if (fixDuration<fixParams.fixDuration) 
        startIndex=max(fixationIndices)+1;
        continue;
    end
    
    % classify each position in the fixation
    
    EyeData.segment(segmentIndex).tagType(fixationIndices)='F';

    
    % plot x,y, positions for each point in the fixation
    if (configData.useGui.findFix==true)
        figure(f);
        plot(EyeData.segment(segmentIndex).sampleTime(fixationIndices),EyeData.segment(segmentIndex).angleX(fixationIndices)-tempFix.x,'b.-');
        uiwait(f);
        if (ishandle(f))
            close(f);
        end;
    end

    fixStartIndex=min(fixationIndices);
    fixEndIndex=max(fixationIndices);
    fixations(fixIndex).startIndex=fixStartIndex;
    fixations(fixIndex).endIndex=fixEndIndex;
    fixations(fixIndex).duration=EyeData.segment(segmentIndex).sampleTime(fixEndIndex) - EyeData.segment(segmentIndex).sampleTime(fixStartIndex);
    fixIndex=fixIndex+1;
    
    % start next window from end of previous fixation
    startIndex=max(fixationIndices)+1;
    
end

nonFix=size(find(EyeData.segment(segmentIndex).tagType(1:maxIndex)=='N'),1);
nonFixPct=(nonFix/maxIndex)*100;

EyeData.segment(segmentIndex).fixations=fixations;
EyeData.segment(segmentIndex).fixCount=size(fixations,2);
EyeData.segment(segmentIndex).nonFixPct=nonFixPct;



end
