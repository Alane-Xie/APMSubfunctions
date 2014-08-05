
%======================= AnalyseSFMThreshold.m ============================
clear all
addpath('G:\Parietal patients\BistableMATLAB\APMSubfunctions');
RootDir = 'G:\Parietal patients\Results';
% SubjectDir = uigetdir(RootDir, 'Select subject to analyse');

SubjectDir = uigetdir(RootDir, 'Select data to analyse');
% SubjectDir = 'G:\Parietal patients\Results\RH';

[SessionDir, Subject] = fileparts(SubjectDir);
SessionDirs = dir(SubjectDir);
SessionDirs = SessionDirs(3:end);
AllData = [];
for Session = 1:numel(SessionDirs)
    fprintf('\nCollating session %s...', SessionDirs(Session).name);
    cd(fullfile(SubjectDir, SessionDirs(Session).name));
    SFMthreshData = dir('SFMthresh*');
    for Block = 1:numel(SFMthreshData)
       load(SFMthreshData(Block).name);     
       Trials(Trials(:,4)==0,:) = [];       % Delete trials that weren't completed
       if numel(Trials(1,:)<6)
          Trials(:,6) = Trials(:,2).*Trials(:,5);
          Trials(Trials(:,6)==-1, 6) = 0;
       end
       AllData = [AllData; Trials];         % Add trials from current block to all data
%        PlotCurve(Trials, Subject, 0);
    end
end
AllData(:,3) = abs(AllData(:,3));

PlotCurve(AllData, Subject, 0);