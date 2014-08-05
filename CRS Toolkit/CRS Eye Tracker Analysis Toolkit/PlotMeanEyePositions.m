function EyeData=PlotMeanEyePositions(EyeData,f)

% plot mean eye positions in an individual trial over all conditions

% determine mean eye position for each sample point over all trials per
% condition
global configData;


colours='ybgrkcm';

% determine if we need to split the figure first
splitFigure=false;
for (i=1:configData.numConditions)
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(EyeData.eyePositions.meanXPerCondition(i).xPos)>0)
            if (EyeData.stimLengthPerCond(i)~=EyeData.trialLengthPerCond(i)) % plot truncated version
                splitFigure=true;
                break;
            end
        end
    end
end


figure(f);
labels=[];
n=0;
if (splitFigure==true)
    subplot (4,2,6);
else
    subplot(4,2,[6 8]);
end

hold on;
for (i=1:configData.numConditions)
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(EyeData.eyePositions.meanXPerCondition(i).xPos>0))
            n=n+1;
            labels{n}=configData.conditions(i).name;
            cindex=rem(i,size(colours,2));
            if (cindex==0)
                cindex=size(colours,2);
            end
            style=sprintf('-%s',colours(cindex));
            diff=(EyeData.trialLengthPerCond(i)/size(EyeData.eyePositions.meanXPerCondition(i).xPos,2));
            diff=round(diff*1000)/1000;
%            diff=ceil(diff); % round up to whole number of milliseconds
            t=[0:diff:EyeData.trialLengthPerCond(i)];
            % if size of t is different to number of positions truncate t
            t=t(1:length(EyeData.eyePositions.meanXPerCondition(i).xPos));
            plot(t,EyeData.eyePositions.meanXPerCondition(i).xPos,style);
        end
    end
end
title('Mean Horizontal Eye Position');
xlabel('Time from stimulus onset (ms)');
ylabel('Eye position/degrees');
ylim([-2,2]);
l=legend(labels);

set(l,'fontsize',6,'fontname','arial');
set(l,'location','NorthEastOutside');

% plot only over the stimulus length - i.e. ignore ISI if applicable
n=0;
labels=[];
if (splitFigure==true)
    truncPlot=subplot(4,2,8);
end
hold on;
plotTruncated=false;
for (i=1:configData.numConditions)
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(EyeData.eyePositions.meanXPerCondition(i).xPos)>0)
            if (EyeData.stimLengthPerCond(i)~=EyeData.trialLengthPerCond(i)) % plot truncated version
                plotTruncated=true;
                n=n+1;
                labels{n}=configData.conditions(i).name;
                cindex=rem(i,size(colours,2));
                if (cindex==0)
                    cindex=size(colours,2);
                end
                style=sprintf('-%s',colours(cindex));
                diff=(EyeData.trialLengthPerCond(i)/size(EyeData.eyePositions.meanXPerCondition(i).xPos,2));
                diff=round(diff*1000)/1000;
                % determine  end index to truncate plot to
        %            diff=ceil(diff); % round up to whole number of milliseconds
                t=[0:diff:EyeData.stimLengthPerCond(i)];
                % if size of t is different to number of positions truncate t
%                t=t(1:length(EyeData.eyePositions.meanXPerCondition(i).xPos(1:numSamples)));
                plot(t,EyeData.eyePositions.meanXPerCondition(i).xPos(1:size(t,2)),style);
            end
        end
    end
end

if (plotTruncated)
    title('Mean Horizontal Eye Position');
    xlabel('Time from stimulus onset (ms)');
    ylabel('Eye position/degrees');
    l=legend(labels,'location','NorthEastOutside');
    set(l,'fontsize',6,'fontname','arial');
else
   if exist('truncPlot')
       delete(truncPlot);
   end
end

% subplot(4,4,[15 16])
% hold on;
% labels=[];
% n=0;
% for (i=1:configData.numConditions)
%     if (configData.conditions(i).isFixation==0) % don't plot fixation condition
%         n=n+1;
%         labels{n}=configData.conditions(i).name;
%         cindex=rem(i,size(colours,2));
%         if (cindex==0)
%             cindex=size(colours,2);
%         end
%         style=sprintf('-%s',colours(cindex));
%         diff=(configData.designData(1).trialLength/size(meanXPerCondition,2));
%         diff=round(diff*1000)/1000;
%         t=[0:diff:configData.designData(1).trialLength];
%         plot(t,stdXPerCondition(i,:),style);
%     end    
% end
% 
% title('SD Horizontal Eye Position');
% xlabel('Time from stimulus onset (ms)');
% ylabel('Eye position/degrees');
% ylim([0,2]);
% l=legend(labels,'location','NorthEastOutside');
% set(l,'fontsize',6,'fontname','arial');


end