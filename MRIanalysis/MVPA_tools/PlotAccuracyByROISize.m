function [Accuracy, StdError, Voxels] = PlotAccuracyByROISize(Conditions, Subjects, ROIs)

%======================== PlotAccuracyByROISize.m =========================
% Plots SVM classification accuracy by ROI size (voxels) as requested. This
% is based on the data structure returned by Matlab MVPA Toolbox v3.05 by
% Alan Meeson in the CNIL at the University of Birmingham. 
%
% INPUTS
%   Conditions: a cell array of strings of folder names containing the data
%               for each condition to analyse.
%   Subjects:   a cell array of strings of folder names containing the data
%               for each subject to analyse.
%   ROIs:       a cell array of strings of folder names containing the data
%               for each region of interest to analyse.
%
% 14/11/2011 - Written by Aidan Murphy (apm909@bham.ac.uk)
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================
RootDir = fileparts(mfilename('fullpath'));
SVMroot = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\svm analysis';
% SVMroot = '\\psg-zk-hpc-head\HPCData\Data\Aidan\svm analysis';
pathseps = find(SVMroot==filesep);
OutputDir = SVMroot(1:pathseps(end));
if ~exist(fullfile(OutputDir, 'Voxelwise_Accuracy'),'dir')
    mkdir(fullfile(OutputDir, 'Voxelwise_Accuracy'));
end

% if nargin < 1
%     ConditionPath = uigetdir(SVMroot, 'Select SVM data to plot');
%     Conditions{1} = fileparts(ConditionPath);
% end
DifferentROIs = 0;

%====================== SPECIFY WHICH DATA TO PLOT ========================
if nargin < 3
%     Conditions{1} = 'Slant_TrainD_TestD_voxels_1000';
%     Conditions{2} = 'Slant_TrainT_TestT_voxels_1000';
%     Conditions{3} = 'Slant_TrainD+T_TestD+T_voxels';
%     Conditions{4} = 'Slant_TrainD-T_TestD-T_voxels';
    Conditions{1} = 'Slant_TrainD_TestT_RFE_1000';
    Conditions{2} = 'Slant_TrainT_TestD_RFE_1000';

    Subjects = {'AEW','AL','APM2','HB2','JM','KAG','LC','MLP2','SP','SM','TV','WC'};
    MaxNoVoxels = 1000;
    
    if  DifferentROIs == 1
        ROIs = {'V1','V2','VP','V4','LO','pFs','V3','V3A','KO','V7','MT', 'MTplus', 'VIPS', 'POIPS', 'DIPSM', 'DIPSA'};  % BVQX names of ROIs to process
        ROIlabels = {'V1','V2','V3v','V4','LO','pFs','V3d','V3A','KO/V3B','V7','MT', 'MT+/V5', 'VIPS', 'POIPS', 'DIPSM', 'DIPSA'}; 
    else 
        ROIs = {'V1','V2','VP','V4','LO','V3','V3A','KO','V7','MTplus'};            % BVQX names of ROIs to process
        ROIlabels = {'V1','V2','V3v','V4','LO','V3d','V3A','KO/V3B','V7','MT+/V5'}; 
    end
end

%==================== IMPORT DATA FROM SVM_ANALYSIS OUTPUT ================
Accuracy{1} = zeros(numel(ROIs),numel(Conditions));
StdError{1} = zeros(numel(ROIs),numel(Conditions));
for Subject = 1:numel(Subjects)
    fprintf('\n\nProcessing subject %s data...\n', Subjects{Subject});
    for Condition = 1:numel(Conditions)                                     % For each MVPA classification...
    %     if ~exist('Subjects','var')                                     % If a list of subject IDs was not provided...
    %         Subjects = Dir(fullpath(SVMroot, Conditions{Condition}));   % Analyse all subjects in each folder
    %     end
        cd(fullfile(SVMroot, char(Conditions{Condition}), char(Subjects{Subject}), 'results',''));
        for ROI = 1:numel(ROIs)                                             % For each ROI...
            ROIFile = dir(strcat('*',ROIs{ROI},'*.mat'));
            if numel(ROIFile) > 1
                ROIFile = ROIFile(1);
            end
            if numel(ROIFile) ~= 1
                fprintf('Error: %d files were found for %s ROI in %s!\n', numel(ROIFile), ROIs{ROI}, fullfile(char(Conditions{Condition}), char(Subjects{Subject}), 'results',''));
                return
            end
            load(ROIFile(1).name); 
            if numel(cv_accuracy) == 1
                fprintf(['Error: accuracy data for only one ROI size was returned!\n',...
                'Error: Please use the pattern plot script.\n']);
            end
            Accuracy{Subject,ROI} = cv_accuracy;
            StdError{Subject, ROI} = cv_std_error;
            Voxels{Subject, ROI} = num_voxels;
            clear cv_accuracy cv_std_error
        end
        fprintf('Condition %d: %s completed!\n', Condition, Conditions{Condition});
        cd(RootDir);

        %============================= PLOT DATA ==========================
        h = figure;
        for ROI = 1:numel(ROIs)
            f(ROI) = subplot(4,4,ROI);
            UpperSE = Accuracy{Subject,ROI}+StdError{Subject,ROI};
            LowerSE = Accuracy{Subject,ROI}-StdError{Subject,ROI};
            shadedplot(Voxels{Subject, ROI}, UpperSE, LowerSE, [0.5 0.5 1], 'b');
            hold on;
            plot(Voxels{Subject, ROI}, Accuracy{Subject,ROI},'-k', 'LineWidth',2);
            xlim = get(gca, 'xlim');
            plot(xlim, [0.5,0.5], '-r', 'LineWidth', 2);
            set(gca, 'xlim', [0 MaxNoVoxels]);
            xlabel('# voxels', 'FontSize', 8);                     % Add x- and y-axis titles
            ylabel('Prediction accuracy', 'FontSize', 8);
            Title = sprintf('%s', ROIlabels{ROI});
            title(Title, 'fontsize',12, 'FontWeight','bold'); 
            set(gca, 'ylim',[0 1]);
        end
        FigTitle = sprintf('%s: Subject %s', Conditions{Condition}, Subjects{Subject});
        suptitle(FigTitle);
        linkaxes(f,'x');                                                                % Link axes on horizontal and vertical position plots
        rect = Screen('rect', max(Screen('screens')));                                	% Get screen resolution
        set(gcf, 'position', rect);                                                  	% Resize figure to fill half screen
        FigName = fullfile(OutputDir, strcat(Conditions{Condition},Subjects{Subject}));
        FigNames{Condition, Subject} = FigName;
        saveas(h, FigName, 'fig');
    end

end

%====================== SAVE FIGURES AS IMAGE FILES =======================
close all;
for Subject = 1:numel(Subjects)
    for Condition = 1:numel(Conditions)
        open(strcat(FigNames{Condition, Subject}, '.fig'));
        set(gcf, 'position', rect);                             % Resize figure to fill screen
     	screen2png(FigNames{Condition, Subject});
    end
end
close all;

function screen2png(filename)
%SCREEN2JPEG Generate a JPEG file of the current figure with
% dimensions consistent with the figure's screen dimensions.
%
% SCREEN2JPEG('filename') saves the current figure to the
% JPEG file "filename".
%
% Sean P. McCarthy
% Copyright (c) 1984-98 by MathWorks, Inc. All Rights Reserved

if nargin < 1
error('Not enough input arguments!')
end

oldscreenunits = get(gcf,'Units');
oldpaperunits = get(gcf,'PaperUnits');
oldpaperpos = get(gcf,'PaperPosition');
set(gcf,'Units','pixels');
scrpos = get(gcf,'Position');
newpos = scrpos/100;
set(gcf,'PaperUnits','inches',...
'PaperPosition',newpos)
print('-dpng', filename, '-r100');
drawnow
set(gcf,'Units',oldscreenunits,...
'PaperUnits',oldpaperunits,...
'PaperPosition',oldpaperpos)