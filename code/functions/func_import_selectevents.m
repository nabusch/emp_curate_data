function EEG = func_import_selectevents(EEG, cfg)

% --------------------------------------------------------------
% Remove all events/triggers that are not image onsets. Purpose:
% simplify the dataset and make it easier to match triggers to specific
% trials in the logfile without epoching the data.
% --------------------------------------------------------------
is_image_onset = ismember([EEG.event.type], cfg.image_onset_triggers);
EEG = pop_selectevent(EEG, 'event', find(is_image_onset), 'deleteevents','on');
