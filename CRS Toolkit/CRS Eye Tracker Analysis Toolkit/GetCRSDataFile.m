function [cancel,CRSFile,CRScalibFile]=GetCRSDataFile(initialPath)

% get single data file to analyse

global configData;
cancel=true;

mfile = mfilename('fullpath');
CRSpath=[fileparts(mfile) '\']; % fileparts strips off trailing \
CRSFile='';
CRScalibFile='';
segmentCount=0;
if (nargin~=0)
    t=dir(initialPath);
    if (size(t,1)~=0 && isdir(initialPath)==1)
        CRSpath=initialPath;
    end
end

valid=false;
while (valid==false)
    cancel=true;
    currDir=pwd;
    cd (CRSpath);
    [filename,path]=uigetfile({'*.daq','CRS data files (*.daq)'},'Choose file to analyse');

    if (filename==0)
        cd (currDir);
        break;
    else    
        cancel=false;
        CRSFile=[path filename];
    end

    cd (path); % assume calib file is in the same folder as the data file
    [filename,path]=uigetfile({'*.mat','CRS calibration files (*.mat)'},'Choose calibration file');
    cd (currDir);
    
    if (filename==0)
        break;
    else
        cancel=false;
        CRScalibFile=[path filename];
        valid=true;
    end
end

if (cancel==true)
    CRSFile=[];
    CRScalibFile=[];
    return;
end
