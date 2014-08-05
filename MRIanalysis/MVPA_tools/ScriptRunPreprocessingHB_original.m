% =========================
% ScriptRunPreprocessingAll
% =========================
%
% Run fMRI data preprocessig procedures
% semi-automatically & step-by-step
% 
% [generated directory & data structure]
%
% {ExpName}
%     |
%     |
% {PreProcessed_dir}-{sName}-{sIDs}-------(fMRI data)
%                     |   |_{ROI_vtc}
%                     |   |    |_{design}-(design files)
%                     |   |    |_{glm}----(glm files)
%                     |   |    |_{mask}---(mask files)
%                     |   |    |_{prt}----(prt files)
%                     |   |    |_{rtc}----(rtc files)
%                     |   |    |_{smp}----(smp files)
%                     |   |    |_{vmp}----(vmp files)
%                     |   |    |_{vtc}----(vtc files)
%                     |   |_{voi_files}---(voi files)
%                     |   |_{poi_files}---(poi files)
%                     |   |_{PARRECs}-----(raw PAR/RECs)
%                     |_{3d}--------------(3d anatomy)
%
% Last Update: "2011-03-16 19:15:29 banh"

cd('D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant');

% add path to HB's tools
addpath('D:\fMRIDataAEW04\BVQX_hbtools');
addpath('D:\fMRIDataAEW04\BVQXtools_v07g\BVQXtools_v08d');
% addpath('D:/Hiroshi/MATLABtoolbox/BrainVoyagerProcessing/BVQX_hbtools');
% addpath('D:/Hiroshi/MATLABtoolbox/BrainVoyagerProcessing/BVQXtools_v08d');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Please change the parameters listed below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BVver=2;                        % BrainVoyager's version
ExpName='TextureSlant';         % Experiment name

sName='JG';                     % Subject name
sID='zk11_314';                 % Scan ID
RunsToUse = 5:10;               % Select which runs to use


% PreProcessed_dir='../fMRI_preprocessed';
% PreProcessed_dir = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\zk11_270';
% PreProcessed_dir = '..\Aidan\MRI_DATA\TextureSlant\fMRI data';
PreProcessed_dir = 'fMRI data';
% SVM_dir='../SVM_standard';
% SVM_dir= 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\zk11_270\SVM_standard';
SVM_dir= '\SVM_standard';
% SVM_dir= fullfile('fMRI data', sName, sID, 'SVM_standard');

% set stimulus conditions, required to generate PRT files
% cond_params: stimulus condition, Nx5 cells
%              N is the number of different types of PRTs
%              to be generated (main, localizer, etc.)
%               -- cond_params{N}{1} = the names of stimulus conditions
%               -- cond_params{N}{2} = IDs of stimulus conditions, cell {0,1,2,3,...}
%               -- cond_params{N}{3} = colors of each condition
%                                      (n x 3 matrix)(n = the number of conds)
%               -- cond_params{N}{4} = parameters used to generate PRT files
%               -- cond_params{N}{5} = the runs to be used (eg. [1,3,5:8]) (optional)
% For details, see 'RunPreprocessing' & 'ConvertBlockDesign2PRT'

cond_params{1}{1}= {'Fixation', 'T0_D60', 'T0_D-30', 'T60_D0', 'T-30_D0', 'T60_D60', 'T-30_D-30', 'T-30_D60', 'T60_D-30'};
cond_params{1}{2}={0,1,2,3,4,5,6,7,8};
cond_params{1}{3}=[127  127 127;
                   127  0 	0;   
                   0    127	0;
                   0    0   127; 
                   127  127	0;
                   127 	0   127;   
                   0    127 127;
                   127  255	0;   
                   0    127 255];
cond_params{1}{4}=struct('PRTType','Volumes','Experiment',ExpName,'VolumesPerBlock',8,'SkipVolumes',0);
cond_params{1}{5}=RunsToUse;

% GLM setup parameters
% For details, see 'RunAllAfterVTCcreation'
mdm_params='';
glm_params=struct('nvol', 208, 'prtr', 2, 'rcond', 0);
use_runs= RunsToUse;

% MVPA directory structure setup parameters
file_prefixes.hmc='3DMC';
file_prefixes.msk='zk11_';
file_prefixes.prt='design';
file_prefixes.rtc='design';
file_prefixes.vmp='zk';
file_prefixes.voi='*combined';
file_prefixes.vtc='*LTR_THP3c';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Please do not change the codes below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Preprocessing
do_flag_1=[1,1,1,1,1];
RunPreprocessing(PreProcessed_dir,sName,sID,cond_params,do_flag_1);

% GLM & MVPA setup
do_flag_2=[1,1,1,1,1,1,1,1,1];
RunAllAfterVTCcreation(PreProcessed_dir,SVM_dir,sName,sID,mdm_params,glm_params,use_runs,file_prefixes,BVver,do_flag_2)

% remove path to HB's tools
% rmpath('D:/Hiroshi/MATLABtoolbox/BrainVoyagerProcessing/BVQX_hbtools');
% rmpath('D:/Hiroshi/MATLABtoolbox/BrainVoyagerProcessing/BVQXtools_v08d');
