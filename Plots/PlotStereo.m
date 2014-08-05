function PlotStereo(filename)

%========================= PLOTCURVE.m ====================================
% Plots coarse near/far results data 'Results', fits a psychometric curve 
% using the Psignifit function 'do_pfit.m' and saves the figure as a .png 
% file named 'CoarseNF_(Initials)_(date)'.  'do_pfit.m' should be stored in 
% the same directory as 'PlotCurve.m' - otherwise you will be prompted to 
% specify its path.
%
% 06/11/10 - Created (APM)
% 15/03/11 - updated for Coarse/Fine stereo depth test
%==========================================================================

if nargin == 0
    [Filename, SessionDir] = uigetfile('*.mat', 'Load results');       % ask user to specify .mat file containing results to analyze
    load([SessionDir, Filename]);
else
    load(filename);
    [SessionDir, Filename, ext] = fileparts(filename);
end
Initials = SessionData.initials;
% Target = SessionData.Target;
Target = '';
SessionData.TMS = 0;
CoarseOrFine = SessionData.CoarseOrFine;
PlotNeg = 1;

currentDir = cd;                                                    % Save current path as variable


%============== CONVERT STIM LEVEL REFERENCE NUMBERS TO % SIGNAL ==========
if CoarseOrFine == 1
%     ActualStimLevels = 0:10:100;
    XLabel = 'Signal (%)';
    Type = 'Coarse';
elseif CoarseOrFine == 2
%     ActualStimLevels = [1/60,0.1,0.3,0.4,0.5,1,4];
    XLabel = 'Disparity difference (arcmin)';
    Type = 'Fine';
end
% Results(:,3) = ActualStimLevels(Results(:,3));


%==================== CHECK TMS PULSE DELIVERY ONSETS =====================
if SessionData.TMS > 0
    Results = sortrows(Results, 8);                                 % Sort trials by chronological order
    MeanPulseF = mean(diff(Results(:,8)));                          % Calculate mean time (seconds) between TMS pulse deliveries
    SEMPulseF = std(diff(Results(:,8)))/sqrt(numel(Results(:,8)));  % Calculate standard error (seconds)
    fprintf('Mean TMS inter-pulse interval = %ds (+/- %d)\n', 1/MeanPulseF, SEMPulseF);
end

%====================== COUNT AND REMOVE MISSED TRIALS ====================
MissedTrials = find(isnan(Results(:,5)));                           % Identify trials where no response was given
Results(MissedTrials,:) = [];                                       % Remove these trials from the Results matrix


%=================== TALLY ACCURACY RESULTS ===============================
TotalTrials = numel(Results(:,1));                                  % Count how many trials were completed
if PlotNeg == 1
    Results(:,3) = abs(Results(:,3)).*Results(:,2);
end
StimLevels = unique(Results(:,3))';                                 % specify conditions by signal level
TotalConditions = numel(StimLevels);                      
TrialsPerCondition = zeros(TotalConditions,1);                      % Create empty matrix to count trials per condition
Tally = zeros(TotalConditions,1);                                   % Create empty matrix to count correct trials per condition
Results = sortrows(Results, [3 4]);                                 % Sort results by % signal and then repetition
for n = 1:TotalTrials
    condition = find(StimLevels == Results(n,3));                   % find which condition the current trial was
    TrialsPerCondition(condition) = TrialsPerCondition(condition)+1;
    if PlotNeg == 0
        if Results(n,7) == 1                                            % if subject responded correctly (column 7 = 1)...
            Tally(condition) = Tally(condition)+1;                      % add 1 to tally of correct responses for that condition         
        end
    elseif PlotNeg == 1
        if Results(n,6) == 1                                            % if subject responded 'near' (column 6 = 1)...
            Tally(condition) = Tally(condition)+1;                      % add 1 to tally of near responses for that condition         
        end
    end
end
data = nan(TotalConditions,3);
data(:,1) = StimLevels';
data(:,2) = Tally./TrialsPerCondition;
data(:,3) = TrialsPerCondition;
if numel(unique(TrialsPerCondition)) > 1                            % If there were not an equal number of trials for each condition...
    fprintf('Trials per condition = %d\n', TrialsPerCondition);
end


%==================== CALCULATE MEAN RTs ==================================
MinRT = 0.15;                                                       % Set the lower threshold for discarding outlying RTs (seconds)
CorrectTrials = find(Results(:,7) == 1);                            % Find the trials that were answered correctly
NonOutliers = find(Results(:,5) > MinRT);                           % Find the correct trials where RTs were not outliers              
for n = 1:TotalConditions
    RTs{n} = Results((Results(:,3)== StimLevels(n) & Results(:,7)==1 & Results(:,5) > MinRT), 5);
    RTmeans(n) = mean(RTs{n});
    RTsems(n) = std(RTs{n})/sqrt(numel(RTs{n}));
end


%====================== PLOT CURVE AND SAVE FIGURE ========================
xLabel = 'Signal (%)';
figname = strcat(Type, 'NF_', Initials, '_', Target);               % create filename for figure
f(1) = subplot(2,1,1);
try                                                                 % If 'do_pfit.m' is available...
    if strcmp(Target, 'Baseline');
        color = 'black';                                            % Set line colour for baseline condition to black
    else
        color = 'red';                                              % Set line colour for TMS condition to red
    end
    nint = 2;                                                       % Number of intervals (2IFC task)
    [slope,threshold,sd,error,h] = do_pfit(data, nint, color);      % Fit psychometric function
catch                                                               % If 'do_pfit.m' failed...
    Tally = Tally./TrialsPerCondition;
    plot(StimLevels, Tally,'-r.','LineWidth',2, 'MarkerSize',20);   % Plot data points and line graph
end
hold on;         
h = get(gcf,'CurrentAxes');
% set(h, 'YTick',0:0.25:1);                                           % Set y-axis ticks                                    
% set(h, 'ylim',[0 1]);                                               % Set range of y-axis
set(h, 'XTick',StimLevels);                                         % Set x-axis ticks
set(h, 'xlim',[min(StimLevels) max(StimLevels)]);                   % Set range of x-axis
set(h,'fontsize',14);                                         
xlabel(XLabel, 'FontSize', 16, 'FontWeight','bold');
if PlotNeg == 1
    YLabel = 'Proportion near responses';
elseif PlotNeg == 0
    YLabel = 'Proportion correct responses';
end
ylabel(YLabel, 'FontSize', 16, 'FontWeight','bold');
Title = sprintf('Subject: %s, Target: %s, %s Stereo', Initials, Target, Type);
title(Title, 'FontSize', 16, 'FontWeight','bold');
set(gca,'TickDir','out');
set(gca, 'Box', 'off');

f(2) = subplot(2,1,2);
errorbar(StimLevels, RTmeans, RTsems);
set(h, 'XTick',StimLevels);                                         % Set x-axis ticks
set(h, 'xlim',[min(StimLevels) max(StimLevels)]);                   % Set range of x-axis
set(h,'fontsize',14);                                         
xlabel(XLabel, 'FontSize', 16, 'FontWeight','bold');
ylabel('Mean RT (seconds)', 'FontSize', 16, 'FontWeight','bold');
set(gca,'TickDir','out');
set(gca, 'Box', 'off');

if cd ~= currentDir
    figDir = uigetdir(currentDir,'Specify directory to save figure to');
    cd(figDir);
end

cd(SessionDir);
% saveas(gca, figname, 'fig');                                          % save figure as .fig file
% saveas(gca, figname, 'png');                                          % save figure as .png file
% close all;                                                            % close figure