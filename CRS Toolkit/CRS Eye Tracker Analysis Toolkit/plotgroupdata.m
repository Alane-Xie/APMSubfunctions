function PlotGroupData(groupData,f)

global configData;
%plot fixation position by condition

%[labels{1:size(configData.conditions,2)}]=deal(configData.conditions.name);

colours='ybgrkcm';

% loop through all points in each fixation and bin positions for each point

figure(f);

subplot (4,2,[1 3]);
hold on;
n=0;
labels=[];

bins=[-10:0.5:10];

for (i=1:configData.numConditions)
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(groupData.fixSummary.positionData(i).X>0))
            n=n+1;
            labels{n}=configData.conditions(i).name;
            cindex=rem(i,size(colours,2));
            if (cindex==0)
                cindex=size(colours,2);
            end
            style=sprintf('-%s',colours(cindex));
            plot(bins,groupData.fixSummary.positionData(i).X,style);
        end
    end
end
title('X eye position');
xlabel('Position/degrees');
ylabel('Proportion of fixations');
l=legend(labels);
set(l,'fontsize',6,'fontname','arial');

binsX=[-15:0.5:15];

subplot(4,2,[2 4]);
hold on;
labels=[];
n=0;
for (i=1:size(configData.conditions,2))
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(groupData.saccSummary.amplitudeData(i).X)>1) % 1 item denotes that there are no saccades for that condition
            n=n+1;
            labels{n}=configData.conditions(i).name;
            cindex=rem(i,size(colours,2));
            if (cindex==0)
                cindex=size(colours,2);
            end
            style=sprintf('-%s',colours(cindex));
            plot(binsX,groupData.saccSummary.amplitudeData(i).X,style);
        end
    end
end
title('Proportion of saccade amplitudes');
xlabel('Amplitude/degrees');
ylabel('Relative proportion of saccades');
l=legend(labels,'location','NorthEastOutside');
set(l,'fontsize',6,'fontname','arial');

subplot(4,2,[5 7]);
labels=[];
values=[];
n=0;
% plot number of saccades per condition per trial
for (i=1:size(configData.conditions,2))
    if (configData.conditions(i).isFixation==0)
        n=n+1;
        labels{n}=configData.conditions(i).name;
        cond(n)=i;
        values(n)=groupData.saccSummary.groupSaccProps(i);
        errors(n)=groupData.saccSummary.groupSaccPropsErr(i);
    end
end

%EyeData.saccSummary.countData=saccProps;
bar(cond,values,'w');
hold on;
errorbar(cond,values,errors,'linestyle','none','marker','none');

set(gca,'xticklabel',labels);
set(gca,'box','off');
title('Number of saccades per trial per condition ');
xlabel('Condition');
ylabel('Number of saccades');


labels=[];
n=0;
trialLengthPerCond=groupData.session(1).EyeData.trialLengthPerCond;
stimLengthPerCond=groupData.session(1).EyeData.stimLengthPerCond;
splitFigure=false;
for (i=1:configData.numConditions)
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(groupData.eyePositions.meanXPerCondition(i).xPos)>0)
            if (stimLengthPerCond(i)~=trialLengthPerCond(i)) % plot truncated version
                
                splitFigure=true;
                break;
            end
        end
    end
end

if (splitFigure==true)
    subplot (4,2,6);
else
    subplot(4,2,[6 8]);
end
hold on;
for (i=1:configData.numConditions)
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(groupData.eyePositions.meanXPerCondition(i).xPos>0))
            n=n+1;
            labels{n}=configData.conditions(i).name;
            cindex=rem(i,size(colours,2));
            if (cindex==0)
                cindex=size(colours,2);
            end
            style=sprintf('-%s',colours(cindex));
            diff=(trialLengthPerCond(i)/size(groupData.eyePositions.meanXPerCondition(i).xPos,2));
            diff=round(diff*1000)/1000;
%            diff=ceil(diff); % round up to whole number of milliseconds
            t=[0:diff:trialLengthPerCond(i)];
            % if size of t is different to number of positions truncate t
            t=t(1:length(groupData.eyePositions.meanXPerCondition(i).xPos));
            plot(t,groupData.eyePositions.meanXPerCondition(i).xPos,style);
        end
    end
end
title('Mean Horizontal Eye Position ');
xlabel('Time from stimulus onset (ms)');
ylabel('Eye position/degrees');
ylim([-2,2]);
l=legend(labels,'location','NorthEastOutside');

set(l,'fontsize',6,'fontname','arial');

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
        if (length(groupData.eyePositions.meanXPerCondition(i).xPos)>0)
            if (stimLengthPerCond(i)~=trialLengthPerCond(i)) % plot truncated version
                plotTruncated=true;
                n=n+1;
                labels{n}=configData.conditions(i).name;
                cindex=rem(i,size(colours,2));
                if (cindex==0)
                    cindex=size(colours,2);
                end
                style=sprintf('-%s',colours(cindex));
                diff=(trialLengthPerCond(i)/size(groupData.eyePositions.meanXPerCondition(i).xPos,2));
                diff=round(diff*1000)/1000;
                % determine  end index to truncate plot to
        %            diff=ceil(diff); % round up to whole number of milliseconds
                t=[0:diff:stimLengthPerCond(i)];
                % if size of t is different to number of positions truncate t
%                t=t(1:length(EyeData.eyePositions.meanXPerCondition(i).xPos(1:numSamples)));
                plot(t,groupData.eyePositions.meanXPerCondition(i).xPos(1:size(t,2)),style);
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
    if (exist('truncPlot'))
        delete (truncPlot);
    end
end


end