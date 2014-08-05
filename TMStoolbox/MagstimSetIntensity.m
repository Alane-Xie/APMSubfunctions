function Success = MagstimSetIntensity(dio, Intensity)

%Success = MagstimSetIntensity(dio, intensity)
%
%=========================== MagstimSetIntensity.m ========================
% Set TMS pulse intensity, specified as a percentage of maximum stimulator
% output (%MSO).  Conversion of intensity values between decimal and binary
% requires dec2binvec.m and binvec2dec.m functions from the Data Acquisition 
% Toolbox.
%      
% 24/04/11 - Created by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

if nargin ~= 2
    fprintf('MAGSTIM: Incorrect number of input arguments supplied!\n');
    return
end

try
    StimIntensity = dec2binvec(Intensity);                                  % Convert stimulator intensity (%) to binary 
    if numel(StimIntensity) < 7                                             % If binary number has less than 7-bits...
        StimIntensity = [StimIntensity, zeros(1, 7-numel(StimIntensity))];  % Add zeros to the end
    end
    putvalue(dio.Line(2:8), StimIntensity);                                 % Set stimulator output intensity

    % putvalue(dio.PowerSelect, 0);                           % Set Magstim lines 2:8 to send intensity data
    % NewStimIntensity = getvalue(dio.Line(2:8));             % Check the current stimulator intensity
    % putvalue(dio.PowerSelect, 1);                           % Return Magstim lines 2:8 to receive intensity data
    % NewIntensity = binvec2dec(NewStimIntensity);            % Convert from binary to decimal
    % if Intensity == NewIntensity                            % Check that current intensity matches the requested intensity
    %     Success = 1;
    % else
    %     Success = 0;
    % end
    Success = 1;
catch
    Success = 0;
end
end

