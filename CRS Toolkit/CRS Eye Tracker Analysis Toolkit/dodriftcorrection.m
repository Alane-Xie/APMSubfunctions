function EyeData=DoDriftCorrection(EyeData)

global configData;

for (i=1:size(EyeData.segment,2))
    maxIndex=size(EyeData.segment(i).recordNo,1);
    for (j=1:size(EyeData.segment(i).trialsPerCondition,2))
        for (k=1:size(EyeData.segment(i).trialsPerCondition(j).startIndex,2))
            
            startIndex=EyeData.segment(i).trialsPerCondition(j).startIndex(k);
            endIndex=EyeData.segment(i).trialsPerCondition(j).endIndex(k);
            startTime=EyeData.segment(i).sampleTime(startIndex);

            beforeTime=startTime-0.05; % look at previous 50ms
            afterTime=startTime+0.05;
            t=EyeData.segment(i).sampleTime;
            % find indices for beforeTime and afterTime
            if (beforeTime<0)
                beforeTime=0;
            end
            
            if (afterTime>EyeData.segment(i).sampleTime(maxIndex))
                afterTime=EyeData.segment(i).sampleTime(maxIndex);
            end
            
            beforeIndex=min(find(t-beforeTime>=0,1));
            afterIndex=min(find(t-afterTime>=0,1));
            driftStart=startIndex;
            if (EyeData.segment(i).sampleTime(afterIndex)~=afterTime)
                afterIndex=afterIndex-1;
            end
            
            % include only indices which are not marked as blink or loss 
            doDrift=false;
            while (doDrift==false)
                indices=union([beforeIndex:driftStart],[driftStart:afterIndex]);

                saccIndices=find(EyeData.segment(i).tagType(indices)=='S');
                blinkIndices=find(EyeData.segment(i).tagType(indices)=='B');
                lossIndices=find(EyeData.segment(i).tagType(indices)=='L');
                unkIndices=find(EyeData.segment(i).tagType(indices)=='U');
                
                exclIndices=union(saccIndices,blinkIndices);
                exclIndices=union(exclIndices,lossIndices);
                exclIndices=union(exclIndices,unkIndices);
                
                useIndices=setdiff(indices,indices(exclIndices));
            
                if (length(useIndices)<(length(indices))) % 
                    % move forward until all indices are available 
                    beforeIndex=beforeIndex+1;
                    driftStart=driftStart+1;
                    afterIndex=afterIndex+1;
                else
                    doDrift=true;
                end
            end
            
            indices=useIndices;
            driftX=median(EyeData.segment(i).origAngleX(indices));
            EyeData.segment(i).angleX(startIndex:endIndex)=EyeData.segment(i).angleX(startIndex:endIndex)-driftX;
        end
    end

    % changed the way we do drift correction so this is probably redundant
    % now
%{                
            doDrift=false;
            
            beforeStart=startIndex;
            afterStart=startIndex;
            
            % check for drift correction 
            
            indices=union([beforeIndex:beforeStart],[afterStart:afterIndex]);
            
            % include only indices which are not marked as blink or loss etc. - i.e.

            useIndices=find(EyeData.segment(i).tagType(indices)=='N');
            
            indices=indices(useIndices);
            if (~isempty(indices))
                driftX=nanmedian(EyeData.segment(i).origAngleX(indices));
                %disp(sprintf('Drift x : %3.2f',driftX));
                if (abs(driftX)<=2) % within 2 degrees so not at a blink or saccade etc. just do correction
                    EyeData.segment(i).angleX(startIndex:endIndex)=EyeData.segment(i).origAngleX(startIndex:endIndex)-driftX;
                    
                else % might be a blink or saccade near trial boundary so we need to identify a "safe" place to do the correction from
                    while (doDrift==false)

                        % move window backwards until we have a stable sequence
                        if (beforeIndex<=0)
                            beforeIndex=1;
                        end
                        
                        if (beforeStart<=0)
                            beforeStart=0;
                        end
                        
                        stdBefore=nanstd(EyeData.segment(i).origAngleX(beforeIndex:beforeStart));
                        while(stdBefore>0.5)
                            beforeIndex=beforeIndex-1;
                            beforeStart=beforeStart-1;
                            if (beforeIndex<=0)
                                break;
                            end
                            stdBefore=nanstd(EyeData.segment(i).origAngleX(beforeIndex:beforeStart));
                        end

                        % move window forwards likewise
                        stdAfter=nanstd(EyeData.segment(i).origAngleX(afterStart:afterIndex));                
                        while(stdAfter>0.5)
                            afterIndex=afterIndex+1;
                            afterStart=afterStart+1;
                            if (afterStart>=maxIndex)
                                break;
                            end
                            stdAfter=nanstd(EyeData.segment(i).origAngleX(afterStart:afterIndex));
                        end

                        if (beforeIndex<0)
                            beforeIndex=[];
                            beforeStart=[];
                        end

                        if (afterStart>=maxIndex)
                            afterStart=[];
                            afterIndex=[];
                        end

                        % check medians are within a threshold of each other

                        medBefore=nanmedian(EyeData.segment(i).origAngleX(beforeIndex:beforeStart));
                        medAfter=nanmedian(EyeData.segment(i).origAngleX(afterStart:afterIndex));

                        if (isnan(medBefore)) % nothing to compare before just use after window
                            doDrift=true;
                        end

                        if (isnan(medAfter)) % nothing to compare after just use before window
                            doDrift=true;
                        end

                        if (abs(medAfter-medBefore)<=0.05) % within 0.05 degrees visual angle
                            doDrift=true;
                        else
                            % move the window furthest away from fixation

                            if (abs(medBefore)>abs(medAfter))
                                beforeIndex=beforeIndex-1;
                                beforeStart=beforeStart-1;
                            else
                                afterIndex=afterIndex+1;
                                afterStart=afterStart+1;
                            end
                        end

                    end

                    % all indices
                    indices=union([beforeIndex:beforeStart],[afterStart:afterIndex]);

                    % include only indices which are not marked as blink or loss etc. - i.e.

                    useIndices=find(EyeData.segment(i).tagType(indices)=='N');

                    indices=indices(useIndices);
                    if (~isempty(indices))
                        driftX=nanmedian(EyeData.segment(i).origAngleX(indices));
                        %disp(sprintf('Adjusted drift x : %3.2f',driftX));
                        EyeData.segment(i).angleX(startIndex:endIndex)=EyeData.segment(i).origAngleX(startIndex:endIndex)-driftX;
%                         f=figure;
%                         plot(EyeData.segment(i).sampleTime(startIndex:endIndex),EyeData.segment(i).origAngleX(startIndex:endIndex))
%                         hold on;
%                         plot(EyeData.segment(i).sampleTime(startIndex:endIndex),EyeData.segment(i).angleX(startIndex:endIndex),'r')
%                         uiwait(f);
%                         if (ishandle(f))
%                             close(f);
%                             waitfor(f);
%                         end

                    end
                end
            end
        end
end
%}
end

if (configData.useGui.dispDriftSummary==1)
    for (i=1:size(EyeData.segment,2))
        f=figure;
        set(f,'units','pixels');
        set(f,'position',[50 25 1000 925]);
        
        subplot(3,1,1);
        plot(EyeData.segment(i).sampleTime,EyeData.segment(i).origAngleX,'b-');
        title(sprintf('Pre drift correction X position for run %d',i));
        xlabel('Time/s');
        ylabel('Position/degrees');

        subplot(3,1,2);

        plot(EyeData.segment(i).sampleTime,EyeData.segment(i).angleX,'r-');
        title(sprintf('Post drift correction X position for run %d',i));
        xlabel('Time/s');
        ylabel('Position/degrees');

        subplot(3,1,3);
        plot(EyeData.segment(i).sampleTime,EyeData.segment(i).origAngleX-EyeData.segment(i).angleX,'r-');
        title(sprintf('Post drift correction X position for run %d',i));
        xlabel('Time/s');
        ylabel('Position/degrees');

        uiwait(f);
        
        if (ishandle(f))
            close(f);
            waitfor(f);
        end
        
    end
end