
%% Step3b--grand average plots of gaze-shift (saccade) results

%% start clean
clear; clc; close all;

colours = [72, 224, 176;...
           104, 149, 238;...
           251, 129, 81;...
           223, 52, 163];
colours = colours/255;

colour_map = [36, 70, 167;
              47, 78, 171;
              58, 86, 175;
              69, 94, 179;
              80, 102, 183;
              80, 102, 183;
              91, 110, 187;
              102, 117, 192;
              113, 125, 196;
              124, 133, 200;
              135, 141, 204;
              146, 149, 208;
              157, 157, 212;
              166, 166, 216;
              175, 175, 220;
              184, 184, 224;
              193, 193, 228;
              202, 202, 232;
              210, 210, 235;
              219, 219, 239;
              228, 228, 243;
              237, 237, 247;
              246, 246, 251;
              255, 255, 255;
              254, 247, 247;
              253, 238, 238;
              252, 230, 230;
              251, 222, 222;
              250, 213, 214;
              248, 205, 205;
              247, 196, 197;
              246, 188, 189;
              245, 180, 181;
              244, 171, 172;
              243, 163, 164;
              241, 154, 157;
              239, 145, 151;
              237, 137, 144;
              235, 128, 137;
              233, 119, 131;
              232, 110, 124;
              230, 101, 118;
              228, 92, 111;
              226, 84, 104;
              224, 75, 98;
              222, 66, 91];
colour_map = colour_map/255;
ft_size = 26;
    
%% parameters
% pp2do           = [21, 22, 24, 26, 31, 32];
% pp2do           = [17:20,23,25,27:30,33:41];
% pp2do           = [1:16];
pp2do           = [17:41];
% pp2do           = [17, 18, 21, 22, 23, 24, 26, 29, 30, 31, 32, 35]; %yes capture rt, based on minimum diff of 19.5 ms (incon vs con)
% pp2do           = [19, 20, 25, 27, 28, 33, 34, 36, 37, 38, 39, 40, 41]; %no capture rt, based on minimum diff of 19.5 ms (incon vs con)
oneOrTwoD       = 1;        oneOrTwoD_options = {'_1D','_2D'};
nsmooth         = 200;
plotSinglePps   = 0;
plotGAs         = 0;
xlimtoplot      = [-500 1500];

capture_cue_effect = [pp2do', zeros(size(pp2do, 2), 2)];
%% load and aggregate the data from all pp
s = 0;
for pp = pp2do
    s = s+1;

    % get participant data
    param = getSubjParam_AnnaVidi1(pp);

    % load
    disp(['getting data from participant ', param.subjName]);
    load([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');
       
    % save averages (saccade effect (capture cue effect and probe cue reaction)
    capture_cue_effect(s, 2) = mean(saccade.effect(5,saccade.time>=200 & saccade.time<=600));
    capture_cue_effect(s, 3) = mean(mean(saccade.effect(2:4,saccade.time>=1500+200 & saccade.time<=1500+600)));

    % smooth?
    if nsmooth > 0
        for x1 = 1:size(saccade.toward,1)
            saccade.toward(x1,:)  = smoothdata(squeeze(saccade.toward(x1,:)), 'gaussian', nsmooth);
            saccade.away(x1,:)    = smoothdata(squeeze(saccade.away(x1,:)), 'gaussian', nsmooth);
            saccade.effect(x1,:)  = smoothdata(squeeze(saccade.effect(x1,:)), 'gaussian', nsmooth);
        end
        % also smooth saccadesize data over time.
        for x1 = 1:size(saccadesize.toward,1)
            for x2 = 1:size(saccadesize.toward,2)
                saccadesize.toward(x1,x2,:) = smoothdata(squeeze(saccadesize.toward(x1,x2,:)), 'gaussian', nsmooth);
                saccadesize.away(x1,x2,:)   = smoothdata(squeeze(saccadesize.away(x1,x2,:)), 'gaussian', nsmooth);
                saccadesize.effect(x1,x2,:) = smoothdata(squeeze(saccadesize.effect(x1,x2,:)), 'gaussian', nsmooth);
            end
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = saccade.toward;
    d2(s,:,:) = saccade.away;
    d3(s,:,:) = saccade.effect;

    d4(s,:,:,:) = saccadesize.toward;
    d5(s,:,:,:) = saccadesize.away;
    d6(s,:,:,:) = saccadesize.effect;
end

%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
saccadesize.toward = squeeze(mean(d4));
saccadesize.away   = squeeze(mean(d5));
saccadesize.effect = squeeze(mean(d6));

%% all subs
if plotSinglePps
    % toward vs away
    figure;
    for sp = 1:s
        subplot(5,5,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-1.5 1.5]);
        title(pp2do(sp));
    end
    legend(saccade.label);

    % towardness for all conditions condition - gaze shift effect X saccade size
    figure;
    for sp = 1:s
        subplot(5,5,sp);
        cfg = [];
        cfg.parameter = 'effect_individual';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        for sp = 1:s
            subplot(5,5,sp); hold on;
            saccadesize.effect_individual = squeeze(d6(sp,:,:,:)); % put in data from this pp
            cfg.channel = 1; % all conditions combined.
            ft_singleplotTFR(cfg, saccadesize);
            title(pp2do(sp));
        end
        colormap('jet');
    end
end

%% plot grand average data patterns of interest, with error bars
if plotGAs
    % right and left cues, per condition
    figure;
    for sp = 1:5
        subplot(2,3,sp); hold on; title(saccade.label(sp));
        p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,sp,:)), [1,0,0], 'se');
        p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,sp,:)), [0,0,1], 'se');
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-1 2]);
    end
    legend([p1, p2], {'toward','away'});
    
    % towardness per condition - gaze shift effect X saccade size
    figure;
    for sp = 1:5
        subplot(2,3,sp); hold on; title(saccade.label(sp));
        frevede_errorbarplot(saccade.time, squeeze(d3(:,sp,:)), [0,0,0], 'both');
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-1.5 1.5]);
    end
    legend({'effect'});
    
    %% towardness overlay of all conditions
    ylimit = [-0.3, 0.4];

    figure; hold on;
    % plot([0,0], [ylimit], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,2,:)), colours(1,:), 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,3,:)), colours(2,:), 'se');
    p3 = frevede_errorbarplot(saccade.time, squeeze(d3(:,4,:)), colours(3,:), 'se');
    p1.LineWidth = 2.5;
    p2.LineWidth = 2.5;
    p3.LineWidth = 2.5;
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0, 0], ylimit, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    % plot([1500, 1500], [ylimit], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    xlim(xlimtoplot);
    % yticks(linspace(-0.5, 1, 7));
    set(gcf,'position',[0,0, 1800,900])
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    fontsize(ft_size*1.5,"points");
    legend([p1,p2,p3], saccade.label(2:4), 'EdgeColor', 'w', 'Location', 'northeast');
    ylim(ylimit);

    ylimit2 = [-0.3, 0.3];
    figure;
    % subplot(1,2,1);
    hold on;
    p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,5,:)), colours(4,:), 'both');
    p1.LineWidth = 2.5;
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylimit2, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    set(gcf,'position',[0,0, 1800,900])
    %legend([p1], saccade.label(5));
    xlim(xlimtoplot);
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    fontsize(ft_size,"points");

    % subplot(1,2,2); hold on;
    % plot(saccade.time, squeeze(d3(:,5,:)));
    % plot(xlim, [0,0], '--k');
    % legend([p1], saccade.label(5));
    % xlim(xlimtoplot);
    
    %% as function of saccade size
    cfg = [];
    cfg.parameter = 'effect';
    cfg.figure = 'gcf';
    cfg.zlim = [-0.1, 0.1];
    cfg.xlim = xlimtoplot;
    cfg.colormap = colour_map;
    % per condition
    figure;
    % for chan = 1:5
    %     cfg.channel = chan;
    %     subplot(2,3,chan); ft_singleplotTFR(cfg, saccadesize);
    % end
    cfg.channel = 5;
    ft_singleplotTFR(cfg, saccadesize);
    ylabel('Saccade size (dva)')
    xlabel('Time (ms)')
    set(gcf,'position',[0,0, 1000, 1000])
    fontsize(35,"points");
    hold on
    plot([0,0], [0, 7], '--', 'LineWidth',3, 'Color', [0.6, 0.6, 0.6]);
    % plot([1500,1500], [0, 7], '--', 'LineWidth',3, 'Color', [0.6, 0.6, 0.6]);
    ylim([0.2 6.8]);
    title('Saccade towardness over time', 'FontSize', 35);

end
