function plotVoltage(EyeData,segmentIndex,seqStartIndex,seqEndIndex,plotNumber,plotCount)

subplot(plotCount,1,plotNumber);
plot (EyeData.segment(segmentIndex).sampleTime(seqStartIndex:seqEndIndex),EyeData.segment(segmentIndex).voltageData(seqStartIndex:seqEndIndex),'r.-');
hold on;
xlabel('Time/s');
ylabel('voltage');
txt=sprintf('Voltage plot for run: %d',EyeData.segment(segmentIndex).realSegmentIndex);
title(txt);
xlim([EyeData.segment(segmentIndex).sampleTime(seqStartIndex) EyeData.segment(segmentIndex).sampleTime(seqEndIndex)]);
%meanX=nanmean(EyeData.segment(segmentIndex).angleX(seqStartIndex: seqEndIndex));
%yl1=meanX-15;
%yl2=meanX+15;
%ylim([yl1 yl2]);

% yl=ylim;
% ticks=[floor(yl(1)):2:ceil(yl(2))]
% set(gca,'YTick',ticks);
% set(gca,'YTickLabel',ticks');
    
end