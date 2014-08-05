function Drive = FindDrive(Targetfile)

%============================ FindDrive.m =================================
% This function will locate the currently connected disk drive that contains
% the file specified by the input string Targetfile. Target file need not
% be the complete file name. For portable disk drives where the drive name
% will change depending on the PC, this function can be used to identify
% the relevant drive by saving a unique identifier file to the root 
% directory of the drive, e.g. create a file called 'apm909_USB.txt', and
% use this function to search for 'apm909'.
%
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================

Drive = [];
if IsWin
	import java.io.*;
	f=File('');
	r=f.listRoots;
    for i=1:numel(r)
         AllDrives{i} = sprintf('%s',char(r(i)));
    end
    Content{i} = dir(AllDrives{i});
    for Folder = 1:numel(Content{i})
        if ~isempty(strfind(Content{i}(Folder).name, Targetfile))
            Drive = AllDrives{i};
            return;
        end
    end
    fprintf('ERROR: Search completed but file ''%s'' was not located!\n', Targetfile);
else
    fprintf('ERROR: This function only works on Windows operating systems!\n');
end