% function [output] = AnalyzeVernier(SubjectDir, Conditions)

%========================= AnalyzeVernier.m ===============================
% Loads and analyses behavioural performance on the vernier accuity task
% from data stored in the matrix VernierData, which has the columnar
% organization:
%   1: Condition
%   2: Vernier offset from centre (pixels)
%   3: Subject's response (direction)
%   4: Subject's reaction time (seconds)
%   5: Response accuracy
% 
% INPUTS:
% SubjectDir:   is the directory containing a folder for each subject, each
%               with a single session folder inside, each containing a .mat 
%               file for each run, each containing a VernierData matrix.
% Conditions:   is a cell array of stings for each condition, in order,
%               with the first being 'fixation', which coresponds to
%               condition index '0' in the VernierData matrix.
%
% e.g. Conditions Index for texture & disparity slant experiment:
%   0: Fixation
%   1: +60 Disparity only
%   2: -30 Disparity only
%   3: +60 Texture only
%   4: -30 Texture only
%   5: +60 % Congruent texture and disparity
%   6: -30 % Congruent texture and disparity
%   7: Incongruent texture and disparity 1 
%   8: Incongruent texture and disparity 2 
%
% Three subplots are plotted, equivalent to Figure S3 parts A,B and C in 
% the supplementary materials section of Ban et al.(2012). Additionally,
% psychometric curves (equivalent of S3A) are plotted for each subject in a
% separate figure.
%
% DEPENDENICES:
%       Psignifit toolbox
%       APMSubfucntions
%       
%
% REFERENCES:
% Ban H, Preston TJ, Meeson A & Welchman AE (2012). The integration of motion 
%   and disparity cues to depth in dorsal visual cortex. Nature
%   Neuroscience, 
% Popple AV, Smallman HS & Findlay JM (1998). The area of spatial integration  
%   for initial horizontal disparity vergence. Vision Research 38, 319-326. 
%
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================

% Conditions = {'Fixation','T0 D60','T0 D-30','T60 D0','T-30 D0','T60 D60','T-30 D-30','T-30 D60','T60 D-30'};
Conditions = {'Fixation','Disparity 60°','Disparity -30°','Texture 60°','Texture -30°','Congruent 60°','Congruent -30°','Incongruent T-30° D60°','Incongruent T60° D-30°'};
PlotColour = {'-k','-r','--r','-b','--b','-g','--g','-m','--m'};
ConditionsIndex = 0:1:numel(Conditions);
MarkerSize = 4;

if nargin < 1
	SubjectDir = uigetdir(startpath, 'Select session folder');      % ask user to specify directory containing group behaviorual data
    cd(SubjectDir);
end
RootDir = cd;
addpath(strcat(RootDir(1:3),'APMSubfunctions'));
addpath(genpath(strcat(RootDir(1:3),'APMSubfunctions')));
addpath('D:\psignifit');

%=============================== LOAD DATA ================================
AllFiles = dir;
VernierResults = [];
DeleteFolder = [1 2];
SubjectCount = 0;
for S = 3:numel(AllFiles)
    if AllFiles(S).isdir
        SubjectCount = SubjectCount+1;
        SubjectIDs{SubjectCount} = AllFiles(S).name;
        SessionDir = dir(AllFiles(S).name);
        cd(fullfile(AllFiles(S).name, SessionDir(3).name));
        Matfiles = dir('*.mat');
        Designfiles = dir('*.txt');
        fprintf('Acquiring data from %s, %d runs...\n', AllFiles(S).name, numel(Matfiles));
        for Run = 1:numel(Matfiles)
            load(Matfiles(Run).name);                                   
            VernierData(:,7) = ones(1,numel(VernierData(:,1)))*SubjectCount; 	% Record subject number in column 7
            VernierResults = [VernierResults; VernierData];                     % Concatenate subject results data
        end
        cd(RootDir);
    else
        DeleteFolder(end+1) = S;
    end
end
AllFiles(S) = [];
VernierResults = sortrows(VernierResults);
VernierResults(isnan(VernierResults(:,2)),:) = [];              % Remove trials where no vernier target was presented
VernierResults(:,6) = VernierResults(:,3);                      % Copy subject's responses to column 6 of VernierResults matrix
VernierResults(VernierResults(:,6)==-1,6) = 0;                  % Score 'left' (-1) responses as zero
VernierOffsets = unique(VernierResults(:,2));                   % Find the number of vernier offsets presented


%============================ PLOT INDIVIDUAL SUBJECTS ====================
figure(1);
for S = 1:SubjectCount
    s(S) = subplot(5,3,S);
    clear VernierData;
    VernierData = VernierResults(VernierResults(:,7)==S,:);               	% Find trials for current subject
    for C = 1:numel(Conditions)
        AllTrials{S,C} = find(VernierData(:,1)==ConditionsIndex(C));     	% Find trials for current condition
        NoTrials(S,C) = numel(AllTrials{S,C});                                 

        Misses = find(isnan(VernierData(AllTrials{S,C},3)));               	% Find trials for this condition where no response was provided
        NoMisses(S,C) = numel(Misses);
        VernierData(Misses,:) = [];                                      	% Erase trials without responses
        Trials{S,C} = find(VernierData(:,1)==ConditionsIndex(C));        	% Find trials for current condition
        NoTrials(S,C) = numel(Trials{S,C});

        for V = 1:numel(VernierOffsets)
            OffsetTrials{S,C,V} = VernierData(Trials{S,C},2)==VernierOffsets(V);
            if numel(OffsetTrials{S,C,V}) == 0
                PropRight(S,C,V) = nan;
            else
                PropRight(S,C,V) = nanmean(VernierData(Trials{S,C}(OffsetTrials{S,C,V}),6));     	% Find the proportion or 'right' responses
                TotRight(S,C,V) = nansum(VernierData(Trials{S,C}(OffsetTrials{S,C,V}),6));         % Find the total number of 'right' responses
                TotTrials(S,C,V) = sum(OffsetTrials{S,C,V})-numel(find(isnan(VernierData(Trials{S,C}(OffsetTrials{S,C,V}),6))));                                        % Find the total number of trials for this offset
            end
        end
        data(:,1) = VernierOffsets;
        data(:,2) = permute(TotRight(S,C,:),[3,2,1]);
        data(:,3) = permute(TotTrials(S,C,:),[3,2,1]);
        [slope(S,C),threshold(S,C),error(S,C),h(S,C),sd(S,C),se(S,C),upperlim(S,C),lowerlim(S,C),struct{S,C}] = do_pfit2(data, 1, PlotColour{C}(end),MarkerSize);
        hold on;
        clear data;
    end
    set(gca,'ylim',[0 1]);
    xlabel('Vernier offset from centre (arcmin)');
    ylabel('Proportion ''right'' responses');
    title(SubjectIDs{S},'FontSize', 12, 'FontWeight','bold');
    set(gca,'TickDir','out');
    box off;
end
rect = Screen('rect', max(Screen('screens')));
set(gcf, 'position', rect);     
set(s, 'xlim', [-4 4])
set(s, 'xtick', -3:3)
legend(Conditions);


%============================ PLOT GROUP DATA =============================
figure(2);
f(1) = subplot(2,1,1);
for C = 1:numel(Conditions)
    for V = 1:numel(VernierOffsets)
        GroupPropRight(C,V) = sum(PropRight(:,C,V));
        GroupTotRight(C,V)= sum(TotRight(:,C,V));
        GroupTotTrials(C,V) = sum(TotTrials(:,C,V));
    end
    data(:,1) = VernierOffsets;
    data(:,2) = GroupTotRight(C,:)';
    data(:,3) = GroupTotTrials(C,:)';
    [GroupSlope,GroupThreshold,GroupError,Grouph,GroupSD,GroupSE,GroupUpperlim,GroupLowerlim,GroupStruct] = do_pfit2(data, 1, PlotColour{C}(end),MarkerSize);
    hold on;
end
set(gca,'ylim',[0 1]);
xlabel('Vernier offset from centre (arcmin)');
ylabel('Proportion ''right'' responses');
set(gca,'TickDir','out');
box off;
legend(Conditions);

%================================= ANALYSE BIAS ===========================
MeanThresh = mean(threshold);
SEMThresh = std(threshold)/sqrt(numel(threshold(:,1)));
MeanThresh(2,:) = 0;
SEMThresh(2,:) = 0;
f(2) = subplot(2,2,3);
hBias = barweb(MeanThresh', SEMThresh', SEMThresh', 1, [], [], Conditions,[], [0 1 1], 'none', Conditions);
xlabel('Stimulus condition');
set(gca,'XTickLabel', Conditions);
% xticklabel_rotate([],45,[],'Fontsize',10)
ylabel('Bias (arcmin)');
set(gca,'TickDir','out');
box off;

%================================ ANALYSE SLOPE ===========================
MeanSlope = mean(slope);
SEMSlope = std(slope)/sqrt(numel(slope(:,1)));
MeanSlope(2,:) = 0;
SEMSlope(2,:) = 0;
f(3) = subplot(2,2,4);
hBias = barweb(MeanSlope', SEMSlope', SEMSlope', 1, [], [], Conditions,[], [0 1 1], 'none', Conditions);
xlabel('Stimulus condition');
set(gca,'XTickLabel', Conditions);
% xticklabel_rotate([],45,[],'Fontsize',10)
ylabel('Slope');
set(gca,'TickDir','out');
box off;


%============================ PERFORM ANOVAS ==============================

%======== Perform Levene's test for homogeneity of variances
X = [Continuous2' ones(numel(Continuous2),1); Noncontinuous2' ones(numel(Continuous2),1)*2];
Levenetest(X, 0.05);

%======== Perform 2-way ANOVA
varnames = {'Condition';'Slant'};
Condition = [ones(1,numel(Continuous1)), zeros(1,numel(Noncontinuous1)), ones(1,numel(Continuous1)), zeros(1,numel(Noncontinuous1))];
zDiffs = [Continuous1, Noncontinuous1, Continuous2, Noncontinuous2]';
Slant = [ones(1,numel(zDiffs)/2), ones(1,numel(zDiffs)/2)*2]';
anovan(zDiffs,{Condition Slant},'model','full', 'varnames', varnames)
