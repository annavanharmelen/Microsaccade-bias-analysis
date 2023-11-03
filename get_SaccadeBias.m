%% Step3-- gaze-shift calculation

%% start clea
clear; clc; close all;

%% parameter
oneOrTwoD       = 2; oneOrTwoD_options = {'_1D','_2D'};
plotResults     = 1;

for pp = [1:14];

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

    if oneOrTwoD == 1
        [shiftsX, velocity, times] = PBlab_gazepos2shift_1D(cfg, data_input(:,chX,:), time_input);
    elseif oneOrTwoD == 2
        [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    end

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    if oneOrTwoD == 1
        saccadesizes = abs(shiftsX);
        
        shiftsL = double(shiftsX<0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
        shiftsR = double(shiftsX>0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
   
    elseif oneOrTwoD == 2
        saccadesizes = abs(shiftsX+shiftsY*1i);
    
        shiftsNE = double(shiftsX>0 & shiftsY>0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
        shiftsNW = double(shiftsX<0 & shiftsY>0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
        shiftsSE = double(shiftsX>0 & shiftsY<0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
        shiftsSW = double(shiftsX<0 & shiftsY<0 & (saccadesizes>minDisplacement & saccadesizes<maxDisplacement));
    
    end

    %% turn post-change data to NaN
    behdata = readtable(param.log);
    trial_length = behdata.static_duration;

    for trial = 1:length(trial_length)
        selection = times > trial_length(trial);

        if oneOrTwoD == 1
            shiftsL(trial, selection) = NaN;
            shiftsR(trial, selection) = NaN;
        
        elseif  oneOrTwoD == 2
            shiftsNE(trial, selection) = NaN;
            shiftsNW(trial, selection) = NaN;
            shiftsSE(trial, selection) = NaN;
            shiftsSW(trial, selection) = NaN;
        
        end
    end

    %% get relevant contrasts out
    if oneOrTwoD == 1
        saccade = [];
        saccade.time = times;
        saccade.label = {'all','valid','invalid','valid-invalid'};
    
        for selection = [1:3] % conditions.
            if     selection == 1
                sel = ones(size(cueL));
            elseif selection == 2
                sel = valid;
            elseif selection == 3
                sel = invalid;
            end
    
            saccade.toward(selection,:) =  (mean(shiftsL(cueL&sel,:), "omitnan") + mean(shiftsR(cueR&sel,:), "omitnan")) ./ 2;
            saccade.away(selection,:)  =   (mean(shiftsL(cueR&sel,:), "omitnan") + mean(shiftsR(cueL&sel,:), "omitnan")) ./ 2;
                
        end
    
    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);

    % add valid vs. invalid (essentially: how much toward distractor)
    saccade.toward(end+1,:) = (saccade.toward([2],:) - saccade.toward([3],:)) ./ 2;
    saccade.away(end+1,:)   = (saccade.away([2],:)   - saccade.away([3],:)) ./ 2;
    saccade.effect(end+1,:) = (saccade.effect([2],:) - saccade.effect([3],:)) ./ 2;
    
    end

    if oneOrTwoD == 2
        saccade = [];
        saccade.time = times;
        sel = ones(size(cueL));

        saccade.target = (mean(shiftsSW(cueL&sel,:), "omitnan") + mean(shiftsSE(cueR&sel,:), "omitnan")) ./ 2;
        saccade.opp_target = (mean(shiftsNE(cueL&sel,:), "omitnan") + mean(shiftsNW(cueR&sel,:), "omitnan")) ./ 2;
        saccade.nontarget = (mean(shiftsSW(cueR&sel,:), "omitnan") + mean(shiftsSE(cueL&sel,:), "omitnan")) ./ 2;
        saccade.opp_nontarget = (mean(shiftsNE(cueR&sel,:), "omitnan") + mean(shiftsNW(cueL&sel,:), "omitnan")) ./ 2;
        
        % add aggregated fields
        saccade.target_axis = (saccade.target + saccade.opp_target) / 2;
        saccade.nontarget_axis = (saccade.nontarget + saccade.opp_nontarget) / 2;
        saccade.effect = (saccade.target_axis - saccade.nontarget_axis) / 2;
    
    end
    
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    
    if oneOrTwoD == 1
        saccade.toward = smoothdata(saccade.toward, 2,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
        saccade.away   = smoothdata(saccade.away,   2,'movmean',integrationwindow)*1000;
        saccade.effect = smoothdata(saccade.effect, 2,'movmean',integrationwindow)*1000;
    
    elseif oneOrTwoD == 2
        saccade.target          = smoothdata(saccade.target,        2,'movmean',integrationwindow)*1000;
        saccade.opp_target      = smoothdata(saccade.opp_target,    2,'movmean',integrationwindow)*1000;
        saccade.nontarget       = smoothdata(saccade.nontarget,     2,'movmean',integrationwindow)*1000;
        saccade.opp_nontarget   = smoothdata(saccade.opp_nontarget, 2,'movmean',integrationwindow)*1000;
        saccade.target_axis     = smoothdata(saccade.target_axis,   2,'movmean',integrationwindow)*1000;
        saccade.nontarget_axis  = smoothdata(saccade.nontarget_axis,2,'movmean',integrationwindow)*1000;
        saccade.effect          = smoothdata(saccade.effect,        2,'movmean',integrationwindow)*1000;
    
    end

    %% plot
    if plotResults
        if oneOrTwoD == 1
            figure;
            for sp = 1:3
                subplot(2,3,sp);
                hold on
                plot(saccade.time, saccade.toward(sp,:), 'r');
                plot(saccade.time, saccade.away(sp,:), 'b');
                
                title(saccade.label(sp));
                legend({'toward','away'},'autoupdate', 'off');
                plot([0,0], ylim, '--k');
                plot([1500,1500], ylim, '--k');
            end
    
            figure;   
                for sp = 1:3 subplot(2,3,sp);
                    hold on
                    plot(saccade.time, saccade.effect(sp,:), 'k')
                    plot(xlim, [0,0], '--k');
                    title(saccade.label(sp));
                    legend({'effect'},'autoupdate', 'off');
                    plot([0,0], ylim, '--k');
                    plot([1500,1500], ylim, '--k');
                end
    
            figure;
            hold on
            plot(saccade.time, saccade.effect([1:3],:));
            plot(xlim, [0,0], '--k');
            legend(saccade.label([1:4]),'autoupdate', 'off');
            plot([0,0], ylim, '--k');
            plot([1500,1500], ylim, '--k');
            drawnow;
        
        elseif oneOrTwoD == 2
            figure; 
            hold on
            plot(saccade.time, saccade.target, 'r');
            plot(saccade.time, saccade.opp_target, 'Color', [1, 0.5, 0.5]);
            plot(saccade.time, saccade.nontarget, 'b');
            plot(saccade.time, saccade.opp_nontarget, 'Color', [0.5, 0.5, 1]);
            hold off

            figure;
            hold on
            plot(saccade.time, saccade.target_axis, 'r');
            plot(saccade.time, saccade.nontarget_axis, 'b');
            hold off
            
            figure;
            plot(saccade.time, saccade.effect, 'k');

            figure;
            hold on
            plot(saccade.time, saccade.target, 'r');
            plot(saccade.time, saccade.nontarget, 'b');
            hold off
        
        end

    end

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = times;
    saccadesize.label = {'all'};

    cnt = 0;
    for sz = saccadesize.freq;
        cnt = cnt+1;
        if oneOrTwoD == 1
            shiftsL = [];
            shiftsR = [];
            shiftsL = double(shiftsX<-sz+halfbin & shiftsX > -sz-halfbin); % left shifts within this range
            shiftsR = double(shiftsX>sz-halfbin  & shiftsX < sz+halfbin); % right shifts within this range
            
            % NaN data after orientation change
            for trial = 1:length(trial_length)
                selection = times > trial_length(trial);
                shiftsL(trial, selection) = NaN;
                shiftsR(trial, selection) = NaN;
            end
    
           for selection = [1:3] % conditions.
                if selection == 1
                    sel = ones(size(valid));
                elseif selection == 2
                    sel = valid;
                elseif selection == 3
                    sel = invalid;
                end
    
                saccadesize.toward(selection,cnt,:) = (mean(shiftsL(cueL&sel,:), "omitnan") + mean(shiftsR(cueR&sel,:), "omitnan")) ./ 2;
                saccadesize.away(selection,cnt,:) =   (mean(shiftsL(cueR&sel,:), "omitnan") + mean(shiftsR(cueL&sel,:), "omitnan")) ./ 2
            
           end

            % add towardness field
            saccadesize.effect = (saccadesize.toward - saccadesize.away);
            
            % add congruent vs. incongruent (essentially: how much toward distractor)
            saccadesize.toward(end+1,:,:) = (saccadesize.toward([2],:,:) - saccadesize.toward([3],:,:)) ./ 2;
            saccadesize.away(end+1,:,:)   = (saccadesize.away([2],:,:)   - saccadesize.away([3],:,:)) ./ 2;
            saccadesize.effect(end+1,:,:) = (saccadesize.effect([2],:,:) - saccadesize.effect([3],:,:)) ./ 2;
 
        elseif oneOrTwoD == 2
            shiftsNE = [];
            shiftsNW = [];
            shiftsSE = [];
            shiftsSW = [];

            saccadeswithinrange = (sqrt(shiftsX.^2 + shiftsY.^2) > sz-halfbin) & (sqrt(shiftsX.^2 + shiftsY.^2) < sz+halfbin);
            nsacc(cnt) = sum(sum(saccadeswithinrange));
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

            sel = ones(size(cueL));
    
            saccadesize.target(1,cnt,:) = (mean(shiftsSW(cueL&sel,:), "omitnan") + mean(shiftsSE(cueR&sel,:), "omitnan")) ./ 2;
            saccadesize.opp_target(1,cnt,:) = (mean(shiftsNE(cueL&sel,:), "omitnan") + mean(shiftsNW(cueR&sel,:), "omitnan")) ./ 2;
            saccadesize.nontarget(1,cnt,:) = (mean(shiftsSW(cueR&sel,:), "omitnan") + mean(shiftsSE(cueL&sel,:), "omitnan")) ./ 2;
            saccadesize.opp_nontarget(1,cnt,:) = (mean(shiftsNE(cueR&sel,:), "omitnan") + mean(shiftsNW(cueL&sel,:), "omitnan")) ./ 2;
            
            % add aggregated fields
            saccadesize.target_axis(1,cnt,:) = (saccadesize.target(1,cnt,:) + saccadesize.opp_target(1,cnt,:)) ./ 2;
            saccadesize.nontarget_axis(1,cnt,:) = (saccadesize.nontarget(1,cnt,:) + saccadesize.opp_nontarget(1,cnt,:)) ./ 2;
            saccadesize.effect(1,cnt,:) = (saccadesize.target_axis(1,cnt,:) - saccadesize.nontarget_axis(1,cnt,:)) ./ 2;
        
        
        end

    end
   
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    if oneOrTwoD == 1
        saccadesize.toward = smoothdata(saccadesize.toward,3,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
        saccadesize.away   = smoothdata(saccadesize.away,3,  'movmean',integrationwindow)*1000;
        saccadesize.effect = smoothdata(saccadesize.effect,3,'movmean',integrationwindow)*1000;
    
    elseif oneOrTwoD == 2
        saccadesize.target          = smoothdata(saccadesize.target,        3,'movmean',integrationwindow)*1000;
        saccadesize.opp_target      = smoothdata(saccadesize.opp_target,    3,'movmean',integrationwindow)*1000;
        saccadesize.nontarget       = smoothdata(saccadesize.nontarget,     3,'movmean',integrationwindow)*1000;
        saccadesize.opp_nontarget   = smoothdata(saccadesize.opp_nontarget, 3,'movmean',integrationwindow)*1000;
        saccadesize.target_axis     = smoothdata(saccadesize.target_axis,   3,'movmean',integrationwindow)*1000;
        saccadesize.nontarget_axis  = smoothdata(saccadesize.nontarget_axis,3,'movmean',integrationwindow)*1000;
        saccadesize.effect          = smoothdata(saccadesize.effect,        3,'movmean',integrationwindow)*1000;
    
    end

    if plotResults
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = 'maxabs';
        figure;
        if oneOrTwoD == 1
            for chan = 1:3
                cfg.channel = chan;
                subplot(2,3,chan);
                ft_singleplotTFR(cfg, saccadesize);
            end
        elseif oneOrTwoD == 2
            cfg.channel = 1;
            ft_singleplotTFR(cfg, saccadesize);
        end
        colormap('jet');
        drawnow;
    end

    %% save
    save([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');

    %% close loops
end % end pp loop
