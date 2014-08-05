function [Success] = EmailData(Email, Mobile)

%========================= EmailData.m ====================================
% Sends message and data (e.g. results file) to specified e-mail address. 
% Optionally sends an SMS notification to specified mobile phone number.
%
% INPUTS:
%   Email.Address:  	the email address data will be sent to
%   Email.Subject:      subject line of the e-mail
%   Email.Content:      text content of the e-mail
%   Email.SMTP:     	0 = attempt to send through Outlook first, 1 = send through SMTP
%   Email.Attachment:   file to send specified by full path and file name 
%   Mobile.Number:      Optionally send a notification SMS to a mobile phone number
%   Mobile.Network:  	Mobile network provider
%
% REQUIREMENTS:
%   SMS delivery requires MS Outlook and can only be sent to phones on
%   major US networks.
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
% HISTORY
% 27/08/2010 - Created by APM (NIMH, NIH, Bethesda, USA)
% 04/08/2014 - Updated APM
%==========================================================================
if nargin < 1
    Email.Address = {'apm909@bham.ac.uk','aidanmurphy1@hotmail.co.uk'};
    Email.Server = {'adf.bham.ac.uk','smtp.live.com'};
    Email.Subject = 'Test e-mail from Matlab';
    Email.SMTP = 1;
    Email.Content = 'This is test content.';
    Email.Attachment = 'NIFstorage_usage_05-Aug-2014.png';
    Mobile.Number = 2026079730;
    Mobile.Network = 'Sprint';
    fprintf('No input was provided - sending test e-mail...\n');
end
OutlookDir = 'C:\Program Files (x86)\Microsoft Office\Office12';        % Specify path containing Outlook.exe

%================ Check which operating system is running =================
if ispc                                % If running on Windows... 
    Windows = 1;                       % Attempt to use Outlook
elseif isunix || ismac                 % If running on Unix or OSX...
    Email.SMTP = 1;                    % Use web based client
    fprintf('E-mail will be sent via web based account.\n')
end

%======================= SEND EMAIL USING MS OUTLOOK ======================
if Email.SMTP == 0
    try
        [Status, TList] = system('tasklist');       % Call system tasklist
        if isnan(findstr(TList, 'OUTLOOK.EXE'));    % Find if 'Outlook.exe' is running  
            rootDir = cd;
            cd(OutlookDir);                         % Launch MS Outlook
            !outlook.exe &
            cd(rootDir);                            % Return to original directory
        end
        Outlook = actxserver('outlook.Application');
        mail = Outlook.CreateItem('olMail');
        mail.Subject = Email.Subject;
        mail.Body = Email.Content;         
        if EmailBackup > 1
            mail.Attachments.Add(Email.Attachment);
        end
    %     mail.ReadReceiptRequested = true;        	% For read receipt
        for n = 1:numel(Email.Address)
            mail.To = Email.Address{n};
            mail.Send;
        end
        Outlook.release;
    catch
        fprintf('ERROR: failed to access MS Outlook at %s!\n', OutlookDir);
        Email.SMTP = 1;
    end
end

%=================== SEND EMAIL USING WEB BASED CLIENT ====================
if Email.SMTP == 1 
    for n = 2:numel(Email.Address)
        setpref('Internet','SMTP_Server', Email.Server{n});
        setpref('Internet','E_mail',Email.Address{n});
        setpref('Internet','SMTP_Server','mail');
        sendmail(Email.Address{n}, Email.Subject, Email.Content,Email.Attachment);
    end
end
    
if ~isnan(Mobile.Number) && Email.SMTP == 0
    %============== Determine domain to send to based on network provider
    if strcmp(Network, 'Sprint') 
        domain = '@messaging.sprintpcs.com';
    elseif strcmp(Network, 'T-Mobile') 
        domain = '@tmomobile.net';
    elseif strcmp(Network,'AT&T')
        domain = '@txt.att.net';
    elseif strcmp(Network,'Nextel') 
        domain = '@messaging.nextel.com';
    elseif strcmp(Network,'Verizon') 
        domain = '@vtext.com';
    elseif strcmp(Network,'Cingular')
        domain = '@cingularme.com';
    else
        fprintf('ERROR: Network provider ''%s'' not recognized!\n', Network);
        return;
    end

    %============== Send SMS notification of completion
    ExpSMS = strcat(Mobile, domain);
    sendmail(ExpSMS, SMStitle, ...    % send SMS notification that experiment has completed
        strcat('Results data were sucessfully e-mailed to ', ExpEmail));
    Outlook = actxserver('outlook.Application');
    mail = Outlook.CreateItem('olMail');
    mail.Subject = strcat('Experiment completed at: ', datestr(rem(now,1)), ' on: ', datestr(floor(now)));
    mail.To = ExpSMS;
    mail.Body = strcat('Results data were sucessfully e-mailed to... ', ExpEmail);       
    mail.Send;
    Outlook.release;
end    

system('TASKKILL /F /IM OUTLOOK.EXE');          % Use 'Taskkill' command prompt to terminate Outlook 