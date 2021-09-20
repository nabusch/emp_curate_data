%%
% Silently load EEGLAB once to load all necessary paths. Then wipe all the
% unnessesary variables.
addpath('/data3/Niko/EEG-Many-Pipelines/toolboxes/eeglab2021.0/');
addpath('./functions')
addpath(genpath('~/Matlab/Functions/'))
addpath(genpath('C:\Users\nbusch\Dropbox\Resources\Matlab\Functions\'))
eeglab nogui
clear
close all
clc

%%
cfg = getcfg;
subjects = dir([cfg.dir_tf '*TF.mat']);
nsubs = length(subjects);
nconds = length(cfg.conditions);

%%
allpow = zeros(cfg.num_frex, 768, 72, nconds, 2, nsubs);
for isub = 1:length(subjects)
    
    name = num2str(isub, '%02d'); % subject index with trailing zero
    out_eeg_name = ['EMP', name, '_TF.mat'];
    
    fprintf('Loading %s.\n', out_eeg_name)
    load(fullfile(cfg.dir_tf, out_eeg_name))       
    allpow(:,:,:,:,:,isub) = TF.pow;
    
end

bslpow = log10(my_bslcorrect(allpow, 2, TF.times, [-500 0], 'div'));
grandpow = mean(bslpow, 6);

%%
figure(2); 
topoplot([],TF.chanlocs,'style','blank','electrodes',...
    'numbers');
     
%%
chans_post = [31 26 30 63 29];
chans_ant  = [ 4 38 39 11 47 46];

fig.chans{1, :} = [24 25 61 62];
fig.chans{2, :} = chans_ant;
fig.chans{3, :} = chans_ant;
fig.chans{4, :} = chans_ant;

fig.tlims(1, :) = [300 500];
fig.tlims(2, :) = [500 700];
fig.tlims(3, :) = [400 700];
fig.tlims(4, :) = [200 700];

fig.flims(1, :) = [4 8];
fig.flims(2, :) = [3 8];
fig.flims(3, :) = [4 8];
fig.flims(4, :) = [3 6];

for icond = 1:4
   fig.tlims_i(icond,:) = dsearchn(TF.times', fig.tlims(icond,:)');
   fig.flims_i(icond,:) = dsearchn(cfg.frex', fig.flims(icond,:)');
end


ncontours = 64;
figh= figure(1);
set(figh, 'color', 'w');

for icond = 1:nconds
    
    ax_tf = sanesubplot(nconds, 3, {icond, 1:2}); hold all;
    
    testpow = mmean(allpow(:,:,fig.chans{icond,:},icond,:,:), 3);
    [H,P,CI,STATS] = ttest(testpow(:,:,2,:), testpow(:,:,1,:), 'Dim', 4);
    t_threshold = tinv(0.05, STATS.df);
    STATS.tstat(abs(STATS.tstat)<abs(t_threshold)) = 0;
    plotpow = STATS.tstat;
    
    plot_topo = mmean(allpow(...
        fig.flims_i(icond,1):fig.flims_i(icond,2), ...
        fig.tlims_i(icond,1):fig.tlims_i(icond,2), ...
        cfg.EEGchans, ...
        icond, :, :), [1, 2, 6]);
    
    plot_topo = plot_topo(:,2) - plot_topo(:,1);
    
    
    %     plotpow = mean(diff(grandpow(:,:,fig.chans{icond,:},icond,:), [], 5), 3);
    %     plotpow = mmean(grandpow(:,:,fig.chans{icond,:},icond,:), [3,5]);
    
    [~, conth] = contourf(TF.times, cfg.frex, plotpow, ncontours,'linecolor','none');
%     [tfh] = imagesc(TF.times, cfg.frex, plotpow);
    title('Power')
    xlabel('Time [ms]')
    ylabel('Frequency [Hz]')
    set(gca, ...
        'ydir', 'normal', ...
        'xlim', [-200 1000], ...        
        'ylim', [3 30])
    
    my_tfmark(conth, fig.tlims(icond,1), fig.tlims(icond,2), ...
        fig.flims(icond,1), fig.flims(icond,2));

    
    absmax = max(abs([min(plotpow(:)) max(plotpow(:))]));
    set(ax_tf, 'clim', [-absmax absmax]);
    colorbar
    
    if isstr(cfg.conditions{icond,1}{2})
        frmt = '%s';
    else
        frmt = 'd';
    end
    
    titstr = sprintf(['%s: ' frmt ' vs. %s: ' frmt], ...
    cfg.conditions{icond,1}{1}, ...
    cfg.conditions{icond,1}{2}, ...
    cfg.conditions{icond,2}{1}, ...
    cfg.conditions{icond,2}{2});
title(titstr, 'Interpreter', 'none')

    ax_topo = sanesubplot(nconds, 3, {icond, 3});
    makefig_topo(plot_topo, TF.chanlocs, [fig.chans{icond,:}])



end


rb=brewermap(ncontours, '*RdBu');
colormap(rb);
set(gcf,'units','normalized','position',[0.3,0.1,0.4,0.8])

disp(('Done.'))

