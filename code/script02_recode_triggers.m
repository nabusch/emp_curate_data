clear
close all
clc

%% Set configuration.
cfg.dir_main = '/data3/Niko/EEG-Many-Pipelines/curate_EEG_data/';
cfg.dir_bdf = [cfg.dir_main, 'BDF/'];
cfg.dir_eeg = [cfg.dir_main, 'EEG/'];
cfg.dir_behavior = [cfg.dir_main, 'Behavior/'];
cfg.dir_out = [cfg.dir_main, 'OUT/'];


%%
subjects = dir([cfg.dir_eeg '*import.set']);

for isub = 1:length(subjects)
   
    EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);
    
    urname = EEG.urname(1:end-4);
    logname = fullfile(cfg.dir_behavior, [urname, '_Logfile_processed.mat']);
    load(logname);
    
    %%
    ntrials_eeg = length(EEG.event);
    ntrials_log = length(Info.T);
    assert(ntrials_eeg == ntrials_log, 'Number of trials does not match!');
    %%
    LOG = table();
    LOG.trial       = [1:ntrials_log]';
    
    LOG.scene_name  = {Info.T.category_name}';
    LOG.scene_cat(strcmp(LOG.scene_name, 'beaches'))   = 1;
    LOG.scene_cat(strcmp(LOG.scene_name, 'forests'))   = 2;
    LOG.scene_cat(strcmp(LOG.scene_name, 'highways'))  = 3;
    LOG.scene_cat(strcmp(LOG.scene_name, 'buildings')) = 4;
    LOG.scene_man(LOG.scene_cat <= 2) = 1;
    LOG.scene_man(LOG.scene_cat >  2) = 2;
    
    LOG.is_old      = ([Info.T.presentation_no]'-1) > 0;
    
    report_old  = [Info.T.ReportOld]';
    report_old(isnan(report_old)) = 9;
    
    LOG.recog_cat(LOG.is_old &  report_old == 1) = 1;
    LOG.recog_cat(LOG.is_old &  report_old == 0) = 2;
    LOG.recog_cat(~LOG.is_old & report_old == 1) = 3;
    LOG.recog_cat(~LOG.is_old & report_old == 0) = 4;
    LOG.recog_cat(report_old == 9) = 9;
    
    LOG.recognition(LOG.recog_cat == 1) = {'hit'};
    LOG.recognition(LOG.recog_cat == 2) = {'miss'};
    LOG.recognition(LOG.recog_cat == 3) = {'falsealarm'};
    LOG.recognition(LOG.recog_cat == 4) = {'correctreject'};
    
    subs_correct = [Info.T.subsequent_correct]';
    subs_correct(isnan(subs_correct)) = 9;
    LOG.subscorrect = subs_correct;
    
    triggers_new = ...
        10000 * LOG.scene_cat + ...
         1000 * LOG.scene_man + ...
          100 * LOG.is_old + ...
           10 * LOG.recog_cat + ...
            1 * LOG.subscorrect;
        
    %%
    triggers_old = [EEG.event.type];
    error_beach = sum(strcmp(LOG.scene_name, 'beaches')'   & ~ismember(triggers_old, [18, 19, 20]));
    error_build = sum(strcmp(LOG.scene_name, 'buildings')' & ~ismember(triggers_old, [21, 22, 23]));
    error_highw = sum(strcmp(LOG.scene_name, 'highways')'  & ~ismember(triggers_old, [24, 25, 26]));
    error_forst = sum(strcmp(LOG.scene_name, 'forests')'   & ~ismember(triggers_old, [27, 28, 29]));
    assert(sum([error_beach, error_build, error_highw, error_forst]) == 0, 'EEG triggers do not match LOG info!')

    pop_writeeeg(EEG, '/data3/Niko/EEG-Many-Pipelines/curate_EEG_data/test', 'TYPE','EDF');

    %%
        
end