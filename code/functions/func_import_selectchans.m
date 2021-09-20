function EEG = func_import_selectchans(EEG, cfg)
% --------------------------------------------------------------
% Data recorded in Berlin had the usual 64 + 6 external eletrodes, but
% data recorded in Münster (18+) accidentally had almost 300 channels
% recorded, most of them empty. thus, their external electrodes are at the
% very end of this list of useless channels. this was fixed from subjects
% 24 onwards.
% --------------------------------------------------------------

%     if str2num(cfg.subject_name) < 18
%         EEG = pop_select(EEG, 'channel', cfg.EEGchans);
%     elseif str2num(cfg.subject_name) >= 18 && EEG.nbchan > 80
%         EEG = pop_select(EEG, 'channel', [1:64 257:262]);
%     elseif str2num(cfg.subject_name) >= 18 && EEG.nbchan <= 80
%         EEG = pop_select(EEG, 'channel', cfg.EEGchans);
%     end
if EEG.nbchan > 80
    EEG = pop_select(EEG, 'channel', [1:64 257:262]);
else
    EEG = pop_select(EEG, 'channel', cfg.EEGchans);
end

EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');