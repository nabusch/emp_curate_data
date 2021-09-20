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
cfg = getcfg;
subjects = dir([cfg.dir_eeg '*recode.set']);

%% Run across subjects.
parfor isub = 1:length(subjects)
    
    out_eeg_name = ['EMP', sprintf('%02d', isub), '_export'];
    
    % Skip files that have already been recoded.
    if exist(fullfile(cfg.dir_eeg, [out_eeg_name '.set']), 'file') & cfg.overwrite_export == false
        continue
    else
        
        % -------------------------------------------------------------
        % Load EEG data.
        % --------------------------------------------------------------
        EEG = pop_loadset('filename', subjects(isub).name, 'filepath', subjects(isub).folder);
        
        % -------------------------------------------------------------
        % Export to BrainVision format.
        % --------------------------------------------------------------            
%         pop_writebva(EEG, fullfile(cfg.dir_export, out_eeg_name));
        
        % -------------------------------------------------------------
        % Export channel locations.
        % --------------------------------------------------------------            

        % Write only theta phi coordinates. This seems to be what MNE
        % Python requires.
        writelocs(EEG.chanlocs, ...
            fullfile(cfg.dir_export, 'chanlocs_theta_phi.txt'), 'filetype', 'besa')
        
        % Write all chanlocs info in EEGLAB format.
        EEG = pop_chanedit(EEG, 'save', ...
            fullfile(cfg.dir_export, 'chanlocs_eeglab.ced'));

    end    
end

disp('Done.')