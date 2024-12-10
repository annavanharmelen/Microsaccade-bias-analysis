%% Step3b--grand average plots of gaze-shift (saccade) results

%% start clean
clear; clc; close all;
    
%% parameters
nan_trial_overlap = 0;
nan_post_target = 1;

remove_unfixated = 0;
remove_prematures = 1;
only_over_1400 = 0;

pp2do           = [2:25];

nsmooth         = 500;
plotSinglePps   = 0;
plotGAs         = 1;
xlimtoplot      = [-100 1400];

%% predefine size of some matrices
shiftsL = NaN(size(pp2do, 2), 400, 3550);
shiftsR = NaN(size(pp2do, 2), 400, 3550);
selectionL = zeros(size(pp2do, 2), 400, 3550);
selectionR = zeros(size(pp2do, 2), 400, 3550);
avg_saccade_effect = zeros(size(pp2do, 2), 3);
avg_saccade_axis_effect = zeros(size(pp2do, 2), 2);

%% set visual parameters
[bar_size, bright_colours, colours, light_colours, SOA_colours, dark_colours, subplot_size] = setBehaviourParam(pp2do);
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
   
    if nan_trial_overlap == 1
        toadd1 = '_NaNtrialoverlap';
    else
        toadd1 = '';
    end    

    if remove_unfixated == 1
        toadd2 = '_removeUnfixated';
    else
        toadd2 = '';
    end

    if nan_post_target == 1
        toadd3 = '_NaNposttarget';
    else
        toadd3 = '';
    end
    
    if remove_prematures == 1
        toadd4 = '_removePremature';
    else
        toadd4 = '';
    end

    if only_over_1400 == 1
        toadd5 = '_onlyover1400';
    else
        toadd5 = '';
    end

    load([param.path, '\saved_data\saccadeEffects_4D', toadd1, toadd2, toadd3, toadd4, toadd5, '__', param.subjName], 'saccade', 'saccadedirection','saccadesize', 'saccade_lengthsplit');
    
    % save averages (saccade effect (capture cue effect and probe cue reaction)
    avg_saccade_effect(s, 1) = mean(saccade.data(5,saccade.time>=200 & saccade.time<=600));
    avg_saccade_effect(s, 2) = mean(saccade.data(5,saccade.time>=1000 & saccade.time<=3000));
    avg_saccade_effect(s, 3) = mean(saccade.data(5,:));

    avg_saccade_axis_effect(s, 1) = mean(saccade.data(5,saccade.time>=200 & saccade.time<=600) - saccade.data(6,saccade.time>=200 & saccade.time<=600));
    avg_saccade_axis_effect(s, 2) = mean(saccade.data(5,saccade.time>=1000 & saccade.time<=1400) - saccade.data(6,saccade.time>=1000 & saccade.time<=1400));
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
        saccade_lengths.data(s,i,:,:) = saccade_lengthsplit.data(i,:,:);
    end

    % take average of polar hist data
    avg_directions(s,1) = mean(saccadedirection.shiftsL((imag(saccadedirection.shiftsL) < 0) & saccadedirection.selectionL), "all", "omitnan");
    avg_directions(s,2) = mean(saccadedirection.shiftsR((imag(saccadedirection.shiftsR) < 0) & saccadedirection.selectionR), "all", "omitnan");
    
    % collate polar hist data
    n_trialsL = size(saccadedirection.shiftsL, 1);
    n_trialsR = size(saccadedirection.shiftsR, 1);
    shiftsL(s, 1:n_trialsL, :) = saccadedirection.shiftsL;
    shiftsR(s, 1:n_trialsR, :) = saccadedirection.shiftsR;
    selectionL(s, 1:n_trialsL, :) = saccadedirection.selectionL;
    selectionR(s, 1:n_trialsR, :) = saccadedirection.selectionR;
end

selectionL = logical(selectionL);
selectionR = logical(selectionR);
%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
saccadesizes.dimord = saccadesize.dimord;
saccadesizes.label = saccadesize.label;
saccadesizes.time = saccadesize.time;
saccadesizes.freq = saccadesize.freq;

for i = 1:size(saccadesize.data, 1)
    saccadesizes.avg_data(i,:,:) = squeeze(mean(saccadesizes.data(:,i,:,:)));
end

saccade_lengths.dimord = saccade_lengthsplit.dimord;
saccade_lengths.label = saccade_lengthsplit.label;
saccade_lengths.time = saccade_lengthsplit.time;
saccade_lengths.freq = saccade_lengthsplit.freq;

for i = 1:size(saccade_lengthsplit.data, 1)
    saccade_lengths.avg_data(i,:,:) = squeeze(mean(saccade_lengths.data(:,i,:,:)));
end

%% all subs
if plotSinglePps
    % plot toward and away
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size,sp);
        hold on;
        plot(saccade.time, squeeze(saccade_data(sp,1,:,:)));
        plot(saccade.time, squeeze(saccade_data(sp,3,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        % ylim([-0.1 0.3]);
        title(pp2do(sp));
    end
    legend(saccade.label{[1,3]});
    % plot 'effect'
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size,sp);
        hold on;
        plot(saccade.time, squeeze(saccade_data(sp,5,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-0.1 0.1]);
        title(pp2do(sp));
    end
    legend(saccade.label{5});

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
        cfg.channel = 5;
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
    p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,1,:)), colours(1,:), 'se');
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
    p5 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,6,:)), colours(1,:), 'se');
    p6 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,7,:)), 'b', 'se');
    legend([p5, p6], {'target-axis', 'nontarget-axis'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    hold off
    
    % plot the effect
    figure;
    hold on
    p7 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,5,:)), bright_colours(3,:), 'se');
    p7.LineWidth = 2.5;
    fontsize(23, 'points')
    xlim(xlimtoplot);
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylim, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    % legend([p7], 'effect', 'EdgeColor', 'w', 'Fontsize', 28);
    ylabel('Rate (Hz)', 'Fontsize', 28);
    xlabel('Time (ms)', 'Fontsize', 28);
    set(gcf,'position',[0,0, 1800,900])
    xlabel('Time (ms)');
    hold off

    % plot the effect - individuals
    figure;
    hold on
    plot(saccade.time, squeeze(saccade_data(:,5,:)));
    % fontsize(23, 'points')
    xlim(xlimtoplot);
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylim, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    % legend([p7], 'effect', 'EdgeColor', 'w', 'Fontsize', 28);
    ylabel('Rate (Hz)', 'Fontsize', 28);
    xlabel('Time (ms)', 'Fontsize', 28);
    % set(gcf,'position',[0,0, 1800,900])
    xlabel('Time (ms)');
    hold off
    
    % plot only saccades towards the stimulus or the distractor
    figure;
    hold on
    p8 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,1,:)), bright_colours(1,:), 'se');
    p9 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,3,:)), bright_colours(2,:), 'se');
    p8.LineWidth = 2.5;
    p9.LineWidth = 2.5;
    fontsize(23, 'points')
    xlim(xlimtoplot);
    % plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylim, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    legend([p8, p9], {'target', 'nontarget'}, 'EdgeColor', 'w', 'Fontsize', 28);
    ylabel('Rate (Hz)', 'Fontsize', 28);
    xlabel('Time (ms)', 'Fontsize', 28);
    set(gcf,'position',[0,0, 1800,900])
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

    %% just effect as function of saccade size
    cfg = [];
    cfg.parameter = 'avg_data';
    cfg.figure = 'gcf';
    cfg.zlim = 'maxabs';
    cfg.xlim = xlimtoplot;  
    cfg.colormap = brewermap(1000, 'PRGn');
    
    % per condition
    figure;
    cfg.channel = 5;
    ft_singleplotTFR(cfg, saccadesizes);
    ylabel('Saccade size (dva)', 'FontSize', 35, 'Position', [-880 2.8750 1]);
    xlabel('Time (ms)', 'FontSize', 35);
    zticks([]);
    hold on
    set(gcf,'position',[0,0, 1800, 750])
    plot([0,0], [0, 7], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([-500 2300], [5, 5], '--', 'LineWidth',2, 'Color', [0,68,27]/255);
    plot([-500 2300], [3.73, 3.73], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([-500 1400], [1, 1], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    xlim(xlimtoplot);
    ylim([0.25 5.5]);
    title('', 'FontSize', 39);
    fontsize(39,"points");
    text(2420, 5.025, 'Centre', 'FontSize', 34, 'Color', [0,68,27]/255);
    text(2420, 3.755, 'Border', 'FontSize', 34, 'Color',[0.6, 0.6, 0.6]);
    text(1520, 1, 'Microsaccade range', 'FontSize', 34, 'Color',[0.6, 0.6, 0.6]);
    
    
    %% just effect as function of SOA
    cfg = [];
    cfg.parameter = 'avg_data';
    cfg.figure = 'gcf';
    cfg.zlim = 'maxabs';
    cfg.xlim = xlimtoplot;  
    cfg.colormap = brewermap(1000, 'PRGn');
    
    % per condition
    figure;
    cfg.channel = 5;
    ft_singleplotTFR(cfg, saccade_lengths);
    ylabel('SOA (ms)', 'FontSize', 35);
    xlabel('Time (ms)', 'FontSize', 35);
    zticks([]);
    hold on
    set(gcf,'position',[0,0, 1800, 750])
    xlim(xlimtoplot);
    % ylim([0.25 5.5]);
    title('', 'FontSize', 39);
    fontsize(39,"points");

    %% compass plots on cartesian axis
    % figure;
    % subplot(1,2,1)
    % c1 = compass(avg_directions(:,1));
    % for i = 1:size(c1, 1)
    %     c1(i).LineWidth = 2.5;
    %     c1(i).Color = 'k';
    % end
    % 
    % subplot(1,2,2)
    % c2 = compass(avg_directions(:,2));
    % for i = 1:size(c2, 1)
    %     c2(i).LineWidth = 2.5;
    %     c2(i).Color = 'k';
    % end
    % fontsize(25, 'points')
    % title('Right cue', 'FontSize', 35);
    % yticks([]);
    % set(gcf,'position',[0,0, 1600, 1000])
    % 
    % subplot(1,2,1)
    % title('Left cue', 'FontSize', 35);

    %% compass plots on polar axis
    arrow_width_factor = (40/360);
    arrow_height = 0.09;
    x = 1.5;
    
    figure;
    subplot(1,2,1)
    for sp = 1:s
        arrow_width = arrow_width_factor / abs(avg_directions(sp,1));
        
        polarplot([angle(avg_directions(sp,1)), angle(avg_directions(sp,1))], [0, abs(avg_directions(sp,1)) - arrow_height], '-', 'Color', 'k', 'LineWidth', x);
        hold on
        polarplot([angle(avg_directions(sp,1)) - arrow_width, angle(avg_directions(sp,1)) + arrow_width], [abs(avg_directions(sp,1)) - arrow_height, abs(avg_directions(sp,1)) - arrow_height], '-', 'Color', 'k', 'LineWidth', x);
        polarplot([angle(avg_directions(sp,1)) - arrow_width, angle(avg_directions(sp,1))], [abs(avg_directions(sp,1)) - arrow_height, abs(avg_directions(sp,1))], '-', 'Color', 'k', 'LineWidth', x);
        polarplot([angle(avg_directions(sp,1)), angle(avg_directions(sp,1)) + arrow_width], [abs(avg_directions(sp,1)), abs(avg_directions(sp,1)) - arrow_height], '-', 'Color', 'k', 'LineWidth', x); 
    end
    rlim([0 1.2]);
    rticks([1]);
    thetaticks([0:45:360]);

    subplot(1,2,2)
    for sp = 1:s
        arrow_width = arrow_width_factor / abs(avg_directions(sp,2));
        
        polarplot([angle(avg_directions(sp,2)), angle(avg_directions(sp,2))], [0, abs(avg_directions(sp,2)) - arrow_height], '-', 'Color', 'k', 'LineWidth', x);
        hold on
        polarplot([angle(avg_directions(sp,2)) - arrow_width, angle(avg_directions(sp,2)) + arrow_width], [abs(avg_directions(sp,2)) - arrow_height, abs(avg_directions(sp,2)) - arrow_height], '-', 'Color', 'k', 'LineWidth', x);
        polarplot([angle(avg_directions(sp,2)) - arrow_width, angle(avg_directions(sp,2))], [abs(avg_directions(sp,2)) - arrow_height, abs(avg_directions(sp,2))], '-', 'Color', 'k', 'LineWidth', x);
        polarplot([angle(avg_directions(sp,2)), angle(avg_directions(sp,2)) + arrow_width], [abs(avg_directions(sp,2)), abs(avg_directions(sp,2)) - arrow_height], '-', 'Color', 'k', 'LineWidth', x);
    end
    rlim([0 1.2]);
    rticks([1]);
    thetaticks([0:45:360]);
    fontsize(30, 'points')
    title('Right cue', 'FontSize', 35);
    
    subplot(1,2,1)
    title('Left cue', 'FontSize', 35);
    set(gcf,'position',[0,0, 1600, 1000])
    %% plot aggregated polar histogram of all saccades (no weighting)
    bin_edges = [0 1 2 3 4 5 6];
    max_saccade_size = 1; 

    figure;
    subplot(2,2,1);
    polarhistogram(angle(shiftsL((abs(shiftsL) < max_saccade_size) & selectionL)),20);
    title('left cue');
    subplot(2,2,2);
    polarhistogram(angle(shiftsR((abs(shiftsR) < max_saccade_size) & selectionR)),20);
    % title('right cue');
    subplot(2,2,3);
    histogram(abs(shiftsL((abs(shiftsL) < max_saccade_size) & selectionL)), bin_edges);
    xlim([0 10]);
    subplot(2,2,4);
    histogram(abs(shiftsR((abs(shiftsR) < max_saccade_size) & selectionR)), bin_edges);
    xlim([0 10]);

    %% polar histogram of all saccades (all participants weighted as 1)
    fig = figure;
    for sp = 1:s
        p = polarhistogram(angle(shiftsL(sp, selectionL(sp,:,:))),20);
        L_counts(sp,:) = p.Values;
        p = polarhistogram(angle(shiftsR(sp, selectionR(sp,:,:))),20);
        R_counts(sp,:) = p.Values;
    end
    polar_bin_edges = p.BinEdges;
    close(fig)
    
    L_density = L_counts./sum(L_counts, 2);
    R_density = R_counts./sum(R_counts, 2);
    
    L_values = mean(L_density)*100;
    R_values = mean(R_density)*100;

    figure;
    subplot(1,2,1);
    polarhistogram('BinEdges', polar_bin_edges(10:21), 'BinCounts', L_values(10:20), 'FaceColor', [0.6, 0.6, 0.6], 'FaceAlpha', 0.45, 'EdgeColor', [1,1,1]);
    hold on
    polarhistogram('BinEdges', polar_bin_edges(1:11), 'BinCounts', L_values(1:10), 'FaceColor', [0.6, 0.6, 0.6], 'FaceAlpha', 0.9, 'EdgeColor', [1,1,1]);
    rlim([0 10]);
    rticks([5 10]);
    thetaticks([0:45:360]);
    hold off

    subplot(1,2,2);
    polarhistogram('BinEdges', polar_bin_edges(10:21), 'BinCounts', R_values(10:20), 'FaceColor',[0.6,0.6,0.6], 'FaceAlpha', 0.45, 'EdgeColor', [1,1,1]);
    hold on
    polarhistogram('BinEdges', polar_bin_edges(1:11), 'BinCounts', R_values(1:10), 'FaceColor', [0.6, 0.6, 0.6], 'FaceAlpha', 0.9, 'EdgeColor', [1,1,1]);
    rlim([0 10]);
    rticks([5 10]);
    thetaticks([0:45:360]);
    hold off
    fontsize(30, 'points')
    % title('Right cue', 'FontSize', 35);
    set(gcf,'position',[0,0, 1600, 1000])
    
    subplot(1,2,1)
    % title('Left cue', 'FontSize', 35);

    %% plot distribution of saccades per pp
    saccades_per_pp = [];
    for sp = 1:s
        saccades_per_pp(sp,1) = size(shiftsL(sp,selectionL(sp,:,:)), 2);
        saccades_per_pp(sp,2) = size(shiftsR(sp,selectionR(sp,:,:)), 2);
    end
    saccades_per_pp(:,3) = saccades_per_pp(:,1) + saccades_per_pp(:,2);
    [B, I] = sort(saccades_per_pp(:,3), "descend");
    
    figure;
    hold on
    bar(saccades_per_pp(I,1:2), 'stacked');
    hold off
    legend({ 'left', 'right'});
    xlabel('pp number');
    xticks(1:size(pp2do, 2));
    xticklabels(pp2do(I));
    ylabel('number of saccades (n)');

    figure;
    bar(B);
    xlabel('pp number');
    xticks(1:size(pp2do, 2));
    xticklabels(pp2do(I));
    ylabel('number of saccades (n)');
    legend('total');

    %% plot bar chart of different timeframes
    figure;
    hold on
    b1 = bar([1], [mean(avg_saccade_effect(:,1))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:));
    b2 = bar([2], [mean(avg_saccade_effect(:,2))], bar_size, FaceColor=colours(4,:), EdgeColor=colours(4,:));
    errorbar([1], [mean(avg_saccade_effect(:,1))], [std(avg_saccade_effect(:,1)) ./ sqrt(size(pp2do, 2))], 'LineWidth', 3, 'Color', dark_colours(3,:));
    errorbar([2], [mean(avg_saccade_effect(:,2))], [std(avg_saccade_effect(:,2)) ./ sqrt(size(pp2do, 2))], 'LineWidth', 3, 'Color', dark_colours(4,:));
    plot([1,2], [avg_saccade_effect(:,1:2)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);

    % title('Saccade towards rate')
    % legend(labels, 'Location', 'southeast');
    % ylim([-0.03 0.26]);
    ylabel('Saccade bias (ΔHz)');
    % yticks([0 0.1 0.2]);
    xlim([0.3 2.7]);
    xticks([1,2]);
    xticklabels({'Shift', 'Sustain'});
    fontsize(27, "points");
    
    set(gcf,'position',[0,0, 650,1080])

    %% polar histogram of separate timeframes
    time_edges = [200, 600];
    x = 4;
    % get indices of wanted time range
    timeidx = find(abs(saccade.time - time_edges(1)) < 0.01):find(abs(saccade.time - time_edges(2)) < 0.01);

    fig = figure;
    for sp = 1:s
        sp_time_shiftsL = shiftsL(sp,:,timeidx);
        sp_time_selL = selectionL(sp,:,timeidx);
        p = polarhistogram(angle(sp_time_shiftsL(sp_time_selL)),20);
        L_counts(sp,:) = p.Values;

        sp_time_shiftsR = shiftsR(sp,:,timeidx);
        sp_time_selR = selectionR(sp,:,timeidx);
        p = polarhistogram(angle(sp_time_shiftsR(sp_time_selR)),20);
        R_counts(sp,:) = p.Values;
    end
    polar_bin_edges = p.BinEdges;
    close(fig)
    
    L_density = L_counts./sum(L_counts, 2);
    R_density = R_counts./sum(R_counts, 2);
    
    L_values = mean(L_density)*100;
    R_values = mean(R_density)*100;


    figure;
    subplot(1,2,1);
    polarhistogram('BinEdges', polar_bin_edges(11:21), 'BinCounts', L_values(11:20), 'FaceColor', [0.6, 0.6, 0.6], 'FaceAlpha', 0.45, 'EdgeColor', [1,1,1]);
    hold on
    polarhistogram('BinEdges', polar_bin_edges(1:11), 'BinCounts', L_values(1:10), 'FaceColor', bright_colours(x,:), 'FaceAlpha', 0.7, 'EdgeColor', [1,1,1]);
    rlim([0, 10]);
    thetaticks([]);
    rticks([5 10]);
    % title('left cue');
    
    subplot(1,2,2);
    polarhistogram('BinEdges', polar_bin_edges(11:21), 'BinCounts', R_values(11:20), 'FaceColor', [0.6, 0.6, 0.6], 'FaceAlpha', 0.45, 'EdgeColor', [1,1,1]);
    hold on
    polarhistogram('BinEdges', polar_bin_edges(1:11), 'BinCounts', R_values(1:10), 'FaceColor', bright_colours(x,:), 'FaceAlpha', 0.7, 'EdgeColor', [1,1,1]);
    rlim([0, 10]);
    rticks([5 10]);
    thetaticks([]);
    fontsize(50, 'points')
    % title('Right cue', 'FontSize', 35);
    % sgtitle(sprintf('%d - %d ms',time_edges(1), time_edges(2)));
 
    set(gcf,'position',[0,0, 1600, 1000])

    subplot(1,2,1)
    % title('Left cue', 'FontSize', 35);
  
end
