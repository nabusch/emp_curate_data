function cfg = getcfg

%% Directories
cfg.dir_main     = '/data3/Niko/EEG-Many-Pipelines/curate_EEG_data/';
cfg.dir_bdf      = [cfg.dir_main, 'BDF/'];
cfg.dir_eeg      = [cfg.dir_main, 'EEG/'];
cfg.dir_tf       = [cfg.dir_main, 'TF/'];
cfg.dir_behavior = [cfg.dir_main, 'Behavior/'];
cfg.dir_export   = [cfg.dir_main, 'OUT/'];

% Is this our own analysis of the Corenats study? 
% This flag is used for data import/export. If == 0, export only limited
% info about experimental conditions for EEGManyPipelines project.
cfg.is_corenats = 1;

%% Overwrite previously generated daafiles?
cfg.overwrite_import      = true;
cfg.overwrite_recodetrigs = true;
cfg.overwrite_export      = false;
cfg.overwrite_prep1       = true;
cfg.overwrite_ica         = false;
cfg.overwrite_clean       = true;
cfg.overwrite_tf          = false;

%% Importing BDF raw data.
cfg.do_resampling = 1;
cfg.new_sampling_rate = 512;
cfg.do_rereference = 1;
cfg.reref_chan = 31; % 48=channel CZ. 31=Pz.
cfg.EEGchans = 1:70;
cfg.VEOGchan = 71;
cfg.HEOGchan = 72;
cfg.VEOGin = {[ 1 34],[67 68]};
cfg.HEOGin = {[65],   [66]};
cfg.image_onset_triggers = [18, 21, 24, 27, 19, 22, 25, 28, 20, 23, 26, 29];

%% Preprocessing parameters.
cfg.filt_hp_cutoff = 0.1;
cfg.filt_lp_cutoff = 40;
cfg.prep_resamp = 256;
cfg.use_asr = 0;
cfg.epochlims = [-0.800 1.600];
cfg.rejthresh_pre_ica  = 500;
        
cfg.rej_jp_singchan = 9;
cfg.rej_jp_allchans = 5;
cfg.rejthresh_post_ica = 150;
cfg.corrthreshold = 0.7; % max correlation between EOG and ICA activity.
cfg.reref_analysis = []; %leave empty brackets to apply average reference.

%% TF parameters.
cfg.min_freq =  3;
cfg.max_freq = 30;
cfg.num_frex = 28;
cfg.frex = linspace(cfg.min_freq, cfg.max_freq, cfg.num_frex);
cfg.fwhm_t = 2 .* 1./cfg.frex;

%% Experimental design.
cfg.conditions = {
    {'scene_man', 1}, {'scene_man', 2};
    {'is_old', 0}, {'is_old', 1};
    {'subscorrect', 0}, {'subscorrect', 1};
    {'recognition', 'hit'}, {'recognition', 'miss'};
    };

%%


