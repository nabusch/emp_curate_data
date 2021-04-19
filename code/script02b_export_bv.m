%%
% Silently load EEGLAB once to load all necessary paths. Then wipe all the
% unnessesary variables.
addpath('/data3/Niko/EEG-Many-Pipelines/toolboxes/eeglab2021.0/');
addpath('./functions')
eeglab nogui
clear
close all
clc


%% Set configuration.
cfg.dir_main = '/data3/Niko/EEG-Many-Pipelines/curate_EEG_data/';
cfg.dir_bdf = [cfg.dir_main, 'BDF/'];
cfg.dir_eeg = [cfg.dir_main, 'EEG/'];
cfg.dir_behavior = [cfg.dir_main, 'Behavior/'];
cfg.dir_out = [cfg.dir_main, 'OUT/'];
cfg.overwrite_export = true;

subjects = dir([cfg.dir_eeg '*recode.set']);


%%
for isub = 1:length(subjects)
    
    out_eeg_name = ['EMP', sprintf('%02d', isub), '_export'];
    
    % Skip files that have already been recoded.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set'])) & cfg.overwrite_export == false
        continue
    else
        
        %% -------------------------------------------------------------
        % Load EEG data.
        % --------------------------------------------------------------
        EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);
        
        %% -------------------------------------------------------------
        % Export to BrainVision format.
        % --------------------------------------------------------------            
        pop_writebva(EEG, fullfile(cfg.dir_out, out_eeg_name));

    end    
end

disp('Done.')