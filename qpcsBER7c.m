function qpcsBER7()
%  To run samediff2: first import stimulus data and set 'm' to global in
%  the workspace (type 'global m')
%  To run colorconj: create stimulus data by running 'makeImgMats' and set 
%  'conjIms' to global in the workspace (type 'global conjIms')
%
%  BER VERSION 12/2010

%% SET UP STIMULUS COMPUTER
[toss,hostname]=system('hostname');

persistent localpath;
% compname=getenv('COMPUTERNAME');
switch hostname(1:end-1)
    case 'stim_m1' % SET UP 1
        monWidth=121; % LG 3D monitor's width in centimeters (monitor in experimenters room is 33) 
%         monWidth=64; % Samsung monitor's width in centimeters (monitor in experimenters room is 33)
        viewDist=105; % centimeters subject is from screen.
%         localpath='C:\Documents and Settings\lab\Desktop\movstim\';
        localpath='L:\projects\russbe\fMRI\stim\';
    case 'StimMR_Scan' % SCANNER PROJECTOR (as of 4/22/11)
        monWidth=22; % monitors width in centimeters (monitor in experimenters room is 33)
        viewDist=44; % centimeters subject is from screen.
        localpath='C:\Documents and Settings\lab\Desktop\movstim';
    case 'stim_s2' % SET UP 2 (as of 6/07/11)
        monWidth=35.5; % monitors width in centimeters 
        viewDist=91; % centimeters subject is from screen.
    case 'stim_s3' % SET UP 3 (2/22/12)
        monWidth=35.5; % monitors width in centimeters 
        viewDist=91; % centimeters subject is from screen.
        localpath='L:\projects\russbe\fMRI\stim\';
    otherwise
        error('qpcs:system', 'Host computer not recognized: qpcs aborted');
end

disp(['*******   RUNNING ON ' hostname(1:end-1) '     *******'])

pause(1)

persistent currentSystem;
persistent currentStimID;
persistent currentSystemHandle;
persistent reply;
persistent con;

persistent FixScreen;
persistent screenInfo;
persistent dotInfo;
persistent FixImage;


%%  
%*************************************************
% Open a window (full screen)
%*************************************************
s = max(Screen('Screens')); % normal monitors uses the second monitor to display
% s = min(Screen('Screens')); % ipad monitor uses the main monitor to display
 [w, wRect]=Screen('OpenWindow',s,0,[],32,2); %use for real experiment
% [w, wRect]=Screen('OpenWindow',s,0,[800 1 1250 400],32,2); %test window
spf =Screen('GetFlipInterval', w);      % seconds per frame
[FixScreen]=Screen('OpenOffScreenWindow',w,[0 0 0 0],[],32,2);

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
Screen('BlendFunction', FixScreen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 

%*************************************************
% Set Up Screen Variables
%*************************************************
%determines the number of pixels per degree based on monitor and subjects location
PixPerDegree = pi * wRect(3) / atan(monWidth/viewDist/2) / 360;

FixImage.blank=[];
FixImage.spot=[];
FixImage.ring=[];
FixImage.display=[];

screenInfo.bckgnd =0;
screenInfo.curWindow = w;
screenInfo.screenRect = wRect; 
screenInfo.dontclear = 0;
screenInfo.monRefresh = 1/spf;    % frames per second
screenInfo.frameDur = 1000/screenInfo.monRefresh;
screenInfo.center = [wRect(3) wRect(4)]/2; 
screenInfo.ppd = PixPerDegree;

IMAGE=Screen('GetImage', FixScreen);
FixImage.blank=Screen('MakeTexture',screenInfo.curWindow,IMAGE);
% FixImage.display=FixImage.blank;
% FixImage.spot=FixImage.blank;
% FixImage.ring=FixImage.blank;

HideCursor;
rand('seed',GetSecs);

clear IMAGE PixPerDegree s spf toss hostname
% ShowCursor; % for testing
%%
%*************************************************
% Set up socket and wait for connection and input 
%*************************************************
%readTimeOut = 0.001; % how long to wait for the socket info
readTimeOut = 2;

sockcon=pnet('tcpsocket',4610);
pnet(sockcon,'setreadtimeout',readTimeOut);
con=pnet(sockcon,'tcplisten');
if con~=-1
    pnet(con,'setreadtimeout',readTimeOut);
end
[keyIsDown, secs, keyCode, deltaSecs] = KbCheck();

%% WAIT FOR COMMAND FROM QNX
%*************************************************
%  run blocking readline and response commands
%**************************************************


while(1)
    pnet(con,'setreadtimeout',readTimeOut);
    if(pnet(con,'status')==0||con==-1)
        con=pnet(sockcon,'tcplisten'); 
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        if (keyIsDown && strcmp(KbName(keyCode),'esc')) % if the esc key is pressed aborts qpcsAll
            break;
        end
        continue;
    end
    commandIn = pnet(con,'readline');
    if strcmp(commandIn,'')
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        if (keyIsDown==1 && strcmp(KbName(keyCode),'esc')==1)
            break;
        end
        continue;
    end
    if(commandIn=='q')
        break
    end
    if(pnet(con,'status')==0)
        con=pnet(sockcon,'tcplisten');
        continue;         
    end
    try
        reply = '\n';
        parseCommand(commandIn); % determines what function/subfuction to run and then executes it. 
    catch
        psychrethrow(psychlasterror);
    end
    pnet(con,'printf', reply); % indicate completion by sending the reply string back to the QNX computer.
end

%%
%*******************************************************
% FINISH AND CLOSE CONNECTION
%******************************************************
ShowCursor;
sca;
pnet('closeall');

%% READ IN COMMAND AND EXECUTE IT
function parseCommand(command)
% parseCommand(command)
% reads in commands sent through the socket and creates function calls out of them.
% parseCommand is called by by qpcsBER at the end of the while loop.
% command should be a single text string
%           the first "word" in the string should be a function to call
%           each "word" after that will be read in as an arguement to the function
%           each arguement should be separated by a space
%%
     
    commandArray = textscan(command,'%s'); % turns the command string into a cell array broken up by spaces
    
    %******************************************************************
    % If the first word is a command
    %******************************************************************
    switch(sprintf(cell2mat(commandArray{1}(1))))
        case 'ping'
            reply = sprintf('pong %s\n',sprintf(cell2mat(commandArray{1}(2))));
            return
        case 'setsystem' % this case initializes the appropriate functions for the experiment to run
            currentSystem = sprintf(cell2mat(commandArray{1}(2))); % turns experiment name from cell to a string.
            try
                currentSystemHandle = eval(strcat(currentSystem,'()')); % calls experiment function and returns a cell with the list of subfunctions
            catch
                %psychrethrow(psychlasterror); 
            end
            return;
        case 'q' % this will close down the session
            pnet('closeall');
            return;
    end
       
    %******************************************************************
    % The rest of the commands reference the system (persistent currentSystem)
    %******************************************************************

    getComd = @(x) sprintf(cell2mat(commandArray{1}(x))); %returns command at index x

    comdEval = ''; % initializes comdEval to be filled with arguments for the function to be called
    for i =2:size(commandArray{1},1);
        if i==2 
            comdEval=str2num(getComd(2));  % resets comdEval with first sent argument
            continue;
        end
       % comdEval = strcat([comdEval,' ',getComd(i)]); % actually fills the variable with the sent arguments 
        comdEval = [comdEval str2num(getComd(i))];
    end
    
    for i=1:size(currentSystemHandle,1) % loops through all the subfunctions of the current experiment
        if regexp(func2str(currentSystemHandle{i}),getComd(1),'once') > size(currentSystem,2)
            if size(comdEval)==0
                currentSystemHandle{i}();   % calls current subfunction of experiment with no arguments
            else
                currentSystemHandle{i}(comdEval) %calls current subfunction of experiment with arguments
            end
          return;
        end
    end
    
    clear getComd comdEval 
end

%%
    %**************
    % ber_emcalib
    %**************
function emcalibHandle = ber_emcalib()

    emcalibHandle = ...
        {...
            @R_punishStim;...
            @R_fixOn;...
            @R_setFixColor;...
            @R_remoteTargetOn;...
            @R_getStmParamByName;...
            @R_getStmParamName;...
            @R_fixOff;...
            @R_getStmNParams;...
            @R_getStmParam;...
            @R_getBlock;...
            @R_nextTrial;...
            @R_clearscreen;...
            @R_reset;...
            @R_clearstim;...
            @R_getFixPosX;...
            @R_getFixPosY;...
            @R_getFixEye;...
            @newStmParam;...
            @emcalibReset;...
        };

    persistent emcalib_xpos;
    persistent emcalib_ypos;
    persistent emcalib_trial_num;
    persistent emcalib_eye;
    persistent emcalib_block;
    persistent emcalib_fixcolor;

    emcalib_fixcolor = [255 255 255];

    function R_punishStim()

    end
    
    function R_fixOn (varargin)
        WinCenter = screenInfo.center;
        FixationSize=screenInfo.ppd*6;
        dotcenter = screenInfo.ppd*[0; 0];
        if (size(varargin,1)~=0)
%             params=sscanf(varargin{1,1},'%f');
            params=varargin{1,1};
            dotcenter = screenInfo.ppd*[params(1) params(2)];
            FixationSize=screenInfo.ppd*params(3);
        end
        DotLocation=[WinCenter(1)+dotcenter(1) WinCenter(2)-dotcenter(2)]; % y needs to be inverted because screen is calculated from upper right corner
        DisplayFixSize=[DotLocation(1)-FixationSize/2, DotLocation(2)-FixationSize/2, DotLocation(1)+FixationSize/2, DotLocation(2)+FixationSize/2];
        Screen('FillOval',screenInfo.curWindow,emcalib_fixcolor,DisplayFixSize);
        Screen('Flip', w);
    end
    
    function R_setFixColor (varargin)
        params=varargin{1,1};
        emcalib_fixcolor = [params(1) params(2) params(3)];
    end
    
    function R_remoteTargetOn ()

    end
    
    function R_getStmParamByName (varargin)
        params=varargin{1,1};
        switch params(1)
            case 1
                R_getFixPosX();
            case 2
                R_getFixPosY();
            case 3
                R_getFixEye();
            otherwise
                reply = 'ERROR\n';
        end
%         if strcmp(params,'xpos')
%             R_getFixPosX();
%         elseif strcmp(params,'ypos')
%             R_getFixPosY();
%         elseif strcmp(params,'eye')
%             R_getFixEye();
%         else
%             reply = 'ERROR\n';
%         end
    end
    
    function R_getStmParamName ()
        reply = 'xpos\n';
    end
    
    function R_fixOff()
        try
            Screen('Flip', w);        
        catch
            disp('no stimulus was on');
        end
    end
    
    function R_getStmNParams ()
            reply = '3\n';
    end
    
    function R_getStmParam ()
            reply = '0.0\n';
    end
    
    function R_getBlock(n)
        emcalib_trial_num = 0;
        A = perms([-1,0,1]);
        A = [A(:,1:2); -1,-1;0,0;1,1];
        A = [A, zeros(9,1); A, ones(9,1)];
        A = [A,randperm(18)'];
        A = sortrows(A,4);
        emcalib_block = A(:,1:3);
        reply = sprintf('%d\n',size(emcalib_block,1));
    end
    
    function R_nextTrial()
         if(emcalib_trial_num < size(emcalib_block,1)-1)
            emcalib_trial_num = emcalib_trial_num + 1;
         else
             emcalib_trial_num = -1;
             reply = sprintf('-1\n');
             return;
         end
         emcalib_xpos = emcalib_block(emcalib_trial_num,1);
         emcalib_ypos = emcalib_block(emcalib_trial_num,2);
         emcalib_eye = emcalib_block(emcalib_trial_num,3);
         reply = sprintf('%d %d %d %d\n',emcalib_trial_num,emcalib_eye,emcalib_xpos+1,emcalib_ypos+1);
    end
    
    function R_clearscreen()         

    end
    
    function R_reset ()

    end
    
    function R_clearstim ()

    end
    
    function R_getFixPosX  () 
        reply = sprintf('%d\n',emcalib_xpos*6); 
    end
    
    function R_getFixPosY()
        reply = sprintf('%d\n',emcalib_ypos*6);           
    end
    
    function R_getFixEye()
        reply = sprintf('%d\n',emcalib_eye);
    end
    
    function newStmParam (varargin)

    end
    
    function emcalibReset()

    end
    
end

%% 
function HFHandle = block_fixation()

    HFHandle = ...
    {...
        @R_reset;...
        @R_makeFixStim;...
        @R_makeDots;...
        @R_fixOn;
        @R_fixOff;
        @R_dotsOn;...
        @R_dotsOff;...
        @R_chooseDots;...
    };
    
    display('ber_blockfixation')
    R_reset();
    R_makeFixStim();
    R_makeDots();
  
    function R_fixOn()
        Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
        Screen('Flip',w);
    end
    
    function R_fixOff()
        Screen('Flip', w);
    end
    
    function R_dotsOn(varargin)
        
        if ~numel(varargin), 
            disp('R_dotsOn: using default parameters'); 
            params(1) = 90; % default direction is up
            params(2) = 1;  % default Fixation is ON
        else
            params=varargin{1,1};
        end
        dotInfo.dir= params(1); % vertical vectors, dots direction (degrees) for each dot patch
        FixationOn=params(2); % Set to 1 if the Fixation REMAINS ON :: Set to 0 if the Fixation TURNS OFF
        
        pnet(con,'setreadtimeout',.001);
        pnet(con,'printf', reply);  % HERE WE NEED TO "RETURN CONTROL" TO THE SOCKET!
 %       disp('R_dotsOn called');
        rseed = sum(100*clock);
        rand('state', rseed);

        curWindow = screenInfo.curWindow;
        dotColor = dotInfo.dotColor;
        coh   	= dotInfo.coh/1000;	%  % dotInfo.coh is specified on 0... (because of rex needing integers), but we want 0..1
        apD = dotInfo.apXYD(:,3); % diameter of aperture in Degrees
        d_ppd 	= floor(apD/10 * screenInfo.ppd);  % need to figure out why it thinks ppd needs to be reduced!
        dotSize = dotInfo.dotSize; % probably better to leave this in pixels, but not sure
        dontclear = screenInfo.dontclear;

        % change the xy coordinates to pixels (y is inverted - pos on bottom, neg. on top
        center = screenInfo.center;
        center = [center(:,1) + dotInfo.apXYD(:,1)/10*screenInfo.ppd center(:,2) - dotInfo.apXYD(:,2)/10*screenInfo.ppd]; % where you want the center of the aperture

        % create the square for the aperture
        apRect = [center-d_ppd/2 center+d_ppd/2];

        % ndots is the number of dots shown per video frame. wWe will place dots in a square the size of the aperture
        % - Size of aperture = Apd*Apd/100  sq deg
        % - Number of dots per video frame = 16.7 dots per sq.deg/sec,
        %        Round up, do not exceed the number of dots that can be plotted in a video frame (dotInfo.maxDotsPerFrame)
        ndots 	= min(dotInfo.maxDotsPerFrame, ceil(dotInfo.dotDensity * apD .* apD * 0.01 / screenInfo.monRefresh));

        for df = 1 : dotInfo.numDotField,
            dxdy{df} 	= repmat((dotInfo.speed(df)/10) * (10/apD(df)) * (3/screenInfo.monRefresh) ... % dxdy is an N x 2 matrix that gives jumpsize in units on 0-1
                * [cos(pi*dotInfo.dir(df)/180.0) -sin(pi*dotInfo.dir(df)/180.0)], ndots(df),1);  %    	 deg/sec     * Ap-unit/deg  * sec/jump   =   unit/jump
            ss{df}		= rand(ndots(df)*3, 2); % array of dot positions raw [xposition yposition]
            Ls{df}      = cumsum(ones(ndots(df),3))+repmat([0 ndots(df) ndots(df)*2], ndots(df), 1); % divide dots into three sets...
            loopi(df)   = 1; 	% loops through the three sets of dots
        end;
        %
        % loop length is determined by the field "dotInfo.maxDotTime"  if none given, loop until "continue_show=0"
        % is set by other means (eg. user response), otherwise loop until dotInfo.maxDotTime. always one video frame per loop
        if ~isfield(dotInfo,'maxDotTime') || (isempty(dotInfo.maxDotTime) && ndots>0),
            continue_show = -1;
        elseif ndots > 0,
            continue_show = round(dotInfo.maxDotTime*screenInfo.monRefresh)+1000;
        else
            continue_show = 0;
        end

        % % THE MAIN LOOP
        % how dots are presented: 1 group of dots are shown in the first frame, a second group are shown in the second frame, 
        % a third group shown in the third frame, then in the next frame, some percentage of the dots from the first frame are 
        % replotted according to the speed/direction and coherence, the next frame the same is done for the second group, etc.
        while continue_show
%             disp('made it to loop');

             commandIn = pnet(con,'readline');
             if ~isempty(commandIn)
                 fprintf(strcat(commandIn,'\n'));
                 pnet(con,'printf', reply);  % HERE WE NEED TO "RETURN CONTROL" TO THE SOCKET!
             end
%             if strcmp(commandIn,'')
%                 [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
%                 if (keyIsDown==1 && strcmp(KBName(keyCode),'esc')==1)
%                     break;
%                 end
%                 continue;
%             end
             if strcmp(commandIn,'R_dotsOff')
                 continue_show=0;
                 break
             end
            
            for df = 1 : dotInfo.numDotField,

                % ss is the matrix with the 3 sets of dot positions, dots from the last 2 positions + current
                % Ls picks out the set (for ex., with 5 dots on the screen at a time, 1:5, 6:10, or 11:15)
                Lthis{df}  = Ls{df}(:,loopi(df));  % Lthis has the dot positions from 3 frames ago, which is what is then moved in the current loop
                this_s{df} = ss{df}(Lthis{df},:); % this is a matrix of random #s - starting positions for dots not moving coherently        
               %  loopi(df) = loopi(df)+1; % update the loop pointer
                if loopi(df) == 4,
                    loopi(df) = 1;
                end
                L = rand(ndots(df),1) < coh(df); % compute new locations, how many dots move coherently
                this_s{df}(L,:) = this_s{df}(L,:) + dxdy{df}(L,:);	% offset the selected dots
                if sum(~L) > 0
                    this_s{df}(~L,:) = rand(sum(~L),2);	    % get new random locations for the rest
                end
                % wrap around - check to see if any positions are greater than one or less than zero which is out of the 
                % square aperture, and then replace with a dot along one of the edges opposite from direction of motion.
                N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
                if sum(N) > 0
                    ydir = sin(pi*dotInfo.dir(df)/180.0);
                    xdir = cos(pi*dotInfo.dir(df)/180.0);
                    if rand < abs(ydir)/(abs(ydir) + abs(xdir)) % flip a weighted coin to see which edge to put the replaced dots
                        if ydir > 0 % if the dots are moving up puts them back on the bottom after they pass the top border
                            this_s{df}(find(N==1),:) = [rand(sum(N),1) (ydir > 0)*ones(sum(N),1)+this_s{df}(find(N==1),2)];
                        else % if the dots are moving down puts them back on the top after they pass the bottom border
                            this_s{df}(find(N==1),:) = [rand(sum(N),1) (ydir < 0)*ones(sum(N),1)-this_s{df}(find(N==1),2)];
                        end
                    else
                        if xdir < 0
                            this_s{df}(find(N==1),:) = [(xdir < 0)*ones(sum(N),1)+this_s{df}(find(N==1),1) rand(sum(N),1)];
                        else
                            this_s{df}(find(N==1),:) = [(xdir > 0)*ones(sum(N),1)-this_s{df}(find(N==1),1) rand(sum(N),1)];
                        end
                    end
                end

                % convert to stuff we can actually plot
                this_x{df} = floor(d_ppd(df) * this_s{df});	% pix/ApUnit
                dot_show{df} = (this_x{df} - d_ppd(df)/2)'; % shifts dots to the center of the aperture by adding 1/2 the distance to both x and y

            end;
            Screen('Flip', curWindow,0,dontclear); % draws dots from previous loop, first time through doesn't do anything

            % setup the mask - will only see a circular aperture, though dots move in a square aperture.  Minimizes the edge effects.
            for df = 1 : dotInfo.numDotField,
                Screen('FillRect', curWindow, [0 0 0 0], apRect(df,:)+[-20 -20 20 20]); % square that dots do not show up in
                Screen('FillOval', curWindow, [0 0 0 255], apRect(df,:)); % circle that dots do show up in
            end

            Screen('BlendFunction', curWindow, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
            if FixationOn
                Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
            end

            for df = 1:dotInfo.numDotField % now do actual drawing commands, although nothing drawn until next loop
                Screen('DrawDots', curWindow, dot_show{df}, dotSize, dotColor, center(df,:));
            end;

            % tell ptb to get ready while doing computations for next dots presentation
            Screen('DrawingFinished',curWindow,dontclear);
            Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);

            for df = 1 : dotInfo.numDotField,
                ss{df}(Lthis{df}, :) = this_s{df}; % update the dot position array for the next loop
            end;
            % check for end of loop
            continue_show = continue_show - 1;
        end
        Screen('Flip', curWindow,0,dontclear); % present last frame of dots
        if FixationOn
            Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
        end
        Screen('Flip', curWindow); % erase last dots, but leave up fixation and targets (if targets are up) 
    end
    
    function R_dotsOff()
        Screen('Flip', screenInfo.curWindow); % erase last dots, but leave up fixation and targets (if targets are up) 
    end
        
    function R_reset()
        Screen('Flip',w);
    end
        
    function R_makeFixStim(varargin)
        Center = screenInfo.center;
        if ~numel(varargin), 
            disp('R_makeFixStim: using default parameters'); 
            params(1) = .2;
            params(2) = 1;
            params(3) = 5;
            params(4) = .5;
        else
            disp('R_makeFixStim: using recieved parameters');
            params=varargin{1,1};
            Screen('Close',FixImage.display)
        end
       
        FixColor = [255 255 0];
        DegreeFixation=params(1);
        FixContrast=params(2);
        FixationSize=screenInfo.ppd*DegreeFixation;
        DisplayFixSize=[Center(1)-FixationSize/2 Center(2)-FixationSize/2 Center(1)+FixationSize/2 Center(2)+FixationSize/2];
%         DisplayFixSize=[Center(1)-FixationSize Center(2)-FixationSize Center(1)+FixationSize Center(2)+FixationSize];
        DisplayFixColor=FixColor*FixContrast;
        
        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('FillOval',FixScreen,DisplayFixColor,DisplayFixSize); 
        Spot1=Screen('GetImage', FixScreen);
        Spot2=MaskImageInBR(Spot1);
        FixImage.spot=Screen('MakeTexture',screenInfo.curWindow,Spot2);

        RingColor = [0 0 255];
        RingRadius=params(3);
        RingContrast=params(4);
        RingSize=screenInfo.ppd*RingRadius;
%         DisplayRingSize=[Center(1)-RingSize/2 Center(2)-RingSize/2 Center(1)+RingSize/2 Center(2)+RingSize/2];
        DisplayRingSize=[Center(1)-RingSize Center(2)-RingSize Center(1)+RingSize Center(2)+RingSize];
        DisplayRingColor=RingColor*RingContrast;

        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('FrameOval',FixScreen,DisplayRingColor,DisplayRingSize);
        Ring1=Screen('GetImage', FixScreen);
        Ring2=MaskImageInBR(Ring1);
        FixImage.ring=Screen('MakeTexture',screenInfo.curWindow,Ring2);

        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('DrawTexture',FixScreen,FixImage.spot);
        Screen('DrawTexture',FixScreen,FixImage.ring);
        Display1=Screen('GetImage', FixScreen);
        FixImage.display=Screen('MakeTexture',screenInfo.curWindow,Display1);
                     
        Screen('Close',[FixImage.spot FixImage.ring]) % 
        clear params Center *Color Degree* *Contrast *Size Display* Spot1 Ring1 Spot2 Ring2

    end
    
    function R_makeDots(varargin)
%        disp('makeallStimuli called');
      
        if ~numel(varargin), 
            disp('makeDots: using default parameters'); 
            params(1) = 15;
            params(2) = 1;
            params(3) = 90;
            params(4) = 200;
            params(5) = 3;
            params(6) = 5;
            params(7) = 16.7;
            params(8) = 255;
            params(9) = 255;
            params(10) = 255;
            params(11) = 1;
            
        else
            disp('makeDots: using sent parameters');
            params=varargin{1,1};
        end
 
        
        FieldDiameter=params(1);
        Coherence=params(2);
        Direction=params(3);
        Speed = params(4);
        DotSize = params(5);
        DotFieldDuration = params(6);
        DotDensity = params(7);
        DotR = params(8);
        DotG = params(9);
        DotB = params(10);
        DotContrast = params(11);
        try
            dotInfo.apXYD=[0 0 FieldDiameter*10];  %  x, y coordinates, and diameter of aperture(s) in visual degrees *10 for some reaso
            dotInfo.coh=Coherence*1000; % vertical vectors, dots coherence (0...999) for each dot patch
            dotInfo.dotSize= DotSize; % size of dots in pixels, same for all patches
            dotInfo.speed= Speed;    % vertical vectors, dots speed (10th deg/sec) for each dot patch
            dotInfo.dir= Direction;    % vertical vectors, dots direction (degrees) for each dot patch
            dotInfo.maxDotsPerFrame = 1000; % determined by testing video card
            dotInfo.dotColor= [DotR DotG DotB]*DotContrast;  % makes the dots white
            dotInfo.numDotField= 1; % number of fields of dots (Technically unnecessary at this point)
            dotInfo.maxDotTime = DotFieldDuration; % number of seconds dots are shown for.
            dotInfo.dotDensity = DotDensity;
        catch
            disp('catch in R_makeDots')
            Screen('CloseAll');
            psychrethrow(psychlasterror);
        end
    end
    
    function [direction]=R_chooseDots(varargin)
        Alldirections=[0 90 180 270];
        if ~numel(varargin)
            Ordered=Alldirections(randperm(length(Alldirections)));
            direction=Ordered(1);
        else
            Lastdirection=varargin{1,1};
            while 1
                Ordered=Alldirections(randperm(length(Alldirections)));
                direction=Ordered(1);
                if Lastdirection ~= direction
                    break
                end
            end
        end
    end
                    
                
            
end
%% Movie_fixation
function HFHandle = movie_fixation()

    HFHandle = ...
    {...
        @R_reset;...
        @R_makeFixStim;...
        @R_loadMovies;...
        @R_fixOn;
        @R_fixOff;
        @R_movieOpen;...
        @R_movieOn;...
        @R_movieOff;...
        @R_movieClose;...
    };
    
    display('system: movie_fixation')
    R_reset();
    R_makeFixStim();
    persistent MovieInfo
    
    % list the name of the movies that can potentially be used
    MovieInfo.MovieList={'Movie1.avi'; 'Movie2.avi'; 'Movie3.avi'; 'Movie4.avi';... 
        'Movie5.avi'; 'Movie6.avi';... % used for size differences (5 10 15 degrees).
        'Movie7.avi'; 'Movie8.avi'; 'Movie9.avi';... % same content different order.
        'Movie10.avi'; 'Movie11.avi'; 'Movie12.avi';... % agonistic, affiliative, copulations.
        'Movie13.avi'; 'Movie14.avi'; 'Movie15.avi';... % rhesus, polar bears, chimps.
        'Movie16.avi'; 'Movie17.avi'; 'Movie18.avi';...  % Non-social Movies (tornados, snow, volcano, floods)
        'Movie19.avi'; 'Movie20.avi'; 'Movie21.avi';... % Ava Eye maps over Movie1
        'Movie22.avi'; 'Movie23.avi'; 'Movie24.avi';... % Art Eye maps over Movie1
        'Movie25.avi'; 'Movie26.avi';}                  % Shuffled Movie7 (25-3.25secs; 26-11.6secs)
    
    MovieInfo.trialmovie=[];
    MovieInfo.movdim=[];
    MovieInfo.fps=[];
    
    function R_fixOn()
        Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
        Screen('Flip',w);
    end
    
    function R_fixOff()
        Screen('Flip', w);
    end
    
    function R_movieOpen(varargin)
        if ~numel(varargin), 
            disp('R_movieOn: using default parameters'); 
            params(1) = 1;  % sets movie to be default movie
        else
            params=varargin{1,1};
            disp('R_movieOn: using sent parameters');
        end
%         disp(['params = ' num2str(params)])
        moviename=MovieInfo.MovieList{params(1)}; % choices the correct movie to play.
        fullpathmov=[localpath '\' moviename];
        [MovieInfo.trialmovie,movtime,MovieInfo.fps,MovieInfo.movdim(1),MovieInfo.movdim(2)] = Screen('OpenMovie', screenInfo.curWindow, fullpathmov);
        
        disp([moviename ' playing at ' num2str(MovieInfo.fps) 'fps and original size of ' num2str(MovieInfo.movdim)])
        clear params movtime
    end
    
    function R_movieOn(varargin)
        
        
        if ~numel(varargin), 
            disp('R_movieOn: using default parameters'); 
            params(1) = 1;  % default Fixation is ON
            params(2) = 12; % sets default viewing to 12 degrees
            params(3) = 0;  % sets default center X to 0 degrees
            params(4) = 0;  % sets default center Y to 0 degrees
        else
            params=varargin{1,1};
        end
        
        FixationOn=params(1); % Set to 1 if the Fixation REMAINS ON :: Set to 0 if the Fixation TURNS OFF
        degrees=params(2); % sets viewing window to be to X degrees
        CenterOffset(1)=params(3)*screenInfo.ppd;  % sets the center X position of the movie in pixels
        CenterOffset(2)=params(4)*screenInfo.ppd;  % sets the center Y position of the movie in pixels
        
        pnet(con,'setreadtimeout',.001);
        pnet(con,'printf', reply);  % HERE WE NEED TO "RETURN CONTROL" TO THE SOCKET!
 %       disp('R_MovieOn called');
        rseed = sum(100*clock);
        rand('state', rseed);
        
        continue_show = 1;

        % % THE MAIN LOOP
        % how movies are presented: A movie is read into trialmovie using
        % the OpenMovie screen command.  The each frame is read into a
        % texture and flipped onto the screen while the function waits for
        % a OFF command from QNX.  
        
        % change the xy coordinates to pixels and oriented on center point (y is inverted - pos on bottom, neg. on top
        center = [screenInfo.center(1)+CenterOffset(1) screenInfo.center(2)-CenterOffset(2)];
        movdimscaled=MovieInfo.movdim*((screenInfo.ppd*degrees)/MovieInfo.movdim(1));
        MovRect = [center-movdimscaled/2 center+movdimscaled/2]; % create the square for the Movie to play in
        
        Screen('PlayMovie',MovieInfo.trialmovie,1);
        while continue_show
%             disp('made it to loop');

             commandIn = pnet(con,'readline'); % Check to make sure movie should still be playing
             if ~isempty(commandIn)
                 fprintf(strcat(commandIn,'\n'));
                 pnet(con,'printf', reply);  % HERE WE NEED TO "RETURN CONTROL" TO THE SOCKET!
             end
%             if strcmp(commandIn,'')
%                 [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
%                 if (keyIsDown==1 && strcmp(KBName(keyCode),'esc')==1)
%                     break;
%                 end
%                 continue;
%             end
             if strcmp(commandIn,'R_movieOff') % Exits loop if movie is being turned off.
                 continue_show=0;
                 break
             end
            
             movtex = Screen('GetMovieImage', screenInfo.curWindow, MovieInfo.trialmovie);

            % Valid texture returned? A negative value means end of movie reached:
            if movtex<=0
                % We're done, break out of loop:
                break;
            end;
            
%             Screen('BlendFunction', screenInfo.curWindow, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);

            % Draw the new texture immediately to screen:
            Screen('DrawTexture', screenInfo.curWindow, movtex, [],MovRect);
            
            if FixationOn
                Screen('DrawTexture',screenInfo.curWindow,FixImage.display,[],[],[],[],0);
            end
            
%             Screen('DrawingFinished',screenInfo.curWindow);
%             Screen('BlendFunction', screenInfo.curWindow, GL_ONE, GL_ZERO);
            % Update display:
            Screen('Flip', screenInfo.curWindow);

            % Release texture:
            Screen('Close', movtex);
           
        end
        Screen('PlayMovie',MovieInfo.trialmovie,0);
        
        Screen('Flip', screenInfo.curWindow); % erases the last frame of the movie 
        if FixationOn
            Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
            Screen('Flip', screenInfo.curWindow); %  puts up fixation and targets (if targets are up) 
        end
        clear  movtex continue_show center MovRect movdimscaled FixationOn degrees 
    end
    
    function R_movieOff()
        Screen('Flip', screenInfo.curWindow); % erase last dots, but leave up fixation and targets (if targets are up) 
    end
    
    function R_movieClose()
        try
            Screen('CloseMovie',MovieInfo.trialmovie);
            Screen('Flip', screenInfo.curWindow); % erase last dots, but leave up fixation and targets (if targets are up) 
        end
    end
    
    function R_reset()
        Screen('Flip',w);
    end
        
    function R_makeFixStim(varargin)
        
        if ~numel(varargin), 
            disp('R_makeFixStim: using default parameters'); 
            params(1) = .2;
            params(2) = 1;
            params(3) = 5;
            params(4) = .5;
            params(5) = 0;
            params(6) = 0;
        else
            disp('R_makeFixStim: using recieved parameters');
            params=varargin{1,1};
            Screen('Close',FixImage.display)
        end
%         disp(['params = ' num2str(params)])
        
        CenterOffset=[params(5) params(6)]*screenInfo.ppd;
        Center = [screenInfo.center(1)+CenterOffset(1) screenInfo.center(2)-CenterOffset(2)] ;
        
        FixColor = [255 255 0];
        DegreeFixation=params(1);
        FixContrast=params(2);
        FixationSize=screenInfo.ppd*DegreeFixation;
%         DisplayFixSize=[Center(1)-FixationSize/2 Center(2)-FixationSize/2 Center(1)+FixationSize/2 Center(2)+FixationSize/2];
        DisplayFixSize=[Center(1)-FixationSize Center(2)-FixationSize Center(1)+FixationSize Center(2)+FixationSize];
        DisplayFixColor=FixColor*FixContrast;
        
        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('FillOval',FixScreen,DisplayFixColor,DisplayFixSize); 
        Spot1=Screen('GetImage', FixScreen);
        Spot2=MaskImageInBR(Spot1);
        FixImage.spot=Screen('MakeTexture',screenInfo.curWindow,Spot2);

        RingColor = [0 0 255];
        RingRadius=params(3);
        RingContrast=params(4);
        RingSize=screenInfo.ppd*RingRadius;
%         DisplayRingSize=[Center(1)-RingSize/2 Center(2)-RingSize/2 Center(1)+RingSize/2 Center(2)+RingSize/2];
        DisplayRingSize=[Center(1)-RingSize Center(2)-RingSize Center(1)+RingSize Center(2)+RingSize];
        DisplayRingColor=RingColor*RingContrast;

        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('FrameOval',FixScreen,DisplayRingColor,DisplayRingSize);
        Ring1=Screen('GetImage', FixScreen);
        Ring2=MaskImageInBR(Ring1);
        FixImage.ring=Screen('MakeTexture',screenInfo.curWindow,Ring2);

        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('DrawTexture',FixScreen,FixImage.spot);
        Screen('DrawTexture',FixScreen,FixImage.ring);
        Display1=Screen('GetImage', FixScreen);
        Display2=MaskImageInBR(Display1);
        FixImage.display=Screen('MakeTexture',screenInfo.curWindow,Display2);
                     
        Screen('Close',[FixImage.spot FixImage.ring]) % 
        clear params Center *Color Degree* *Contrast *Size Display* Spot1 Ring1 Spot2 Ring2

    end
    
    function R_loadMovies(varargin)
%        disp('makeallStimuli called');
      
        if ~numel(varargin), 
            disp('loadMovies: using default parameters'); 
            params(1) = 1;  % number of movies to load
            params(2) = 0;  % should the movies be randomized
            
        else
            disp('loadMovies: using sent parameters');
            params=varargin{1,1}; % number of movies to load
        end
        
        NumMovies=params(1);
        RandMovies=params(2);
        
        MovieList={'Test1.mov'; 'Test2.avi';}; % list the name of the movies that can potentially be used
        
        if RandMovies
            MovieOrder=MovieList(randperm(length(MovieList)));
        end
    end
               
end

%% BER_WATERCALIB
function watercalibHandle = watercalib()

    watercalibHandle = ...
        {...
            @R_Juicer;...
            
        };
    
end



%% 
    %**************
    % Stereocalib
    %**************

    function stereocalibHandle = stereocalib()

        stereocalibHandle = ...
            {...
                @R_punishStim;...
                @R_fixOn;...
                @R_setFixColor;...
                @R_remoteTargetOn;...
                @R_getStmParamByName;...
                @R_getStmParamName;...
                @R_fixOff;...
                @R_getStmNParams;...
                @R_getStmParam;...
                @R_getBlock;...
                @R_nextTrial;...
                @R_clearscreen;...
                @R_reset;...
                @R_clearstim;...
                @R_getFixPosX;...
                @R_getFixPosY;...
                @R_getFixEye;...
                @newStmParam;...
                @stereocalibReset;...
            };

        persistent stereocalib_xpos;
        persistent stereocalib_ypos;
        persistent stereocalib_trial_num;
        persistent stereocalib_eye;
        persistent stereocalib_block;
        persistent stereocalib_fixcolor;

        try
            FixDt=ones(7,7)*255;
            fixdot = Screen('MakeTexture',w,FixDt);
        catch
            disp('catch in  makestimuli')
            Screen('CloseAll');
            psychrethrow(psychlasterror);
        end
        stereocalib_fixcolor = [255 255 255];

        function R_punishStim()

        end

        function R_fixOn (varargin)
            rect=Screen('Rect', w);
            dotSize = 6;
            dotOffcenter = [0; 0];
            if (size(varargin,1)~=0)
                params=sscanf(varargin{1,1},'%f');
                dotSize = 30*params(4);
                dotOffcenter = 140/6*[params(1); params(2)];
            end
            newRect = [rect(3)/2-dotSize/2+dotOffcenter(1),rect(4)/2-dotSize/2-dotOffcenter(2),rect(3)/2+dotSize/2+dotOffcenter(1),rect(4)/2+dotSize/2-dotOffcenter(2)];
            Screen('DrawTexture', w, fixdot, rect, newRect,[],[],[],stereocalib_fixcolor);
            Screen('Flip', w);
        end

        function R_setFixColor (varargin)
            params=sscanf(varargin{1,1},'%f');
            stereocalib_fixcolor = [params(1) params(2) params(3)];
        end

        function R_remoteTargetOn ()

        end

        function R_getStmParamByName (varargin)
            params=sscanf(varargin{1,1},'%s');
            if strcmp(params,'xpos')
                R_getFixPosX();
            elseif strcmp(params,'ypos')
                R_getFixPosY();
            elseif strcmp(params,'eye')
                R_getFixEye();
            else
                reply = 'ERROR\n';
            end
        end

        function R_getStmParamName ()
            reply = 'xpos\n';
        end

        function R_fixOff()
            try
                Screen('Flip', w);        
            catch
                disp('no stimulus was on');
            end
        end

        function R_getStmNParams ()
                reply = '3\n';
        end

        function R_getStmParam ()
                reply = '0.0\n';
        end

        function R_getBlock(n)
            stereocalib_trial_num = 0;
            A = perms([-1,0,1]);
            A = [A(:,1:2); -1,-1;0,0;1,1];
            A = [A, zeros(9,1); A, ones(9,1)];
            A = [A,randperm(18)'];
            A = sortrows(A,4);
            stereocalib_block = A(:,1:3);
            reply = sprintf('%d\n',size(stereocalib_block,1));
        end

        function R_nextTrial()
             if(stereocalib_trial_num < size(stereocalib_block,1)-1)
                stereocalib_trial_num = stereocalib_trial_num + 1;
             else
                 stereocalib_trial_num = -1;
                 reply = sprintf('-1\n');
                 return;
             end
             stereocalib_xpos = stereocalib_block(stereocalib_trial_num,1);
             stereocalib_ypos = stereocalib_block(stereocalib_trial_num,2);
             stereocalib_eye = stereocalib_block(stereocalib_trial_num,3);
             reply = sprintf('%d %d %d %d\n',stereocalib_trial_num,stereocalib_eye,stereocalib_xpos+1,stereocalib_ypos+1);
        end

        function R_clearscreen()         

        end

        function R_reset ()

        end

        function R_clearstim ()

        end

        function R_getFixPosX  () 
            reply = sprintf('%d\n',stereocalib_xpos*6); 
        end

        function R_getFixPosY()
            reply = sprintf('%d\n',stereocalib_ypos*6);           
        end

        function R_getFixEye()
            reply = sprintf('%d\n',stereocalib_eye);
        end

        function newStmParam (varargin)

        end

        function stereocalibReset()

        end

    end

%% BER_TRAINING version 3
function OKNhandle = ber_training()

    OKNhandle = ...
        {...
            @R_fixOn;...
            @R_ringOn;...
            @R_fixOff;...
            @R_ringOff;...
            @R_dotsOn;...
            @R_dotsOff;...
            @R_gratOff;...
            @R_dispOn;...
            @R_makeFixStim;...
            @R_makeAllStimuli;...
        };
    
%     R_reset();
    disp('ber_training');
    R_makeAllStimuli()

    function R_dispOn()
        Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
        Screen('Flip',w);
    end

    function R_fixOn(varargin)
        Center = screenInfo.center;
        FixColor = [255 255 0];
        
        if ~numel(varargin), 
            disp('R_fixOn: using default parameters'); 
            params(1) = 1;
            params(2) = .5;
        else
           %             params=[sscanf(varargin{1,1},'%f')]
           params=varargin{1,1};
        end

        DegreeFixation=params(1);
        FixContrast=params(2);

        FixationSize=screenInfo.ppd*DegreeFixation;
        DisplayFixSize=[Center(1)-FixationSize/2 Center(2)-FixationSize/2 Center(1)+FixationSize/2 Center(2)+FixationSize/2];
        DisplayFixColor=FixColor*FixContrast;

        Screen('FillOval',screenInfo.curWindow,DisplayFixColor,DisplayFixSize); 
%         Screen('Flip', screenInfo.curWindow,0,screenInfo.dontclear);
        
        clear params Center FixColor DegreeFixation FixContrast FixationSize DisplayFixSize DisplayFixColor
    end

    function R_ringOn(varargin)
        Center = screenInfo.center;
        RingColor = [0 0 255];

        if ~numel(varargin), 
            disp('R_ringOn: using default parameters'); 
            params(1) = 1;
            params(2) = .5;
        else
           %             params=[sscanf(varargin{1,1},'%f')]
           params=varargin{1,1};
        end
      
        DegreeRing=params(1);
        RingContrast=params(2);


        RingSize=screenInfo.ppd*DegreeRing;
        DisplayRingSize=[Center(1)-RingSize/2 Center(2)-RingSize/2 Center(1)+RingSize/2 Center(2)+RingSize/2];
        DisplayRingColor=RingColor*RingContrast;

        Screen('FrameOval',screenInfo.curWindow,DisplayRingColor,DisplayRingSize);
        Screen('Flip', screenInfo.curWindow,0,screenInfo.dontclear);

        FixImage.display=Screen('GetImage', screenInfo.curWindow);
        FixImage.display=Screen('MakeTexture',screenInfo.curWindow,FixImage.display);
        
        clear params Center RingColor DegreeRing RingContrast RingSize DisplayRingSize DisplayRingColor
    end

    function R_fixOff()
        Screen('Flip',w);
    end

    function R_ringOff()
        Screen('Flip',w);
    end
    
    function R_dotsOn(varargin)
        
        if ~numel(varargin), 
            disp('R_dotsOn: using default parameters'); 
            params(1) = 90; % default direction is up
            params(2) = 0;  % default Fixation is ON
        else
            params=varargin{1,1};
        end
        dotInfo.dir= params(1); % vertical vectors, dots direction (degrees) for each dot patch
        FixationOn=params(2); % Set to 1 if the Fixation REMAINS ON :: Set to 0 if the Fixation TURNS OFF
        
        rseed = sum(100*clock);
        rand('state', rseed);

        curWindow = screenInfo.curWindow;
        dotColor = dotInfo.dotColor;
        coh   	= dotInfo.coh/1000;	%  % dotInfo.coh is specified on 0... (because of rex needing integers), but we want 0..1
        apD = dotInfo.apXYD(:,3); % diameter of aperture in Degrees
        d_ppd 	= floor(apD/10 * screenInfo.ppd);  % need to figure out why it thinks ppd needs to be reduced!
        dotSize = dotInfo.dotSize; % probably better to leave this in pixels, but not sure
        dontclear = screenInfo.dontclear;

        % change the xy coordinates to pixels (y is inverted - pos on bottom, neg. on top
        center = screenInfo.center;
        center = [center(:,1) + dotInfo.apXYD(:,1)/10*screenInfo.ppd center(:,2) - dotInfo.apXYD(:,2)/10*screenInfo.ppd]; % where you want the center of the aperture

        % create the square for the aperture
        apRect = [center-d_ppd/2 center+d_ppd/2];

        % ndots is the number of dots shown per video frame. wWe will place dots in a square the size of the aperture
        % - Size of aperture = Apd*Apd/100  sq deg
        % - Number of dots per video frame = 16.7 dots per sq.deg/sec,
        %        Round up, do not exceed the number of dots that can be plotted in a video frame (dotInfo.maxDotsPerFrame)
        ndots 	= min(dotInfo.maxDotsPerFrame, ceil(dotInfo.dotDensity * apD .* apD * 0.01 / screenInfo.monRefresh));

        for df = 1 : dotInfo.numDotField,
            dxdy{df} 	= repmat((dotInfo.speed(df)/10) * (10/apD(df)) * (3/screenInfo.monRefresh) ... % dxdy is an N x 2 matrix that gives jumpsize in units on 0-1
                * [cos(pi*dotInfo.dir(df)/180.0) -sin(pi*dotInfo.dir(df)/180.0)], ndots(df),1);  %    	 deg/sec     * Ap-unit/deg  * sec/jump   =   unit/jump
            ss{df}		= rand(ndots(df)*3, 2); % array of dot positions raw [xposition yposition]
            Ls{df}      = cumsum(ones(ndots(df),3))+repmat([0 ndots(df) ndots(df)*2], ndots(df), 1); % divide dots into three sets...
            loopi(df)   = 1; 	% loops through the three sets of dots
        end;
        %%
        % loop length is determined by the field "dotInfo.maxDotTime"  if none given, loop until "continue_show=0"
        % is set by other means (eg. user response), otherwise loop until dotInfo.maxDotTime. always one video frame per loop
        if ~isfield(dotInfo,'maxDotTime') || (isempty(dotInfo.maxDotTime) && ndots>0),
            continue_show = -1;
        elseif ndots > 0,
            continue_show = round(dotInfo.maxDotTime*screenInfo.monRefresh);
        else
            continue_show = 0;
        end

        % % THE MAIN LOOP
        % how dots are presented: 1 group of dots are shown in the first frame, a second group are shown in the second frame, 
        % a third group shown in the third frame, then in the next frame, some percentage of the dots from the first frame are 
        % replotted according to the speed/direction and coherence, the next frame the same is done for the second group, etc.
        while continue_show
            for df = 1 : dotInfo.numDotField,

                % ss is the matrix with the 3 sets of dot positions, dots from the last 2 positions + current
                % Ls picks out the set (for ex., with 5 dots on the screen at a time, 1:5, 6:10, or 11:15)
                Lthis{df}  = Ls{df}(:,loopi(df));  % Lthis has the dot positions from 3 frames ago, which is what is then moved in the current loop
                this_s{df} = ss{df}(Lthis{df},:); % this is a matrix of random #s - starting positions for dots not moving coherently        
               %  loopi(df) = loopi(df)+1; % update the loop pointer
                if loopi(df) == 4,
                    loopi(df) = 1;
                end
                L = rand(ndots(df),1) < coh(df); % compute new locations, how many dots move coherently
                this_s{df}(L,:) = this_s{df}(L,:) + dxdy{df}(L,:);	% offset the selected dots
                if sum(~L) > 0
                    this_s{df}(~L,:) = rand(sum(~L),2);	    % get new random locations for the rest
                end
                % wrap around - check to see if any positions are greater than one or less than zero which is out of the 
                % square aperture, and then replace with a dot along one of the edges opposite from direction of motion.
                N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
                if sum(N) > 0
                    ydir = sin(pi*dotInfo.dir(df)/180.0);
                    xdir = cos(pi*dotInfo.dir(df)/180.0);
                    if rand < abs(ydir)/(abs(ydir) + abs(xdir)) % flip a weighted coin to see which edge to put the replaced dots
                        if ydir > 0 % if the dots are moving up puts them back on the bottom after they pass the top border
                            this_s{df}(find(N==1),:) = [rand(sum(N),1) (ydir > 0)*ones(sum(N),1)+this_s{df}(find(N==1),2)];
                        else % if the dots are moving down puts them back on the top after they pass the bottom border
                            this_s{df}(find(N==1),:) = [rand(sum(N),1) (ydir < 0)*ones(sum(N),1)-this_s{df}(find(N==1),2)];
                        end
                    else
                        if xdir < 0
                            this_s{df}(find(N==1),:) = [(xdir < 0)*ones(sum(N),1)+this_s{df}(find(N==1),1) rand(sum(N),1)];
                        else
                            this_s{df}(find(N==1),:) = [(xdir > 0)*ones(sum(N),1)-this_s{df}(find(N==1),1) rand(sum(N),1)];
                        end
                    end
                end

                % convert to stuff we can actually plot
                this_x{df} = floor(d_ppd(df) * this_s{df});	% pix/ApUnit
                dot_show{df} = (this_x{df} - d_ppd(df)/2)'; % shifts dots to the center of the aperture by adding 1/2 the distance to both x and y

            end;
            Screen('Flip', curWindow,0,dontclear); % draws dots from previous loop, first time through doesn't do anything

            % setup the mask - will only see a circular aperture, though dots move in a square aperture.  Minimizes the edge effects.
            for df = 1 : dotInfo.numDotField,
                Screen('FillRect', curWindow, [0 0 0 0], apRect(df,:)+[-20 -20 20 20]); % square that dots do not show up in
                Screen('FillOval', curWindow, [0 0 0 255], apRect(df,:)); % circle that dots do show up in
            end

            Screen('BlendFunction', curWindow, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
            
            if FixationOn
                Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
            end

            for df = 1:dotInfo.numDotField % now do actual drawing commands, although nothing drawn until next loop
                Screen('DrawDots', curWindow, dot_show{df}, dotSize, dotColor, center(df,:));
            end;

            % tell ptb to get ready while doing computations for next dots presentation
            Screen('DrawingFinished',curWindow,dontclear);
            Screen('BlendFunction', curWindow, GL_ONE, GL_ZERO);

            for df = 1 : dotInfo.numDotField,
                ss{df}(Lthis{df}, :) = this_s{df}; % update the dot position array for the next loop
            end;
            % check for end of loop
            continue_show = continue_show - 1;
        end
        Screen('Flip', curWindow,0,dontclear); % present last frame of dots

        Screen('DrawTexture',screenInfo.curWindow,FixImage.display);
        Screen('Flip', curWindow); % erase last dots, but leave up fixation and targets (if targets are up) 
    end
    
    function R_dotsOff()
        Screen('Flip', screenInfo.curWindow); % erase last dots, but leave up fixation and targets (if targets are up) 
    end
    
    function R_gratOff()
    end
    
    function R_reset()

    end
    
    function R_makeFixStim(varargin)
        Center = screenInfo.center;
        
        if ~numel(varargin), 
            disp('R_makeFixStim: using default parameters'); 
            params(1) = .2;
            params(2) = 1;
            params(3) = 5;
            params(4) = .5;
        else
            disp('R_makeFixStim: using recieved parameters');
            params=varargin{1,1};
        end

        FixColor = [255 255 0];
        DegreeFixation=params(1);
        FixContrast=params(2);
        FixationSize=screenInfo.ppd*DegreeFixation;
        DisplayFixSize=[Center(1)-FixationSize/2 Center(2)-FixationSize/2 Center(1)+FixationSize/2 Center(2)+FixationSize/2];
        DisplayFixColor=FixColor*FixContrast;

        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('FillOval',FixScreen,DisplayFixColor,DisplayFixSize); 
        FixImage.spot=Screen('GetImage', FixScreen);
        FixImage.spot=MaskImageInBR(FixImage.spot);
        FixImage.spot=Screen('MakeTexture',screenInfo.curWindow,FixImage.spot);
        
        RingColor = [0 0 255];
        DegreeRing=params(3);
        RingContrast=params(4);
        RingSize=screenInfo.ppd*DegreeRing;
        DisplayRingSize=[Center(1)-RingSize/2 Center(2)-RingSize/2 Center(1)+RingSize/2 Center(2)+RingSize/2];
        DisplayRingColor=RingColor*RingContrast;

        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('FrameOval',FixScreen,DisplayRingColor,DisplayRingSize);
        FixImage.ring=Screen('GetImage', FixScreen);
        FixImage.ring=MaskImageInBR(FixImage.ring);
        FixImage.ring=Screen('MakeTexture',screenInfo.curWindow,FixImage.ring);

        Screen('DrawTexture',FixScreen,FixImage.blank);
        Screen('DrawTexture',FixScreen,FixImage.spot);
        Screen('DrawTexture',FixScreen,FixImage.ring);
        FixImage.display=Screen('GetImage', FixScreen);
        FixImage.display=Screen('MakeTexture',screenInfo.curWindow,FixImage.display);
        
        clear params Center *Color Degree* *Contrast *Size Display*
    end
    
    function R_makeAllStimuli(varargin)
  %      disp('makeallStimuli ');
      
        if ~numel(varargin), 
            disp('R_makeAllStim: using default parameters'); 
            params(1) = 15;
            params(2) = 1;
            params(3) = 90;
            params(4) = 200;
            params(5) = 3;
            params(6) = 5;
            params(7) = 16.7;
        else
            params=varargin{1,1};
        end
 
        
        FixationRing=params(1);
        Coherence=params(2);
        Direction=params(3);
        Speed = params(4);
        DotSize = params(5);
        DotFieldDuration = params(6);
        DotDensity = params(7);
        try
            dotInfo.apXYD=[0 0 FixationRing*10];  %  x, y coordinates, and diameter of aperture(s) in visual degrees *10 for some reaso
            dotInfo.coh=Coherence*1000; % vertical vectors, dots coherence (0...999) for each dot patch
            dotInfo.dotSize= DotSize; % size of dots in pixels, same for all patches
            dotInfo.speed= Speed;    % vertical vectors, dots speed (10th deg/sec) for each dot patch
            dotInfo.dir= Direction;    % vertical vectors, dots direction (degrees) for each dot patch
            dotInfo.maxDotsPerFrame = 1000; % determined by testing video card
            dotInfo.dotColor= [255 255 255];  % makes the dots white
            dotInfo.numDotField= 1; % number of fields of dots (Technically unnecessary at this point)
            dotInfo.maxDotTime = DotFieldDuration; % number of seconds dots are shown for.
            dotInfo.dotDensity = DotDensity;
        catch
            disp('catch in R_makeAllStimuli')
            Screen('CloseAll');
            psychrethrow(psychlasterror);
        end
    end
%     
%     function R_getNextStim()
%         reply = sprintf('%d\n',arrayStimOrder(currentStimID));
%         currentStimID = currentStimID + 1;
%     end
%     function R_stimIDRange(varargin)
%         params=sscanf(varargin{1,1},'%f');                
%         initStim = params(1);
%         R_reset();
%     end
end

end


