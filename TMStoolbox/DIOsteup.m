DAQinfo = daqhwinfo('nidaq');                       % Check that nidaq adaptors are installed
        Device = DAQinfo.InstalledBoardIds{1};              % Find correct device ID
        dio = digitalio('nidaq', Device);                   % create a digital I/O object associated with the National Instruments DAQ
        out = propinfo(dio);    

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
    AllLines = getvalue(dio.TriggerReturn);                 % **DO NOT REMOVE**: intensity adjustments will fail if getvalue for TriggerReturn is not called before hand! ...not sure why
