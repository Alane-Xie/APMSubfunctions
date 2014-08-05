function [Version, ToolboxName] = CheckToolbox(RequestedToolbox)

%=========================== CheckToolbox.m ===============================
% Function to check whether a licence is available for the queried MATLAB
% toolbox specified by input string 'RequestedToolbox'.  The function is 
% case and delimiter sensitive, so the input must either be the exact name 
% of toolbox as it is stored in Matlab, or some part of the name.
% If a match is found, the version number (double) and full name (string) 
% of the toolbox is returned.  Otherwise, a version number zero is returned.
%
% e.g. CheckToolbox('Psych')
%
% Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

Version = 0;
ToolboxName = [];
Toolboxes = ver;                                                % Check availability of MATLAB toolboxes
for i = 1:numel(Toolboxes)
   if ~isempty(strfind(Toolboxes(i).Name,RequestedToolbox))   	% If the requested toolbox IS listed...
       ToolboxName = Toolboxes(i).Name;
       Version = Toolboxes(i).Version;                          % Return toolbox version
       if ischar(Version)                                       % If 'version' is returned as a string
           Version = str2double(Version(1));                  	% Convert first digit to double
       end
   end
end