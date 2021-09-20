function EEG = func_import_readbdf(cfg, in_bdf_name)

% --------------------------------------------------------------
% Import Biosemi raw data.
% --------------------------------------------------------------
fullfilename = fullfile(cfg.dir_bdf, in_bdf_name);

fprintf('Loading %s\n', fullfilename);
EEG = pop_fileio(fullfilename);
EEG.urname = in_bdf_name;
