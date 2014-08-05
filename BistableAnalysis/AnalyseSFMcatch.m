
%========================== AnalyseSFMcatch.m =============================
% Collects SFMcatch data from all sessions for a single subject (navigating
% the prescribed folder structure) and analyses perceptual report and eye 
% tracking data for each session, before calculating averaged normalized
% perceptual switch rate statistics.
%
% DEPENDENCIES:
%       APMSubfunctions + EyelinkSubfunctions
%       CalAnalysis.m (old version for 9-point cross cal)
%       AnalyseBistable.m
%       ExtractOKN.m
%
% 23/12/2011 - Written by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

clear all
RootDir = 'G:\Parietal patients\Results';
SubfunctionDir = 'G:\Parietal patients\BistableMATLAB\APMSubfunctions';
addpath(SubfunctionDir);
addpath(genpath(SubfunctionDir));                                          % Add subfolders within APM subfunction folder


% SubjectDir = uigetdir(RootDir, 'Select subject to analyse');
SubjectDir = 'G:\Parietal patients\Results\MH';


[SessionDir, Subject] = fileparts(SubjectDir);
SessionDirs = dir(SubjectDir);
SessionDirs = SessionDirs(3:end);
AllData = [];
for Session = 1:numel(SessionDirs)
    fprintf('\n\nAnalysing session %s data...\n', SessionDirs(Session).name);
    cd(fullfile(SubjectDir, SessionDirs(Session).name));
    CalDir = dir('Cal*');                       % Get Eyelink calibration directories
    SFMcatch = dir('SFMcatch*');                % Get SFMcatch .mat files
    SFMEDFs = dir('*.edf');                     % Get .edf files
    SFMDATs = dir('*DAT.mat');                  % Get DAT.mat files
    
    %====================== GET CALIBRATION DATA ==========================
    for Cal = 1:numel(CalDir)
        fprintf('Analysing calibration data %s (%d of %d)\n', CalDir(Cal).name, Cal, numel(CalDir));
        cd(CalDir(Cal).name);
        TargetPosFile = dir('*pos.mat');
        CalDATfile = dir('*DAT.mat');
        load(TargetPosFile.name);
        CalDATfile = fullfile(SubjectDir, SessionDirs(Session).name, CalDir(Cal).name, CalDATfile(1).name);
        EL{CalDir} = CalAnalysis(TargetPos, CalDATfile);
        cd(fullfile(SubjectDir, SessionDirs(Session).name));
    end
    
    %=====================
    if numel(SFMEDFs)~= numel(SFMDATs)          % Check if all .edfs were sucessfully converted to dat.mats
        
        
    end
    
 
    for n = 1:numel(SFMcatch)
    
        
        
    end
    
%     for Block = 1:numel(SFMthreshData)
%        load(SFMthreshData(Block).name);     
%        Trials(Trials(:,4)==0,:) = [];       % Delete trials that weren't completed
%        if numel(Trials(1,:)<6)
%           Trials(:,6) = Trials(:,2).*Trials(:,5);
%           Trials(Trials(:,6)==-1, 6) = 0;
%        end
%        AllData = [AllData; Trials];         % Add trials from current block to all data
% %        PlotCurve(Trials, Subject, 0);
%     end
end


