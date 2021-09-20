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
addpath('../Preprocessing/')
cfg = getcfg;
load('grandaverage.mat')

%%
nconds = size(cfg.conditions,1)+1;
nsubs  = length(grand.dprime);

alphabet = ('A':'Z').';
chars = num2cell(alphabet(1:nconds));
chars = chars.';
charlbl = strcat('(',chars,')');

fig.cond_title{1} = 'Scene category';
fig.cond_title{2} = 'Old/new effect';
fig.cond_title{3} = 'Subsequent memory effect';
fig.cond_title{4} = 'Remembered/forgotten';
fig.cond_title{5} = 'Performance';

fig.t = grand.times;
fig.chans{1, :} = [25 27 29 64 62];;
fig.chans{2, :} = [48 32 47 ];
fig.chans{3, :} = [3 37 36 4 38 39];
fig.chans{4, :} = [12 48 49 19 32 56];
fig.chans{5, :} = [48 32 47 ];

fig.twin(1, :) = [100 200];
fig.twin(2, :) = [300 600];
fig.twin(3, :) = [300 600];
fig.twin(4, :) = [400 800];
fig.twin(5, :) = [300 600];

for i = 1:nconds
    fig.xwin(i, :) = round(eeg_lat2point(fig.twin(i, :), 1, ...
        grand.srate, [fig.t(1) fig.t(end)], 1/1000)); % Convert time to sampling points
end

fig.tplot = [-200 800];

fig.cm_lines1 = brewermap(2, 'Pastel1');
fig.cm_lines2 = brewermap(nsubs, 'Blues');

close all

figh= figure(1);
set(figh, 'color', 'w');

for icond = 1:nconds
    
    % .................................................................
    % Compute data for plotting
    % .................................................................
    
    if icond == 5
        
        [sort_perf, sort_idx] = sort(grand.dprime);
        ref_condition = 2;
        
        plot_erp = mmean(grand.data(fig.chans{icond,:}, :, sort_idx, ref_condition, 2), [1]);
%         plot_erp = plot_erp(:,:,1) - plot_erp(:,:,2);
        plot_erp = my_bslcorrect(plot_erp, 1, grand.times, [-500 0], 'sub');
        
        statdata = mmean(...
            grand.data(fig.chans{icond,:}, ...
            fig.xwin(icond,1):fig.xwin(icond,2), sort_idx, ref_condition, 2), [1 2 ]);
        
        [rho, p] = corr(statdata, sort_perf', 'Type', 'Spearman');
        fig.stat_str = sprintf('rho = %2.2f; p = %0.3f', rho, p);
        
    else
        plot_erp = mmean(grand.data(fig.chans{icond,:}, :, :, icond, :), [1, 3]);
        plot_erp = my_bslcorrect(plot_erp, 1, grand.times, [-500 0], 'sub');
        
        plot_topo = mmean(grand.data(1:70, fig.xwin(icond,1):fig.xwin(icond,2), :, icond, :), [2, 3]);
        plot_topo = plot_topo(:,2) - plot_topo(:,1);
        
        statdata = mmean(...
            grand.data(fig.chans{icond,:}, ...
            fig.xwin(icond,1):fig.xwin(icond,2), :, icond, :), [1 2]);
        
        [h,p,ci,stats] = ttest(statdata(:,1), statdata(:,2));
        fig.stat_str = sprintf('t(%d)=%2.2f; p=%0.3f', stats.df, stats.tstat, p);
    end
    
    % .................................................................
    % Line plot
    % .................................................................
    erpax(icond) = sanesubplot(2, nconds, {1, icond}); hold all
    
    text(-0.1,1.1,charlbl{icond},'Units','normalized','FontSize',14, ...
        'FontWeight', 'Bold')

    
    plot_hand = plot(fig.t, plot_erp, 'linewidth', 2);
    makefig_formatplot(fig, icond)
    
    if icond == 5
        set(erpax(icond), 'colororder', fig.cm_lines2)
    else
        makefig_legend(cfg, icond, plot_hand)
        set(erpax(icond), 'colororder', fig.cm_lines1)
    end
    
    % .................................................................
    % Topography/Scatter plot
    % .................................................................   
    topoax(icond) = sanesubplot(2, nconds, {2, icond});
    
    if icond == 5        
        hold on;
        for isub = 1:nsubs
            plot(statdata(isub), sort_perf(isub), 'o', ...
                'markerfacecolor', fig.cm_lines2(isub,:), ...
                'MarkerEdgeColor', 'none' )
        end
        xlabel('averaged ERP')
        ylabel('performance (d-prime')
        axis square
    else
        makefig_topo(plot_topo, grand.chanlocs, [fig.chans{icond,:}])
    end
    
end

rb=brewermap(64, '*RdBu');
for i = 1:nconds-1
    colormap(topoax(i), rb);
end

set(gcf,'units','normalized','position',[0.1,0.1,0.8,0.8])
disp(('Done.'))

