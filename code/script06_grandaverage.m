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
cfg.corrthreshold = 0.7;

cfg.overwrite_clean = true;

subjects = dir([cfg.dir_eeg '*clean.set']);

addpath('./functions/')

grand.conditions = {
    {'scene_man', 1}, {'scene_man', 2};
    {'is_old', 0}, {'is_old', 1};
    {'subscorrect', 0}, {'subscorrect', 1};
    };

%%
eeginfo = pop_loadset('filename', subjects(1).name, ...
    'filepath', subjects(1).folder, ...
    'loadmode', 'info');

grand.data = nan(eeginfo.nbchan, eeginfo.pnts, length(subjects), size(grand.conditions,1), 2);


for isub = 1:length(subjects)
    
    name = num2str(isub, '%02d'); % subject index with trailing zero
    out_eeg_name = ['EMP', name, '_clean'];
    
    % Load the dataset.
    EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);
    EEG = pop_rmbase(EEG, [EEG.times(1) 0]);

    EEG = pop_reref( EEG, [], 'keepref','on','exclude',[cfg.VEOGchan, cfg.HEOGchan] );
    
    for icond = 1:size(grand.conditions,1)
        for ilevel = 1:2
            trials = [EEG.logfile.(grand.conditions{icond,ilevel}{1})] == grand.conditions{icond,ilevel}{2};
            
            grand.data(:, :, isub, icond, ilevel) = mean(EEG.data(:,:,trials),3);
        end
    end
end

grand.chanlocs = EEG.chanlocs;
grand.times = EEG.times;
grand.srate = EEG.srate;
save('grandaverage.mat', 'grand')

disp('Done.')