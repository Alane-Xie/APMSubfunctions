

UserName = 'apm909';    % UoB logon username
Job = 'Cluster';        % 'Local'/ 'Cluster' ?
MVPAToolboxDir = 'D:\fMRIDataAEW04\Matlab MVPA Toolbox v3.06.05';
ClusterUserDir = '\\psg-zk-hpc-head\HPCData\Data\Aidan';

ConfigFiles = {'Texture_Disp2Tex_config.txt','Texture_Tex2Disp_config.txt'};
% ConfigFiles = {'Slant_TrainD_TestD_voxels_config.txt', 'Slant_TrainT_TestT_voxels_config.txt'}; 


if strcmp(Job, 'Local')
    RootDir = 'D:\fMRIDataAEW04\Aidan\MRI_DATA\TextureSlant';
    cd(RootDir);
    ConfigFiles = dir('*.txt');

    if iscell(ConfigFiles)
        ConfigFile = fullfile(RootDir, ConfigFiles{i});
    elseif istruct(ConfigFiles)
        ConfigFile = fullfile(RootDir, ConfigFiles(i).name);
    end
    
    fprintf('\n\nMVPA Toolbox will now run the following %d config files:\n', numel(ConfigFiles));
    fprintf('     %s\n', ConfigFiles.name);
    fprintf('Start time = %s\n\n', datestr(now));

    for n = 1:numel(ConfigFiles)
        ConfigFile = fullfile(RootDir, ConfigFiles{n});
        
        Config = MVPA_main(ConfigFile);
        Graph_All(Config);
    end

elseif strcmp(Job, 'Cluster')
    addpath(genpath(MVPAToolboxDir));
    RootDir = ClusterUserDir;
    for i = 1:numel(ConfigFiles)
        if iscell(ConfigFiles)
            ConfigFile = fullfile(RootDir, ConfigFiles{i});
        elseif istruct(ConfigFiles)
            ConfigFile = fullfile(RootDir, ConfigFiles(i).name);
        end
        my_config = load_config_file(ConfigFile);
        my_job = submit_to_cluster(my_config);
    end
end


% jm = findResource('scheduler', 'type', 'jobmanager', 'Name', 'HPC_48', 'LookupURL', 'PSG-ZK-HPC-HEAD');
% [pending queued running finished] = findJob(jm, 'UserName',UserName);
% my_jobs = findJob(jm,'UserName', UserName);
% check_job_status(my_jobs)
% view_job_errors(my_jobs);

% destroy(my_jobs);
