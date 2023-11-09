
%% Step3b--grand average plots of gaze-shift (saccade) results

%% start clean
clear; clc; close all;
    
%% parameters
pp2do           = [1:22];
nsmooth         = 200;
plotSinglePps   = 0;
plotGAs         = 0;
xlimtoplot      = [-500 3200];

%% set visual parameters
[bar_size, bright_colours, colours, dark_colours, subplot_size] = setBehaviourParam(pp2do);
colour_map = create_colour_map(101);
ft_size = 26;

%% load and aggregate the data from all pp
s = 0;
for pp = pp2do
    s = s+1;

    % get participant data
    param = getSubjParam(pp);

    % load
    disp(['getting data from participant ', param.subjName]);
    load([param.path, '\saved_data\saccadeEffects_4D__', param.subjName], 'saccade','saccadesize', 'saccadedirection');
    
    % smooth?
    if nsmooth > 0
        for i = 1:size(saccade.data,1)
            saccade.data(i,:) = smoothdata(squeeze(saccade.data(i,:)), 'gaussian', nsmooth);
        end

        %also smooth saccadesize data over time.
        for i = 1:size(saccadesize.data,1)
            for j = 1:size(saccadesize.data,2)
                saccadesize.data(i,j,:) = smoothdata(squeeze(saccadesize.data(i,j,:)), 'gaussian', nsmooth);
            end
        end
    end

    % put timecourses into matrix, with pp as first dimension
    for i = 1:size(saccadesize.data, 1)
        saccade_data(s,i,:) = saccade.data(i,:);
        saccadesizes.data(s,i,:,:) = saccadesize.data(i,:,:);
    end

    % collate polar hist data
    avg_directions(s,1) = nanmean(nanmean(saccadedirection.shiftsL(saccadedirection.selectionL)));
    avg_directions(s,2) = nanmean(nanmean(saccadedirection.shiftsR(saccadedirection.selectionR)));
    total_directions(s,1) = nansum(nansum(saccadedirection.shiftsL(saccadedirection.selectionL)));
    total_directions(s,2) = nansum(nansum(saccadedirection.shiftsR(saccadedirection.selectionR)));
    shiftsL(s,:,:) = saccadedirection.shiftsL;
    shiftsR(s,:,:) = saccadedirection.shiftsR;
    selectionL(s,:,:) = saccadedirection.selectionL;
    selectionR(s,:,:) = saccadedirection.selectionR;
end
%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
saccadesizes.dimord = saccadesize.dimord;
saccadesizes.label = saccadesize.label;
saccadesizes.time = saccadesize.time;
saccadesizes.freq = saccadesize.freq;

for i = 1:size(saccadesize.data, 1)
    saccadesizes.avg_data(i,:,:) = squeeze(mean(saccadesizes.data(:,i,:,:)));
end

%% all subs
if plotSinglePps
    % plot 'effect'
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size,sp);
        hold on;
        plot(saccade.time, squeeze(saccade_data(sp,7,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend(saccade.label{7});

    % plot 'effect' x saccadesize
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect_individual';
        cfg.figure = 'gcf';
        cfg.zlim = 'maxabs';
        cfg.xlim = xlimtoplot;
        subplot(subplot_size, subplot_size,sp);
        hold on;
        cfg.channel = 1;
        saccadesize.effect_individual = squeeze(saccadesizes.data(sp,:,:,:));
        ft_singleplotTFR(cfg, saccadesize);
        title(pp2do(sp));
        colormap('jet');
    end

    % plot polar histograms per participant
    bin_edges = [0 1 2 3 4 5 6];
    figure;
    title('Left');
    c = 1;
    for sp = 1:s
        subplot(subplot_size,subplot_size*2,c);
        polarhistogram(angle(shiftsL(sp,selectionL(sp,:,:))),20);
        title(pp2do(sp));

        subplot(subplot_size,subplot_size*2,c + 1);
        histogram(abs(shiftsL(sp,selectionL(sp,:,:))), bin_edges);
        xlim([0 6]);
        ylim([0 500]);
        title(sum(sum(selectionL(sp,:,:))));
        c = c + 2;
    end

    figure;
    title('Right');
    c = 1;
    for sp = 1:s
        subplot(subplot_size,subplot_size*2,c);
        polarhistogram(angle(shiftsR(sp,selectionR(sp,:,:))),20);
        title(pp2do(sp));

        subplot(subplot_size,subplot_size*2,c + 1);
        histogram(abs(shiftsR(sp,selectionR(sp,:,:))), bin_edges);
        xlim([0 6]);
        ylim([0 500]);
        title(sum(sum(selectionR(sp,:,:))));
        c = c + 2;
    end

end

%% Plot grand average data patterns of interest, with error bars
if plotGAs
    % plot all four possible directions separately
    figure; 
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,1,:)), 'r', 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,2,:)), [1, 0.5, 0.5], 'se');
    p3 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,3,:)), 'b', 'se');
    p4 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,4,:)), [0.5, 0.5, 1], 'se');
    legend([p1, p2, p3, p4], {'target', 'opposite-target', 'nontarget', 'opposite-nontarget'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    hold off
    
    % plot both axes of directions separately
    figure;
    hold on
    p5 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,5,:)), 'r', 'se');
    p6 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,6,:)), 'b', 'se');
    legend([p5, p6], {'target-axis', 'nontarget-axis'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    hold off
    
    % plot the effect
    figure;
    hold on
    p7 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,7,:)), 'k', 'se');
    legend([p7], {'effect'});
    xlabel('Time (ms)');
    hold off
    
    % plot only saccades towards the stimulus or the distractor
    figure;
    hold on
    p8 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,1,:)), 'r', 'se');
    p9 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,3,:)), 'b', 'se');
    legend([p8, p9], {'target', 'nontarget'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    hold off
    
    %% as function of saccade size
    cfg = [];
    cfg.parameter = 'avg_data';
    cfg.figure = 'gcf';
    cfg.zlim = 'maxabs';
    cfg.xlim = xlimtoplot;
    cfg.colormap = 'jet';
    
    % per condition
    figure;
    for condition = 1:size(saccadesizes.label, 2)
        subplot(3, 3, condition);
        cfg.channel = condition;
        ft_singleplotTFR(cfg, saccadesizes);
        ylabel('Saccade size (dva)')
        xlabel('Time (ms)')
        hold on
        % set(gcf,'position',[0,0, 1000, 1000])
        % fontsize(35,"points");
        % plot([0,0], [0, 7], '--', 'LineWidth',3, 'Color', [0.6, 0.6, 0.6]);
        % plot([1500,1500], [0, 7], '--', 'LineWidth',3, 'Color', [0.6, 0.6, 0.6]);
        ylim([0.2 6.8]);
    end
    % title('Saccade towardness over time', 'FontSize', 35);


    %% compass plots
    figure;
    subplot(1,2,1)
    compass(avg_directions(:,1), 'k') 
    title('Left cue');
    subplot(1,2,2)
    compass(avg_directions(:,2), 'k')
    title('Right cue');

    figure;
    subplot(1,2,1)
    compass(total_directions(:,1), 'k') 
    title('Left cue');
    subplot(1,2,2)
    compass(total_directions(:,2), 'k')
    title('Right cue');
end