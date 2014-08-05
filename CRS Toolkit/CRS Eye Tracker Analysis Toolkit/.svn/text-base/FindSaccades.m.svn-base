function [EyeData,cancel]=FindSaccades(EyeData, inSaccParams,inBlinkParams,segmentIndex)
% find saccades and blinks in CRS data based on criteria defined in inSaccParams
% inputs

% inSaccParams - parameters for identifying saccades
% inBlinkParams
% index of segment

% find index of first point where velocity exceeds velocity threshold

    
    startIndex=0; % point to start looking from
    %maxIndex=size(EyeData.segment(segmentIndex).velVector,1); % size of velocity vector
    EyeData.segment(segmentIndex).blinkCount=0;
    maxIndex=EyeData.segment(segmentIndex).totalSamples;
    
    if (size(EyeData.segment(segmentIndex).velX,1)<EyeData.segment(segmentIndex).totalSamples)
        maxIndex=size(EyeData.segment(segmentIndex).velX,1);
    end
    
    global f;
    global configData;
    f=-1;
    if (configData.useGui.findSaccs==true)
        f=figure;
    end
    
    saccCount=0;
    falseSaccCount=0;
    movedCount=0;
    global classAs;
    cancel=false;
    while (startIndex<maxIndex) 
        details='';
        % get first value which meets threshold criterion for an event by
        % looking at velocity
        eventStart=find(abs(EyeData.segment(segmentIndex).velX(startIndex+1:maxIndex))>inSaccParams.velThreshold,1);

        if (startIndex>=maxIndex)
            break;
        end
        
        if (isempty(eventStart)) % no eye movement found, we are done
            break;
        else % look for end point 
            eventStart=startIndex+eventStart;
            eventTime=EyeData.segment(segmentIndex).sampleTime(eventStart);
        
            if (eventStart>=maxIndex) % end of the data
                break;
            end
            
%            if (EyeData.segment(segmentIndex).velX(eventStart)>0)
                eventEnd=find(abs(EyeData.segment(segmentIndex).velX(eventStart+1:maxIndex))<inSaccParams.velThreshold,1); % check when velocity drops below threshold again
%            else
%                eventEnd=find(EyeData.segment(segmentIndex).velX(eventStart+1:maxIndex)>=0,1);
%            end
            
            if (isempty(eventEnd))
                eventEnd=maxIndex; % continues up until the last sample
                startIndex=eventEnd;
            else % determine read end point
                eventEnd=eventStart+eventEnd-1;

                startIndex=eventEnd; % start after the last event has finished

                % because we overlook NaN's check if there is a NaN before the
                % detected end of an event - if so then event is most likely
                % an artifact before a blink or loss of signal

                findNaN=find(isnan(EyeData.segment(segmentIndex).velX(eventStart+1:maxIndex)),1);
                if (~isempty(findNaN))
    
                    findNaN=eventStart+findNaN-1; % get real position of NaN
                
                    if (findNaN<eventEnd)
                        eventEnd=findNaN-1;
                    end
                end

            end
        end
        
        if (eventStart==eventEnd)
            continue;
        end
        
        eventStartTime=EyeData.segment(segmentIndex).sampleTime(eventStart);
        eventEndTime=EyeData.segment(segmentIndex).sampleTime(eventEnd);
        eventDur=eventEndTime-eventStartTime;
        
        durThreshold=inSaccParams.durThreshold/1000; % in seconds

        if (eventDur < durThreshold)
            continue; % movement was not long enough to be real
        end


        maxVelocity=max(EyeData.segment(segmentIndex).velX(eventStart:eventEnd));
        minVelocity=min(EyeData.segment(segmentIndex).velX(eventStart:eventEnd));
        
        meanVelocity=nanmean(EyeData.segment(segmentIndex).velX(eventStart:eventEnd));

        peakVelocity=max(abs(EyeData.segment(segmentIndex).velX(eventStart:eventEnd)));

        velRatio=abs(meanVelocity/peakVelocity);
        
        diffAngleX=EyeData.segment(segmentIndex).angleX(eventEnd)-EyeData.segment(segmentIndex).angleX(eventStart);

        % compare amplitudes and durations between actual and expected for
        % a saccade
        
        eventAmp=abs(diffAngleX);
        
        if (eventAmp < inSaccParams.ampThreshold)
            continue; % saccade amplitude not big enough
        end

        eventDurms=eventDur*1000;
        expectedAmp=((eventDurms)-21)/2.2; % from main sequence equation
        if (expectedAmp<0) % duration is less than 22ms - from main sequence leads to a negative visual angle
            expectedAmp=0; % set amplitude to 0
        end

        expectedDur=2.2*eventAmp + 21; % main sequence equation

        if (eventDurms < expectedDur)
            pctDur=(eventDurms/expectedDur)*100;
        else
            pctDur=(expectedDur/eventDurms)*100;
        end

        if (eventAmp < expectedAmp)
            pctAmp=(eventAmp/expectedAmp)*100;
        else
            pctAmp=(expectedAmp/eventAmp)*100;
        end

        
        checkVisually=false;

        % check amplitudes and durations to determine if movement is a
        % blink or a saccade or something else
                
        if (pctAmp>inSaccParams.saccMainSeqPercent) && (pctDur>inSaccParams.saccMainSeqPercent) % both duration and amplitude are within threshold of main sequence parameters
            if (velRatio>0.5) && (velRatio<0.75)% velocity ratios are also within range so this is most likely a saccade
                classAs='S';
            else
                classAs='S'; % might be a saccade but best to check it visually first
                checkVisually=true;
            end
        elseif (pctDur > inSaccParams.saccMainSeqPercent) % durations are within threshold of expected
            if (velRatio>0.5) && (velRatio<0.75) 
                classAs='S';
                checkVisually=true;
            else
                classAs='U'; % not definitively a saccade
%                checkVisually=true;
            end
        elseif (pctAmp>inSaccParams.saccMainSeqPercent) % amplitudes are within threshold of expected
            if (velRatio>0.5) && (velRatio<0.75)
                classAs='S';
                checkVisually=true;
            else
                classAs='U';
%                checkVisually=true;
            end
        elseif(pctDur>inSaccParams.saccMainSeqPctCheck)
            if (velRatio>0.5) && (velRatio<0.75)
                classAs='U';
                checkVisually=true;
            else
                classAs='U';
            end
        else
            classAs='N';
        end

        % if peak velocity is higher than equivalent to a saccade of a
        % specific velocity (e.g. for amplitude of 15 degrees peak velocity is abour 350 deg/s
        % then consider the eye movement a blink instead

        if (peakVelocity>inSaccParams.maxPeakVelocity) % movement has higher velocity than max peak velocity of a saccade
            if (classAs~='S')
                classAs='B'; % mark as a blink
            else
                checkVisually=true;
                classAs='B'; % mark as a blink but check visually
            end
        end

        if(eventAmp>inBlinkParams.minBlinkAmplitude) % movement has greater amplitude than minimum blink amplitude
            if (classAs~='S')
                classAs='B';
            else
                classAs='B';
                checkVisually=true;
            end
        end
        
%{        
        if (classAs~='S') && (checkVisually==false) && (peakVelocity>inSaccParams.maxPeakVelocity)
            classAs='B'; % class as a blink
        end
        
        if ((classAs~='S') && (classAs~='B')) && (checkVisually==false) && (eventAmp>inBlinkParams.minBlinkAmplitude)
            classAs='B';
        else
            classAs='U';
            checkVisually=true;
        end
%}
        if (isfield(configData.useGui,'skipInter'))
            if (configData.useGui.skipInter==true)
                checkVisually=false; % override
            end
        end

        if (checkVisually==true)  || (configData.useGui.findSaccs==true)
            if (classAs=='S')
                details=sprintf('Possible saccade - %3.2f %% of expected duration\n%3.2f %% of expected amplitude\nVelocity ratio %3.2f',pctDur,pctAmp,velRatio);
            else
                details='';
            end
        end

        
        if (classAs=='B')       
            % movement is most probably a blink 

            % following a blink the data is most likely to be unreliable
            % so we need to exclude data following a blink 

            % determine when the blink actually ends

            % look at previous sequence from before the blink and get a mean eye
            % position
            blinkStartIndex=eventStart;
            blinkWindow=inBlinkParams.blinkWindow/1000;
            blinkEndIndex=eventEnd;

            
            beforeBlinkTime=EyeData.segment(segmentIndex).sampleTime(eventStart)-blinkWindow;
            % look for a sequence where standard deviation is within 0.5
            % degrees - hopefully will put us behind any humps prior to the
            % blink

            t=EyeData.segment(segmentIndex).sampleTime;
            beforeBlinkIndex=min(find(t-beforeBlinkTime>=0));
            
            foundBeforeBlink=false;
            noBeforeWindow=false;
            endLoop=false;
            while (endLoop==false)
                % check standard deviation 
                stdBefore=nanstd(EyeData.segment(segmentIndex).angleX(beforeBlinkIndex:blinkStartIndex));
                if (stdBefore<0.1)
                    foundBeforeBlink=true;
                    endLoop=true;
                elseif (isnan(stdBefore))
                    noBeforeWindow=true;
                    endLoop=true;
                else
                    % move window backwards
                    beforeBlinkIndex=beforeBlinkIndex-1;
                    blinkStartIndex=blinkStartIndex-1;
                end
                
                if (beforeBlinkIndex<=1) % beginning of the data
                    beforeBlinkIndex=1;
                    noBeforeWindow=true;
                    endLoop=true;
                end
                
                if (blinkStartIndex<=1)
                    blinkStartIndex=1;
                    noBeforeWindow=true;
                    endLoop=true;
                end
            
                blinkDur=EyeData.segment(segmentIndex).sampleTime(blinkEndIndex)-EyeData.segment(segmentIndex).sampleTime(blinkStartIndex);
                if (blinkDur*1000>inBlinkParams.maxBlinkThreshold)
                    endLoop=true;
                end
                
            end

            % determine mean position before the blink
            if (noBeforeWindow==false)
                meanBefore=nanmean(EyeData.segment(segmentIndex).angleX(beforeBlinkIndex:blinkStartIndex));

                % use a moving window until the mean eye position is within
                % threshold of the position prior to the blink 
                while (blinkEndIndex<=maxIndex)
                    endWindowTime=EyeData.segment(segmentIndex).sampleTime(blinkEndIndex)+blinkWindow;
                    if (endWindowTime>EyeData.segment(segmentIndex).sampleTime(maxIndex))
                        endWindowTime=EyeData.segment(segmentIndex).sampleTime(maxIndex);
                    end

                    endWindowIndex=min(find([EyeData.segment(segmentIndex).sampleTime]-endWindowTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 
                    meanAfter=nanmean(EyeData.segment(segmentIndex).angleX(blinkEndIndex:endWindowIndex));
                    if (abs(meanAfter-meanBefore)<inBlinkParams.postBlinkMinThreshold)
                        break;
                    else
                        blinkEndIndex=blinkEndIndex+1;
                        endWindowIndex=endWindowIndex+1;
                        if (endWindowIndex>=maxIndex)
                            break;
                        end
                        
                    end
                    
                    blinkDur=EyeData.segment(segmentIndex).sampleTime(blinkEndIndex)-EyeData.segment(segmentIndex).sampleTime(blinkStartIndex);
                    if (blinkDur*1000>inBlinkParams.maxBlinkThreshold)
                        break;
                    end
                end
            else
                endWindowTime=EyeData.segment(segmentIndex).sampleTime(blinkEndIndex)+blinkWindow;
                if (endWindowTime>EyeData.segment(segmentIndex).sampleTime(maxIndex))
                    endWindowTime=EyeData.segment(segmentIndex).sampleTime(maxIndex);
                end
                endWindowIndex=min(find([EyeData.segment(segmentIndex).sampleTime]-endWindowTime>=-0.0001,1)); % -0.0001 to avoid rounding problems due to high precision which take us to the next index 
            end
            
            % finally check the std deviation of position and increment the window until
            % deviation is below threshold over a certain amount of time
            %  or we hit maximum duration for a blink

            endBlink=false;
%            sampleWindow=inBlinkParams.postBlinkVelDuration/EyeData.segment(segmentIndex).sampleDiff;

            while (endBlink==false)
                endBlink=true;
                stdPos=nanstd(EyeData.segment(segmentIndex).angleX(blinkEndIndex:endWindowIndex));
                if (stdPos > inBlinkParams.postBlinkPosVariation)
                    blinkEndIndex=blinkEndIndex+1; % move to the next point and retry
                    endWindowIndex=endWindowIndex+1;
                    endBlink=false;
                end

                % check duration if we are bigger than maxThreshold
                % then cut the blink off anyway
                blinkDur=EyeData.segment(segmentIndex).sampleTime(blinkEndIndex)-EyeData.segment(segmentIndex).sampleTime(blinkStartIndex);
                if (blinkDur*1000>inBlinkParams.maxBlinkThreshold)
                    endBlink=true;
                end
            end

            % move event accordingly
            eventEnd=blinkEndIndex;
            eventStart=blinkStartIndex;
            eventEndTime=EyeData.segment(segmentIndex).sampleTime(eventEnd);
            eventStartTime=EyeData.segment(segmentIndex).sampleTime(eventStart);
            startIndex=eventEnd;
        end

        EyeData.segment(segmentIndex).tagType(eventStart:eventEnd)=classAs;
        
        % plot the data
        
        % find the index for time closest to inSaccParams.saccSequenceExtraTime before and after the
        % saccade sequence
        if ((configData.useGui.findSaccs==true) || (checkVisually==true))
            extraTime=inSaccParams.saccSequenceExtraTime/1000;
    %        extraTime=round(extraTime/1000)*1000;

            seqStartTime=eventStartTime-extraTime;
            if (seqStartTime<=0)
                seqStartIndex=1;
            else
                t=EyeData.segment(segmentIndex).sampleTime;
                seqStartIndex=min(find(t-seqStartTime>=0,1));
                if (EyeData.segment(segmentIndex).sampleTime(seqStartIndex)> seqStartTime)
                    seqStartIndex=seqStartIndex-1;
                end

                if (seqStartIndex <1)
                    seqStartIndex=1;
                end
            end

            seqEndTime=eventEndTime+extraTime;
            if (seqEndTime >= EyeData.segment(segmentIndex).sampleTime(maxIndex))
                seqEndIndex=maxIndex;
            else
                t=[EyeData.segment(segmentIndex).sampleTime];
                t1=abs(t-seqEndTime);
                seqEndIndex=find(t1==min(t1),1);
                
                if (EyeData.segment(segmentIndex).sampleTime(seqEndIndex)<seqEndTime)
                    seqEndIndex=seqEndIndex+1;
                end

                if (seqEndIndex>maxIndex)
                    seqEndIndex=maxIndex;
                end
            end
            
            
            if (f==-1) % we're not showing every blink/saccade just ones which are suspect
                f=figure;
            end
            
            figure(f);

            % produce a plot of the data around the found sequence
            classAs='C';
            [classButtons, mainSeqButton,cursor1,cursor2]=plotSaccSequence(f, EyeData,segmentIndex, seqStartIndex, seqEndIndex, eventStartTime,eventEndTime,maxVelocity,minVelocity);
            set(mainSeqButton,'callback',@plotMainSequence);

            set(classButtons,'SelectionChangeFcn',@handleButtons);
            set(classButtons,'SelectedObject',[]);  % No selection
            set(classButtons,'Visible','on');
            hold off;
            if (~strcmp(details,''))
                uiwait(Msgbox(details,'Suspected saccade detected, please classify','modal'));
            end
            uiwait(f);

            if (ishandle(f))
                % get cursor positions
                cursor1pos=getcursorlocation(f,cursor1);
                cursor2pos=getcursorlocation(f,cursor2);

                % switch cursor positions if they are reversed
                if cursor1pos > cursor2pos
                    temp=cursor1pos;
                    cursor1pos=cursor2pos;
                    cursor2pos=temp;
                end

                deletecursor(f,cursor1);
                deletecursor(f,cursor2);

                 % determine if cursor position was moved
                 moved=false;
                
                if (EyeData.segment(segmentIndex).sampleTime(eventStart)~=cursor1pos)
                    moved=true;
                end
                
                if (EyeData.segment(segmentIndex).sampleTime(eventEnd)~=cursor2pos)
                    moved=true;
                end
                
                 % find nearest start and end positions based on sample time
                 if (moved==true)
                     t=[EyeData.segment(segmentIndex).sampleTime];
                     
                     newEventStart=min(find(t-cursor1pos>=0,1));
                     
                     newEventEnd=min(find(t-cursor2pos>=0,1));
                     if (EyeData.segment(segmentIndex).sampleTime(newEventEnd)~=cursor2pos)
                         newEventEnd=newEventEnd-1;
                     end
                         
                     if (newEventStart~=eventStart)
                         moved=true;
                     end

                     if (newEventEnd~=eventEnd)
                         moved=true;
                     end

                     if (moved==true)
                         movedCount=movedCount+1;
                     end
                     
                     eventStart=newEventStart;
                     eventEnd=newEventEnd;
                 end
                 
            end
        end
        
        cancel=false;
        EyeData.segment(segmentIndex).tagType(eventStart:eventEnd)='N';
        
        switch  (classAs)
        case ''
            if (ishandle(f))
                close(f);
            end
            cancel=true;
            break; % cancel
        case 'C' 
            if (ishandle(f))
                close(f);
            end
            cancel=true;
            break; % cancel
        case 'S'
            saccCount=saccCount+1;
            EyeData.segment(segmentIndex).tagType(eventStart:eventEnd)=classAs;
        case 'U'
            falseSaccCount=falseSaccCount+1;
            EyeData.segment(segmentIndex).tagType(eventStart:eventEnd)=classAs;
        case {'B','L'}
            % sometimes blinks will override saccades which might have
            % shown up at the beginning of the blink
            % check if there are any tags for saccades and reduced saccade
            % count appropriately
            
            saccTags=find(EyeData.segment(segmentIndex).tagType(eventStart:eventEnd)=='S');
            if (length(saccTags>0))
                saccCount=saccCount-1;
            end
            
            % check we don't have any previous positions which are still
            % marked as a saccade - extend the blink backwards if we do
            
            if (EyeData.segment(segmentIndex).tagType(eventStart)=='S')
                replaceSacc=false;
                replIndex=eventStart-1;
                while (replaceSacc==false)
                    if (EyeData.segment(segmentIndex).tagType(replIndex)=='S')
                        replIndex=replIndex-1;
                    else
                        replaceSacc=true;
                    end
                end
                eventStart=replIndex;
            end
                        
            EyeData.segment(segmentIndex).tagType(eventStart:eventEnd)=classAs;
            % NaN any data which is marked as a blink
            EyeData.segment(segmentIndex).angleX(eventStart:eventEnd)=NaN;
            EyeData.segment(segmentIndex).velX(eventStart:eventEnd)=NaN;
            if (classAs=='B')
                EyeData.segment(segmentIndex).blinkCount=EyeData.segment(segmentIndex).blinkCount+1;
            end
        end

    end

    if (ishandle(f))
        close (f);
        waitfor(f);
    end

    EyeData.segment(segmentIndex).saccCount=saccCount;
%    if (configData.useGui.dispSaccSummary==1)
%        msg=sprintf('For Run: %d\nNumber of saccades detected: %d Number of false positives %d Number of moved saccades %d',EyeData.segment(segmentIndex).realSegmentIndex,saccCount,falseSaccCount,movedSaccCount);
%        uiwait(msgbox(msg,'Saccades','modal'));
%    end
    
    if (configData.useGui.dispBlinkSummary==true)
        if (~ishandle(f))
            f=figure;
        end

        % plot original data and data with blinks excluded for comparison purposes
        figure(f);
        clf(f);
        set(f,'position',[100,100,900,800]);

        set(f,'name',sprintf('Blink summary for run %d',segmentIndex));
        subplot(2,1,1);
        plot(EyeData.segment(segmentIndex).sampleTime(1:maxIndex),EyeData.segment(segmentIndex).origAngleX(1:maxIndex),'b.-');

        xlabel('Time/s');
        ylabel('Position/degrees');
        legend('X position');
        txt=sprintf('Eye position before removing blinks for run: %d',EyeData.segment(segmentIndex).realSegmentIndex);
        title(txt);

        ylimit=ylim();
        subplot(2,1,2)
        plot(EyeData.segment(segmentIndex).sampleTime(1:maxIndex),EyeData.segment(segmentIndex).angleX(1:maxIndex),'b.-');

        xlabel('Time/s');
        ylabel('Position/degrees');
        legend('X position');
        txt=sprintf('Eye position after removing blinks for run: %d',EyeData.segment(segmentIndex).realSegmentIndex);
        title(txt);
        ylim(ylimit); % use same scale as before removing blinks
        uiwait(f);

        if (ishandle(f))
            close(f);
            waitfor(f);
        end
    end    

    function plotMainSequence(hObject,eventData,handles)
        f1=figure;
        cursor1pos=getcursorlocation(f,cursor1);
        cursor2pos=getcursorlocation(f,cursor2);

        % switch cursor positions if they are reversed
        if cursor1pos > cursor2pos
            temp=cursor1pos;
            cursor1pos=cursor2pos;
            cursor2pos=temp;
        end

        dur=(cursor2pos-cursor1pos)*1000;
        plotAmpDur(f1,diffAngleX,dur);
        uiwait(f1)
        if(ishandle(f1))
            close(f1);
            waitfor(f1);
        end
    end

    
end

