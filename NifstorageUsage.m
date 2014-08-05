
%=========================== NifstorageUsage.m ============================
% This function calculates the amount of memory taken up by each user
% directory on Einstein and saves and plots the results. The optional input
% RequestedUsers is a cell array of strings of the user IDs that you would
% like to calculate, save, and plot data for.
%
% EXAMPLE: 
%   RequestedUsers = {'apjones','russ','hung','deng','murphy','godlove','maier','mcmahon','schmid','Others'};
%   NifstorageUsage(RequestedUsers);
%==========================================================================

function [UserDir, FolderSize] = NifstorageUsage(RequestedUsers)

    if nargin == 0
%         RequestedUsers = {};
        RequestedUsers = {'apjones','russ','hung','deng','murphy','godlove'};%,'maier','mcmahon','schmid','Others'};
    end

  	FolderNames = {'PROJECTS','RAWDATA','PROCDATA'};%,'USRLAB/projects','USRLAB/rawdata','USRLAB/data'};
    if ismac
        NIFPath = '/Volumes';
    else
        NIFPath = '/einstein0';
    end
    
    
    %======================= Check directory sizes
    for f = 1:numel(FolderNames)
        NIFPaths{f} = fullfile(NIFPath, FolderNames{f});
        fprintf('\n\nSearching for user directories in: %s...\n', NIFPaths{f});
        Users{f} = dir(fullfile(NIFPaths{f}));                               % Get all users folders in this directory
        fprintf('%d user directories found. Calculating memory usage...\n', numel(Users{f}));
        UserNames = struct2cell(Users{f});                                  % Convert stucture to cell array
        UserNames(2:end,:) = [];                                            % Remove al cells except names
        if ~isempty(RequestedUsers)                                         % If requested users were specified...
            UserIndx = zeros(1, numel(RequestedUsers));
            for i = 1:numel(RequestedUsers)
                TmpIndx = strmatch(RequestedUsers{i},UserNames);            % Find folder for each user
                if isempty(TmpIndx)
                    UserIndx(i) = 0;
                elseif ~isempty(TmpIndx)
                    UserIndx(i) = TmpIndx;
                end
            end
        else
            UserIndx = 1:numel(UserNames);
        end

        for u = 1:numel(UserIndx)
            if UserIndx(u)>0
                if strcmp(UserNames{UserIndx(u)}(1),'.') 

                else
                    UserDir{f}{u} = fullfile(NIFPaths{f}, Users{f}(UserIndx(u)).name);
                    FolderSize(u,f) = dirsize(UserDir{f}{u})/10^9;
                    fprintf('Folder %s \t\t= %0.2f GB\n', UserDir{f}{u}, FolderSize(u,f));
                end
            else
                FolderSize(u,f) = 0;
            end
        end
    end
    save(sprintf('NIFstorageUsage_%s.mat', datestr(now, 'dd-mmm-yyyy')));     % Save results to .mat file
    
    %======================= Plot results figure
    figure('units','normalized','position',[0 0 0.8 0.5]);
    subplot(1,2,1);
    hax = barh(FolderSize, 'stacked');
    legend(FolderNames, 'location','southeast');
    xlabel('Folder size (GB)');
    set(gca,'yTickLabel', RequestedUsers);
    grid on;
    box off;
    title(sprintf('NIFstorage usage %s', datestr(now, 'dd-mmm-yyyy')),'Fontsize',18);
    
    subplot(1,2,2);
    Totals = sum(FolderSize,2);
    pie(Totals,RequestedUsers(1:numel(Totals)));
    if SaveFig == 1
        export_fig(['NIFstorage_usage_', datestr(now, 'dd-mmm-yyyy'),'.png'], '-png');
    end
end

%======================= Check directory size (including subdirectories)
function x = dirsize(path)
    s = dir(path);
    name = {s.name};
    isdir = [s.isdir] & ~strcmp(name,'.') & ~strcmp(name,'..');
    this_size = sum([s(~isdir).bytes]);
    sub_f_size = 0;
    if(~all(isdir == 0))
        subfolder = strcat(path, filesep(), name(isdir));
        sub_f_size = sum([cellfun(@dirsize, subfolder)]);
    end
    x = this_size + sub_f_size;
end