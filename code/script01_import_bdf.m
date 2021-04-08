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
cfg.dir_main = '/data3/Niko/EEG-Many-Pipelines/curate_EEG_data/Code/';
cfg.dir_bdf = [cfg.dir_main, 'BDF/'];
cfg.dir_eeg = [cfg.dir_main, 'EEG/'];
cfg.dir_behavior = [cfg.dir_main, 'Behavior/'];

cfg.do_resampling = 1;
cfg.new_sampling_rate = 512;

cfg.do_rereference = 1;
cfg.reref_chan = 31; % 31=channel CZ.

cfg.EEGchans = 1:70;
cfg.VEOGchan = 71;
cfg.HEOGchan = 72;

cfg.VEOGin = {[ 1 34],[67 68]};
cfg.HEOGin = {[65],   [68]};

cfg.image_onset_triggers = [18, 21, 24, 27, 19, 22, 25, 28, 20, 23, 26, 29];


%% Load subject information
subs_table = readtable(fullfile(cfg.dir_main, 'SubjectsTable.xlsx'));
subject_str_in = subs_table.Name(subs_table.Include==1);

%%
for isub = 1:length(subject_str_in)
    
    in_bdf_name = ['CN_crt_', subject_str_in{isub} '.bdf'];
    out_eeg_name = ['EMP', sprintf('%02d', isub), '_import'];
    
    % Skip files that have already been imported.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set']))
        continue
    else
        
        % --------------------------------------------------------------
        % Import Biosemi raw data.
        % --------------------------------------------------------------
        EEG = func_import_readbdf(cfg, in_bdf_name);
        
        % --------------------------------------------------------------
        % Data recorded in Berlin had the usual 64 + 6 external eletrodes, but
        % data recorded in Münster (18+) accidentally had almost 300 channels
        % recorded, most of them empty. thus, their external electrodes are at the
        % very end of this list of useless channels. this was fixed from subjects
        % 24 onwards.
        % --------------------------------------------------------------
        EEG = func_import_selectchans(EEG, cfg);
        
        % --------------------------------------------------------------
        % Biosemi is recorded reference-free. We apply rereferincing in
        % software.
        % --------------------------------------------------------------
        EEG = func_import_reref(EEG, cfg);
        
        % --------------------------------------------------------------
        % Compute VEOG and HEOG.
        % --------------------------------------------------------------
        EEG = func_import_eyechans(EEG, cfg);
        
        % --------------------------------------------------------------
        % Downsample data. Removing and adding back the path is necessary for
        % avoiding an error of the resample function. Not sure why. Solution is
        % explained here: https://sccn.ucsd.edu/bugzilla/show_bug.cgi?id=1184
        % --------------------------------------------------------------
        EEG = func_import_downsample(EEG, cfg);
        
        % --------------------------------------------------------------
        % Remove all events/triggers that are not image onsets. Purpose:
        % simplify the dataset and make it easier to match triggers to specific
        % trials in the logfile without epoching the data.
        % --------------------------------------------------------------
        EEG = func_import_selectevents(EEG, cfg);
        
        % --------------------------------------------------------------
        % Save the new EEG file in EEGLAB format.
        % --------------------------------------------------------------
        EEG = pop_editset(EEG, 'setname', out_eeg_name);
        pop_saveset(EEG, 'filename', out_eeg_name, 'filepath', cfg.dir_eeg);
        
    end
end