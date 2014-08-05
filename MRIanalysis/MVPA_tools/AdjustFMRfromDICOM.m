
%======================= AdjustFMRfromDICOM.m =============================
% When a DICOM file is converted to an FMR, the range of signal is 10 times
% lower than when we convert PAR/REC to FMR.  These FMRs therefore need to
% have their signal amplified by a factor of 10.
%
% 06/01/2012 - Written by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

ScaleFactor = 10;                                   % Amount to multiply FMR intensity by


% dicom4tofmr;          
FMRfile = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\fMRI data\JG\zk11_314\12_zk11_314.TDS\12_zk11_314-0001-0001-0001_flipped.fmr';

FMRfile = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\fMRI data\FZ\zk12_102\09_zk12_102.TDS\09_zk12_102.TDS.fmr';

fmr = BVQXfile(FMRfile);
% fmr = BVQXfile('*.fmr', 'Please select a segmented FMR');

fmr.LoadSTC;                                        % load STC in FMR

% vmr.VMRData = vmr.VMRData*10;                     % Scale VMR data

% %==================== REMOVE REQUESTED VOLUMES ============================
VolsToRemove = 199:208;                             % Specify volumes to remove
fmr.NrOfVolumes = fmr.NrOfVolumes-numel(VolsToRemove);
fmr.Slice.STCData(:,:,VolsToRemove,:) = NaN;
newfilename = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\fMRI data\FZ\zk12_102\09_zk12_102.TDS\09_zk12_102.TDS.fmr';
fmr.SaveAs(newfilename);                            % Save new .FMR file
fmr.ClearObject;                                    % Clear BVQX objects


imshow(fmr.Slice.STCData(:,:,1,14));
fmr.Slice.STCData = fmr.Slice.STCData*10;           % Scale FMR data


newfilename = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant\fMRI data\JG\zk11_314\12_zk11_314.TDS\12_zk11_314_flipped_scaled.fmr'; 
fmr.SaveAs(newfilename);                            % Save new .FMR file
fmr.ClearObject;                                    % Clear BVQX objects