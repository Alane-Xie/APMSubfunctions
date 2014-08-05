function EyeData=ProcessSaccades(EyeData)

% process ASL data extracting saccades which have been tagged

% parameters EyeData structure

% process data for saccade events, 
global configData;

Saccades=[];

numConds=configData.numConditions;%size(EyeData.segment(1).conditionValues,2);
condCount(1:numConds)=0;

% define saccade structure format

saccadeStruct=struct('segment',[],'saccStartIndex',[],'saccEndIndex',[],'saccDuration',[],'saccAmpX',[]);
Saccades.perCondition=struct('count',0,'Saccade',saccadeStruct);

for (i=1:numConds)
    Saccades.perCondition(i).count=0;
end

% loop through each segment
for (i=1:size(EyeData.segment,2))

    if (EyeData.segment(i).include==true)
        startIndex=1;

        % evaluate condition for each sample in the saccade

        maxIndex=EyeData.segment(i).totalSamples;
    %    maxIndex=size(EyeData.segment(i).sampleTime,1);
        while (startIndex<maxIndex)
            % search for start tagType
            saccStartIndex=find(EyeData.segment(i).tagType(startIndex:maxIndex)=='S',1);

            if (isempty(saccStartIndex)) % go onto the next segment
                break;
            else
                saccStartIndex=startIndex+saccStartIndex-1;
            end

            saccEndIndex=find(EyeData.segment(i).tagType(saccStartIndex:maxIndex)~='S',1);
            if (isempty(saccEndIndex))
                saccEndIndex=maxIndex;
            else
                saccEndIndex=saccStartIndex+saccEndIndex-1; % get real end index for saccade
                saccEndIndex=saccEndIndex-1; % subtract 1 to get end of saccade
            end

            % get condition count for each condition
            for (j=1:configData.numConditions)
                condCount(j)=size(find(EyeData.segment(i).condition(saccStartIndex:saccEndIndex)==j),2);
            end

            maxCond=max(condCount);
            condIndex=find(condCount==maxCond);
            
            if (size(condIndex,2)>1)
                rand('twister',sum(100*clock))
                if (rand<0.5)
                    condIndex=condIndex(1);
                else
                    condIndex=condIndex(2);
                end
            end

            Saccades.perCondition(condIndex).count=Saccades.perCondition(condIndex).count+1;
            
            count=Saccades.perCondition(condIndex).count;
            
            
            Saccades.perCondition(condIndex).Saccade(count).segment=i;
            Saccades.perCondition(condIndex).Saccade(count).saccStartIndex=saccStartIndex;
            Saccades.perCondition(condIndex).Saccade(count).saccEndIndex=saccEndIndex;
            Saccades.perCondition(condIndex).Saccade(count).saccDuration=EyeData.segment(i).sampleTime(saccEndIndex)-EyeData.segment(i).sampleTime(saccStartIndex);

            
            
            % get amplitude
            saccStartX=EyeData.segment(i).angleX(saccStartIndex);
            saccEndX=EyeData.segment(i).angleX(saccEndIndex);

            saccDiffX=saccEndX-saccStartX;
            Saccades.perCondition(condIndex).Saccade(count).saccAmpX=saccDiffX;
            
            startIndex=saccEndIndex+1;
        end

        if (configData.useGui.dispSaccSummary==true)
            f=figure;
            set(f,'units','pixels')
            set(f,'position',[50 25 1000 925]);


            % plot x positional data
            plot(EyeData.segment(i).sampleTime,EyeData.segment(i).angleX,'-');
            hold on
            % plot all saccades in this segment regardless of condition
            for (k=1:size(Saccades.perCondition,2))
                for(l=1:Saccades.perCondition(k).count)
                    if (Saccades.perCondition(k).Saccade(l).segment==i) % only plot saccades in this segment
                        startIndex=Saccades.perCondition(k).Saccade(l).saccStartIndex;
                        endIndex=Saccades.perCondition(k).Saccade(l).saccEndIndex;
                        plot (EyeData.segment(i).sampleTime(startIndex:endIndex),EyeData.segment(i).angleX(startIndex:endIndex),'-r');
                    end
                end
            end

            title('Saccades detected (x-axis)');
            xlabel('Time/s');
            ylabel('Position/degrees');

            uiwait(f);
            if (ishandle(f))
                close(f);
                waitfor(f);
            end
        end
    end
    %}
end

EyeData.saccades=Saccades;

conditions=configData.conditions;

ampCounts=struct('X',[]);
ampProps=struct('X',[]);
binsX=[-10:0.5:10];
 
for (i=1:size(conditions,2))

    % bin the amplitudes by degree visual angle   
    if (EyeData.saccades.perCondition(i).count>0)
        ampCounts(i).X=histc([EyeData.saccades.perCondition(i).Saccade.saccAmpX],binsX);

        % calculate proportion
        totalAmps(i)=EyeData.saccades.perCondition(i).count;
        ampProps(i).X=ampCounts(i).X/totalAmps(i);
    else
        ampProps(i).X=0;
    end
end

EyeData.saccSummary.amplitudeData=ampProps;

n=0;
for (i=1:size(configData.conditions,2))
    n=n+1;
    saccProps(n)=EyeData.saccades.perCondition(i).count/EyeData.trialsPerCondition(i);
end

EyeData.saccSummary.saccCounts=saccProps;

end
