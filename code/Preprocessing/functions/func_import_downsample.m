function EEG = func_import_downsample(EEG, cfg)

% --------------------------------------------------------------
% Downsample data. Removing and adding back the path is necessary for
% avoiding an error of the resample function. Not sure why. Solution is
% explained here: https://sccn.ucsd.edu/bugzilla/show_bug.cgi?id=1184
% --------------------------------------------------------------
if cfg.do_resampling == 1
    [pathstr, ~, ~] = fileparts(which('resample.m'));
    rmpath([pathstr '/'])
    addpath([pathstr '/'])
    EEG = pop_resample( EEG, cfg.new_sampling_rate);
end
