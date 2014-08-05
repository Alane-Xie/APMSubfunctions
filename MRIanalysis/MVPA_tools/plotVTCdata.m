function plotVTCdata(expDir, subjID, scanID, voiFileName, PlotVols)
% function plotVTCdata(expDir, subjID, scanID, voiFileName, PlotVols)

%========================== plotVTCdata.m =================================
% This script plots the time course for the first N volumes of each run 
% within a session, in each VOI.
%
% INPUTS
%   expDir:     where all the files for all subjects are located for this 
%               particular experiment. Usually ending in \fMRI Data\
%   subjID:     the initials of the subject used to separate different 
%               participants. e.g. MLP
%   scanID:     Given at the scanner for each session. e.g. zk11_241
%   voiFileName:The full path of the voi file that has the talariach 
%               co-ordinates we want to check the time course for. 
%               e.g. 'all_ROIs_combined.voi'
%   PlotVols:   sets the range for default x-axis limits, for which volumes
%               to display BOLD signal for ([1, n]). Default is all volumes.
%
% EXAMPLE 
%   plotVTCdata('D:\fMRIDataZK04\RelativeDepthLabel\fMRI Data\',...
%   'LMP','zk11_252','all_ROIs_combined.voi', [1,40]);
%
% HISTORY
%   21/10/2011 - Created by Matt Patten. From Australia, with love.
%   22/03/2012 - Cannibalized and streamlined by APM
%
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================
if nargin < 1
    ScanDir = uigetdir('D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\fMRI data', 'Select scan folder');
    pathseps = find(ScanDir==filesep);
    scanID = ScanDir(pathseps(end)+1:end);
    subjID = ScanDir(pathseps(end-1)+1:pathseps(end)-1);
    expDir = ScanDir(1:pathseps(end-1));
    [voiFile, voiPath, ] = uigetfile('*.voi', 'Select a .voi file', fullfile(expDir, subjID));
    voiFileName = fullfile(voiPath, voiFile);
end
    
outputDir = fullfile(expDir, 'vtc_plots', subjID);      % Create output directory
if ~exist('vtc_plots','dir')
    mkdir('vtc_plots');
end
if ~exist(outputDir,'dir')
    mkdir(outputDir);                                   % create individual subject directory
end

% voiDir = [expDir '\' subjID '\VOIs\'];      % load VOI experiment directory - assumes regular lab directory structure
allVOIs = BVQXfile(voiFileName);   % Assumes consistent naming of voi file, 

%If not consistently named use this in conjuction with Hiroshi's script 'GetFiles' (which requires 'wildcardsearch' and 'regexpdir')
%This will search for voi files in the stated directory
%prefix_voi = '*combined';
%VOIfile = GetFiles(voiDir,'*.voi',prefix_voi);
%allVOIs = BVQXfile(VOIfile);

%========================== Load VTC filenames ============================
sessionDir = [expDir '\' subjID '\' scanID '\'];        % define the session directory
allVTCfiles = dirrec(sessionDir,'.vtc')';               % find all vtc files within this directory
% allVTCfiles = allVTCfiles(1:5);             % FOR FZ ONLY!!
%restrict VTC files to a certain suffix - using BV 2.3 they all come out ending in TAL.VTC 
%so ensuring this suffix means I won't include older VTCs from previous BV versions
vtcCount = 1;
for i=1:length(allVTCfiles)
    lengthVTC = length(allVTCfiles{i});
    if strcmpi(allVTCfiles{i}((lengthVTC-6):lengthVTC),'TAL.VTC') %if specific VTC file
        vtcs{vtcCount} = allVTCfiles{i};
        vtcCount = vtcCount + 1;
    end
end

vtcs = vtcs'; % because filenames are much easier to read as a column rather than as a row!

for k=1:allVOIs.NrOfVOIs                                        % for however many vois this participant has (in the voi file)
    f(k) = figure('Units','normalized','Position',[0 0 1 1]); 	% open new figure - whole screen size
    for j=1:length(vtcs)                                        % for each VTC file
        currentFile = BVQXfile(vtcs{j});                        % load the BVQX file into MATLAB
        timeCourses = currentFile.VOITimeCourse(allVOIs);       % gather time course for this run
        AllTimeCourses(:,j) = timeCourses(21:end-20,k);
        if ~exist('PlotVols','var')
            PlotVols = [1, length(timeCourses)];
        end
        minTC = min(timeCourses(:,k));                          % find min and max of current timecourse
        maxTC = max(timeCourses(:,k));
        meanTC = mean(timeCourses(:,k));
        stdTC = std(timeCourses(:,k));
        medianTC = median(timeCourses(:,k));

        h(j) = subplot(ceil(length(vtcs)/3),3,j);               % put figure in appropriate position of the subplot
        plot(PlotVols(1):PlotVols(2), timeCourses(PlotVols(1):PlotVols(2),k),'r','LineWidth',1);   %Plot time course for specified number of volumes
        hold on;
%         plot([4 4],[minTC-50 maxTC+50],'g','LineWidth',0.5); 	%plot vertical line at middle and end of initial fixation
%         plot([8 8],[minTC-50 maxTC+50],'k','LineWidth',1); 
        set(gca,'XLim', PlotVols,'YLim',[minTC-20 maxTC+20],'XTick',[0:20:PlotVols(2)],'LineWidth',1,'FontName','Arial','TickLength',[0.005;0.01]);
        xlabel('Volumes');
        title(['Run ' num2str(j)]);
        ylabel('BOLD signal');
        box off;
        hold off;
        currentFile.ClearObject;                                                            % clear VTC file from memory   

    end
    suptitle([subjID,' ',scanID,' ',allVOIs.VOI(k).Name]);
    saveas(f(k), fullfile(outputDir, [subjID '_' scanID '_' allVOIs.VOI(k).Name]), 'fig');	% save all runs for this particular voi
    saveas(f(k), fullfile(outputDir, [subjID '_' scanID '_' allVOIs.VOI(k).Name]), 'png');
    close;                                                                                  % close the figure
    
    %====================== Plot signal distribution ======================
    g(k) = figure('Units','normalized','Position',[0.25 0.25 0.75 0.75]); 	% open new figure - middle of screen
    NotchBoxplot(AllTimeCourses);
    hold on;
    xlabel('Runs');
    ylabel('BOLD signal');
    box off;
	suptitle([subjID,' ',scanID,' ',allVOIs.VOI(k).Name]);
    saveas(f(k), fullfile(outputDir, [subjID '_' scanID '_' allVOIs.VOI(k).Name '_Box']), 'fig');	% save all runs for this particular voi
    saveas(f(k), fullfile(outputDir, [subjID '_' scanID '_' allVOIs.VOI(k).Name '_Box']), 'png');
    close;   
end
