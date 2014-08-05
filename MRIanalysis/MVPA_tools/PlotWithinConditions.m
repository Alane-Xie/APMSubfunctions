% function [pValuesAccuracy, pValuesDprime] = PlotWithinConditions(PlotDprime)

%======================= PlotWithinConditions.m ===========================
% Plot support vector machine (SVM) classification accuracies and/or d-prime 
% values for within-condition train and test comparisons, and perform 
% t-tests or ANOVA to compare combined-cue condition accuracies to minimum
% bound predicted by quadratic summation of individual cues. 
%
% INPUTS
%   PlotDprime:     0 = plot accuracies, 1 = plot d-prime values
%   DifferentROIs:	0 = plot common ROIs, 1 = plot all ROIs
%   PlotMean:       0 = plot individual subject data, 1 = plot group mean
%   BootStrap:      0 = no, >0 = number of bootstrap iterations
%
% REFERENCES
% Ban H, Preston TJ, Meeson A & Welchman AE (2012). The integration of 
%   motion and disparity cues to depth in dorsal visual cortex. Nature
%   Neuroscience, 15: 636-643.
%
% REVISIONS
% 31/01/2012 - Updated (APM)
% 08/02/2012 - Index calculation and ANOVA added (APM)
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================
SubfunctionDir = 'G:\APMSubfunctions';
addpath(SubfunctionDir);
addpath(genpath(SubfunctionDir));
% if nargin < 1
    PlotDprime = 1;
    DifferentROIs = 0;      % Analyse all ROIs for each subject, use NaN accuracy for missing ROIs
% end

%====================== SPECIFY WHICH DATA TO PLOT ========================
SVMroot = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\svm analysis';
OutputDir = fullfile(SVMroot, 'Within_Conditions_acc');
if ~exist(OutputDir, 'dir')
    mkdir(OutputDir);
end

RequestedVoxels = 300;

Conditions{1} = 'Slant_TrainT_TestT_voxels';
Conditions{2} = 'Slant_TrainD_TestD_voxels';
Conditions{3} = 'Slant_TrainD+T_TestD+T_voxels';
Conditions{4} = 'Slant_TrainD-T_TestD-T_voxels';
Legend = {'T', 'D', 'D+T', 'D-T', 'QuadSum'};

% Conditions{1} = 'Slant_TrainT_TestD';
% Conditions{2} = 'Slant_TrainD_TestT';
% Legend = {'T->D', 'D->T'};
% Subjects = {'AEW','AL','APM2','HB2','JM','LC','MLP2','SP','WC','KAG','SM'};


AllSubjects = {'AEW_2','AL','APM2','FZ_2','HB2','JM','JG','KAG','LC','LP','MLP2','SM_2','SP','TV','WC'};
% Subjects = {'AEW','AL2','APM2','FZ_3','HB2','JM_2','KAG_2','LC_2','MLP2','SM2','SP','TV','WC'};
Subjects = {'AEW','AL2','APM2','HB2','JM_2','LC_3','MLP2','SP','TV2','WC','KAG','SM_2'};



% ROIs = {'V1','V2','V3','V4','LO','pFs','V3A','KO','V7','MT', 'VP', 'MTplus', 'VIPS', 'POIPS', 'DIPSM', 'DIPSA'};
if  DifferentROIs == 1
    ROIs = {'V1','V2','VP','V4','LO','pFs','V3','V3A','KO','V7','MT', 'MTplus', 'VIPS', 'POIPS', 'DIPSM', 'DIPSA'};  % BVQX names of ROIs to process
    ROIlabels = {'V1','V2','V3v','V4','LO','pFs','V3d','V3A','KO/V3B','V7','MT', 'MT+/V5', 'VIPS', 'POIPS', 'DIPSM', 'DIPSA'}; 
else 
    ROIs = {'V1','V2','VP','V4','LO','V3','V3A','KO','V7','MTplus'};            % BVQX names of ROIs to process
    ROIlabels = {'V1','V2','V3v','V4','LO','V3d','V3A','KO/V3B','V7','MT+/V5'}; 
end

%==================== IMPORT DATA FROM SVM_ANALYSIS OUTPUT ================
Accuracy = zeros(numel(Subjects), numel(ROIs),numel(Conditions)+1);
StdError = zeros(numel(Subjects), numel(ROIs),numel(Conditions)+1);
dprime = zeros(numel(Subjects)+1, numel(ROIs),numel(Conditions)+1);
for S = 1:numel(Subjects)
    
    fprintf('\n\nProcessing subject %s data...\n', Subjects{S});
    for Condition = 1:numel(Conditions)                                     % For each MVPA classification...
    %     if ~exist('Subjects','var')                                     % If a list of subject IDs was not provided...
    %         Subjects = Dir(fullpath(SVMroot, Conditions{Condition}));   % Analyse all subjects in each folder
    %     end
        cd(fullfile(SVMroot, char(Conditions{Condition}), char(Subjects{S}), 'results',''));
        for ROI = 1:numel(ROIs)                                             % For each ROI...
            ROIFile = dir(strcat('*',ROIs{ROI},'.mat'));
            if numel(ROIFile) ~= 1
                if DifferentROIs == 1
                    Accuracy(S, ROI, Condition) = NaN;
                    StdError(S, ROI, Condition) = NaN;
                    dprime(S, ROI, Condition) = NaN;
                else
                    fprintf('Error: %d files were found for %s ROI in %s!\n', numel(ROIFile), ROIs{ROI}, fullfile(char(Conditions{Condition}), Subjects{S}, 'results',''));
                    return
                end
            else
                load(ROIFile(1).name);                                  % Load accuracies for this ROI
                NoVoxels = min([RequestedVoxels, num_voxels(end)]);     	% If there are fewer than the requested number of voxels, use as many as available
                if num_voxels(end)<RequestedVoxels
                    fprintf('Accuracy data was only available for %d voxels for %s!\n', NoVoxels, ROIs{ROI});
                end
                if strcmp(Subjects{S}, 'HB2') || strcmp(Subjects{S}, 'KAG_2') 
                    if Condition == 3
                        Accuracy(S, ROI, 4) = cv_accuracy(find(num_voxels==NoVoxels));
                        StdError(S, ROI, 4) = cv_std_error(find(num_voxels==NoVoxels));
                        dprime(S, ROI, 4) = 2*erfinv(2*Accuracy(S, ROI, 4)-1);
                    elseif Condition == 4
                        Accuracy(S, ROI, 3) = cv_accuracy(find(num_voxels==NoVoxels));
                        StdError(S, ROI, 3) = cv_std_error(find(num_voxels==NoVoxels));
                        dprime(S, ROI, 3) = 2*erfinv(2*Accuracy(S, ROI, 3)-1);
                    else
                    	Accuracy(S, ROI, Condition) = cv_accuracy(find(num_voxels==NoVoxels));
                        StdError(S, ROI, Condition) = cv_std_error(find(num_voxels==NoVoxels));
                        dprime(S, ROI, Condition) = 2*erfinv(2*Accuracy(S, ROI, Condition)-1);
                    end
                else
                    Accuracy(S, ROI, Condition) = cv_accuracy(find(num_voxels==NoVoxels));
                    StdError(S, ROI, Condition) = cv_std_error(find(num_voxels==NoVoxels));
                    
                    if Accuracy(S, ROI, Condition)==1
                       tacc=0.9999;
                    elseif Accuracy(S, ROI, Condition)==0
                       tacc=0.0001;
                    else
                       tacc=Accuracy(S, ROI, Condition);
                    end
                    dprime(S, ROI, Condition) = 2*erfinv(2*tacc-1);
                end
                clear cv_accuracy cv_std_error
            end
        end
        fprintf('Condition %d: %s completed!\n', Condition, Conditions{Condition});
    end
end
cd('D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant');

%=============== CALCULTAE QUADRATIC SUMMATION OF SINGLE CUES =============
for S = 1:numel(Subjects)
    for ROI = 1:numel(ROIs)
        dprime(S, ROI, 5) = sqrt(dprime(S, ROI, 1)^2 + dprime(S, ROI, 2)^2);	% Calculate d' for quadratic summation of single cues
    end
end

% %===================== CALCULTAE GROUP MEAN ACCURACIES ====================
% for ROI = 1:numel(ROIs)
%     for Condition = 1:numel(Conditions)+1
%         if Condition < 5
%             Accuracy(numel(Subjects)+1, ROI, Condition) = nanmean(Accuracy(:, ROI, Condition));
%             StdError(numel(Subjects)+1, ROI, Condition) = nanstd(Accuracy(:, ROI, Condition))/sqrt(numel(Subjects));
%         end
%       	dprime(numel(Subjects)+1, ROI, Condition) = nanmean(dprime(:, ROI, Condition));
%     end
% 
% end
% for ROI = 1:numel(ROIs)
% 	dprime(numel(Subjects)+1, ROI, 5) = nanmean(dprime(1:numel(Subjects), ROI, 5));
% end


%============================ PERFORM T-TESTS =============================
alpha = 0.05;
for ROI = 1:numel(ROIs)
    for S = 1:numel(Subjects)
        Accuracy(S, ROI, 5) = (erf(dprime(S, ROI, 5)/2)+1)/2;          % Convert quad.summ d-prime to accuracy value
        StdError(S, ROI, 5) = 0;
        QuadSumAccuracy(S, ROI) = Accuracy(S, ROI, 5);
        CombinedAccuracy(S, ROI) = Accuracy(S, ROI, 3);
        IncongruentAccuracy(S, ROI) = Accuracy(S, ROI, 4);
        QuadSumDprime(S, ROI) = dprime(S, ROI, 5);
        CombinedDprime(S, ROI) = dprime(S, ROI, 3);
        IncongruentDprime(S, ROI) = dprime(S, ROI, 4);
    end
	[h,p,ci] = ttest(QuadSumAccuracy(:, ROI), CombinedAccuracy(:,ROI), alpha);
 	pValuesAccuracy(ROI) = p;
    [h,p,ci] = ttest(QuadSumDprime(:, ROI), CombinedDprime(:,ROI), alpha);
    pValuesDprime(ROI) = p;
    
	[h,p,ci] = ttest(IncongruentAccuracy(:, ROI), CombinedAccuracy(:,ROI), alpha);
    pValuesCongruencyAcc(ROI) = p;
	[h,p,ci] = ttest(IncongruentDprime(:, ROI), CombinedDprime(:,ROI), alpha);
    pValuesCongruencyDp(ROI) = p;
    
end


%========================= Convert quadratic summation d' values to accuracies for means
for ROI = 1:numel(ROIs)
    Accuracy(numel(Subjects)+1, ROI, 5) = (erf(dprime(numel(Subjects)+1, ROI, 5)/2)+1)/2;
    StdError(numel(Subjects)+1, ROI,5) = 0;
end


Accuracy = permute(Accuracy, [2,3,1]);
StdError = permute(StdError, [2,3,1]);
dprime = permute(dprime, [2,3,1]);

for n = 1:numel(Subjects)
    AllAccuracy(n, :) = reshape(Accuracy(:,:,n), 1, numel(Accuracy(:,:,n)));
    AllDprime(n, :) = reshape(dprime(:,:,n), 1, numel(dprime(:,:,n)));
end
MeanAccuracies = nanmean(AllAccuracy);
SEMAccuracies = nanstd(AllAccuracy)/sqrt(numel(AllAccuracy(:,1)));
MeanDprime = nanmean(AllDprime);
SEMDprime = nanstd(AllDprime)/sqrt(numel(AllDprime(:,1)));

Accuracy(:,:, numel(Subjects)+1) = reshape(MeanAccuracies, [numel(ROIs), numel(Conditions)+1]);
StdError(:,:, numel(Subjects)+1) = reshape(SEMAccuracies, [numel(ROIs), numel(Conditions)+1]);
dprime(:,:, numel(Subjects)+1) = reshape(MeanDprime, [numel(ROIs), numel(Conditions)+1]);
dStdError = zeros(size(dprime(:,:,S)));
dStdError(:,:, numel(Subjects)+1) = reshape(SEMDprime, [numel(ROIs), numel(Conditions)+1]);



assignin('base', 'AllAccuracy', AllAccuracy)
% assignin('base', 'pValues', pValues)
assignin('base', 'Accuracy', Accuracy)
assignin('base', 'StdError', StdError)
assignin('base', 'dprime', dprime)

FigRect = Screen('Rect',max(Screen('Screens')));
FigRect(3) = 3*FigRect(3)/4;
FigRect(4) = FigRect(4)/3;

%=============================== PLOT DATA ================================
for S = 1:numel(Subjects)+1
    figure;
    
    if PlotDprime == 0
        Plot(S) = barweb(Accuracy(:,:,S), StdError(:,:,S), StdError(:,:,S), 1, [], [], ROIlabels);%, groupnames, bw_title, bw_xlabel, bw_ylabel, bw_colormap, gridstatus, bw_legend);
        Measure = 'Accuracy';
    elseif PlotDprime == 1
        Plot(S) = barweb(dprime(:,:,S), dStdError(:,:,S), dStdError(:,:,S), 1, [], [], ROIlabels);%, groupnames, bw_title, bw_xlabel, bw_ylabel, bw_colormap, gridstatus, bw_legend);
        Measure = 'DPrime';
    end
    hold on;
    if PlotDprime == 0
        xlim = get(gca, 'xlim');
        plot(xlim, [0.5,0.5], '-r', 'LineWidth', 2);
%         set(gca, 'ylim',[min([min(Accuracy{S}),0.5]) 1]);
        set(gca, 'ylim',[0.4 1]);
        ylabel('Prediction accuracy', 'FontSize', 12, 'FontWeight','bold');
    else
%         set(gca, 'ylim', [-1 2]);
        ylabel('d''', 'FontSize', 12, 'FontWeight','bold');
    end
    xlabel('ROI', 'FontSize', 12, 'FontWeight','bold');                	% Add x- and y-axis titles
    set(gca,'XTickLabel',ROIlabels);
    if S <= numel(Subjects)
        Title = sprintf('Subject %s', Subjects{S});
        Filename = fullfile(OutputDir, ['SVM_',Measure,'_', Subjects{S}]);
    else
        Title = sprintf('Group Mean (N = %d)', numel(Subjects));
        Filename = fullfile(OutputDir, ['Group_Mean_SVM_',Measure]);
    end
    title(Title, 'fontsize',12, 'FontWeight','bold'); 
    legend(Legend, 'Location', 'NorthEast');
    set(gca,'YGrid','on');
    
    if DifferentROIs == 1
        set(gcf, 'position', FigRect);                              % Resize figure to fill window
    end
    saveas(gcf, Filename, 'fig');
    FigNames{S} = Filename;
end


% figure;
% Pathways{1} = [1 2];
% Pathways{2} = [3 4 5];
% Pathways{3} = [6 7 8 9 10];
% Parthway{4} = [11 12 13];
% for i = 1:3
%     MeanFig(i) = subplot(1,3,i);
%     Plot(S) = barweb(Accuracy(:,:,end), StdError(:,:,end), StdError(:,:,end), 1, [], [], ROIlabels);%, groupnames, bw_title, bw_xlabel, bw_ylabel, bw_colormap, gridstatus, bw_legend);
%     Measure = 'Accuracy';
%     hold on;
%     
%     
% end






close all;
for S = 1:numel(Subjects)+1
    open(strcat(FigNames{S}, '.fig'));
    if DifferentROIs == 1
        screen2png(FigNames{S});
    else
        saveas(gcf, FigNames{S}, 'png');
    end
end

[IndexpValues phi] = PlotIndex(Accuracy, Subjects, ROIs, ROIlabels, Conditions);


% function map = rainbow(m)
% %
% %   function map = rainbow(m)
% %
% %   RAINBOW(M) returns an M-by-3 matrix containing an RAINBOW colormap.
% %   RAINBOW, by itself, is the same length as the current colormap.
% %
% %   For example, to reset the colormap of the current figure:
% %
% %             colormap(rainbow)
% %
% %   See also GRAY, HOT, COOL, BONE, COPPER, PINK, FLAG, PRISM, JET,
% %   COLORMAP, RGBPLOT, HSV2RGB, RGB2HSV.
% %
% % March 98H.Yamamoto
% 
% if nargin < 1, m = size(get(gcf,'colormap'),1); end
% % h = (0:m-1)'/max(m,1);
% h = (m-1:-1:0)'/max(m,1);
% if isempty(h)
%   map = [];
% else
%   map = hsv2rgb([h ones(m,2)]);
% end