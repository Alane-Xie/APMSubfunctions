function plotVelocity(EyeData,segmentIndex,seqStartIndex,seqEndIndex,velMaxThreshold,velMinThreshold,plotNumber,plotCount)

subplot(plotCount,1,plotNumber);
plot (EyeData.segment(segmentIndex).velTime(seqStartIndex:seqEndIndex),EyeData.segment(segmentIndex).velX(seqStartIndex:seqEndIndex),'k.-');        
hold on;

% plot positions where data has been identified
lossIndices=find(EyeData.segment(segmentIndex).tagType(seqStartIndex:seqEndIndex)=='L');
fixIndices=find(EyeData.segment(segmentIndex).tagType(seqStartIndex:seqEndIndex)=='F');
saccIndices=find(EyeData.segment(segmentIndex).tagType(seqStartIndex:seqEndIndex)=='S');
blinkIndices=find(EyeData.segment(segmentIndex).tagType(seqStartIndex:seqEndIndex)=='B');
unkIndices=find(EyeData.segment(segmentIndex).tagType(seqStartIndex:seqEndIndex)=='U');

time=EyeData.segment(segmentIndex).velTime(seqStartIndex:seqEndIndex);
dataLoss=NaN(1,seqEndIndex-seqStartIndex+1);
dataLoss(lossIndices)=0;

dataFix=NaN(1,seqEndIndex-seqStartIndex+1);
dataFix(fixIndices)=0;

dataSacc=NaN(1,seqEndIndex-seqStartIndex+1);
dataSacc(saccIndices)=0;

dataBlink=NaN(1,seqEndIndex-seqStartIndex+1);
dataBlink(blinkIndices)=0;

dataUnk=NaN(1,seqEndIndex-seqStartIndex+1);
dataUnk(unkIndices)=0;

%plot (EyeData.segment(segmentIndex).velTime(seqStartIndex:seqEndIndex),EyeData.segment(segmentIndex).velX(seqStartIndex:seqEndIndex),'r.-');        
%plot (EyeData.segment(segmentIndex).velTime(seqStartIndex:seqEndIndex),EyeData.segment(segmentIndex).velY(seqStartIndex:seqEndIndex),'b.-');        

plot (time,dataLoss,'rx','Markersize',10);
plot(time,dataFix,'b+','Markersize',10);
plot(time,dataSacc,'go','Markersize',10);
plot(time,dataBlink,'ks','Markersize',10);
plot(time,dataUnk,'m*','Markersize',10);


xlabel('Time/s');
ylabel('Velocity deg/s');
txt=sprintf('Velocity plot for run : %d',EyeData.segment(segmentIndex).realSegmentIndex);
title(txt);
xlim([EyeData.segment(segmentIndex).sampleTime(seqStartIndex) EyeData.segment(segmentIndex).sampleTime(seqEndIndex)]);
%ylim([velMinThreshold*1.1 velMaxThreshold*1.1]);
grid;
end
