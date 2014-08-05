function [dio, AI] = MagstimDIO(StimModel, Port)

%============================= MagstimDIO.m ===============================
% This function initializes digital in/out connections necessary for Matlab
% control of Magstim stimulators.  
%
% INPUTS:
% StimModel:    1) Any Magstim: BNC trigger I/O
%               2) Magstim Rapid²/ 200²: HD-26 serial port
%               3) Magstim Rapid/ 200: 36 pin Centronics connection
%
% Port:         1) DB-25 parallel port (e.g. LPT1)
%               2) DE-9 serial port (e.g. COM1)
%               3) USB port -> National Instruments DAQ (e.g. USB-6229)
%               4) USB port -> Measurement Computing DAQ (e.g. USB-1208)
%
%**************************** WARNING *************************************
% Manually arming the stimulator while an external control cable is 
% connected can result in equipment malfunction!  If you wish to control
% a stimulator via Matlab using the MagstimToolbox then please refer to the
% manual provided.
%**************************************************************************
%
% Created by Aidan Murphy (apm909@bham.ac.uk)
%
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================

if Port ~= 2                                                        % Unless the serial port is being used...
    DAQversion = daqhwinfo;                                         % Data Acquisition Toolbox is required
    if ~strcmp(DAQversion.ToolboxName, 'Data Acquisition Toolbox')  % If it's not available...
        fprintf('MAGSTIM: Error accessing Data Aquasition Toolbox! Cannot receive or send digital I/O without it.\n');
        return;
    end
elseif Port == 2
    if StimModel ~= 2
        fprintf('MAGSTIM: Only Rapid2 models of stimulator can be controlled by serial port connection!\n');
        return;
    end
end


%===================== SETUP DIGITAL IN/OUT ===============================
if Port == 1                                        % For DB25 PARALLEL PORT connection...
    try
        DAQinfo = daqhwinfo('parallel');                    % Check that parallel port adaptors are installed
        dio = digitalio('parallel', 'LTP1');                % create a digital I/O object associated with LTP1
        out = propinfo(dio);
    catch
        fprintf(['MAGSTIM: Error accessing parallel port driver.  See ', ...
            '<a href="http://www.mathworks.com/help/toolbox/daq/f11-17968.html">MathWorks</a> for instructions.\n\n']);
        abort;
    end
elseif Port == 2                                    % For DB9 SERIAL PORT connection...
    SerialInfo = instrhwinfo('serial');                        
    SerialObj = serial(SerialInfo(1).ObjectConstructorName, ...
        'BaudRate',     9600, ...
        'DataBits',     8, ...
        'StopBits',     1, ...
        'Parity',       'none', ...
        'FlowControl',  'none', ...
        'Terminator',   '?');
    sSerialObj.TimerPeriod = 0.5;                           % Set period of executing the callback function (seconds)
    fopen(SerialObj);                                       
    SerialObj.TimerFcn = {'Rapid2_MaintainCommunication'};  % Callback function to prevent stimulator disarming itself after 1s inactivity
    Rapid2_Delay(150, serialPortObj);
    
elseif Port == 3                                    % For NATIONAL INSTRUMENTS USB DAQs...
    try
        DAQinfo = daqhwinfo('nidaq');                       % Check that nidaq adaptors are installed
        Device = DAQinfo.InstalledBoardIds{1};              % Find correct device ID
        dio = digitalio('nidaq', Device);                   % create a digital I/O object associated with the National Instruments DAQ
        out = propinfo(dio);
    catch
        fprintf(['MAGSTIM: Error accessing nidaq (National Instruments) driver  using DAQ toolbox.\nSee ', ...
            '<a href="http://www.mathworks.com/products/daq/supportedio14005.html">MathWorks</a> for instructions.\n\n']);
        abort;
    end
elseif Port == 4                                    % For MEASUREMENT COMPUTING USB DAQs...
    try
        DAQinfo = daqhwinfo('mcc');                         % Check that Measurement Computing adaptors are installed
        Device = DAQinfo.InstalledBoardIds{1};              % Find correct device ID
        dio = digitalio('mcc',Device);                      % create a digital I/O object associated with the Measurement Computing DAQ
    catch
        fprintf(['MAGSTIM: Error accessing Measurement Computing driver using DAQ toolbox.\nSee ', ...
        '<a href="http://www.mathworks.com/products/daq/supportedio14005.html">MathWorks</a> for instructions.\n',...
        'Next we will attempt to access your Measurement Computing USB device using PsychToolbox...\n\n']);
        try                                                 % If DAQ toolbox is unavailable, try using Psychtoolbox instead
            AssertOpenGL;                                   % Check if PsychToolbox is installed
            devices = PsychHID('Devices');                  % Check if PsychHID is found
        catch
            fprintf(['MAGSTIM: Error accessing Measurement Computing driver using PsychToolbox.\n This option will only work for',...
                'USB-1208FS, -1408FS, or -1608FS devices.  If you have one of these devices connected,\n see', ...
                '<a href="http://docs.psychtoolbox.org/DaqTest">PsychToolbox Wiki</a> for instructions.\n\n']);
            abort;
        end
    end
end

%===================== Append DIO structure with setup info ===============
if exist('dio', 'var')                                          % If a digital in/out object was setup...
    dio.StimModel = StimModel;                                  % add stimulator model
    dio.Port = Port;                                            % add computer port
end

%===================== Configure INPUTS and OUTPUTS =======================
if StimModel == 1                                       % For BNC connection...
    out = propinfo(dio);
    hline = addline(dio, 0, 0, 'out', 'Trigger');               % add output line to the dio object
    hline = addline(dio, 1, 1, 'in', 'TriggerReturn');          % add input line to the dio object
    putvalue(dio.Trigger, 0);                                   % set output line to zero
    
    TMSinfo = sprintf(['MAGSTIM: You have selected to control TMS pulse delivery via the BNC connector on the rear of the Magstim unit,',...
        'Under this setting the experimenter must set all Magstim parameters manually (e.g. output intensity, standyby).\n\n']); 
    disp(TMSinfo);
    
elseif StimModel == 2 
    fprintf(['MAGSTIM: Control of second generation Magstim stimulators (Rapid2/ 2002/ Bistim2) has not yet been implemented.\n',...
        'If you have a serial port connection, consider using the Rapid2 Toolbox instead.  See ', ...
        '<a href="http://www.psych.usyd.edu.au/tmslab/rapid2andrept.html</a> for instructions.\n\n']);
    
elseif StimModel == 3 
    if Port == 1                                        % For DB25 <-> 36 pin Centronics (Magstim 200/ Rapid)
        HardwareInversion = 1;                                  % Specified LTP lines are hardware inverted
        hline = addline(dio, 0, 2, 'out', 'PowerSelect');       % add output line for pin 1 to configure data lines as inputs (*Hardware Inverted)
        putvalue(dio.Line(1), 0);                               % Set power control select high to configure Magstim data lines as inputs
        hline = addline(dio, 0:6, 0, 'out', 'Intensity');       % add output lines for pins 2:8 to control INTENSITY
        hline = addline(dio, 7, 0, 'out', 'Trigger');           % add output line for pin 9 to control TRIGGER
        hline = addline(dio, 3, 1, 'in', 'Ready');              % add input line for pin 10 to check when Magstim is READY
        hline = addline(dio, 4, 1, 'in', 'ReplaceCoil');        % add input line for pin 11 to check when coil reaches 40°C (*Hardware Inverted, 0 = replace)
        hline = addline(dio, 2, 1, 'in', 'CoilTemp37');         % add input line for pin 12 to check when coil reaches 37°C
        hline = addline(dio, 1, 1, 'in', 'CoilActive');         % add input line for pin 13 to check when coil interlock switch is pressed (0 = coil active)
        hline = addline(dio, 1, 2, 'out', 'Run');               % add output line for pin 14 to arm Magstim and start charging (*Hardware Inverted)
        hline = addline(dio, 0, 1, 'in', 'Armed/Standby');      % add input line for pin 15 to check ARMED(1)/STANDBY(0)
        hline = addline(dio, 2, 2, 'out', 'Stop');              % add output line for pin 16 to disarm Magstim if armed

        TMSinfo = sprintf(['MAGSTIM: You have selected to control TMS pulse delivery via the 36-pin Centronics connector \non the rear of a 1st generation Magstim unit. ',...
            'Under this setting all Magstim parameters will \nbe controlled automatically by MATLAB and cannot be overridden manually without disconnection.\n',...
            'In the event of an error the Magstim should be switched off.\n\n']);
        disp(TMSinfo);
    
    elseif StimModel == 3 && Port > 2                   % For any USB DIO <-> 36 pin Centronics (Magstim 200/ Rapid)
        HardwareInversion = 0;                                  % No lines are hardware inverted
        hline = addline(dio, 0, 2, 'out', 'PowerSelect');       % add output line for pin 1 to configure data lines as inputs (NOT hardware inverted!)
        putvalue(dio.PowerSelect, 1);                           % Set power control select high to configure Magstim data lines as inputs
        hline = addline(dio, 0:6, 0, 'out', 'Intensity');       % add output lines for pins 2:8 to control INTENSITY
        hline = addline(dio, 7, 0, 'out', 'Trigger');           % add output line for pin 9 to control TRIGGER
        hline = addline(dio, 3, 1, 'in', 'Ready');              % add input line for pin 10 to check when Magstim is READY
        hline = addline(dio, 4, 1, 'in', 'ReplaceCoil');        % add input line for pin 11 to check when coil reaches 40°C ((NOT hardware inverted!)
        hline = addline(dio, 2, 1, 'in', 'CoilTemp37');         % add input line for pin 12 to check when coil reaches 37°C
        hline = addline(dio, 1, 1, 'in', 'CoilActive');         % add input line for pin 13 to check when coil switch is pressed (0 = coil active)
        hline = addline(dio, 1, 2, 'out', 'Run');               % add output line for pin 14 to arm Magstim and start charging (0 = Arm, 1 = Disarm)
        hline = addline(dio, 0, 1, 'in', 'Armed');              % add input line for pin 15 to check ARMED(1)/STANDBY(0)
        hline = addline(dio, 2, 2, 'out', 'Stop');              % add output line for pin 16 to disarm Magstim if armed (0 = Disarm, 1 = Arm)
        hline = addline(dio, 5, 1, 'in', 'TriggerReturn');      % add input line for pin 18 to check TTL TRIGGER RETURN (**DAQ ONLY**)


        %=========== SETUP ANALOG INPUT TO MONITOR COIL TEMPERATURE ===========
        try
            AI = analoginput('nidaq',Device);                       % create an analog input associated with the National Instruments DAQ
            hchannel = addchannel(AI, 0, 'Analog_Coil_Temp');       % add analog input chanel to pin 17 = coil temperature (10mV/°C)
            duration = 0.01;                                        % 10 ms acquisition time
            set(AI,'SampleRate',1000);                              % 1kHz sampling rate
            ActualRate = get(AI,'SampleRate');
            set(AI,'SamplesPerTrigger',duration*ActualRate);
            set(AI,'TriggerType','Manual');
            blocksize = get(AI,'SamplesPerTrigger');
            Fs = ActualRate;
            start(AI)                                               % Begin sampling analog channel
            trigger(AI)                                             % Begin sampling analog channel
            wait(AI,duration + 1)
            CoilTempV = getdata(AI);                                % Acquire coil temperature data
            CoilTempDegC = mean(CoilTempV)*-1;                      % Convert from millivolts to average temperature         
            delete(AI);                                             % Delete analog input when finished
            clear AI;
            fprintf('Current coil temperature is %.2f degrees C\n', CoilTempDegC);
        catch
             fprintf(['MAGSTIM: Error creating an analog input.  Measurement of starting coil temperature is not available.\n']);
        end
    end
    
    %====================== READ/ WRITE TO IO LINES =======================
    putvalue(dio.Trigger, 1);                               % Set pin 9 high to prepare TRIGGER
    Success = MagstimSetIntensity(dio, Pulse.Intensity);    % Set stimulator INTENSITY to default
    
%     StimIntensity = de2bi(Pulse.Intensity,7);               % Convert stimulator intensity (%) to 7-bit binary (requires de2bi.m from Communications Toolbox)  
%     putvalue(dio.Line(2:8), StimIntensity);                 % Set stimulator INTENSITY

    if getvalue(dio.Armed) ~= 0                             % If Magstim is NOT currently in STANDBY...
        putvalue(dio.Stop, 1);                              % DISARM the Magstim
    end
    if getvalue(dio.Line(10)) ~= 1                          % Check that Magstim is ready to deliver a pulse
        fprintf('MAGSTIM: Error, Magstim is not ready!  Please check Magstim is switched on and connected.\n'); 
        abort(dio);
    end
end