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
cfg.EEGchans = 1:70;
cfg.VEOGchan = 71;
cfg.HEOGchan = 72;
cfg.corrthreshold = 0.7;

cfg.overwrite_clean = true;

subjects = dir([cfg.dir_eeg '*ica.set']);

addpath('./functions/')

%%
for isub = 1:length(subjects)
    
    
    name = num2str(isub, '%02d'); % subject index with trailing zero
    out_eeg_name = ['EMP', name, '_clean'];
    
    % Skip files that have already been recoded.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set'])) & cfg.overwrite_clean == false
        continue
    else
        
        % Load the dataset.        
        EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);
        
        % Find ICA components correlated with EOG channels.        
        eog_chans = [cfg.HEOGchan, cfg.VEOGchan];
        badics = find_bad_ics(EEG, eog_chans, cfg.corrthreshold);        
        
        % Remove bad ICs from the original data.
        EEG = pop_subcomp(EEG, badics, 0);
        
        % Save clean data.
        EEG = pop_editset(EEG, 'setname', out_eeg_name);                
        pop_saveset(EEG, 'filename', out_eeg_name, 'filepath', cfg.dir_eeg);
        
    end
end
disp('Done.')