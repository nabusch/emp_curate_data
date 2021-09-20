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
cfg.eeg_export_format = 'GDF';

cfg.overwrite_prep1 = true;

subjects = dir([cfg.dir_eeg '*recode.set']);

addpath('./functions/')

%%
for isub = 1:length(subjects)
    
    
    name = num2str(isub, '%02d'); % subject index with trailing zero
    out_eeg_name = ['EMP', name, '_prep1'];
    
    % Skip files that have already been recoded.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set'])) & cfg.overwrite_prep1 == false
        continue
    else
        
        % Load the dataset.
        
        EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);

        EEG = pop_resample( EEG, 256);
        EEG = pop_eegfiltnew(EEG, 'locutoff',0.1);
        EEG = pop_eegfiltnew(EEG, 'hicutoff',40);
        EEG = pop_epoch( EEG, {}, [-0.5         1.0], 'newname', 'EMP01_import epochs', 'epochinfo', 'yes');
        
        
        % Reject remaining trials with extreme amplitude values.
        %EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
        
        %     rejthresh = 150;
        %     EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan, ...
        %         -rejthresh, rejthresh, EEG.xmin, EEG.xmax, 1, 1);
        
        % Change the EEG.setname and save the data to disk under a new name.
        EEG.setname =['EMP' name ' prep 1'];
        
        %     filepath_out = 'D:\Sciebo_WWU\nbusch\Lehre\EEG-Seminar_WS18\Clean3\';
        %     EEG = pop_saveset(EEG, 'filename', filename_out, 'filepath', eeg_path_out);
        pop_saveset(EEG, 'filename', out_eeg_name, 'filepath', cfg.dir_eeg);
    end
end
disp('Done.')