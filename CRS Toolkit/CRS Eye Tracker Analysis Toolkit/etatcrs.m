function etatcrs

% global function for Eye Tracking Analysis Toolbox

% config data contains all config parameters etc.
global configData;
configData=[];
global EyeData;
EyeData=[];

global Saccades;
global Fixations;
Saccades=[];
Fixations=[];

% load parameter files if they exist

% get local path
path=[fileparts(mfilename('fullpath')) '\'];


if (~isempty(dir([path 'crsparams.mat'])))
    load ('crsparams.mat','CRSParams');
    if (exist('CRSParams'))
        configData.CRSParams=CRSParams;
    end
    
end

if (~isempty(dir([path 'saccparams.mat'])))
    load ('saccparams.mat','saccParams');
    if (exist('saccParams'))
        configData.saccParams=saccParams;
    end
    
end

if (~isempty(dir([path 'blinkparams.mat'])))
    load ('blinkparams.mat','blinkParams');
    if (exist('blinkParams'))
        configData.blinkParams=blinkParams;
    end
end

if (~isempty(dir([path 'fixparams.mat'])))
    load ('fixparams.mat','fixParams');
    if (exist('fixParams'))
        configData.fixParams=fixParams;
    end
    
end

if (~isempty(dir([path 'limitparams.mat'])))
    load ('limitparams.mat','limitParams');
    if (exist('limitParams'))
        configData.limitParams=limitParams;
    end
    
end

%configData.maxConditions=15;
%configData.maxRuns=10;
%configData.maxSessions=10;
% show the main menu
MainMenuCRS;

end
