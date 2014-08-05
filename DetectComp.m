function [CompInfo] = DetectComp

%============================ DetectComp.m ================================
% This function queries and returns information about the computer that the
% function is run on, which can in turn be used to identify the machine and
% load appropriate parameters.
%
% Written by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

CompInfo.SID = get(com.sun.security.auth.module.NTSystem,'DomainSID');  % Check Windows Security Identifier
CompInfo.CompName = char(getenv('computername'));                           	% Get Windows PC name
[CompInfo.Status, CompInfo.Licence] = system('lmutil lmhostid -n');   	% Get License manager details

if strcmp(CompInfo.CompName, 'PSYCHL-AEW-04')
    fprintf('Running on Aidan''s PC\n');
elseif strcmp(CompInfo.CompName, 'PSG-AEW-02')
    fprintf('Running on Haploscope PC\n');
end

%============== Get ETHERNET address of computer's network card (x-platform)
try
    sid = '';
    ni = java.net.NetworkInterface.getNetworkInterfaces;
    while ni.hasMoreElements
        addr = ni.nextElement.getHardwareAddress;
        if ~isempty(addr)
            CompInfo.Ethernet = [sid, '.', sprintf('%.2X', typecast(addr, 'uint8'))];	% Get MAC address
        end
    end
catch
    CompInfo.Ethernet = '';
end

%============== Get computer name (x-platform)
CompInfo.CompName = getHostName(java.net.InetAddress.getLocalHost());  	% Get x-platform computer name (requires Java)


if strcmp(CompInfo.SID, 'S-1-5-21-1390067357-308236825-725345543')      % If it matches with the Bham SID...
    fprintf('DISPLAY: You are connected to the University of Birmingham network\n');
end



