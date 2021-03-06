function IdentifyHeadMotion(scanDir, subjID, scanID, Threshold, volPerBlock)

%======================== IdentifyHeadMotion.m ============================
% This function analyses 3D motion correction data from BrainVoyagerQX for 
% each run within a scan session. It plots translational head movements in
% each direction (x,y and z) and identifies sharp head motion between 
% consecutive volumes. Volumes containing sharp head motion are saved to a
% .mat file so that they can be excluded from subsequent analysis (e.g.
% MVPA).
%
% INPUTS
%   scanDir:    directory of scan session to analyse
%   subjID:     subject initials or ID number (e.g. 'APM')
%   scanID:     scan session ID (e.g. 'zk10_147')
%   Threshold:  maximum acceptable movement between consecutive volumes (mm)
%   volPerBlock:number of volumes in each block
% 
% HISTORY
% 29/11/2011 -  Updated by APM. This function was developed from code provided
%               by Matthew Patten and Sheng Li in the CNIL.
% 30/04/2012 -  Updated to analyse movement by condition for block designs
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================
global motion
if nargin < 1
    DefaultScanDir = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\fMRI data\';
    scanDir = uigetdir(DefaultScanDir, 'Select scan session folder');
end
if nargin < 3
 	pathseps = find(scanDir==filesep);
    scanID = scanDir(pathseps(end)+1:end);
    subjID = scanDir(pathseps(end-1)+1:pathseps(end)-1);
    volPerBlock = 8;
end
BoxColour = [0.75 0.75 0.75];
scanDir = scanDir(1:pathseps(end-1));
if nargin < 4
    Threshold = 0.5;        % Set default threshold for identifying sharp movement (mm/� between consecutive volumes)
end

if ~exist(fullfile(scanDir,'HeadMotion'),'dir')
    mkdir(fullfile(scanDir,'HeadMotion'));
end
Plotfilename = fullfile(scanDir,'HeadMotion',[subjID '_' scanID]);      % Create plot output filename
scanDir = fullfile(scanDir, subjID, scanID);                            % Locate file directory
SDMs = dirrec(scanDir,'.sdm');                                          % find all .sdm files within specified directory
sdmCount = 1;
for i=1:length(SDMs)
    lengthSDM = length(SDMs{i});
    if strcmp(SDMs{i}((lengthSDM-7):lengthSDM),'3DMC.sdm')              % if specifically a motion correction sdm file
        motionSDMs{sdmCount} = SDMs{i};
        sdmCount = sdmCount + 1;
    end
end

%===================== IDENTIFY SHARP HEAD MOVEMENTS ======================
noOfSDMs = 0;                                           %initial setting
for j=1:length(SDMs)
    if strcmp(SDMs{j}((end-7):end),'3DMC.sdm')
        noOfSDMs = noOfSDMs + 1;
        NewSDMs{noOfSDMs} = SDMs{j};
    end
end
SDMs = NewSDMs;
for i=1:noOfSDMs
    filename = fullfile(scanDir, strcat(subjID, '_motion_correction'));
    IdentifySharpMotion(SDMs, filename, Threshold)
end

%====================== PLOT MOVEMENTS FOR EACH RUN =======================
f = figure('Units','normalized','Position',[0 0 1 1]);  
movementCutOff = 7;                                                     % Set default y-axis limits (mm)
MovementAxisColour = {'r','g','b','c','m','y'};
for j=1:length(motionSDMs)                                              % For each run/ motion correction file...
    currentFile = BVQXfile(motionSDMs{j});                              % Load the BVQX file into MATLAB
    transMovement = currentFile.SDMMatrix(:,1:6);                       % Load the movements from each volume
    noOfVolumes = size(transMovement, 1);    
    noOfBlocks = ceil(noOfVolumes/volPerBlock);
    h(j) = subplot(ceil(length(motionSDMs)/3),3,j);                     % Put figure in appropriate position of the subplot
    for block = 1:2:noOfBlocks
        X = [block*volPerBlock, block*volPerBlock, (block+1)*volPerBlock, (block+1)*volPerBlock,];
        Y = [-movementCutOff movementCutOff movementCutOff -movementCutOff];
        C = zeros(size(X));
        p = patch(X,Y,C);
        hold on;
        set(p,'FaceColor',BoxColour, 'EdgeColor', 'none');            	% Fill the box with specified colour
    end
    for xyz = 1:size(transMovement,2)      
        plot(transMovement(:,xyz),MovementAxisColour{xyz},'LineWidth',2);
        hold all;
    end
    set(gca,'XLim',[0 noOfVolumes],'YLim',[-movementCutOff movementCutOff],'LineWidth',1,'FontName','Arial','TickLength',[0.02;0.025]);
    xlabel('Volumes');
    ylabel('Head movement (mm)');
    title(['Run ' num2str(j)]);
    if j==1
        legend({'Translation X','Translation Y','Translation Z'});
    end
%     for xyz=1:size(transMovement,2)                                     % For each axis (X, Y, Z)...
%         SharpMotionVols{xyz, j} = find(abs(diff(transMovement(:,xyz))) >= Threshold)+1;	% Find consecutive motion correction values exceeding threshold
%         for i=1:numel(SharpMotionVols{xyz, j})
%             plot(repmat(SharpMotionVols{xyz, j}(i),[1,2]), [-movementCutOff movementCutOff], 'r', 'LineWidth',1);
%         end
%     end

    for i = 1:numel(motion(1,j).motion_trials)
        plot(repmat(motion(1,j).motion_trials(i),[1,2]), [-movementCutOff movementCutOff], 'r', 'LineWidth',1);
    end

    hold off;
    set(gca,'TickDir','out');
    box off;
    zoom xon;
end
FinalDisplacement = max(abs(transMovement(end,[1 2 3])));
suptitle(['Head movement: ',subjID,' ',scanID]);
saveas(f, Plotfilename, 'fig');
FigRect = Screen('Rect',max(Screen('Screens')));
set(gcf, 'position', FigRect);                              % Resize figure to fill window
screen2png(Plotfilename);
% saveas(f, Plotfilename, 'png');


%======================== CHECK MOVEMENT BY CONDITION =====================
DesignDir = fullfile(scanDir,'ROI_vtc','design');
if exist(DesignDir,'dir') ~= 7
    DesignDir = uigetdir(scanDir, 'Select design files folder');
end
DesignFiles = dir(DesignDir);
DesignFiles = DesignFiles(3:end);
for d = 1:numel(DesignFiles);
   Blocks{d} = textread(fullfile(DesignDir, DesignFiles(d).name));
end
Conditions = unique(Blocks{1});

figure;


BlockVols = motion(1,j).motion_trials-floor(motion(1,j).motion_trials/volPerBlock)*volPerBlock;

keyboard


MovVolumes{1} = [];
for i = 1:numel(Conditions)
    h(i) = subplot(ceil(numel(Conditions)/2),2,i);    
    
    for j = 1:length(motionSDMs)            % For each run
        Block = find(Blocks{j}==Conditions(i));
        Volumes = Block*volPerBlock-(volPerBlock-1);
        for k = 1:numel(Volumes)
            for z = 1:numel(motion(1,j).motion_trials)
                CondVol = find(Volumes(k):Volumes(k)+(volPerBlock-1)== motion(1,j).motion_trials(z));
                if ~empty(CondVol)
                    MovVolumes{i}(end+1) = CondVol;
                end
            end
        end
    end
end

%================= display results from the file created ==================
load (filename);
fprintf('\n\n================= SHARP HEAD MOVEMENT DETECTION ===================\n');
fprintf('Subject ID.......... %s\nScan ID............. %s\nMovement threshold.. %.2f mm\nNumber of runs...... %d\n',subjID, scanID, Threshold, noOfSDMs);
fprintf('Maximum displacement at end of run %d = %.2f mm\n\n', length(motionSDMs), FinalDisplacement);
fprintf('The following volumes contain sharp head movements:\n');
sumSharpMotion = 0;
for i=1:length(motion)
	fprintf('Run %d: %s\n', i, num2str(motion(1,i).motion_trials));
    sumSharpMotion = sumSharpMotion + length(motion(1,i).motion_trials);
end
fprintf('Total number of volumes containing sharp motion = %d\n', sumSharpMotion);
end

function IdentifySharpMotion(SDMFiles, OutputFile, Threshold)

%======================= IdentifySharpMotion.m ============================
% function to identify any volumes which are subject to sharp movement
% works by checking if there is a change of either 1mm or 1 degree between
% subsequent volumes in any direction or orientation
%
% Parameters:
%       SDMFiles........cell array containing fully qualified path for motion SDM files to
%                       check - one SDM file per run
%       VolumesPerRun...number of volumes per run
%       Threshold.......threshold for sharp motion (mm) between consecutive
%                       volumes
%       OutputFile......fully qualified path for mat file listing volumes which show
%                       sharp motion
%
% XX/XX/2009 - Written by Sheng Li
% 07/12/2011 - Updated to auto detect number of volumes in each run (APM & MLP)
%==========================================================================
global motion
interval = 2;                                       % index difference between two volumes to check
numMotionPredictors=6;                              % motion predictors - x,y,z translation and orientation

motion_trials = cell(1,length(SDMFiles));
for f = 1:length(SDMFiles); 
    sdm = BVQXfile(SDMFiles{f});                    % load SDM file
    VolumesPerRun = size(sdm.SDMMatrix, 1);
  	motion_vol = zeros(6,VolumesPerRun-interval);   % 6 corresponds to number of predictors for motion correction
    for i = 1:numMotionPredictors
        tmp = sdm.SDMMatrix(:,i);
        for j = 1:VolumesPerRun-interval
            for k = 1:interval
                if abs(tmp(j)-tmp(j+k)) > Threshold % sharp motion detected on specific predictor
                    motion_vol(i,j:j+k) = 1;
                end
            end
        end
    end
    motion_trials{f} = find(sum(motion_vol)>0);     % get indices of volumes with sharp motion - in any direction/orientation
	motion(f).filename=SDMFiles{f};                 
	motion(f).motion_trials=motion_trials{f};
end
save(OutputFile,'motion')
end