function script03_prep_simple

%%
% Silently load EEGLAB once to load all necessary paths. Then wipe all the
% unnessesary variables.
% addpath(genpath('/data3/Niko/EEG-Many-Pipelines/toolboxes/eeglab2021.0/functions/sigprocfunc'));
% addpath('./functions')
% eeglab nogui
% clear; close all; clc

%% Set configuration.
cfg = getcfg;
subjects = dir([cfg.dir_eeg '*recode.set']);

%% Run across subejcts.
parfor isub = 1:length(subjects)
    
    name = num2str(isub, '%02d'); % subject index with trailing zero
    out_eeg_name = ['EMP', name, '_prep1'];
    
    % Skip files that have already been processed.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set']), 'file') & cfg.overwrite_prep1 == false
        continue
    else
        
        % ----------------------------------------------------------
        % Load the dataset.
        % ----------------------------------------------------------
        EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);
        
        
        % ----------------------------------------------------------
        % Further downsampling if necessary.
        % ----------------------------------------------------------
        if cfg.prep_resamp ~= EEG.srate
            EEG = pop_resample( EEG, cfg.prep_resamp);
        end
        
        
        % ----------------------------------------------------------
        % Filter the data.
        % ----------------------------------------------------------
        EEG = pop_eegfiltnew(EEG, 'locutoff', cfg.filt_hp_cutoff);
        EEG = pop_eegfiltnew(EEG, 'hicutoff', cfg.filt_lp_cutoff);
        
        
        % ----------------------------------------------------------
        % Epoch data.
        % ----------------------------------------------------------
        EEGep = pop_epoch( EEG, {}, cfg.epochlims, 'newname', EEG.setname, 'epochinfo', 'yes');
        
        
        % ----------------------------------------------------------
        % Artifact rejection.
        % ----------------------------------------------------------

        % I do a temorary baseline correction, otherwise the rejection by
        % extreme amplitudes gets confused if there are still some DC
        % shifts in theraw data. However, we apply the trial rejection to
        % the un-baseline corrected data, because ICA ilkes that better.
        tmpeeg = pop_rmbase(EEGep, []);
        
        % Reject trials with extreme amplitude values.
        [tmpeeg, rejinds] = pop_eegthresh(tmpeeg, 1, cfg.EEGchans, ...
            -cfg.rejthresh_pre_ica, cfg.rejthresh_pre_ica, EEG.xmin, EEG.xmax, 1, 0);
        
        % Temporary average reference. Necessary because joint prob. cannot
        % handle empty reference channel.
        tmpeeg = pop_reref( tmpeeg, cfg.reref_analysis, 'keepref','on','exclude',[cfg.VEOGchan, cfg.HEOGchan] );
        
        tmpeeg = pop_jointprob(tmpeeg, 1, cfg.EEGchans, ...
            cfg.rej_jp_singchan, cfg.rej_jp_allchans, 1, 0, 0);
        
        rejinds = find(tmpeeg.reject.rejthresh | tmpeeg.reject.rejjp);
               
        % EEGbad = pop_select( EEGep, 'trial', rejinds);
        EEG = pop_select( EEGep, 'notrial', rejinds);        
        EEG.rejected_trials = rejinds;
        
        
        % ----------------------------------------------------------
        % Change the EEG.setname and save the data to disk under a new name.
        % ----------------------------------------------------------
        EEG.setname =['EMP' name ' prep 1'];
        pop_saveset(EEG, 'filename', out_eeg_name, 'filepath', cfg.dir_eeg);
    end
end

disp('Done.')
