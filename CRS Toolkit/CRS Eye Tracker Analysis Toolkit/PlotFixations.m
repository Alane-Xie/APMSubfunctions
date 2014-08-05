function  EyeData=PlotFixations(EyeData,f)
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

for (i=1:size(EyeData.fixationsPerCondition,2))

    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (length(EyeData.fixSummary.positionData(i).X>0))
            n=n+1;
            labels{n}=configData.conditions(i).name;
            cindex=rem(i,size(colours,2));
            if (cindex==0)
                cindex=size(colours,2);
            end
            style=sprintf('-%s',colours(cindex));
            plot(bins,EyeData.fixSummary.positionData(i).X,style);
        end
    end
end
title('X eye position');
xlabel('Position/degrees');
ylabel('Proportion of fixations');
l=legend(labels);
set(l,'fontsize',6,'fontname','arial');
    

end