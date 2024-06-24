%% Step1--Trial epoch extraction

%% start clean
clear; clc; close all;

%% set loops
for pp      = [10:11];

    %% Set trig labels and epoch timings
    values2use  = 21:28; % cue onset
    prestim     = -0.5; % 
    poststim    = 3.2; % until 3 s after
    
    %% participant-specific information
    param = getSubjParam(pp); 
    disp(['getting data from ', param.subjName]);
    
    %% read header of asc file that contains all messages etc.
    hdr = ft_read_header([param.eds]);
    hdr.Fs = 1000;
    
    %% read in full dataset at once
    cfg = [];
    cfg.dataset = param.eds;
    cfg.hdr = hdr;
    eyedata = ft_preprocessing(cfg);
    
    %% nan blinks using function
    plotting = true;
    eyedata = frevede_nanBlinks_1eye(eyedata, hdr, plotting);
    
    %% epoch using custom code
    clear event;
    idx = 0;
    for t = 1:length((hdr.orig.msg))
        x = findstr(hdr.orig.msg{t}, 'trig'); % find timepoints label start with 'trig', find all trigs
        if x % whenever find the word 'trig' check what trig value it has, and what the data sample is, to epoch around.
            disp(['found trigger no. ' num2str(idx)]);
            idx = idx+1;
            event.label(idx) =  {[hdr.orig.msg{t}(x:end)]};
            event.timestamp(idx) = str2double([hdr.orig.msg{t}(4:x-1)]);
            
            % find closest possible sample to make sure to always have one...
            [a,b] = min(abs(hdr.orig.dat(1,:) - event.timestamp(idx)));
            event.sample(idx) = b;
        end
    end
    
    % get labels of triggers we wish to epoch around
    idx = 0;
    for v = values2use; 
        idx = idx+1;   
        lab2use(idx) = {['trig', num2str(v)]}; 
    end
    
    % get trl with begin sample, endsample, and offset
    trloi = match_str(event.label, lab2use); % trl of interest from all events
    soi = event.sample(trloi)'; % samples of interest, given trials of interest.
    trl_eye = [soi+prestim*hdr.Fs, soi+(poststim-0.001)*hdr.Fs, ones(length(soi),1)*prestim*hdr.Fs]; % determine startsample, endsample, and offset
    
    % re-define trial after trig & timerange selection
    cfg = [];
    cfg.trl = trl_eye;
    eyedata = ft_redefinetrial(cfg, eyedata);
    
    % get timepoints for each epoch
    trigval = [];
    for trl = 1:length(trloi)
        trigval(trl) = str2double(event.label{trloi(trl)}(5:end));
        eyedata.time{trl} = prestim:1/hdr.Fs:poststim-1/hdr.Fs; % for some reason timing was way off an inconsistent across pp, even though trl_eye looked fine. Hopefully this corrects it...
    end
    eyedata.trialinfo(:,1) = trigval';
    
    %% get to three channels
    % we only need x-axis, y-axis, & pupil from now on
    eyedata.label(2:4) = {'eyeX','eyeY','eyePupil'};
    
    % keep only relevant eye-data channels
    cfg = [];
    cfg.channel = {'eyeX','eyeY','eyePupil'};
    eyedata = ft_selectdata(cfg, eyedata);
    
    %% save data as function of pp name and eyedata session
    save([param.path, '\epoched_data\eyedata_AnnaMicro2','_'  param.subjName], 'eyedata');
    
    %% test plot
    % figure; 
    % subplot(2,2,1); plot(eyedata.time{1}, eyedata.trial{1}); legend(eyedata.label);
    % subplot(2,2,2); plot(eyedata.time{10}, eyedata.trial{10}); legend(eyedata.label);
    % subplot(2,2,3); plot(eyedata.time{100}, eyedata.trial{100}); legend(eyedata.label);
    % subplot(2,2,4); plot(eyedata.time{200}, eyedata.trial{200}); legend(eyedata.label); 
    % 
%% end loops
end % end of pp loop
