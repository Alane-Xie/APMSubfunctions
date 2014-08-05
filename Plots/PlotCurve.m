function PlotCurve(Results, Subject)

% Plots SFM results data 'Results', fits a psychometric curve using the 
% Psignifit function 'do_pfit.m' and saves the figure as a .png file named 
% 'ShadedSFM_(Subject)_(date)'.  'do_pfit.m' should be stored in the same
% directory as 'PlotCurve.m' - otherwise you will be prompted to specify
% its path.
%
% 06/11/10 - Created (APM)

%==================== CHECK PATH FOR 'do_pfit.m' ==========================

currentDir = cd;                                                    % Save current path as variable
if exist('do_pfit.m','file') ~= 2                                   % If 'do_pfit.m' is not in the current directory...
    pfitDir = uigetdir(currentDir,'Specify Psignifit directory');   % Ask user to specify directory containing 'do_pfit.m'
    if pfitDir == 0                                                 % If user presses 'Cancel'...
        abort
    else
        cd(pfitDir);                                                % Change to directory containing 'do_pfit.m'
    end
elseif exist('do_pfit.m','file')==2
    pfit = 1;
end


%=================== TALLY RESULTS =======================================

TotalTrials = numel(Results(:,1));                         % Count how many trials were completed
StimLevels = unique(Results(:,3))';                        % specify conditions by signal level
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

figname = strcat('DisparitySFM_', Subject, '_', date);              % create filename for figure
if pfit == 1                                                        % If 'do_pfit.m' is available...
    color = 'red';                                                  % Set line colour
    nint = 1;                                   
    [slope,threshold,sd,error,h] = do_pfit(data, nint, color);      % Fit psychometric function
elseif pfit == 0                                                    % If 'do_pfit.m' is unavailable...
    plot(StimLevels,Tally,'-r.','LineWidth',2, 'MarkerSize',20);    % Plot data points and line graph
end
hold on;                
set(gca, 'YTick',0:0.25:1);                                     % Set y-axis ticks                                    
set(gca, 'ylim',[0 1]);                                         % Set range of y-axis
set(gca, 'XTick',StimLevels);                                   % Set x-axis ticks
set(gca, 'xlim',[min(StimLevels) max(StimLevels)]);             % Set range of x-axis
set(gca,'fontsize',14);                                         
xlabel(xLabel, 'FontSize', 16, 'FontWeight','bold')
ylabel('Probability of ''Clockwise'' response', 'FontSize', 16, 'FontWeight','bold')

if cd ~= currentDir
    figDir = uigetdir(currentDir,'Specify directory to save figure to');
    cd(figDir);
end

saveas(gca, figname, 'fig');                                          % save figure as .fig file
saveas(gca, figname, 'png');                                          % save figure as .png file

