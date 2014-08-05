function OfflineTMS(StimModel, Port, Protocol)

%======================== OfflineTMS.m ====================================
% Generates, displays and delivers pulse sequences intended for
% transcranial magnetic stimulation (TMS) protocols.  The pulses are sent
% as TTL pulses from either a USB digital I/O card or the PC parallel port 
% to the stimulator's BNC I/O or serial connections.
%
%
% StimModel:    1) Magstim Rapid/ 200: 36 pin Centronics connection
%               2) Magstim Rapid²: HD-26 serial port
%               3) Magstim 200²/ BiStim²: HD-26 serial port
%               4) Other: BNC trigger I/O
%
% Port:         1) DB-25 parallel port (e.g. LPT1)
%               2) DE-9 serial port (e.g. COM1)
%               3) USB port -> National Instruments DAQ (e.g. USB-6229)
%               4) USB port -> Measurement Computing DAQ (e.g. USB-1208)
%
% Protocol:     1) 1Hz rTMS: 1 pulse at 1Hz for 15 minutes total 
%               2) cTBS300: 3 pulses at 50Hz repeated every 200ms for 20s total
%               3) cTBS600: 3 pulses at 50Hz repeated every 200ms for 40s total
%               4) iTBS600: 2s train repeated every 10s for 190s total
%
% REFERENCES
% Huang YZ, Edwards MJ, Rounin E, Bhatia KP & Rothwell JC (2005).  Theta
% Burst Stimulation of the Human Motor Cortex.  Neuron, 45(2): 201-206.
%
% Sinclair C, Faulkner D, Hammond G (2006).  Flexible real-time control of
% MagStim 200² units for use in transcranial magnetic stimulation studies.
% Journal of Neuroscience Methods, 158(1): 133-136.
%
%
% HISTORY
% 15/02/11 - created by Aidan Murphy (apm909@bham.ac.uk)
% 22/04/11 - Updated for NI->DB25 (APM)
% 24/04/11 - Updated for DB9->HD26 (APM)
%==========================================================================
global win;

if Port ~= 2                                                        % Unless the serial port is being used...
    DAQversion = daqhwinfo;                                         % Data Acquisition Toolbox is required
    if ~strcmp(DAQversion.ToolboxName, 'Data Acquisition Toolbox')  % If it's not available...
        fprintf('Error accessing Data Aquasition Toolbox! Cannot receive or send digital I/O without it.\n');
        return;
    end
end
    
%===================== SETUP TMS PULSE SEQUENCE PARAMETERS ================
switch Protocol
    case 1                          % For repetative TMS...
        Pulse.Protocol = 'rTMS';
        Pulse.Total = 900;          
        Pulse.PerTrain = 1;         % Set pulses per train to 1 for single pulse
        Pulse.Frequency = 1;        % Set frequency (Hz) between pulse trains
    case 2                          % For continuous theta burst stimulation (300 pulses)...
        Pulse.Protocol = 'cTBS300';
        Pulse.Total = 300; 
        Pulse.PerTrain = 3;         % Set pulses per train to 3 for theta burst
        Pulse.TrainFreq = 50;       % Set frequency (Hz) within pulse trains
        Pulse.Frequency = 5;        % Set frequency (Hz) between pulse trains
    case 3                          % For continuous theta burst stimulation (600 pulses)...
        Pulse.Protocol = 'cTBS600';
        Pulse.Total = 600;
        Pulse.PerTrain = 3;         % Set pulses per train to 3 for theta burst
        Pulse.TrainFreq = 50;       % Set frequency (Hz) within pulse trains
        Pulse.Frequency = 5;        % Set frequency (Hz) between pulse trains
    case 4                          % For intermittent theta burst stimulation (600 pulses)...
        Pulse.Protocol = 'iTBS600';
        Pulse.Total = 600;
        Pulse.PerTrain = 3;         % Set pulses per train to 3 for theta burst
        Pulse.TrainFreq = 50;       % Set frequency (Hz) within pulse trains
        Pulse.Frequency = 5;        % Set frequency (Hz) between pulse trains
        Pulse.IntervalOn = 2000;    % Set on period for intermittent stimulation (ms)
        Pulse.IntervalOff = 8000;   % Set off period for uintermittent stimulation (ms)
end

Pulse.Intensity = 40;                                               % Set default stimulator intensity (% maximum output)
Pulse.Duration = 1;                                                 % Set TTL pulse duration (milliseconds)
StimDuration = (Pulse.Total/Pulse.PerTrain)*(1/Pulse.Frequency);    % Calculate total stimulation duration (seconds)

KbName('UnifyKeyNames');                    % Unify key names for OS
TriggerKey = KbName('space');               % set keyboard input for triggering test pulse
FinishKey = KbName('q');                    % set keyboard input for quitting test mode
IntensityDown = KbName('DownArrow');        % set keyboard input for decreasing stimulator intensity
IntensityUp = KbName('UpArrow');            % set keyboard input for increasing stimulator intensity 
keyPressDelay = 0.2;                        % set the minimum time between valid key presses (s)


%===================== SETUP DIGITAL IN/OUT ===============================
if Port == 1                                        % For DB25 PARALLEL PORT connection...
    try
        DAQinfo = daqhwinfo('parallel');                    % Check that parallel port adaptors are installed
        dio = digitalio('parallel', 'LTP1');                % create a digital I/O object associated with LTP1
        out = propinfo(dio);
    catch
        fprintf(['Error accessing parallel port driver.  See ', ...
            '<a href="http://www.mathworks.com/help/toolbox/daq/f11-17968.html">MathWorks</a> for instructions.\n']);
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
        fprintf(['Error accessing nidaq (National Instruments) driver  using DAQ toolbox.\nSee ', ...
            '<a href="http://www.mathworks.com/products/daq/supportedio14005.html">MathWorks</a> for instructions.\n\n']);
        abort;
    end
elseif Port == 4                                    % For MEASUREMENT COMPUTING USB DAQs...
    try
        DAQinfo = daqhwinfo('mcc');                         % Check that Measurement Computing adaptors are installed
        Device = DAQinfo.InstalledBoardIds{1};              % Find correct device ID
        dio = digitalio('mcc',Device);                      % create a digital I/O object associated with the Measurement Computing DAQ
    catch
        fprintf(['Error accessing Measurement Computing driver using DAQ toolbox.\nSee ', ...
        '<a href="http://www.mathworks.com/products/daq/supportedio14005.html">MathWorks</a> for instructions.\n',...
        'Next we will attempt to access your Measurement Computing USB device using PsychToolbox...\n\n']);
        try                                                 % If DAQ toolbox is unavailable, try using Psychtoolbox instead
            AssertOpenGL;                                   % Check if PsychToolbox is installed
            devices = PsychHID('Devices');                  % Check if PsychHID is found
        catch
            fprintf(['Error accessing Measurement Computing driver using PsychToolbox.\n This option will only work for',...
                'USB-1208FS, -1408FS, or -1608FS devices.  If you have one of these devices connected,\n see', ...
                '<a href="http://docs.psychtoolbox.org/DaqTest">PsychToolbox Wiki</a> for instructions.\n\n']);
            abort;
        end
    end
end


%===================== Configure INPUTS and OUTPUTS =======================
if StimModel == 4                                           % For BNC connection...
    out = propinfo(dio);
    hline = addline(dio, 0, 0, 'out', 'Trigger');           % add output line to the dio object
    hline = addline(dio, 1, 1, 'in', 'TriggerReturn');      % add input line to the dio object
    putvalue(dio.Trigger, 0);                               % set output line to zero
    
    TMSinfo = sprintf(['\nAttention!  You have selected to control TMS pulse delivery via the BNC connector on the rear of the Magstim unit,',...
        'Under this setting the experimenter must set all Magstim parameters manually (e.g. output intensity, standyby).']); 
    disp(TMSinfo);
    
elseif StimModel == 1 && Port == 1                        % For DB25 <-> 36 pin Centronics (Magstim 200/ Rapid)
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
    
    TMSinfo = sprintf(['\nAttention!  You have selected to control TMS pulse delivery via the 36-pin Centronics connector \non the rear of a 1st generation Magstim unit. ',...
        'Under this setting all Magstim parameters will \nbe controlled automatically by MATLAB and cannot be overridden manually without disconnection.\n',...
        'In the event of an error the Magstim should be switched off.\n\n']);
    disp(TMSinfo);
    
    %============= READ/ WRITE TO IO LINES
    putvalue(dio.Trigger, 1);                               % Set pin 9 high to prepare TRIGGER
    StimIntensity = de2bi(Pulse.Intensity,7);               % Convert stimulator intensity (%) to 7-bit binary (requires de2bi.m from Communications Toolbox)  
    putvalue(dio.Line(2:8), StimIntensity);                 % Set stimulator INTENSITY
    if getvalue(dio.Line(15)) == 0                          % If Magstim is currently in STANDBY...
        putvalue(dio.Line([14, 16]), [1 1]);                % ARM the Magstim
        WaitSecs(1);                                        % Give the Magstim time to arm
    end
    if getvalue(dio.Line(10)) ~= 1                          % Check that Magstim is ready to deliver a pulse
       fprintf('MAGSTIM ERROR: Magstim is not ready!  Please check Magstim is switched on and connected.\n'); 
       abort(dio);
    end
  
elseif StimModel == 1 && Port > 2                         % For any USB DIO <-> 36 pin Centronics (Magstim 200/ Rapid)
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
         fprintf(['Error creating an analog input.  Measurement of starting coil temperature is not available.\n']);
    end

    %============= READ/ WRITE TO IO LINES
    putvalue(dio.Trigger, 1);                               % Set pin 9 high to prepare TRIGGER
    Success = MagstimSetIntensity(dio, Pulse.Intensity);    % Set stimulator INTENSITY to default
end


%===================== CONFIRM PARAMETER SELECTION ========================
ScreenID = max(Screen('Screens'));                              % Display on monitor 2 if available...
HideCursor;                                                     % Hide mouse pointer
ListenChar(2);                                                  % supress keyboard input to command window
warning off all;                                                % turn off Matlab warning messages
Background = [0 0 0];
Screen('Preference', 'VisualDebugLevel', 1);                    % Make initial screen black instead of white
Screen('Preference', 'ConserveVRAM', 1+256);
[win, Rect] = Screen('OpenWindow', ScreenID, Background);
Screen('TextSize', win, 32);                                    % set the size of text
Screen('TextFont', win, 'Arial');                               % set the font
Information = sprintf(['You have selected to deliver %s using %d TMS pulses\n\nat a frequency of %d Hz and %d%% of maximum stimulator output.\n\n', ...
    'This TMS protocol is within the safety guidelines for repetetive stimulation.  Press any key to begin test mode.\n'], Pulse.Protocol, Pulse.Total, Pulse.Frequency, Pulse.Intensity);
DrawFormattedText(win, Information, 50, 'center', [255 255 255], []); % Draw text
Screen('Flip', win);  
KbWait;

%===================== DRAW PULSE SEQUENCE TO FIGURE ======================
TTLplot = zeros(1, StimDuration*1000);
TTLplot(1:(1000/Pulse.Frequency):end) = 1;
for n = 1:Pulse.PerTrain
    TTLplot((n*1000/Pulse.TrainFreq):(1000/Pulse.Frequency):end) = 1;
end


%============================ ARM THE MAGSTIM =============================
if getvalue(dio.Armed) == 0                             % If Magstim is currently in STANDBY...
    putvalue(dio.Run, 0);                               % ARM the Magstim
    putvalue(dio.Stop, 1);                              % turn off STOP
    WaitSecs(1);                                        % Give the Magstim time to arm
end
TriggerCheck = getvalue(dio.TriggerReturn);             % **DO NOT REMOVE**: intensity adjustments will fail if getvalue for TriggerReturn is not called first! ...not sure why


%======================== ADMINISTER TEST PULSE ===========================
QuitTest = 0; LastPress = GetSecs;
while QuitTest == 0
    Intensity = sprintf('Stimulator intensity = %d%% of maximum output.', Pulse.Intensity);
    DrawFormattedText(win, Intensity, 'center', 'center', [255 255 255], []); % Draw text
    Screen('Flip', win);
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;                    % Check for keypress
    if keyIsDown && secs > (LastPress+keyPressDelay)                    % If a key has been pressed...
        LastPress = secs;                                               % Record the time of the key press
        if keyCode(27)                                                  % If the Esc key is pressed...
            abort(dio);
        elseif keyCode(TriggerKey)
             Success = MagstimTrigger(dio);
        elseif keyCode(FinishKey)
            QuitTest = 1;
        end
        if StimModel < 4
            if keyCode(IntensityUp) && Pulse.Intensity < 100
                Pulse.Intensity = Pulse.Intensity+1;
                Success = MagstimSetIntensity(dio, Pulse.Intensity);      % Set stimulator INTENSITY
            elseif keyCode(IntensityDown) && Pulse.Intensity > 0
                Pulse.Intensity = Pulse.Intensity-1;
                Success = MagstimSetIntensity(dio, Pulse.Intensity);      % Set stimulator INTENSITY
            end
        end
    end
end


Ready = sprintf('Stimulator intensity has been set at %d%% of maximum output.\n\nIf the selected parameters are incorrect, press Escape to quit.\n\nIf the selected parameters are correct, press space bar to begin.', Pulse.Intensity);
DrawFormattedText(win, Ready, 'center', 'center', [255 255 255], []);   % Draw text
Screen('Flip', win);  
Ready = 0;
while Ready == 0
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;                    % Check for keypress
    if keyIsDown && secs > (LastPress+keyPressDelay)
        LastPress = secs;
        if keyCode(27)                                                  % If the Esc key is pressed...
            abort(dio);
        elseif keyCode(TriggerKey)
            Ready = 1;
        end
    end
end


%=========================== BEGIN STIMULATION ============================
Start = GetSecs;
for p = 1:Pulse.Total/Pulse.PerTrain                                % For the total number of pulse trains being delivered...
    for n = 1:Pulse.PerTrain                                        % For the number of pulses per train...
        Success = MagstimTrigger(dio);                              % Send TTL pulse
        if Pulse.PerTrain>1                                         % If a pulse train is being delivered...
            WaitSecs((1/Pulse.TrainFreq)-Pulse.Duration/1000);      % Wait for the remaining cycle
            if StimModel < 4
                if getvalue(dio.Line(10)) ~= 1
                   fprintf('MAGSTIM ERROR: Magstim was not ready in time for next pulse delivery!\n'); 
                end
            end
        end
        
        PulseCount = sprintf('%d of %d pulses delivered.\n', p*Pulse.PerTrain, Pulse.Total);
        DrawFormattedText(win, PulseCount, 'center', 'center', [255 255 255], []);   % Draw text
        Screen('Flip', win);  
        
        while GetSecs < Start+(p*1/Pulse.Frequency)                             % Wait for the remaining inter-train interval to elapse
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;                    % Check for keypress
            if keyIsDown && keyCode(27)                                         % If the Esc key is pressed...
                abort(dio);
            end
            if StimModel < 4                                                   % If sufficient connections are available...
                Status = MagstimStatus(dio);                                    % Check Magstim status
            end
        end
    end
end

Screen('Closeall');                                                             % Close all PTB windows
warning on all;

end

function abort(dio)
global win;
ShowCursor;
ListenChar(1);
if ~isempty(dio)                                                % If a digital I/O object has been created...
    putvalue(dio.Stop, 0);                                      
    putvalue(dio.Line([14, 16]), [0 0]);                        % DISARM the Magstim  
    delete(dio);                                                % Delete digital in/out object
    clear dio;
end
Screen('Closeall');                                             % Close all PTB windows
warning on all;
error('Aborting due to user cancellation!');
end