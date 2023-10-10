
%% Step2b--grand average plots of gaze-position results

%% start clean
clear; clc; close all;

%% parameters
% pp2do = [1:16];
pp2do = [17:41];
% pp2do           = [17, 18, 21, 22, 23, 24, 26, 29, 30, 31, 32, 35]; %yes capture rt, based on minimum diff of 19.5 ms (incon vs con)
% pp2do           = [19, 20, 25, 27, 28, 33, 34, 36, 37, 38, 39, 40, 41]; %no capture rt, based on minimum diff of 19.5 ms (incon vs con)

nsmooth         = 200;
baselineCorrect = 1;
removeTrials    = 1; % remove trials with more than XX pixel deviation from baseline
plotSinglePps   = 0;
plotGAs         = 0;
xlimtoplot      = [-500 2500];

colours = [72, 224, 176;...
           104, 149, 238;...
           251, 129, 81;...
           223, 52, 163];
colours = colours/255;

ft_size = 26;

capture_cue_effect = [pp2do', zeros(size(pp2do, 2), 2)];
%% load and aggregate the data from all pp
s = 0;
for pp = pp2do;
    s = s+1;

    % get participant data
    param = getSubjParam_AnnaVidi1(pp);

    % load
    disp(['getting data from participant ', param.subjName]);

    if baselineCorrect == 1 toadd1 = '_baselineCorrect'; else toadd1 = ''; end % depending on this option, append to name of saved file.
    if removeTrials == 1    toadd2 = '_removeTrials';    else toadd2 = ''; end % depending on this option, append to name of saved file.

    load([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, '__', param.subjName], 'gaze');
      
    % save averages (gaze effect (capture cue effect and probe cue reaction)
    capture_cue_effect(s, 2) = mean(gaze.towardness(5,gaze.time>=400 & gaze.time<=1000));
    capture_cue_effect(s, 3) = mean(mean(gaze.towardness(2:4,gaze.time>=1500+400 & gaze.time<=1500+1000)));

    % smooth?
    if nsmooth > 0
        for x1 = 1:size(gaze.dataL,1);
            gaze.dataL(x1,:)      = smoothdata(squeeze(gaze.dataL(x1,:)), 'gaussian', nsmooth);
            gaze.dataR(x1,:)      = smoothdata(squeeze(gaze.dataR(x1,:)), 'gaussian', nsmooth);
            gaze.towardness(x1,:) = smoothdata(squeeze(gaze.towardness(x1,:)), 'gaussian', nsmooth);
            gaze.blinkrate(x1,:)  = smoothdata(squeeze(gaze.blinkrate(x1,:)), 'gaussian', nsmooth);
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = gaze.dataR;
    d2(s,:,:) = gaze.dataL;
    d3(s,:,:) = gaze.towardness;
    d4(s,:,:) = gaze.blinkrate;
end

%% make GA

%% all subs
if plotSinglePps
    % towardness
    figure;
    for sp = 1:s
        subplot(5,5,sp); hold on;
        plot(gaze.time, squeeze(d3(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-5 5]);
        title(pp2do(sp));
    end
    legend(gaze.label);

    % blink rate
    figure;
    for sp = 1:s
        subplot(5,5,sp); hold on;
        plot(gaze.time, squeeze(d4(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-20 100]);
        title(pp2do(sp));
    end
    legend(gaze.label);
end

%% plot grand average data patterns of interest, with error bars
if plotGAs
    % right and left cues, per condition
    figure;
    for sp = 1:5
        subplot(2,3,sp); hold on; title(gaze.label(sp));
        p1 = frevede_errorbarplot(gaze.time, squeeze(d1(:,sp,:)), [1,0,0], 'se');
        p2 = frevede_errorbarplot(gaze.time, squeeze(d2(:,sp,:)), [0,0,1], 'se');
        xlim(xlimtoplot); ylim([-10 10]);
    end
    legend([p1, p2], {'R','L'});
    
    % towardness per condition
    figure;
    for sp = 1:5
        subplot(2,3,sp); hold on; title(gaze.label(sp));
        frevede_errorbarplot(gaze.time, squeeze(d3(:,sp,:)), [0,0,0], 'both');
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-5 5]);
    end
    legend({'toward'});
    
%% towardness overlay of all conditions
    figure; hold on;
    ylimit = [-4, 4];
    plot([0,0], [ylimit], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    % plot([1500,1500], [-4, 10], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    p1 = frevede_errorbarplot(gaze.time, squeeze(d3(:,2,:)), colours(1,:), 'se');
    p2 = frevede_errorbarplot(gaze.time, squeeze(d3(:,3,:)), colours(2,:), 'se');
    p3 = frevede_errorbarplot(gaze.time, squeeze(d3(:,4,:)), colours(3,:), 'se');
    p1.LineWidth = 2.5;
    p2.LineWidth = 2.5;
    p3.LineWidth = 2.5;
    ylim(ylimit);
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    legend([p1,p2,p3], gaze.label(2:4), 'EdgeColor', 'w', 'Location', 'northeast');
    xlim(xlimtoplot);
    ylabel('Gaze towardness (px)');
    xlabel('Time (ms)');
    set(gcf,'position',[0,0, 1800,900])
    fontsize(ft_size,"points");

    ylimit2 = [-4, 3];
    figure;
    % subplot(1,2,1);
    hold on;
    p1 = frevede_errorbarplot(gaze.time, squeeze(d3(:,5,:)), colours(4,:), 'both');
    p1.LineWidth = 2.5;
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylimit2, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    % legend(p1, gaze.label(5), 'EdgeColor', 'w', 'Location', 'northeast');
    xlim(xlimtoplot);
    ylabel('Gaze towardness (px)');
    xlabel('Time (ms)');
    set(gcf,'position',[0,0, 1800,900])
    fontsize(ft_size,"points");
    ylim(ylimit2);
    
    % subplot(1,2,2); hold on;
    % p1 = plot(gaze.time, squeeze(d3(:,5,:)));
    % plot(xlim, [0,0], '--k');
    % legend([p1], gaze.label(5));
    % xlim(xlimtoplot);
    % 
    %% blink rate
    figure; 
    hold on;
    p1 = frevede_errorbarplot(gaze.time, squeeze(d4(:,2,:)), [1,0,0], 'se');
    p2 = frevede_errorbarplot(gaze.time, squeeze(d4(:,3,:)), [1,0,1], 'se');
    p3 = frevede_errorbarplot(gaze.time, squeeze(d4(:,4,:)), [0,0,1], 'se');
    plot(xlim, [0,0], '--k');
    plot([0,0], [-5, 30], '--k')
    legend([p1,p2,p3], gaze.label(2:4));
    xlim(xlimtoplot);

end