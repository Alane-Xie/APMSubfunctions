
%========================== RunGroupChecks.m ==============================
% Runs multiple analyses on multiple subjects, necessary for checking data
% quality prior to SVM analysis. These can include:
%
%       Head motion (IdentifyHeadMotion.m)
%       BOLD signal by ROI (plotVTCdata.m)
%       Vernier task performance (AnalyzeVernier.m)
%       SVM accuracy by ROI size (PlotAccuracyByROISize.m)
%       
%
% HISTORY
%   21/10/2011 - Written by APM
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================

DataDir = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\fMRI data';
Subjects = {'AEW','AL','APM2','FZ','HB2','JM','KAG','LC','LP','MLP2','SM','SP','TV','WC'};
scanID = {'zk12_107', 'zk11_304', 'zk11_302', 'zk12_102', 'zk11_291', 'zk11_307', 'zk11_299', 'zk12_090','zk11_313', 'zk11_309', 'zk12_110', 'zk11_310', 'zk12_096', 'zk11_303'};

RootDir = cd;
addpath(genpath(fullfile(RootDir(1:3),'APMSubfunctions')));
cd(DataDir);

for i = 10:numel(Subjects)
    scanDir = fullfile(DataDir, Subjects{i}, scanID{i});
    voiFolder = fullfile(DataDir, Subjects{i}, 'VOIs');
    AllVoiFiles = dir(voiFolder);
    voiFileName = AllVoiFiles(3).name;
    for n = 1:numel(AllVoiFiles)
        if ~isempty(strfind(AllVoiFiles(n).name, 'combined'))
            voiFileName = AllVoiFiles(n).name;
        end
    end
    
%     IdentifyHeadMotion(scanDir);                                                      % Plot head motion
    plotVTCdata(DataDir, Subjects{i}, scanID{i}, fullfile(voiFolder,voiFileName));      % Plot BOLD signal by ROI
end