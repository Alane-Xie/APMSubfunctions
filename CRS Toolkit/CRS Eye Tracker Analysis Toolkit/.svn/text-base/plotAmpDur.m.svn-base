function plotAmpDur(f,inAmpX,inDur)

% plot amplitude/duration relationship for main sequence
%parameters

% p = plot to use
% amplitude in degrees,duration in milliseconds

figure(f);
hold on;
inAmpX=abs(inAmpX);

plot(inAmpX,inDur,'rx'); % relationship requires duration in ms

amp=[0:30];
dur=(2.2.*amp) + 21; % equation for main sequence relationship between amplitude and duration

plot (amp,dur);
%if (inDur>max(dur))
%    ylim([0 inDur]);
%end

xlabel('amplitude/deg');
ylabel('duration/ms');
title('Main sequence');

legend('Diff in x','Main Sequence','Location','NorthEastOutside');
hold off;
end