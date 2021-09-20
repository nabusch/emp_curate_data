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

cfg.overwrite_ica = false;

subjects = dir([cfg.dir_eeg '*prep1.set']);

addpath('./functions/')

%%
for isub = 1:length(subjects)
    
    
    name = num2str(isub, '%02d'); % subject index with trailing zero
    out_eeg_name = ['EMP', name, '_ica'];
    
    % Skip files that have already been recoded.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set'])) & cfg.overwrite_ica == false
        continue
    else
        
        % Load the dataset.
        
        EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);

        % Run ICA.
        EEG.data = double(EEG.data);                     
        EEG.ICArank = length(cfg.EEGchans)-2;
        
        % Set the rng to a fixed value so that everybody always gets the
        % same results. The exact value does not matter, 3 is a lucky
        % number.
        rng(3);
        
        [EEG, com] = pop_runica(EEG, 'icatype', 'binica', ...
            'extended', 1, ...
            'chanind', cfg.EEGchans, ...
            'pca', EEG.ICArank);
        
        EEG.data = single(EEG.data);
        
        EEG = pop_editset(EEG, 'setname', out_eeg_name);
        
        
        pop_saveset(EEG, 'filename', out_eeg_name, 'filepath', cfg.dir_eeg);
    end
end
disp('Done.')