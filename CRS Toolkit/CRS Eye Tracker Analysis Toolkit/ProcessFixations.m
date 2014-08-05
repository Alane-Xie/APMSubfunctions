function EyeData=ProcessFixations(EyeData)

global configData;
conditions=configData.conditions;


for (i=1:size(EyeData.segment,2))
    if (EyeData.segment(i).include==true)
        
        for (j=1:size(EyeData.segment(i).fixations,2))

                fixationIndices=[EyeData.segment(i).fixations(j).startIndex: EyeData.segment(i).fixations(j).endIndex];
                EyeData.segment(i).fixations(j).meanX=nanmean(EyeData.segment(i).angleX(fixationIndices));
                EyeData.segment(i).fixations(j).stdX=nanstd(EyeData.segment(i).angleX(fixationIndices));
        end
    end

    if (configData.useGui.dispFixSummary==true)
        f=figure;
    
        clf(f);
        set(f,'position',[50 480 1000 450]);
        msg=sprintf('For Run: %d\nNumber of fixations detected %d % Non fixation remaining:  %3.2f',EyeData.segment(i).realSegmentIndex,size(EyeData.segment(i).fixations,2),EyeData.segment(i).nonFixPct);
        set(f,'name',msg);
        plot(EyeData.segment(i).sampleTime(1:EyeData.segment(i).totalSamples),EyeData.segment(i).angleX(1:EyeData.segment(i).totalSamples),'b');
        title(sprintf('Fixations detected (x-axis positions) for run %d',EyeData.segment(i).realSegmentIndex));
        xlabel('Time /s');
        ylabel('Position/degrees');

        hold on

        % draw a line for the mean over the whole fixation for the length of
        % the fixation

        for (j=1:size(EyeData.segment(i).fixations,2))
            startfix=EyeData.segment(i).fixations(j).startIndex;
            endfix=EyeData.segment(i).fixations(j).endIndex;
            t1=EyeData.segment(i).sampleTime(startfix);
            t2=EyeData.segment(i).sampleTime(endfix);
            meanX=EyeData.segment(i).fixations(j).meanX;
            stdX=EyeData.segment(i).fixations(j).stdX;
            line([t1 t2],[meanX meanX],'color','r');
            line ([t1 t2],[meanX+stdX,meanX+stdX],'color','g');
            line ([t1 t2],[meanX-stdX,meanX-stdX],'color','g');

        end

        grid;
        uiwait(f);
        
        if (ishandle(f))
            close(f);
            waitfor(f);
        end
        
    end
end

fixationsPerCondition=[];
fixcount(1:size(conditions,2))=0;
for (i=1:size(EyeData.segment,2))
    if (EyeData.segment(i).include==true)
        for (j=1:size(EyeData.segment(i).fixations,2))
            fixSequence=EyeData.segment(i).fixations(j).startIndex:EyeData.segment(i).fixations(j).endIndex;
            startIndex=fixSequence(1);
            maxIndex=max(fixSequence);
            while (startIndex<=max(fixSequence))
                cond=EyeData.segment(i).condition(startIndex);
                endIndex=find(EyeData.segment(i).condition(startIndex:maxIndex)~=cond,1);
                if (isempty(endIndex))
                    endIndex=maxIndex;
                else
                    endIndex=startIndex+endIndex-1;
                    endIndex=endIndex-1; % because we find the first position where condition changes
                end
                fixcount(cond)=fixcount(cond)+1;
                fixationsPerCondition(cond).meanX(fixcount(cond))=nanmean(EyeData.segment(i).angleX(startIndex:endIndex));
                fixationsPerCondition(cond).stdX(fixcount(cond))=nanmean(EyeData.segment(i).angleX(startIndex:endIndex));
                startIndex=endIndex+1;
            end
        end
    end
end

bins=[-10:0.5:10];
for (i=1:size(fixationsPerCondition,2))
    
    % bin positions for each point
     % bin the amplitudes by degree visual angle   
     
    if (~isempty(fixationsPerCondition(i).meanX))
        posCounts(i).X=histc([fixationsPerCondition(i).meanX],bins);

        % calculate proportion
        total(i)=size(fixationsPerCondition(i).meanX,2);
        posProps(i).X=posCounts(i).X/total(i);
    else
        posCounts(i).X=[];
        total(i)=0;
        posProps(i).X=[];
    end
end

EyeData.fixSummary.positionData=posProps;
EyeData.fixationsPerCondition=fixationsPerCondition;


end