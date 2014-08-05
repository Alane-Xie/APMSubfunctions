function SemiAutoVBM(filename)

%============================ SemiAutoVBM.m ===============================
% Semi-automated pre-processing for voxel-based morphometry (VBM) lesion 
% analysis using SPM8 for MATLAB, with visualization in MRIcron.  
%
%   STEP 1: CONVERSION TO NIfTI-1 *****************************************
%       If an image format other than .nii is selected, conversion of the selected
%       file to NIfTI will be attempted via the following methods:
%       1) SPM8                 http://www.fil.ion.ucl.ac.uk/spm/software/spm8/
%       2) dcm2nii.exe          http://www.cabiatl.com/mricro/mricron/dcm2nii.html
%       3) r2aGUI.m             http://r2agui.sourceforge.net/
%       4) dicom2Nifti111.m     http://users.fmrib.ox.ac.uk/~robson/internal/Dicom2Nifti.htm
% 
%   STEP 2: APPROXIMATE ALIGNMENT IN MNI COORDINATES **********************
%       Displays image in SPM window for manual check of orientation and
%       approximate alignment with MNI coordinate space.
%
%   STEP 3: UNIFIED SEGMENTATION ******************************************
%       Uses unified segmentation method (Ashburner & Friston, 2005) 
%       implemented in SPM5 and onward.
%       
%   STEP 4: LESION IDENTIFICATION *****************************************
%       Uses fuzzy clustering method (Seghier et al., 2008) implemented in
%       moh_LesionIdentification_short.m (provided by Mohamed Seghier).
%
% REFERENCES:
% Ashburner J & Friston KJ (2005). Unified segmentation.  NeuroImage,
%       26(3):839-851. http://dx.doi.org/10.1016/j.neuroimage.2005.02.018
% Bates E, Wilson SM, Saygin AP, Dick F, Sereno MI, Knight RT and Dronkers
%       NF (2003).  Voxel-based lesion-sympton mapping.  Nature Neuroscience,
%       6(5):448-450.  http://dx.doi.org/10.1038/nn1050
% Seghier ML, Ramlackhansingh A, Crinion J, Leff AP and Price CJ (2008).  
%       Lesion identification using unified segmentation-normalisation models 
%       and fuzzy clustering.  NeuroImage, 41:1253-1266.
%
% REVISIONS:
% 25/01/2012 - Written by Aidan Murphy (apm909@bham.ac.uk)
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================

rootDir = fileparts(mfilename('fullpath'));                     % Get just the directory path
addpath(fullfile('..\..\','APMSubfunctions'));                  % Add APM subfunction folder to path
addpath(genpath(fullfile('..\..\','APMSubfunctions')));         % Add subfolders within APM subfunction folder
clc;                                                            % Clear Matlab command line
% EditorColour([0 0 0],[1 1 1]);                                  % Adjust background colour
help SemiAutoVBM                                                % Print header information to screen

Steps = {0 0 1};

%============== Specify directories
MRIcronDir = 'D:\MRIcron';                                      % Specify path of MRIcron's dcm2nii.exe file (required for PAR/REC/DICOM conversion)
% MRIcronDir = 'C:\Program Files\MRIcron';
ControlsDir = 'home/data/patient_data/MRI_T1/Controls';         

% web('http://www.mccauslandcenter.sc.edu/mricro/mricron/install.html', '-browser');  % Open MRIcron download page

if strcmp('SPM8',spm('ver'));                       % Check SPM version   
    NiiFormatMRIcro = 'Y';                          % Specify NIfTI format for MRIcro [Y = NIfTI format, N = Analyze format]
    NiiFormatSPM = 'nii';                        	% Specify NIfTI format for SPM ('img' = 2 file (.hdr+.img),'nii' = 1 file)
    Controls = 'Oasis_control_SPM8';                % Specify name of control subjects data
elseif strcmp('SPM5',spm('ver'));
    NiiFormatMRIcro = 'Y';                          % Specify NIfTI format for MRIcro [Y = NIfTI format, N = Analyze format]
    NiiFormatSPM = 'img';                           % Specify NIfTI format for SPM ('img' = 2 file (.hdr+.img),'nii' = 1 file)
    Controls = 'Oasis_control_preprocessSPM5';      % Specify name of control subjects data
elseif strcmp('SPM2',spm('ver'));
    NiiFormatMRIcro = 'N';                          % Specify NIfTI format for MRIcro [Y = NIfTI format, N = Analyze format]
    NiiFormatSPM = 'img';                           % Specify NIfTI format for SPM ('img' = 2 file (.hdr+.img),'nii' = 1 file)
end


fprintf('============== SemiAutoVBM.m Preprocessing =================\n\n');
fprintf('MATLAB Version............. %s\n', version);                       % Check MATLAB version and release date
fprintf('SPM Version................ %s\n', spm('ver'));                    % Check SPM version
fprintf('MRIcron directory.......... %s\n', MRIcronDir);                    % Check MRIcron path


%======================= SELECT IMAGES TO PROCESS =========================
fprintf('\n=======================================================\n');
fprintf('STEP 1: Load NIfTI-1 format images to process...\n');
fprintf('=======================================================\n');
if nargin < 1
    [ImPath, ImFile, ImIndex]= uigetfile({'*.img;*.hdr;*.par;*.rec;*.dcm;*.nii'}, 'Select 3D image file(s)','MultiSelect', 'on');
    if isequal(ImFile,0) || isequal(ImPath,0)                            	% If user pressed 'Cancel'
        return                                                           	% Stop function
    end
end
if ischar(ImFile)                                                   	% If only a single file was selected...                                           
    NoImFiles = 1;
    FullFilename{1} = fullfile(ImPath, ImFile);
    [ImPath, ImName, ImExt] = fileparts(FullFilename{1});              	% Determine file type by extension
    ImFileExt{1} = ImExt;
elseif iscell(ImFile)                                                   % If multiple files were selected...
    NoImFiles = numel(ImFile);
    for i = 1:NoImFiles
        FullFilename{i} = fullfile(ImPath, ImFile{i});
        [ImPath, ImName, ImExt] = fileparts(FullFilename{i});           % Determine file types by extension
        ImFileExt{i} = ImExt;
    end
end

if Steps{1} == 1 && ~strcmpi(ImFileExt, '.nii')
    NIfTIfile = Convert2NIfTI(filenames, filepath, MRIcronDir);
else
    NIfTIfile = fullfile(ImPath, ImFile);
end


%================ OPEN NIfTI IMAGE IN SPM AND ALIGN WITH MNI ==============
if Steps{2} == 1
    fprintf('\n\n=======================================================\n');
    fprintf('STEP 2: Check orientation and alignment with MNI space\n');
    fprintf('=======================================================\n');

    %============ Display canonical MNI coordinate view
    SPMDir = fileparts(which('spm'));                                       % Find path of SPM
    CanonicalMNI = fullfile(SPMDir, 'canonical\avg152T1.nii');              % Specify canonical example of T1 in MNI coordinates for comparison
    spm_image('init',CanonicalMNI);                                         % Display canonical image
    spm_orthviews('Reposition', [22 0 -21]);                                % Reposition view
    fs = get(0,'Children');                                                 
    res = getframe(fs(1));                                                  % Capture figure window
    MNIfig = figure;                                                      	% Open new figure window
    imshow(res.cdata);                                                      % Show captured image in new window
%     imwrite(res.cdata, 'MNI.jpg');                                       	% save the window as JPG

    %============ Display NIfTI image
    spm_image('init',NIfTIfile);                                            % Display NIfTI image
    
    
    spm_check_registration(char({CanonicalMNI; NIfTIfile}));                % Check registration of NIfTI to MNI space
    Matrix = spm_get_space(NIfTIfile);                                   	% Get the voxel-to-world mapping      

    spm_realign
end


%========================== PROCESS IMAGES ================================
if Steps{3} == 1
    fprintf('\n\n=======================================================\n');
    fprintf('STEP 3: Unified Segmentation and spatial normalization\n');
    fprintf('=======================================================\n');

    %=========== Set segmentation options
    opts.tpm = [];                               % n tissue probability images for each class
    opts.ngaus = [1 3 4];                        % number of Gaussians per class (n+1 classes)
    opts.warpreg = [];                           % warping regularisation
    opts.warpco = [];                            % cutoff distance for DCT basis functions
    opts.biasreg = [];                           % regularisation for bias correction
    opts.biasfwhm = [12 12 12];                  % FWHM of Gausian form for bias regularisation
    opts.regtype = [];                           % regularisation for affine part
    opts.fudge = [];                             % a fudge factor

    results = spm_preproc(NIfTIfile, opts);         


    % Preprocessing, including segmentation and non-linear normalisation
    %     * spm_preproc (spm_config_preproc, spm_prep2sn, spm_preproc_write), SPM5's unified segmentation and normalisation
    %     * spm_normalise, the old pre-SPM5 non-unified spatial normalisation
    %     * spm_segment, the old pre-SPM5 non-unified tissue segmentation
    %     * spm_smooth
end


fprintf('\n\n=======================================================\n');
fprintf('STEP 5: Lesion definition based on fuzzy clustering\n');
fprintf('=======================================================\n');
if strcmp('SPM5',spm('ver'))
    moh_LesionIdentification_short;     
end



%=========== View in MRIcron in full screen mode with binary lesion map overlaid
fprintf('\n\n=======================================================\n');
fprintf('STEP 6: Vizualization in MRIcron and save images\n');
fprintf('=======================================================\n');

eval(sprintf('! start /MAX %s %s -o %s', fullfile(MRIcronDir,'mricron.exe'), NIfTIfile, BinaryLesionMap)); 	

fprintf('To save the binary lesion map as a .png image:\n');
fprintf('   - Open Multislice view (press ''Ctrl + M'')\n');
fprintf('   - Select: File > Open Settings > VBMmultislice.ini\n');
fprintf('   - Select: File > Save as bitmap\n');