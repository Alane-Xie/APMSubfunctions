classdef ScreenConfig
    
    properties(SetAccess=private,GetAccess=public)
        ScreenCfg=[];
    end
    
    methods (Access=public)
        
        % constructor takes filename
        function this=ScreenConfig(ScreenConfigFile)
            if (nargin==0)
                this.ScreenCfg=[];
            else
                temp=load(ScreenConfigFile);
                this.ScreenCfg=temp.ScreenCfg;
            end

        end
        
        function this=LoadScreenConfig(this,ScreenConfigFile)
            
            temp=load(ScreenConfigFile);
            this.ScreenCfg=temp.ScreenCfg;
        end
        

        function this=SetScreenConfig(this,ScreenConfigFile)
            
            % determine which screen should be showing which image and save information
            % to a file
            
            %Screen('Preference', 'SkipSyncTests', 1);
            Screen('Preference', 'VisualDebugLevel', 2);
            KbName('UnifyKeyNames');
            
            % get details for each screen
            
            screens=screen('screens');
            
            % reset this.ScreenCfg
            
            this.ScreenCfg=[];
            this.ScreenCfg.Left=[]; % index of left screen
            this.ScreenCfg.Right=[]; % index of right screen
            this.ScreenCfg.Full=[]; % index of full screen
            this.ScreenCfg.UnSet=[]; % indices of screens which are unset
            this.ScreenCfg.NotUsed=[]; % indices of screens which are not used
            
            % for each screen display a question mark in the middle of the screen and
            % ask the user to select L,R or N to determine the physical position of the
            % screen
            valid=false;
            while (valid==false)
                
                
                for (i=1:length(screens))
                    % get dimensions for each screen
                    realindex=screens(i); % real screen index
                    this.ScreenCfg.screens(i).rect=screen('rect',realindex); % get dimensions of screen
                    this.ScreenCfg.screens(i).index=realindex; % get actual index - screens start from 0 = full screen
                    
                    
                    if (screens(i)==0) % full screen
                        this=this.SetScreen(i,'F');
                        %this.ScreenCfg.Full=unique([this.ScreenCfg.Full i]); % store Matlab index not real actual screen index - can get real index from this
                    else
                        this.ScreenCfg.screens(i).position='?';
                        this.SetScreen(i,'U');
                        %this.ScreenCfg.UnSet=unique([this.ScreenCfg.UnSet i]);
                        PsychImaging('PrepareConfiguration');
                        [wnd,screenRect]=PsychImaging('OpenWindow',realindex,[0 0 0]);
                        
                        this.DrawScreenIdent(wnd,screenRect,this.ScreenCfg.screens(i).position);
                        Screen('Flip',wnd);
                        nextScreen=false;
                        
                        while (nextScreen==false)
                            [keyIsDown,secs,keyCode] = KbCheck;
                            if keyIsDown
                                if keyCode(kbName('ESCAPE'))==1
                                    this.abort;
                                elseif keyCode(kbName('L')) == 1
                                    this=this.SetScreen(i,'L');
                                    nextScreen=true;
                                    %break;
                                elseif keyCode(kbName('R'))==1
                                    this=this.SetScreen(i,'R');
                                    nextScreen=true;
                                    %break;
                                elseif keyCode(kbName('N'))==1
                                    this=this.SetScreen(i,'N');
                                    nextScreen=true;
                                    %break;
                                end
                            end
                        end
                        if (nextScreen==true)
                            % briefly show what the screen has been set to       
                            this.DrawScreenIdent(wnd,screenRect,this.ScreenCfg.screens(i).position);
                            screen('Flip',wnd);
                            waitsecs(1);
                        end


                        sca;
                    end
                end
                
                sca;
                
                % test to make sure screens are set correctly
                
                % for example make sure for Left and Right that only 1 screen is set
                
                if (length(screens)==1) % only one screen so we are all good
                    valid=true;
                else
                    % validate screens
                    valid=true;

                    if (length(this.ScreenCfg.Left)==0)
                        yn=(input('No screens have been identified as left - you will not be able to present stimuli in stereo with this configuration.\n Is the correct (y/n) ','s')=='y');
                        if (yn==true)
                            valid=true;
                        else
                            valid=false;
                        end
                    
                    
                    elseif (length(this.ScreenCfg.Left)>1)
                        yn=(input('More than one screen has been identified as left - stereo presentation will use only the first identified screen. \n Is this correct (y/n) ','s')=='y');
                        if (yn==true)
                            valid=true;
                        else
                            valid=false;
                        end
                    end
                    
                    if (valid==true)
                    
                        if (length(this.ScreenCfg.Right)==0)
                            yn=(input('No screens have been identified as right - you will not be able to present stimuli in stereo with this configuration.\n Is the correct (y/n) ','s')=='y');
                            if (yn==true)
                                valid=true;
                            end


                        elseif (length(this.ScreenCfg.Right)>1)
                            yn=(input('More than one screen has been identified as right - stereo presentation will use only the first identified screen. \n Is this correct (y/n) ','s')=='y');
                            if (yn==true)
                                valid=true;
                            end
                        end
                     end
                    
                end
            end
            
            if (valid==true)
                yn=(input(sprintf('Save screen configuration to file %s (y/n) ',ScreenConfigFile),'s')=='y');
                if (yn==true)
                    ScreenCfg=this.ScreenCfg;
                    save (ScreenConfigFile,'ScreenCfg');
                end
            end
        end
        
        function TestScreenConfig(this)
            
            Screen('Preference', 'VisualDebugLevel', 2);
            
            s=sprintf([...
                'Instructions:use the following keys to identify screens.\n'...
                'F - Full Screen \n'...
                'L - Left Screen only\n'...
                'R - Right Screen\n'...
                'D - Dual screens as separate windows\n'...
                'S - Dual screens using stereo buffers\n'...
                'C - Dual screens using crossed stereo buffers\n'...
                'B - Dual screens using a slave screen\n\n'...
                'Space - close all open screens\n'...
                'Escape - finish\n'...
                'Shift - use PsychImaging to open windows rather than screen\n'...
                'I - redisplay these instructions';...
                ]);

            disp(s);
            
            this.CheckConfig();
            test=true;
            sca;
            keyCode=[];
            KbName('UnifyKeyNames');
            while (test==true)
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyIsDown
                    if (keyCode('Shift'))==1
                        Imaging=true; % use Psychtoolbox Imaging pipeline
                    else
                        Imaging=false;
                    end
                    if keyCode(kbName('I'))==1
                        disp(s);
                    elseif keyCode(kbName('ESCAPE'))==1
                        test=false;
                    elseif keyCode(kbName('space'))==1
                            sca;
                    elseif keyCode(kbName('F'))==1
                        sca;
                        [wnd,rect]=this.OpenFullScreen([0 0 0],Imaging);
                        if(isempty( wnd)) return;end;
                        this.DrawScreenIdent(wnd,rect,'F');
                        screen('Flip',wnd);
                        
                    elseif keyCode(kbName('L')) == 1
                        sca;
                        [wnd,rect]=this.OpenLeftScreen([0 0 0],Imaging);
                        if(isempty( wnd)) return;end;
                        this.DrawScreenIdent(wnd,rect,'L');
                        screen('Flip',wnd);
                        
                    elseif keyCode(kbName('R'))==1
                        sca;
                        [wnd,rect]=this.OpenRightScreen([0 0 0],Imaging);
                        if( isempty(wnd)) return;end;
                        this.DrawScreenIdent(wnd,rect,'R');
                        screen('Flip',wnd);
                        
                    elseif keyCode(kbName('D'))==1
                        sca;
                        [leftwnd,leftrect,rightwnd,rightrect]=this.OpenDualScreen([0 0 0],Imaging);
                        if( isempty(leftwnd) | isempty(rightwnd)) return;end;
                        this.DrawScreenIdent(leftwnd,leftrect,'D(L)');
                        this.DrawScreenIdent(rightwnd,rightrect','D(R)');
                        screen('flip',leftwnd,[],[],[],1);
                    elseif keyCode(kbName('S'))==1
                        sca;
                        
                        [wnd,rect]=this.OpenStereoBuffers(0,[0 0 0],Imaging);
                        if( isempty(wnd)) return;end;
                        screen('selectstereodrawbuffer',wnd,0);
                        this.DrawScreenIdent(wnd,rect,'S(L)');
                        screen('selectstereodrawbuffer',wnd,1);
                        this.DrawScreenIdent(wnd,rect,'S(R)');
                        screen('Flip',wnd,[],[],[],1);
                        
                    elseif keyCode(kbName('C'))==1
                        sca;
                        [wnd,rect]=this.OpenCrossedStereoBuffers(0,[0 0 0],Imaging);
                        if(isempty( wnd)) return;end;
                        screen('selectstereodrawbuffer',wnd,0);
                        this.DrawScreenIdent(wnd,rect,'C(L)');
                        screen('selectstereodrawbuffer',wnd,1);
                        this.DrawScreenIdent(wnd,rect,'C(R)');
                        screen('Flip',wnd,[],[],[],1);
                        
                    elseif keyCode(kbName('B'))==1
                        sca;
                        [wnd,rect]=this.OpenSlaveStereoScreen([0 0 0],Imaging);
                        if( isempty(wnd)) return;end;
                        screen('selectstereodrawbuffer',wnd,0);
                        this.DrawScreenIdent(wnd,rect,'B(L)');
                        screen('selectstereodrawbuffer',wnd,1);
                        this.DrawScreenIdent(wnd,rect,'B(R)');
                        screen('Flip',wnd,[],[],[],1);
                    end
                    
                end
            end
            sca;
        end
        
        
        function DrawScreenIdent(this,wnd,screenRect,ident)
            
            % set font parameters
            font = 'Arial';
            fontsize = 96;
            Screen(wnd,'TextFont',font);
            Screen(wnd,'TextSize',fontsize);
            
            txtrect=screen(wnd,'TextBounds',ident);
            txtwidth=txtrect(3)-txtrect(1);
            Screen(wnd,'DrawText',ident,(screenRect(3)-txtwidth)/2,screenRect(4)/2,[255 255 255]);
            
        end
        
        function Left=GetLeftScreen(this)
            this.CheckConfig;
            Left=[];
            if (length(this.ScreenCfg.Left)==0)
                error('Unable to continue, no left screens have been identified');
            elseif (length(this.ScreenCfg.Left)>1)
                warning('Multiple left screens identified - using first screen only (%d)',this.ScreenCfg.Left(1));
            end
            Left=this.ScreenCfg.Left(1);
            
        end
        
        function Right=GetRightScreen(this)
            this.CheckConfig;
            Right=[];
            if (length(this.ScreenCfg.Right)==0)
                error('Unable to continue, no right screens have been identified');
            elseif (length(this.ScreenCfg.Right)>1)
                warning('Multiple right screens identified - using first screen only (%d)',this.ScreenCfg.Right(1));
            end
            Right=this.ScreenCfg.Right(1);
        end
        
        function [wnd,wndRect]=OpenLeftScreen(this,colour,imaging)
            
            this.CheckConfig;
            Left=this.GetLeftScreen();
            
            wnd=[];
            wndRect=[];
            if (~exist('imaging','var'))
                imaging=false;
            end
            
            if (~exist('colour','var'))
                colour=[127 17 127];
            end
            
            if (imaging==true)
                PsychImaging('PrepareConfiguration');
                [wnd,wndRect]=PsychImaging('OpenWindow',this.ScreenCfg.screens(Left).index,colour);
            else
                [wnd,wndRect]=Screen('OpenWindow',this.ScreenCfg.screens(Left).index,colour);
            end
            
        end
        
         function [wnd,wndRect]=OpenFullScreen(this,colour,imaging)
            
            wnd=[];
            wndRect=[];
            if (~exist('imaging','var'))
                imaging=false;
            end
            
            if (~exist('colour','var'))
                colour=[127 17 127];
            end
            
            if (imaging==true)
                PsychImaging('PrepareConfiguration');
                [wnd,wndRect]=PsychImaging('OpenWindow',0,colour);
            else
                [wnd,wndRect]=Screen('OpenWindow',0,colour);
            end
            
        end
        
        function [wnd,wndRect]=OpenRightScreen(this,colour,imaging)
            this.CheckConfig;
            Right=this.GetRightScreen;
            
            wnd=[];
            wndRect=[];
            
            if (~exist('imaging','var'))
                imaging=false;
            end
            
            if (~exist('colour','var'))
                colour=[127 17 127];
            end
            
            
            if (imaging==true)
                PsychImaging('PrepareConfiguration');
                [wnd,wndRect]=PsychImaging('OpenWindow',this.ScreenCfg.screens(Right).index,colour);
            else
                [wnd,wndRect]=Screen('OpenWindow',this.ScreenCfg.screens(Right).index,colour);
            end
            
        end
        
        function [leftwnd,leftwndRect,rightwnd,rightwndRect]=OpenDualScreen(this,colour,imaging)
            
            Left=this.GetLeftScreen;
            Right=this.GetRightScreen;
            
            leftwnd=[];
            leftwndRect=[];
            rightwnd=[];
            rightwndRect=[];
            
            if (~exist('imaging','var'))
                imaging=false;
            end
            
            if (~exist('colour','var'))
                colour=[127 17 127];
            end
            
            if (imaging==true)
                PsychImaging('PrepareConfiguration');
                
                [leftwnd,leftwndRect]=PsychImaging('OpenWindow',this.ScreenCfg.screens(Left).index,colour);
                PsychImaging('PrepareConfiguration');
                
                [rightwnd,rightwndRect]=PsychImaging('OpenWindow',this.ScreenCfg.screens(Right).index,colour);
            else
                [leftwnd,leftwndRect]=Screen('OpenWindow',this.ScreenCfg.screens(Left).index,colour);
                [rightwnd,rightwndRect]=Screen('OpenWindow',this.ScreenCfg.screens(Right).index,colour);
            end
        end
        
        
        function [wnd,wndRect]=OpenStereoBuffers(this,screen,colour,imaging)
            
            wnd=[];
            wndRect=[];
            
            if (~exist('imaging','var'))
                imaging=false;
            end
            
            if (~exist('colour','var'))
                colour=[127 17 127];
            end
            
            
            if (imaging==true)
                PsychImaging('PrepareConfiguration');
                [wnd,wndRect]=PsychImaging('OpenWindow',screen,colour,[],[],[],4);
            else
                [wnd,wndRect]=Screen('OpenWindow',screen,colour,[],[],[],4);
            end
        end
        
        function [wnd,wndRect]=OpenCrossedStereoBuffers(this,screen,colour,imaging)
            
            wnd=[];
            wndRect=[];
            
            if (~exist('imaging','var'))
                imaging=false;
            end
            
            if (~exist('colour','var'))
                colour=[127 17 127];
            end
            
            
            if (imaging==true)
                [wnd,wndRect]=PsychImaging('OpenWindow',screen,colour,[],[],[],5);
            else
                [wnd,wndRect]=Screen('OpenWindow',screen,colour,[],[],[],5);
            end
        end
        
        function [wnd,wndRect]=OpenSlaveStereoScreen(this,colour,imaging)
            
            Left=this.GetLeftScreen;
            Right=this.GetRightScreen;
            
            wnd=[];
            wndRect=[];
            
            if (~exist('imaging','var'))
                imaging=false;
            end
            
            if (~exist('colour','var'))
                colour=[127 17 127];
            end
            
            
            
            if (imaging==true)
                PsychImaging('PrepareConfiguration');
                
                [wnd,wndRect]=PsychImaging('OpenWindow',this.ScreenCfg.screens(Left).index,colour,[],[],[],10);
                PsychImaging('PrepareConfiguration');
                PsychImaging('OpenWindow',this.ScreenCfg.screens(Right).index,colour,[],[],[],10);
            else
                [wnd,wndRect]=Screen('OpenWindow',this.ScreenCfg.screens(Right).index,colour,[],[],[],5);
                Screen('OpenWindow',this.ScreenCfg.screens(Right).index,colour,[],[],[],10);
            end
        end
        
    end
    
    methods (Access=private)
        
        
            
            
        function CheckConfig(this)
            if (isempty(this.ScreenCfg))
                error('Screen config must be loaded before testing');
            end
        end
        
        % standard code for cleaning up if the script is aborted etc.
        function abort(this)
            showcursor;
            screen('closeall');
        end
        
        function this=SetScreen(this,index,position)
            
            this.ScreenCfg.screens(index).position=position;
            
            excludeL=false;
            excludeR=false;
            excludeN=false;
            excludeU=false;
            excludeF=false;
            
            switch position
                case 'F'
                    excludeF=true;
                    [this.ScreenCfg.Full]=unique([this.ScreenCfg.Full index]);
                case 'U'
                    excludeU=true;
                    [this.ScreenCfg.UnSet]=unique([this.ScreenCfg.UnSet index]);
                case 'L'
                    excludeL=true;
                    [this.ScreenCfg.Left]=unique([this.ScreenCfg.Left index]);
                case 'R'
                    excludeR=true;
                    [this.ScreenCfg.Right]=unique([this.ScreenCfg.Right index]);
                case 'N'
                    excludeN=true;
                    [this.ScreenCfg.NotUsed]=unique([this.ScreenCfg.NotUsed index]);
            end
            
            if (excludeL==false)
                [this.ScreenCfg.Left]=setdiff(this.ScreenCfg.Left,index);
            end
            
            if (excludeR==false)
                [this.ScreenCfg.Right]=setdiff(this.ScreenCfg.Right,index);
            end
            
            if (excludeF==false)
                [this.ScreenCfg.Full]=setdiff(this.ScreenCfg.Full,index);
            end
            
            if (excludeU==false)
                [this.ScreenCfg.UnSet]=setdiff(this.ScreenCfg.UnSet,index);
            end
            
            if (excludeN==false)
                [this.ScreenCfg.NotUsed]=setdiff(this.ScreenCfg.NotUsed,index);
            end
            
        end
    end
end

