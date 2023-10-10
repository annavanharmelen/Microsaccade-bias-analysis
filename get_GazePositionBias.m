%% Step2--Gaze position calculation

%% start clean
clear; clc; close all;

%% parameters
for pp = [1:16];

baselineCorrect = 0; 
removeTrials    = 0; % remove trials where gaze deviation larger than value specified below. Only sensible after baseline correction!
max_x_pos       = 50; % remove trials with x_position bigger than 50 pixels (~1degree)???
plotResults     = 0;

%% load epoched data of this participant data
param = getSubjParam_AnnaVidi1(pp);
load([param.path, '\epoched_data\eyedata_AnnaVidi1','_'  param.subjName], 'eyedata');

%% optional: add relevant behavioural file data 

%% only keep channels of interest
cfg = [];
cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

%% reformat such that all data in single matrix of trial x channel x time
cfg = [];
cfg.keeptrials = 'yes';
tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?

% dirty hack to get proxy for blink rate
tl.blink = squeeze(isnan(tl.trial(:,1,:))*100); % 0 where not nan, 1 where nan (putative blink, or eye close etc.)... *100 to get to percentage of trials where blink at that time

%% baseline correct?
if baselineCorrect
    tsel = tl.time >= -.25 & tl.time <= 0; 
    bl = squeeze(mean(tl.trial(:,:,tsel),3));
    for t = 1:length(tl.time);
        tl.trial(:,:,t) = ((tl.trial(:,:,t) - bl));
    end
end

%% remove trials with gaze deviation >= 50 pixels
chX = ismember(tl.label, 'eyeX');
chY = ismember(tl.label, 'eyeY');

if plotResults
figure; plot(tl.time, squeeze(tl.trial(:,chX,:))); title('all trials - full time range');
end

if removeTrials
    tsel = tl.time>= 0 & tl.time <=1.5; % only check within this time range of interest
    figure; subplot(1,2,1); plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel))); title('before');
    for trl = 1:size(tl.trial,1)
        oktrial(trl) = sum(abs(tl.trial(trl,chX,tsel)) > max_x_pos)==0; % after baselining, no more deviation than XXX pixels... which is about 1 degree
    end
    tl.trial = tl.trial(oktrial,:,:);
    tl.trialinfo = tl.trialinfo(oktrial,:);
    subplot(1,2,2); plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel))); title('after');
    proportionOK(pp) = mean(oktrial)*100;
end

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

%% get relevant contrasts out
gaze = [];
gaze.time = tl.time * 1000;
gaze.label = {'all','congruent','neutral','incongruent','congruent-vs-incongruent'};

for selection = [1:4] % conditions.
    if     selection == 1  sel = ones(size(congruent))==1;
    elseif selection == 2  sel = congruent;
    elseif selection == 3  sel = neutral;
    elseif selection == 4  sel = incongruent;
    end
    gaze.dataL(selection,:) = squeeze(nanmean(tl.trial(sel&targL, chX,:)));
    gaze.dataR(selection,:) = squeeze(nanmean(tl.trial(sel&targR, chX,:)));
    gaze.blinkrate(selection,:) = squeeze(nanmean(tl.blink(sel, :)));
end

% add towardness field
gaze.towardness = (gaze.dataR - gaze.dataL) ./ 2;

% add congruent vs. incongruent (essentially: how much toward distractor)
gaze.dataL(end+1,:) = (gaze.dataL([2],:) - gaze.dataL([4],:)) ./ 2;
gaze.dataR(end+1,:) = (gaze.dataR([2],:) - gaze.dataR([4],:)) ./ 2;
gaze.towardness(end+1,:) = (gaze.towardness([2],:) - gaze.towardness([4],:)) ./ 2;
gaze.blinkrate(end+1,:) = (gaze.blinkrate([2],:) - gaze.blinkrate([4],:)) ./ 2;

%% plot
if plotResults
    figure;    for sp = 1:5 subplot(2,3,sp); hold on; plot(gaze.time, gaze.dataR(sp,:), 'r'); plot(gaze.time, gaze.dataL(sp,:), 'b'); title(gaze.label(sp)); legend({'R','L'},'autoupdate', 'off'); plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k');  end
    figure;    for sp = 1:5 subplot(2,3,sp); hold on; plot(gaze.time, gaze.towardness(sp,:), 'k'); plot(xlim, [0,0], '--k');          title(gaze.label(sp)); legend({'T'},'autoupdate', 'off'); plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k'); end
    figure;                                  hold on; plot(gaze.time, gaze.towardness([1:5],:)); plot(xlim, [0,0], '--k');            legend(gaze.label([1:5]),'autoupdate', 'off'); plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k'); 
    figure;                                  hold on; plot(gaze.time, gaze.blinkrate([1:5],:)); plot(xlim, [0,0], '--k');             legend(gaze.label([1:5]),'autoupdate', 'off'); plot([0,0], ylim, '--k');plot([1500,1500], ylim, '--k'); title('blinkrate');
end

%% save
if baselineCorrect == 1 toadd1 = '_baselineCorrect'; else toadd1 = ''; end; % depending on this option, append to name of saved file.    
if removeTrials == 1    toadd2 = '_removeTrials';    else toadd2 = ''; end; % depending on this option, append to name of saved file.    

save([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, '__', param.subjName], 'gaze');

drawnow; 

%% close loops
end % end pp loop


