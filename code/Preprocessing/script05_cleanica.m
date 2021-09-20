% function script05_cleanica

%%
% Silently load EEGLAB once to load all necessary paths. Then wipe all the
% unnessesary variables.
% addpath(genpath('/data3/Niko/EEG-Many-Pipelines/toolboxes/eeglab2021.0/functions/sigprocfunc'));
% addpath('./functions')
% eeglab nogui
% clear
% close all
% clc

%% Set configuration.
cfg = getcfg;
subjects = dir([cfg.dir_eeg '*ica.set']);

%% Run across subjects.
for isub = 1:length(subjects)
        
    name = num2str(isub, '%02d'); % subject index with trailing zero
    out_eeg_name = ['EMP', name, '_clean'];
    
    % Skip files that have already been recoded.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set']), 'file') & cfg.overwrite_clean == false
        continue
    else
        
        % Load the dataset.        
        EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);
        
        % Find ICA components correlated with EOG channels.        
        eog_chans = [cfg.HEOGchan, cfg.VEOGchan];
        badics = find_bad_ics(EEG, eog_chans, cfg.corrthreshold);        
        
        % Remove bad ICs from the original data.
        EEG = pop_subcomp(EEG, badics, 0);
        
        % --------------------------------------------------------------
        % Recompute the HEOG/VEOG for the cleaned data.
        % --------------------------------------------------------------
        EEG.data(cfg.VEOGchan,:,:) = mean(EEG.data(cfg.VEOGin{1},:,:),1) - mean(EEG.data(cfg.VEOGin{2},:,:),1); % VEOG
        EEG.data(cfg.HEOGchan,:,:) = mean(EEG.data(cfg.HEOGin{1},:,:),1) - mean(EEG.data(cfg.HEOGin{2},:,:),1); % HEOG       

        
        % --------------------------------------------------------------
        % Do a last round of trial rejection to get rid of trials with huge
        % amplitudes. This important for a few datasets with strong sweat
        % artifacts.        
        % --------------------------------------------------------------        
        EEG = pop_rmbase(EEG, []);
        
        EEG = pop_reref( EEG, cfg.reref_analysis, 'keepref','on','exclude',[cfg.VEOGchan, cfg.HEOGchan] );
    
        [EEG, i] = pop_eegthresh(EEG, 1, cfg.EEGchans, ...
            -cfg.rejthresh_post_ica, cfg.rejthresh_post_ica, ...
            EEG.xmin, EEG.xmax, 1, 1);
        
        % Save clean data.
        EEG = pop_editset(EEG, 'setname', out_eeg_name);                
        pop_saveset(EEG, 'filename', out_eeg_name, 'filepath', cfg.dir_eeg);
        
    end
end
disp('Done.')