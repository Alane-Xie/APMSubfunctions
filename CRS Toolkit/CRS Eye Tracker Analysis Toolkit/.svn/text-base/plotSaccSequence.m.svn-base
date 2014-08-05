function [classButtons,mainSeqButton,cursorStart, cursorEnd]=plotSaccSequence(f, EyeData,segmentIndex, seqStartIndex, seqEndIndex, highlightStartTime,highlightEndTime,velMaxThreshold,velMinThreshold)

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
figtitle=sprintf('Sequence (duration %f milliseconds)',seqdur);
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
lossButton = uicontrol('Style','Radio','String','Lost Signal',...
    'pos',[310 10 80 30],'parent',classButtons,'HandleVisibility','off');
unClassButton = uicontrol('Style','Radio','String','Unclassifiable',...
    'pos',[310 10 80 30],'parent',classButtons,'HandleVisibility','off');

cancelButton = uicontrol('Style','Radio','String','Cancel',...
    'pos',[410 10 80 30],'parent',classButtons,'HandleVisibility','off');
mainSeqButton=0;
mainSeqButton=uicontrol('Style','Pushbutton','String','Main Sequence',...
    'pos',[500 10 100 30]);

plotVelocity(EyeData,segmentIndex,seqStartIndex,seqEndIndex,velMaxThreshold,velMinThreshold,1,3);
plotPosition(EyeData,segmentIndex,seqStartIndex,seqEndIndex,2,3);
%plotPupil(EyeData,segmentIndex,seqStartIndex,seqEndIndex,3,4);
plotVoltage(EyeData,segmentIndex,seqStartIndex,seqEndIndex,3,3);

cursorStart=createCursor(f);
cursorEnd=createCursor(f);

SetCursorLocation(cursorEnd,highlightEndTime);
SetCursorLocation(cursorStart,highlightStartTime);
subplot(3,1,1);
legend('velocity','data loss','fixation','saccade','blink','unknown');%,'x velocity','y velocity');
subplot(3,1,2);
legend('x position');
subplot(3,1,3);
legend('Voltage');
%{
subplot(4,1,3);
legend('Pupil Detect','CR Detect');

subplot(4,1,4);
legend('Pupil Diameter');
%}
end

