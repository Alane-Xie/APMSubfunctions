function NiftiFile = Convert2Nifti(filenames, filepath)

%============================ Convert2Nifti.m =============================
% Converts 3D MRI/ 4D fMRI files into the NIfTI-1 (.nii) format, from any 
% of the following formats:
%       1) Dicom (.dcm or directory), 
%       2) Analyze (.hdr & .img)
%       3) Phillips (.par & .rec)
%
% Depending on the input file format, the function will attempt to use whichever
% of the following conversion methods are available:
%       1) SPM8                 http://www.fil.ion.ucl.ac.uk/spm/software/spm8/
%       2) dcm2nii.exe          http://www.mccauslandcenter.sc.edu/mricro/mricron/dcm2nii.html
%       3) r2aGUI.m*            http://r2agui.sourceforge.net/
%       4) dicom2Nifti111.m*    http://users.fmrib.ox.ac.uk/~robson/internal/Dicom2Nifti.htm
%
% REQUIREMENTS:
%   It is recommended that SPM and MRIcron be installed and added to the
%   MATLAB path. Conversion MATLAB functions contained in APMSubfunctions
%   can be used if these programs are not available, but they are limited:
%       * r2aGUI.m............. Converts from .PAR/.REC format only
%       * dicom2Nifti111.m..... Converts from .DCM format only
%
% REVISIONS:
%   25/01/2012 - Written by Aidan Murphy
%   22/08/2013 - Updated for new MRIcron version 6/2013
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================
help Convert2NIfTI

if nargin < 1
    [ImFile, ImPath, ImIndex]= uigetfile({'*.img;*.hdr;*.par;*.rec;*.dcm'}, 'Select 3D image file(s)','MultiSelect', 'on');
    if isequal(ImFile,0) || isequal(ImPath,0)                        	% If user pressed 'Cancel'
        return                                                         	% Stop function
    end
    if ischar(ImFile)                                                 	% Count how many image files were selected                                           
        NoImFiles = 1;
        FullFilename{1} = fullfile(ImPath, ImFile);
        [ImPath, ImName, ImExt] = fileparts(FullFilename{1});          	% Determine file type by extension
        ImFileExt{1} = ImExt;
    elseif iscell(ImFile)                                              	% If multiple files were selected
        NoImFiles = numel(ImFile);
        for i = 1:NoImFiles
            FullFilename{i} = fullfile(ImPath, ImFile{i});
            [ImPath, ImName, ImExt] = fileparts(FullFilename{i});     	% Determine file types by extension
            ImFileExt{i} = ImExt;
        end
    end
else
    FullFilename{1} = filenames;
    [ImPath, ImName, ImExt] = fileparts(FullFilename{1});
end

if isempty(ImFileExt{1})                                                % DICOM FOLDER IMAGE (no file extension)
    InputFormat = 'DICOM FOLDER';
elseif strcmpi(ImFileExt{1}, '.par')||strcmpi(ImFileExt{1}, '.rec')     % PHILLIPS IMAGE (.PAR/.REC FORMAT)
    InputFormat = 'PHILLIPS';
elseif strcmpi(ImFileExt{1}, '.dcm')                                    % DICOM IMAGE (.DCM FORMAT)
    InputFormat = 'DICOM';
elseif strcmpi(ImFileExt{1}, '.hdr')||strcmpi(ImFileExt{1}, '.img')     % ANALYZE IMAGE (.HDR/.IMG FORMAT)
    InputFormat = 'ANALYZE';
else                                                                    % Unrecognized file extension
    InputFormat = 'NOT RECOGNIZED';
    fprintf('ERROR: Input file format ''%s'' is not recognized!',ImFileExt{1});
    return;
end


%================== CHECK AVAILABLE CONVERSION SOFTWARE ===================
fprintf('\n\n%s\nConvert2NIfTI.m converting ''%s''...\n%s\n\n', repmat('*',[1,60]),FullFilename{1},repmat('*',[1,60]));

%============ SPM settings
SPMDir = fileparts(which('spm'));
if isempty(SPMDir)
    Methods.SPM = 0;
    fprintf('SPM directory not found in MATLAB path! Will attempt file conversion using other methods...\n');
    disp('You may wish to download and install <a href="http://www.fil.ion.ucl.ac.uk/spm/software/spm8/">SPM</a>.')
else
    Methods.SPM = 1;
end

%============ MRIcron settings
MRIcron.Dir = '/Users/aidanmurphy/Documents/MRIcron';   % Specify MRIcron directory
MRIcron.App = fullfile(MRIcron.Dir,'dcm2nii');          % Get full path of dcm2nii application
MRIcron.Ini = 'Convert2Nifti.ini';                      % Specify .ini file with default settings
if ispc && ~isunix
    MRIcron.App = [MRIcron.App,'.exe'];                 
end
if exist('dcm2nii','file')~= 2
    Methods.MRIcron = 0;
    fprintf('MRIcron / dcm2nii application not found in MATLAB path! Will attempt file conversion using other methods...\n');
    disp('You may wish to download and install <a href="http://www.mccauslandcenter.sc.edu/mricro/mricron/install.html">MRIcron</a>.');
else
    Methods.MRIcron = 1;
end
SourceFilename = 'Y';                                   % Name NIFTI file after source filename?
DateInFilename = 'N';                                   % Put date in new filename?
EventsInFilename = 'N';                                 % Put event data in new filename?
Anon = 'N';                                             % remove identifying information?
Gzip = 'N';                                             % zip output file (.nii.gz)?
NiiOutput = 'Y';                                        % Output .nii file? (N = .hdr/.img)


%===================== CONVERT INPUT FILES TO NIfTI =======================

switch InputFormat
    
    %================= DICOM FOLDER IMAGE (no file extension) =============
    case 'DICOM FOLDER'     
        if Methods.MRIcron == 0
            fprintf('ERROR: Selected input file had no ');
            return;
        end
        OutputDir = fileparts(ImPath);
    %  	eval(sprintf('!%s -b %s -o %s %s', MRIcron.App, MRIcron.Ini, OutputDir, ImPath));
        eval(sprintf('!%s -a %s -d %s -e %s -f %s -g %s -n %s %s %s', MRIcron.App, Anon, DateInFilename, EventsInFilename, SourceFilename, Gzip, NiiOutput, ImPath));

        
    %================= CONVERT PHILLIPS IMAGE (.PAR/.REC FORMAT) ==========    
    case 'PHILLIPS'              	
        if Methods.MRIcron == 1
            for i = 1:NoImFiles
                eval(sprintf('!%s -f %s -n %s %s %s', MRIcronApp, SourceFilename, NiiFormatMRIcro, FullFilename{i}, FullFilename{i+1}));
            end
        else
            options.prefix       = '';
            options.usefullprefix= 0;                       % 1 = do not append PARfilename to output files, use prefix only, plus filenumber
            options.pathpar      = ImPath;                  % complete path containing PAR files (with trailing /)
            options.subaan       = 0;                       % 1 = files will be written in a different subdirectory per PAR file, otherwise all to pathpar
            options.outputformat = 1;                       % 1 = Nifti output format (spm5), 2 = Analyze (spm2)
            options.angulation   = 1;                       % 1 = include affine transformation as defined in PAR file in hdr part of Nifti file (nifti only, EXPERIMENTAL!)
            options.dim          = 3;                       % 3 = single 3D nii files will be produced, 4 = one 4D nii file will be produced
            outfiles = convert_r2a(filelist, options);  
        end
    
        
    %================= CONVERT DICOM IMAGE (.DCM FORMAT) ==================
    case 'DICOM'                                               
        if Methods.MRIcron == 1                                               	% Try processing using MRIcron
            eval(sprintf('!%s -f %s -n %s %s %s', fullfile(MRIcronDir,'dcm2nii.exe'),SourceFilename, NiiFormatMRIcro, FullFilename{1}, FullFilename{2}));

        else
            if Methods.SPM == 1                                                 % Otherwise try using SPM
                hdr = spm_dicom_headers(ImFile);                             	% Get .hdr filenames from list of filenames
                opts = 'all';                                                	% Specify options for DICOM import
                root_dir = 'flat';                                             	% Specify directory tree format
                out = spm_dicom_convert(hdr,opts,root_dir,NiiFormatSPM);      	% Convert files
                out.files;                                                    	% Check converted files
            else
                error = dicom2Nifti111(input_pathname, output_pathname , handles);
            end
        end

        
    %================= CONVERT ANALYZE IMAGE (.HDR/.IMG FORMAT) ===========   
    case 'ANALYZE'           
        if Methods.MRIcron == 1                                               	% Try processing using MRIcron
            for i = 1:NoImFiles
                eval(sprintf('!%s -f %s -n %s %s', MRIcronApp,SourceFilename, NiiFormatMRIcro, FullFilename{i}));
            end
        else
            if Methods.SPM == 1                                             	% SPM method
                if strcmp('SPM8',spm('ver'))                                 	% If running SPM8, convert to .nii...
                    hdr = spm_dicom_headers(InputFile);
                    spm_dicom_convert(hdr,'all','flat','nii');
                end
            end
        end
end

NiftiFile = fullfile(ImPath,[ImFile,'.nii']);                                  	% Get full path of Nifti file
if exist(NiftiFile,'file')~=2                                                   % Check file was created
    NiftiFile = [];                                                             % Otherwise return empty output
end