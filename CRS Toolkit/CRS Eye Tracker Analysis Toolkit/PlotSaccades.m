function EyeData=PlotSaccades(EyeData,f)

global configData;

binsX=[-10:0.5:10];

colours='ybgrkcm';
figure(f);


% plot proportions against bins
% subplot(3,2,3);
% labels=[];
% n=0;
% hold on;
% for (i=1:size(conditions,2))
%     if (configData.conditions(i).isFixation==0) % don't plot fixation condition
%         n=n+1;
%         labels{n}=configData.conditions(i).name;
%         % determine colour to plot the line
%         cindex=rem(i,size(colours,2));
%         if (cindex==0)
%             cindex=size(colours,2);
%         end
%         style=sprintf('-%s',colours(cindex));
%         plot(binsX,ampProps(i).X,style);
%     end
% end
% 
% title('X saccade amplitude');
% xlabel('Amplitude/degrees');
% ylabel('Proportion of saccades');
%l=legend(labels);
%set(l,'fontsize',6,'fontname','arial');



% subplot(4,4,6);
% hold on;
% labels=[];
% n=0;
% for (i=1:size(conditions,2))
%     if (configData.conditions(i).isFixation==0) % don't plot fixation condition
%         n=n+1;
%         labels{n}=configData.conditions(i).name;
%         cindex=rem(i,size(colours,2));
%         if (cindex==0)
%             cindex=size(colours,2);
%         end
%         style=sprintf('-%s',colours(cindex));
%         plot(binsY,ampProps(i).Y,style);
%     end
% end
% title('Y saccade amplitude');
% xlabel('Amplitude/degrees');
% ylabel('Proportion of saccades');
% %l=legend(labels);
% %set(l,'fontsize',6,'fontname','arial');

    
subplot(4,2,[2 4]);
hold on;
labels=[];
n=0;
for (i=1:size(configData.conditions,2))
    if (configData.conditions(i).isFixation==0) % don't plot fixation condition
        if (EyeData.saccades.perCondition(i).count>0) 
            n=n+1;
            labels{n}=configData.conditions(i).name;
            cindex=rem(i,size(colours,2));
            if (cindex==0)
                cindex=size(colours,2);
            end
            style=sprintf('-%s',colours(cindex));
            plot(binsX,EyeData.saccSummary.amplitudeData(i).X,style);
        end
    end
end
title('Saccade amplitudes per condition');
xlabel('Amplitude/degrees');
ylabel('Relative proportion of saccades');
l=legend(labels,'location','NorthEastOutside');
set(l,'fontsize',6,'fontname','arial');


% % plot durations of eye movement per condition
% durRange=struct('range',[]);
% binsDur=[0:.01:0.5];
% 
% for (i=1:size(conditions,2))
%     if (EyeData.saccades.perCondition(i).count>0)
%         durRange(i).range=histc([EyeData.saccades.perCondition(i).Saccade.saccDuration],binsDur);
%         total(i)=EyeData.saccades.perCondition(i).count;
%         durProps(i).dur=durRange(i).range/total(i);
%     else
%         durProps(i).dur=0;
%     end
% end

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
        values(n)=EyeData.saccSummary.saccCounts(i);
    end
end

%EyeData.saccSummary.countData=saccProps;
bar(cond,values,'w');
set(gca,'xticklabel',labels);
set(gca,'box','off');
title('Saccades per trial per condition');
xlabel('Condition');
ylabel('Number of saccades');
if (max(values)>0)
    ylim([0 max(values)*1.1]);
else
    ylim([0 1]);
end


% subplot (4,4,[11 12]);
% hold on;
% n=0;
% labels=[];
% for (i=1:size(conditions,2))
%     if (configData.conditions(i).isFixation==0) % don't plot fixation condition
%         n=n+1;
%         labels{n}=configData.conditions(i).name;
%          cindex=rem(i,size(colours,2));
%         if (cindex==0)
%             cindex=size(colours,2);
%         end
%         style=sprintf('-%s',colours(cindex));
%         plot(binsDur,durProps(i).dur,style);
%     end
% end
% 
% title('Duration of saccades per condition');
% xlabel('Duration/secs');
% ylabel('Proportion of saccades');
% l=legend(labels);
% set(l,'fontsize',6,'fontname','arial');
end
    
    





