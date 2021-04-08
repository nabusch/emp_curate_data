function EEG = func_import_eyechans(EEG, cfg)

% --------------------------------------------------------------
% Compute VEOG and HEOG.
% --------------------------------------------------------------
EEG.data(cfg.VEOGchan,:,:) = mean(EEG.data(cfg.VEOGin{1},:,:)) - mean(EEG.data(cfg.VEOGin{2},:,:)); % VEOG
EEG.data(cfg.HEOGchan,:,:) = mean(EEG.data(cfg.HEOGin{1},:,:)) - mean(EEG.data(cfg.HEOGin{2},:,:)); % HEOG

EEG.chanlocs(cfg.VEOGchan).labels = 'VEOG';
EEG.chanlocs(cfg.HEOGchan).labels = 'HEOG';

EEG.nbchan = size(EEG.data,1);
EEG = eeg_checkset(EEG, 'chanlocsize', 'chanlocs_homogeneous');
