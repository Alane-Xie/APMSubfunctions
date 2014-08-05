function Status = MagstimStatus(dio)

% [Timestamp, CoilTemp37, CoilTemp40, Ready, CoilActive] = MagstimStatus(dio)
%
%=========================== MagstimStatus.m ==============================
% Checks current status of Magstim based on available output lines and
% compares it to the status returned by the previous status update call.
% Changes in status are returned in the variable 'Status':
%
%       Ready:          Is the Magstim currently armed and ready? (1 = true, 0 = false)
%       CoilTemp40:     Is the coil temperature below 40°C? (1 = true, 0 = false)
%       CoilActive:     Is the coil interlock switch pressed? (1 = false, 0 = true)
%       Timestamp:      system time (seconds) when function was called
%       CoilTemp37:     Is the coil temperature above 37°C? (1 = true, 0 = false)
%      
% 24/04/11 - Created by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

Timestamp = GetSecs;                                            % Record the system time of the function call
CoilTemp37 = getvalue(dio.CoilTemp37);                          % Check whether the Magstim coil has reached 37°C (1 = true, 0 = false)
CoilTemp40 = getvalue(dio.ReplaceCoil);                         % Check whether the Magstim coil has reached 40°C (0 = true, 1 = false)
Ready = getvalue(dio.Ready);                                    % Check whether the Magstim is armed and fully charged (1 = true, 0 = false)
CoilActive = getvalue(dio.CoilActive);                          % Check whether coil interlock switches are pressed (0 = true, 1 = false)

if CoilTemp40 == 1                                              % If the coil has reached 40°C...
    fprintf('MAGSTIM ERROR: coil temperature exceeds 40°C.  Stimulator cannot be armed!\n');
end
if CoilActive == 1                                              % If the coil interlock switch is not pressed...
    fprintf('MAGSTIM ERROR: coil interlock switch is not pressed.  Stimulator cannot be triggered!\n');
end

Status = [Timestamp, CoilTemp37, CoilTemp40, Ready, CoilActive];