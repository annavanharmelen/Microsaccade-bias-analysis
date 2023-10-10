%% Step3-- gaze-shift calculation

%% start clean
clear; clc; close all;

%% parameters
for pp = [21, 22, 24, 26, 31, 32];

    oneOrTwoD       = 1; oneOrTwoD_options = {'_1D','_2D'};
    plotResults     = 1;

    %% load epoched data of this participant data
    param = getSubjParam_AnnaVidi1(pp);
    load([param.path, '\epoched_data\eyedata_AnnaVidi1','_'  param.subjName], 'eyedata');

    %% add relevant behavioural file data

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

    %% reformat such that all data in single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
    tl.trial(:,1,:) = dva_x;
    tl.trial(:,2,:) = dva_y;

    %% selection vectors for conditions -- this is where it starts to become interesting!

    % cued item location
    targL = ismember(tl.trialinfo(:,1), [11,13,15]);
    targR = ismember(tl.trialinfo(:,1), [12,14,16]);

    captureL = ismember(tl.trialinfo(:,1), [11,14]);
    captureR = ismember(tl.trialinfo(:,1), [12,13]);

    % distractor timing
    congruent =     ismember(tl.trialinfo(:,1), [11,12]);
    neutral =       ismember(tl.trialinfo(:,1), [15,16]);
    incongruent  =  ismember(tl.trialinfo(:,1), [13,14]);

    % channels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];
    data_input = squeeze(tl.trial);
    time_input = tl.time*1000;

    if oneOrTwoD == 1         [shiftsX, velocity, times]             = PBlab_gazepos2shift_1D(cfg, data_input(:,chX,:), time_input);
    elseif oneOrTwoD == 2     [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    end

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    if oneOrTwoD == 1     saccadesize = abs(shiftsX);
    elseif oneOrTwoD == 2 saccadesize = abs(shiftsX+shiftsY*1i);
    end
    shiftsL = shiftsX<0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);
    shiftsR = shiftsX>0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);

    %% get relevant contrasts out
    saccade = [];
    saccade.time = times;
    saccade.label = {'all','congruent','neutral','incongruent','congruent-vs-incongruent'};

    for selection = [1:4] % conditions.
        if     selection == 1  sel = ones(size(congruent));
        elseif selection == 2  sel = congruent;
        elseif selection == 3  sel = neutral;
        elseif selection == 4  sel = incongruent;
        end

        saccade.toward(selection,:) =  (mean(shiftsL(targL&sel,:)) + mean(shiftsR(targR&sel,:))) ./ 2;
        saccade.away(selection,:)  =   (mean(shiftsL(targR&sel,:)) + mean(shiftsR(targL&sel,:))) ./ 2;
    end

    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);

    % add congruent vs. incongruent (essentially: how much toward distractor)
    saccade.toward(end+1,:) = (saccade.toward([2],:) - saccade.toward([4],:)) ./ 2;
    saccade.away(end+1,:)   = (saccade.away([2],:)   - saccade.away([4],:)) ./ 2;
    saccade.effect(end+1,:) = (saccade.effect([2],:) - saccade.effect([4],:)) ./ 2;

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccade.toward = smoothdata(saccade.toward,2,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccade.away   = smoothdata(saccade.away,2,  'movmean',integrationwindow)*1000;
    saccade.effect = smoothdata(saccade.effect,2,'movmean',integrationwindow)*1000;

    %% plot
    if plotResults
        figure;    for sp = 1:5 subplot(2,3,sp); hold on; plot(saccade.time, saccade.toward(sp,:), 'r'); plot(saccade.time, saccade.away(sp,:), 'b'); title(saccade.label(sp)); legend({'toward','away'},'autoupdate', 'off'); plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k'); end
        figure;    for sp = 1:5 subplot(2,3,sp); hold on; plot(saccade.time, saccade.effect(sp,:), 'k'); plot(xlim, [0,0], '--k');                    title(saccade.label(sp)); legend({'effect'},'autoupdate', 'off'); plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k'); end
        figure;                                   hold on; plot(saccade.time, saccade.effect([1:5],:)); plot(xlim, [0,0], '--k'); legend(saccade.label([1:5]),'autoupdate', 'off'); plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k');
        drawnow;
    end

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = times;
    saccadesize.label = {'all','congruent','neutral','incongruent','congruent-vs-incongruent'};

    cnt = 0;
    for sz = saccadesize.freq;
        cnt = cnt+1;
        shiftsL = [];
        shiftsR = [];
        shiftsL = shiftsX<-sz+halfbin & shiftsX > -sz-halfbin; % left shifts within this range
        shiftsR = shiftsX>sz-halfbin  & shiftsX < sz+halfbin; % right shifts within this range

        for selection = [1:4] % conditions.
            if     selection == 1  sel = ones(size(congruent));
            elseif selection == 2  sel = congruent;
            elseif selection == 3  sel = neutral;
            elseif selection == 4  sel = incongruent;
            end

            saccadesize.toward(selection,cnt,:) = (mean(shiftsL(targL&sel,:)) + mean(shiftsR(targR&sel,:))) ./ 2;
            saccadesize.away(selection,cnt,:) =   (mean(shiftsL(targR&sel,:)) + mean(shiftsR(targL&sel,:))) ./ 2;
        end

    end
    % add towardness field
    saccadesize.effect = (saccadesize.toward - saccadesize.away);

    % add congruent vs. incongruent (essentially: how much toward distractor)
    saccadesize.toward(end+1,:,:) = (saccadesize.toward([2],:,:) - saccadesize.toward([4],:,:)) ./ 2;
    saccadesize.away(end+1,:,:)   = (saccadesize.away([2],:,:)   - saccadesize.away([4],:,:)) ./ 2;
    saccadesize.effect(end+1,:,:) = (saccadesize.effect([2],:,:) - saccadesize.effect([4],:,:)) ./ 2;

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccadesize.toward = smoothdata(saccadesize.toward,3,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccadesize.away   = smoothdata(saccadesize.away,3,  'movmean',integrationwindow)*1000;
    saccadesize.effect = smoothdata(saccadesize.effect,3,'movmean',integrationwindow)*1000;

    if plotResults
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        %cfg.zlim = [-0.01, 0.01];
        figure;
        for chan = 1:5
            cfg.channel = chan;
            subplot(2,3,chan); ft_singleplotTFR(cfg, saccadesize);
        end
        colormap('jet');
        drawnow;
    end

    %% save
    save([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');

    %% close loops
end % end pp loop


