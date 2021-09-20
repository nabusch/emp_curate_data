function script02_recode_triggers

%%
% Silently load EEGLAB once to load all necessary paths. Then wipe all the
% unnessesary variables.
% addpath(genpath('/data3/Niko/EEG-Many-Pipelines/toolboxes/eeglab2021.0/'));
% addpath('./functions')
% eeglab nogui
% clear
% close all
% clc

%% Set configuration.
cfg = getcfg;
subjects = dir([cfg.dir_eeg '*import.set']);

%% Run across subjects.
parfor isub = 1:length(subjects)
    
    out_eeg_name = ['EMP', sprintf('%02d', isub), '_recode'];
    
    % Skip files that have already been recoded.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set']), 'file') & cfg.overwrite_recodetrigs == false
        continue
    else
        
        %% -------------------------------------------------------------
        % Load EEG data and behavioral logfile. Check that number of trials is
        % identical in both files.
        % --------------------------------------------------------------
        [EEG, T] = func_recode_readdata(cfg, subjects, isub);
        
        
        %% -------------------------------------------------------------
        % Remove all events/triggers that are not image onsets. Purpose:
        % simplify the dataset and make it easier to match triggers to specific
        % trials in the logfile without epoching the data.
        % --------------------------------------------------------------
        EEG = func_recode_selectevents(EEG, cfg);
        
        
        %% -------------------------------------------------------------
        % The number of trials/events in EEG and behavioral logfile do not
        % always match. Either because EEG was started too early and
        % includes the training trials, or it was started too late. We try
        % to correct the discrepancy here and select the matching trials.
        % --------------------------------------------------------------
        [EEG, T] = func_recode_match_triggers(EEG, T);
        
        
        %% --------------------------------------------------------------
        % Extract relevant behavioral information and write to CSV file.
        % --------------------------------------------------------------
        LOG = func_recode_makelogtable(T, cfg, isub);
        
        
        %% --------------------------------------------------------------
        % For our own analysis of the CORENATS experiment, we want want to
        % include all information in the EEG.events structure, including
        % number of presentation and lags to previous and next presentation
        % of that item. We just skip this information for the
        % EEGManyPipelines public dataset.
        % --------------------------------------------------------------
        if cfg.is_corenats
            EEG = func_recode_include_all_events(EEG, T);
        end
        
        %% --------------------------------------------------------------
        % Generate new triggers based on logfile and check that information
        % about trial order is consistent in EEG triggers and behavioral
        % logfile.
        % --------------------------------------------------------------
        EEG = func_recode_eegtrigs(EEG, LOG);
        EEG.logfile = LOG;
        
        
        % --------------------------------------------------------------
        % Save the new EEG file in EEGLAB format.
        % --------------------------------------------------------------
        EEG = pop_editset(EEG, 'setname', out_eeg_name);
        pop_saveset(EEG, 'filename', out_eeg_name, 'filepath', cfg.dir_eeg);
        
    end
end

disp('Done.')