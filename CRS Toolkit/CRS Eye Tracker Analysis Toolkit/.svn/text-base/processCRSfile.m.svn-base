function CRSsegment=processCRSFile(dataFile,calibFile,CRSParams)
    % load calibration file
    load(calibFile);

    volt2ang=1/b(2); % these are from calibration file
    rawData=daqread(dataFile);
    
    % find positions with Nan - these are dropouts - should be very few of
    % these in the data
    nanVoltage=find(isnan(rawData));
    
    % change Nan's to average of values either side

    for (i=1:size(nanVoltage))
        vIndex=nanVoltage(i);
        if (vIndex==1)
            rawData(vIndex)=rawData(2); % special case at beginnning
        elseif (vIndex==length(rawData))
            rawData(vIndex)=rawData(vIndex-1);
        else
            voltage= nanmean([rawData(vIndex-1) rawData(vIndex+1)]);
            rawData(vIndex)=voltage;
        end
    end

    % process the raw voltage data to clean it up etc.

    % pad the data to the nearest thousand as we FFT in blocks of 1000
    % samples
%    CRSdata = padarray(CRSdata,(ceil(length(CRSdata)/1000)*1000)-length(CRSdata),0,'post');
%    CRSdata = padarray(CRSdata,1000,0,'post');
    rawData=padarray(rawData,(ceil(length(rawData)/1000)*1000)-length(rawData),0,'post');
    rawData=padarray(rawData,1000,0,'post');
%    cleanData=CRSdata;
    % CRS data tends to show mains hum at 50Hz and higher harmonics

    % remove this using an FFT (this is taken directly from Tim's code
    % except he processed the angular data rather than the raw data
    % directly

    fundamental = 50;
    firstHarmonic = 100;
    secondHarmonic = 150;
    thirdHarmonic = 200;

    fundamental = [fundamental 1000-fundamental]+1;
    firstHarmonic = [firstHarmonic 1000-firstHarmonic]+1;
    secondHarmonic = [secondHarmonic 1000-secondHarmonic]+1;
    thirdHarmonic = [thirdHarmonic 1000-thirdHarmonic]+1;

    for (j=1:length(rawData)/1000) % FFT in 1 second blocks
        startPtr = (j-1)*1000+1;
        stopPtr = (j)*1000;

%        blockFFT = fft(CRSdata(startPtr:stopPtr));
        voltFFT=fft(rawData(startPtr:stopPtr));

%        disp(sprintf('start : %d, stop : %d',startPtr,stopPtr));
%        blockFFT(fundamental) = 0; % take out nasty 50Hz hum
%        blockFFT(firstHarmonic) = 0; % take out 2nd harmonic
%        blockFFT(secondHarmonic) = 0; % take out 3rd harmonic 
%        blockFFT(thirdHarmonic) = 0; % take out 4th harmonic

        voltFFT(fundamental) = 0; % take out nasty 50Hz hum
        voltFFT(firstHarmonic) = 0; % take out 2nd harmonic
        voltFFT(secondHarmonic) = 0; % take out 3rd harmonic 
        voltFFT(thirdHarmonic) = 0; % take out 4th harmonic
        
%        blockiFFT=ifft(blockFFT);
        voltiFFT=ifft(voltFFT);

%        cleanData(startPtr:stopPtr) = blockiFFT;
        voltageData(startPtr:stopPtr)=voltiFFT;
    end


    % high pass filter 20 cycles - remove head movements

    wholeFFT=fft(voltageData);
    passFreq=[0:CRSParams.highPassFrequency (length(voltageData)-CRSParams.highPassFrequency):length(voltageData)-1]+1;
    wholeFFT(passFreq)=0;
    voltageData=ifft(wholeFFT);

    %low pass filter - remove oscillations etc. which are much faster
    %than the eye can move (high frequency noise?)
    threshold=CRSParams.lowPassFrequency; %frequency of 14000 
    passFreq= [threshold:(length(voltageData)-threshold)]+1;
    wholeFFT=fft(voltageData);
    wholeFFT(passFreq)=0; 
    voltageData=ifft(wholeFFT);

    CRSdata=voltageData*volt2ang;

    % downsample the data so its easier to work with
    downSampleSize=1000/CRSParams.downsampleRate;
    CRSdata=downsample(CRSdata,downSampleSize);
    
    CRSsegment.voltageData=downsample(voltageData,downSampleSize);
    CRSsegment.voltageData=CRSsegment.voltageData'; % transpose
    
    CRSsegment.angleX=CRSdata';

    % save the data 
%    CRSsegment.CRSxPos=CRSdata'; % transpose

    % setup timestamp on each sample

    % determine duration of data in seconds
    endTime=length(CRSdata) /CRSParams.downsampleRate;
    startTime=0;

    sampleDiff=(1000/CRSParams.downsampleRate)/1000;
    CRSsegment.sampleDiff=sampleDiff;
    CRSsegment.sampleTime=[0:sampleDiff:endTime-sampleDiff]';
    if (size(CRSsegment.sampleTime,2)~=size(CRSsegment.angleX,2))
        errordesc=('Error generating timestamps for samples');
        errordlg(errordesc);
        error(errordesc);
    end
    
    CRSsegment.numRecords=length(CRSdata);
    CRSsegment.totalSamples=length(CRSdata); % this can get modified later when we assign conditions etc.
    CRSsegment.startTime=0;
    CRSsegment.endTime=endTime;
    CRSsegment.duration=endTime-startTime;
    CRSsegment.recordNo=[1:length(CRSdata)]';


    % get fixation position as median position over the whole segment -

   % CRSsegment.CRSxFix=nanmedian([CRSdata]);

    % determine difference in x position and y position from calculated
    % fixation position


    CRSsegment.origAngleX=CRSsegment.angleX;
    CRSsegment.tagType(1:size(CRSsegment.recordNo,1))='N'; % N=nothing
    CRSsegment.tagType=CRSsegment.tagType';

end
