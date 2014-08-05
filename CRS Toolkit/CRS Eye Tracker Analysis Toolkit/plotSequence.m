function [classButtons,cursorStart, cursorEnd]=plotSequence(f, ASLData,segmentIndex, seqStartIndex, seqEndIndex, highlightStartTime,highlightEndTime)

% plot a sequence of the data for evaluation

% parameters
% figure = figure handle to plot into
% segmentIndex - run index
% seqStartIndex - index into data to start plotting from
% seqEndIndex - index into data to end plotting at
% highlightStartTime - time at which to draw start of section to highlight
% highlightEndTime - time at which to draw end of section to highlight

% returns classification of sequence - S=Saccade B=Blink

global classAs;
classAs='';
figure(f);
clf(f);
set(f,'position',[100,100,900,800]);
%get sequence duration

seqdur=highlightEndTime-highlightStartTime;
seqdur=seqdur*1000;
figtitle=sprintf('Classify sequence (duration %f milliseconds)',seqdur);
set(f,'name',figtitle);
set(f,'units','pixels');
classButtons = uibuttongroup('visible','off','Position',[0 0 500 50]);
set (classButtons,'Parent',f);
saccButton = uicontrol('Style','Radio','String','Saccade',...
    'pos',[10 10 80 30],'parent',classButtons,'HandleVisibility','off');
blinkButton = uicontrol('Style','Radio','String','Blink',...
    'pos',[110 10 80 30],'parent',classButtons,'HandleVisibility','off');
neitherButton = uicontrol('Style','Radio','String','Neither',...
    'pos',[210 10 80 30],'parent',classButtons,'HandleVisibility','off');
cancelButton = uicontrol('Style','Radio','String','Cancel',...
    'pos',[310 10 80 30],'parent',classButtons,'HandleVisibility','off');

refreshButton=uicontrol('Style','Pushbutton','String','Refresh',...
    'pos',[400 10 50 30]);

subplot(4,1,1);
plot (ASLData.segment(segmentIndex).velTime(seqStartIndex:seqEndIndex),ASLData.segment(segmentIndex).velVector(seqStartIndex:seqEndIndex),'k.-');        
hold on;
plot (ASLData.segment(segmentIndex).velTime(seqStartIndex:seqEndIndex),ASLData.segment(segmentIndex).velX(seqStartIndex:seqEndIndex),'r.-');        
plot (ASLData.segment(segmentIndex).velTime(seqStartIndex:seqEndIndex),ASLData.segment(segmentIndex).velY(seqStartIndex:seqEndIndex),'b.-');        

xlabel('Time/s');
ylabel('Velocity deg/s');
title('Velocity plot');

subplot(4,1,2);
plot (ASLData.segment(segmentIndex).sampleTime(seqStartIndex:seqEndIndex),ASLData.segment(segmentIndex).angleX(seqStartIndex:seqEndIndex),'r.-');
hold on;
plot (ASLData.segment(segmentIndex).sampleTime(seqStartIndex:seqEndIndex),ASLData.segment(segmentIndex).angleY(seqStartIndex:seqEndIndex),'b.-');
%plot (ASLData.segment(segmentIndex).sampleTime(seqStartIndex:seqEndIndex),ASLData.segment(segmentIndex).angleVec(seqStartIndex:seqEndIndex),'m.-');
xlabel('Time/s');
ylabel('visual angle/deg');
title('Position plot');

cursorStart=createCursor(f);
cursorEnd=createCursor(f);

subplot(4,1,1);
legend('vector velocity','x velocity', 'y velocity');
subplot(4,1,2);
legend('x position','y position');

SetCursorLocation(cursorEnd,highlightEndTime);
SetCursorLocation(cursorStart,highlightStartTime);

subplot(4,1,3);
% plot pupil diameter and overlay on the right hand y axis with pupil and
% CR recognition

% plot pupil diameter and pupil detection
[ax h1 h2]=plotyy (ASLData.segment(segmentIndex).sampleTime(seqStartIndex:seqEndIndex),...
    ASLData.segment(segmentIndex).pupilOn(seqStartIndex:seqEndIndex),...
    ASLData.segment(segmentIndex).sampleTime(seqStartIndex:seqEndIndex),...
    ASLData.segment(segmentIndex).pupilDiam(seqStartIndex:seqEndIndex));

set(h1,'color',[1 0 0]);
set(h2,'color',[0 0 1]);
set(h1,'marker','.');
set(h2,'marker','.');

hold (ax(1));
%axes(ax(2))

h3=plot(ASLData.segment(segmentIndex).sampleTime(seqStartIndex:seqEndIndex),...
    ASLData.segment(segmentIndex).crOn(seqStartIndex:seqEndIndex));

set(h1,'color',[1 0 0]);
set(h2,'color',[0 0 1]);
set(h3,'color',[0 0 0]);

set(h1,'marker','.');
set(h2,'marker','.');
set(h3,'marker','.');

ylim(ax(1),[-0.1 1.1]);
set(ax(2),'ycolor',[0 0 0]);
set(ax(1),'ycolor',[0 0 0]);
set(ax(1),'ytick',[0 1]);


xlabel('Time/s');

ylabel(ax(1),'Pupil/CR On');
ylabel(ax(2),'Pupil diameter');
title('Pupil characteristics plot');

legend([h1 h3 h2],'Pupil Detect','CR Detect','Pupil Diameter');


end