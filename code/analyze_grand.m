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
load('grandaverage.mat')

%%
nconds = size(grand.conditions,1);

cond_title{1} = 'Scene category';
cond_title{2} = 'Old/new effect';
cond_title{3} = 'Subsequent memory effect';

t = grand.times;
chans{1, :} = [20 30 31 57 29];
chans{2, :} = [48 32 47 ];
chans{3, :} = [3 37 36 4 38 39];

twin(1, :) = [100 200];
twin(2, :) = [300 600];
twin(3, :) = [300 600];
xwin(1, :) = round(eeg_lat2point(twin(1, :), 1, grand.srate, [t(1) t(end)], 1/1000)); % Convert time to sampling points
xwin(2, :) = round(eeg_lat2point(twin(2, :), 1, grand.srate, [t(1) t(end)], 1/1000)); % Convert time to sampling points
xwin(3, :) = round(eeg_lat2point(twin(3, :), 1, grand.srate, [t(1) t(end)], 1/1000)); % Convert time to sampling points

tplot = [-200 800];

cm=brewermap(2, 'Pastel1');

close all
figure
for icond = 1:nconds
    
    for ilevel = 1:2
        condstr{ilevel} = sprintf('%s: %d', grand.conditions{icond, ilevel}{1}, grand.conditions{icond, ilevel}{2});
    end
    
    plot_erp = mmean(grand.data(chans{icond,:}, :, :, icond, :), [1, 3]);
    plot_erp = my_bslcorrect(plot_erp, 1, grand.times, [-500 0], 'sub');
    
    plot_topo = mmean(grand.data(1:70, xwin(icond,1):xwin(icond,2), :, icond, :), [2, 3]);
    plot_topo = plot_topo(:,2) - plot_topo(:,1);
    
    
    statdata = mmean(...
        grand.data(chans{icond,:}, ...
        xwin(icond,1):xwin(icond,2), :, icond, :), [1 2]);
    
    [h,p,ci,stats] = ttest(statdata(:,1), statdata(:,2));
    statstr = sprintf('t(%d)=%2.2f; p=%0.3f', stats.df, stats.tstat, p);
    
    
    erpax(icond) = sanesubplot(2, nconds, {1, icond}); hold all
    set(erpax(icond), 'colororder', cm)
    
    ph = plot(grand.times, plot_erp, 'linewidth', 2);
    xline(0, 'color', [0.8 0.8 0.8]);
    yline(0, 'color', [0.8 0.8 0.8]);
    xlabel('time (ms)')
    ylabel('amplitude (µV)')
    title({cond_title{icond}, statstr})
    xlim([tplot]);
    
    ylims = get(gca, 'Ylim');
    fl = patch([twin(icond,1) twin(icond,2) twin(icond,2) twin(icond,1)],...
        [ylims(1)+0.1 ylims(1)+0.1 ylims(2) ylims(2)], ...
        'r', 'facecolor', [0.9 0.9 0.9], 'edgecolor', 'none');
    
    % set(gca,'children',[ph fl]);
    uistack(fl, 'bottom')
    
    set(gca,'TickDir','out');
    
    legend(ph,condstr, 'Interpreter', 'none', 'location', 'best')
    legend('boxoff')
    
    
    topoax(icond) = sanesubplot(2, nconds, {2, icond});
    topoplot(plot_topo, grand.chanlocs, 'electrodes', 'on', 'maplimits', 'absmax','emarker2', {[chans{icond,:}],'.','w',15,1} ,...
        'whitebk','on');
    colorbar('southoutside')
    
    
    
    
end

% colormap(erpax(1),cm)
% colormap(erpax(2),cm)
% colormap(erpax(3),cm)


rb=brewermap(64, '*RdBu');
colormap(topoax(1), rb);
colormap(topoax(2), rb);
colormap(topoax(3), rb);
% tightfig