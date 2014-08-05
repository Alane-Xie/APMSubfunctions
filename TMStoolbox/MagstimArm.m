function Success = MagstimArm(dio)

% Success = MastimArm(dio)
%
%============================ MagstimArm ==================================
% Arms Magstim 200/ Rapid/ BiStim (mk I units with a Centronics 36-pin
% connection), ready to deliver a pulse and returns the variable 'success'
% to indicate whether the unit has been sucessfully armed (1 = true, 0 =
% false).
%
%      
% 24/04/11 - Created by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

Status = MagstimStatus(dio);                           % Check the current status of the Magstim
if Status(3) == 1 || Status(5) == 1
    
end
putvalue(dio.Stop, 1);                                 % Turn off the signal to disarm the unit
putvalue(dio.Run, 0);                                  % Arm the Magstim and begin charge sequence
WaitSecs(0.5);                                         % Give the Magstim time to charge
Success = getvalue(dio.Ready);                         % Check whether the Magstim is armed and fully charged