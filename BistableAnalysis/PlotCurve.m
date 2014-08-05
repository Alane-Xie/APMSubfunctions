function Fig = PlotCurve(Results, Subject, Save)

%============================= PlotCurve.m ================================
% Plots SFM results data 'Results', fits a psychometric curve using the 
% Psignifit function 'do_pfit.m' and saves the figure as a .png file named 
% 'ShadedSFM_(Subject)_(date)'.  'do_pfit.m' should be stored in the same
% directory as 'PlotCurve.m' - otherwise you will be prompted to specify
% its path.
%
% 06/11/10 - Created (APM)
%==========================================================================

if nargin < 1
	[Filename, SessionDir] = uigetfile('SFMthresh*', 'Load results');  	% ask user to specify .mat file containing results to analyze
    load([SessionDir, Filename]);
    Save = 0;
    Subject = '';
end
if exist('Results', 'var') ~= 1 && exist('Trials', 'var') == 1
    Results = Trials;
end

%=================== TALLY RESULTS ======================================
TotalTrials = numel(Results(:,1));                         % Count how many trials were completed
StimLevels = unique(Results(:,3))';                        % specify conditions by signal level
if min(StimLevels) >= 0                                    % If all stimulus levels were positive...
    StimLevels = unique(Results(:,3).*Results(:,2))';      % Get stim levels including +/- sign
end
TotalConditions = numel(StimLevels);                
TrialsPerCondition = TotalTrials/TotalConditions;
Tally = zeros(1,TotalConditions); 
Results = sortrows(Results, [2 3]);                        % Sort results by stimulus shape and then % signal      
n=1; condition = 1;
while n <= TotalTrials
    if Results(n,5) == 1                                   % if subject responded CONVEX or VERTICAL (1)
        Tally(condition) = Tally(condition)+1;             % add 1 to tally of convex/ vertical responses for that condition
    end
    n=n+1;                                                 % tally next result
    condition = ceil(n/TrialsPerCondition);                % select which condition bin to add to
end
data = nan(TotalConditions,3);
data(:,1) = StimLevels';
data(:,2) = Tally;
data(:,3) = ones(TotalConditions,1)*TrialsPerCondition;

%====================== PLOT CURVE AND SAVE FIGURE ========================
if max(StimLevels)==100
    xLabel = 'Disparity (% veridical)';
elseif max(StimLevels)<100
    xLabel = 'Disparity (arcmin)';
end

figname = strcat('SFMthresh_', Subject, '_', date);                 % create filename for figure
Fig = figure;
try                                                                 % If 'do_pfit.m' is available...
    color = 'red';                                                  % Set line colour
    nint = 1;                                   
    [slope,threshold,sd,error,h] = do_pfit(data, nint, color);      % Fit psychometric function
catch                                                               % If 'do_pfit.m' is unavailable...
    plot(StimLevels,Tally,'-r.','LineWidth',2, 'MarkerSize',20);    % Plot data points and line graph
end
hold on;                
set(gca, 'YTick',0:0.25:1);                                     % Set y-axis ticks                                    
set(gca, 'ylim',[0 1]);                                         % Set range of y-axis
set(gca, 'XTick',StimLevels);                                   % Set x-axis ticks
set(gca, 'xlim',[min(StimLevels) max(StimLevels)]);             % Set range of x-axis
set(gca, 'TickDir','out');
set(gca,'fontsize',10);                                         
xlabel(xLabel, 'FontSize', 12)
ylabel('Probability of ''Clockwise'' response', 'FontSize', 12)
Title = sprintf('Subject %s', Subject);
title(Title, 'FontSize', 12, 'FontWeight','bold')


if Save == 1
%     figDir = uigetdir(currentDir,'Specify directory to save figure to');
    saveas(gca, figname, 'fig');                                          % save figure as .fig file
    saveas(gca, figname, 'png');                                          % save figure as .png file
end