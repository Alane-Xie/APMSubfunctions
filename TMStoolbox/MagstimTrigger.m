function Success = MagstimTrigger(dio)

% Success = MagstimTrigger(dio)
%
%=========================== MagstimTrigger ===============================
% Triggers Magstim 200/ Rapid/ BiStim (mk I units with a Centronics 36-pin
% connection), by sending a brief (~1ms) TTL pulse and returns the variable 
% 'success' to indicate whether the unit reported sucessfully delivering a
% TMS pulse (1 = true, 0 = false).
%
%      
% 24/04/11 - Created by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

Success = 0;
if getvalue(dio.Armed) ~= 1                                % Check stimulator is armed and ready
    fprintf('MAGSTIM ERROR: stimulator was not ready at time of requested pulse delivery!\n');
    return
end
putvalue(dio.Trigger, 0);                                  % send TTL pulse
if ~isempty(dio.TriggerReturn)                             % If a TriggerReturn digital input line is available...
    Success = getvalue(dio.TriggerReturn);                 % check if the stimulator returned a TTL pulse
    if Success == 0
        fprintf('MAGSTIM ERROR: a TTL pulse was sent, but no pulse delivery was reported by the stimulator!\n'); 
    end
end
putvalue(dio.Trigger, 1);                                  % immediately reset trigger output line