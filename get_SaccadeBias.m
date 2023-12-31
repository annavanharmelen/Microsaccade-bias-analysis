%% Step3-- gaze-shift calculation

%% start clea
clear; clc; close all;

%% parameter
plotResults = 0;
remove_prematures = 1;

%% loop over participants
for pp = [1:25];

    %% load epoched data of this participant data
    param = getSubjParam(pp);
    load([param.path, '\epoched_data\eyedata_AnnaMicro1','_'  param.subjName], 'eyedata');

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

    %% reformat all data to a single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
    tl.time = tl.time * 1000;

    %% remove premature trials
    if remove_prematures
        % get behavioural data
        behdata = readtable(getSubjParam(pp).log);
        
        % select premature trials
        oktrials = ismember(behdata.premature_pressed, {'False'});

        % remove non-oktrials from eye-tracking data
        tl.trial = tl.trial(oktrials,:,:);
        tl.trialinfo = tl.trialinfo(oktrials,:,:);
    end

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
    tl.trial(:,1,:) = dva_x;
    tl.trial(:,2,:) = dva_y;

    %% selection vectors for conditions -- this is where it starts to become interesting!
    % cued item location
    targL = ismember(tl.trialinfo(:,1), [21,22,23,24]);
    targR = ismember(tl.trialinfo(:,1), [25,26,27,28]);

    cueL = ismember(tl.trialinfo(:,1), [22,24,25,27]);
    cueR = ismember(tl.trialinfo(:,1), [21,23,26,28]);

    % orientation direction change 
    clockwise       =  ismember(tl.trialinfo(:,1), [21,22,25,26]);
    anticlockwise   =  ismember(tl.trialinfo(:,1), [23,24,27,28]);
    
    % validity
    valid = ismember(tl.trialinfo(:,1), [22,24,26,28]);
    invalid = ismember(tl.trialinfo(:,1), [21,23,25,27]);
       
    % channels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];
    data_input = squeeze(tl.trial);
    time_input = tl.time;

    [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    saccadesizes = abs(shiftsX+shiftsY*1i);

    shiftsNE = double(shiftsX>0 & shiftsY>0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsNW = double(shiftsX<0 & shiftsY>0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsSE = double(shiftsX>0 & shiftsY<0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    shiftsSW = double(shiftsX<0 & shiftsY<0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));

    %% turn post-change data to NaN
    behdata = readtable(param.log);
    trial_length = behdata.static_duration;

    for trial = 1:length(trial_length)
        selection = times > trial_length(trial);

        shiftsNE(trial, selection) = NaN;
        shiftsNW(trial, selection) = NaN;
        shiftsSE(trial, selection) = NaN;
        shiftsSW(trial, selection) = NaN;
    end

    %% get relevant contrasts out
    saccade = [];
    saccade.time = times;
    sel = ones(size(cueL));
    saccade.label = {'target','opp_target','nontarget','opp_nontarget', 'target_axis', 'nontarget_axis', 'effect'};

    saccade.data(1,:) = (mean(shiftsSW(cueL&sel,:), "omitnan") + mean(shiftsSE(cueR&sel,:), "omitnan")) ./ 2;
    saccade.data(2,:) = (mean(shiftsNE(cueL&sel,:), "omitnan") + mean(shiftsNW(cueR&sel,:), "omitnan")) ./ 2;
    saccade.data(3,:) = (mean(shiftsSW(cueR&sel,:), "omitnan") + mean(shiftsSE(cueL&sel,:), "omitnan")) ./ 2;
    saccade.data(4,:) = (mean(shiftsNE(cueR&sel,:), "omitnan") + mean(shiftsNW(cueL&sel,:), "omitnan")) ./ 2;
    
    % add aggregated fields
    saccade.data(5,:) = (saccade.data(1,:) + saccade.data(2,:)) / 2;
    saccade.data(6,:) = (saccade.data(3,:) + saccade.data(4,:)) / 2;
    saccade.data(7,:) = (saccade.data(5,:) - saccade.data(6,:)) / 2;

    
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    
    for i = 1:size(saccade.label, 2)
        saccade.data(i,:,:) = smoothdata(saccade.data(i,:,:), 2, 'movmean', integrationwindow)*1000;
    end
       
    %% plot
    if plotResults
        figure; 
        hold on
        plot(saccade.time, saccade.data(1,:,:), 'r');
        plot(saccade.time, saccade.data(2,:,:), 'Color', [1, 0.5, 0.5]);
        plot(saccade.time, saccade.data(3,:,:), 'b');
        plot(saccade.time, saccade.data(4,:,:), 'Color', [0.5, 0.5, 1]);
        hold off

        figure;
        hold on
        plot(saccade.time, saccade.data(5,:,:), 'r');
        plot(saccade.time, saccade.data(6,:,:), 'b');
        hold off
        
        figure;
        plot(saccade.time, saccade.data(7,:,:), 'k');

        figure;
        hold on
        plot(saccade.time, saccade.data(1,:,:), 'r');
        plot(saccade.time, saccade.data(3,:,:), 'b');
        hold off
    end

    %% polar histogram
    % set shifts
    shifts = shiftsX+shiftsY*1i;
    for trial = 1:length(trial_length)
        selection = times > trial_length(trial);
        shifts(trial, selection) = NaN;
    end
    
    saccadedirection = [];
    saccadedirection.shiftsL = shifts(cueL, :);
    saccadedirection.shiftsR = shifts(cueR, :);
    saccadedirection.selectionL = abs(saccadedirection.shiftsL) > 0;
    saccadedirection.selectionR = abs(saccadedirection.shiftsR) > 0;

    if plotResults
        figure;
        subplot(2,2,1);
        polarhistogram(angle(saccadedirection.shiftsL(saccadedirection.selectionL)),20);
        subplot(2,2,2);
        polarhistogram(angle(saccadedirection.shiftsR(saccadedirection.selectionR)),20);
        subplot(2,2,3);
        histogram(abs(saccadedirection.shiftsL(saccadedirection.selectionL)));
        xlim([0 10]);
        subplot(2,2,4);
        histogram(abs(saccadedirection.shiftsR(saccadedirection.selectionR)));
        xlim([0 10]);
    end

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = times;
    saccadesize.label = saccade.label;

    c = 0;
    for sz = saccadesize.freq;
        c = c+1;
        
        shiftsNE = [];
        shiftsNW = [];
        shiftsSE = [];
        shiftsSW = [];

        saccadeswithinrange = (sqrt(shiftsX.^2 + shiftsY.^2) > sz-halfbin) & (sqrt(shiftsX.^2 + shiftsY.^2) < sz+halfbin);

        shiftsNE = double(shiftsX>0 & shiftsY>0 & saccadeswithinrange);
        shiftsNW = double(shiftsX<0 & shiftsY>0 & saccadeswithinrange);
        shiftsSE = double(shiftsX>0 & shiftsY<0 & saccadeswithinrange);
        shiftsSW = double(shiftsX<0 & shiftsY<0 & saccadeswithinrange);
        
        % NaN data after orientation change
        for trial = 1:length(trial_length)
            selection = times > trial_length(trial);
            shiftsNE(trial, selection) = NaN;
            shiftsNW(trial, selection) = NaN;
            shiftsSE(trial, selection) = NaN;
            shiftsSW(trial, selection) = NaN;
        end

        saccadesize.data(1,c,:) = (mean(shiftsSW(cueL,:), "omitnan") + mean(shiftsSE(cueR,:), "omitnan")) ./ 2;
        saccadesize.data(2,c,:) = (mean(shiftsNE(cueL,:), "omitnan") + mean(shiftsNW(cueR,:), "omitnan")) ./ 2;
        saccadesize.data(3,c,:) = (mean(shiftsSW(cueR,:), "omitnan") + mean(shiftsSE(cueL,:), "omitnan")) ./ 2;
        saccadesize.data(4,c,:) = (mean(shiftsNE(cueR,:), "omitnan") + mean(shiftsNW(cueL,:), "omitnan")) ./ 2;
        
        % add aggregated fields
        saccadesize.data(5,c,:) = (saccadesize.data(1,c,:) + saccadesize.data(2,c,:)) ./ 2;
        saccadesize.data(6,c,:) = (saccadesize.data(3,c,:) + saccadesize.data(4,c,:)) ./ 2;
        saccadesize.data(7,c,:) = (saccadesize.data(5,c,:) - saccadesize.data(6,c,:)) ./ 2;
    
    end
   
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
   
    for i = 1:size(saccade.label, 2)
        saccadesize.data(i,:,:) = smoothdata(saccadesize.data(i,:,:), 3, 'movmean', integrationwindow)*1000;
    end
    
    %% plot results
    if plotResults
        cfg = [];
        cfg.parameter = 'data';
        cfg.figure = 'gcf';
        cfg.zlim = 'maxabs';
        figure;
        for i = 1:size(saccade.label,2)
            subplot(2,4,i);
            cfg.channel = i;
            ft_singleplotTFR(cfg, saccadesize);
        end
        colormap('jet');
        drawnow;
    end

    %% save
    % depending on this option, append to name of saved file. 
    if remove_prematures == 1
        toadd1 = '_removePremature';
    else
        toadd1 = '';
    end    

    save([param.path, '\saved_data\saccadeEffects_4D', toadd1, '__', param.subjName], 'saccade', 'saccadedirection','saccadesize');

    %% close loops
end % end pp loop
