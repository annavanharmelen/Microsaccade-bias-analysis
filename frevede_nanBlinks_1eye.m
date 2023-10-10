function [data_out] = frevede_nanBlinks_1eye(edata, hdr, plotting)

%% find blinks
signal2findblinkson = abs(squeeze(edata.trial{1}([3],:))); % eyeY
blinks = signal2findblinkson==0;
onsets = find(diff(blinks) == 1);
offsets = find(diff(blinks) == -1);

if plotting
    tsel1 = edata.time{1} >= 0 & edata.time{1} <= 50; % just for plotting...
    figure;    subplot(2,1,1); hold on;    plot(edata.time{1}(tsel1), squeeze(edata.trial{1}([2,3],tsel1)));    ylim2keep1 = ylim; title('before');
end

%% make sure onset and offset same length and make sense.
while onsets(1) > offsets(1)     offsets(1) = []; end
nonsets = length(onsets);   if length(offsets) > length(onsets)     offsets = offsets(1:nonsets); end
noffsets = length(offsets); if length(onsets)  > length(offsets)    onsets  = onsets(1:noffsets); end

nsamp2corr = 100; % xx samples on either side of detected starting/ending point

% dont consider onsets and offsets too close to edge of trial, so that no samples left to remove on either side
torem = onsets<=nsamp2corr | onsets>= hdr.nSamples-nsamp2corr | offsets<=nsamp2corr | offsets>= hdr.nSamples-nsamp2corr;
onsets(torem) = []; offsets(torem) = [];

%% nan data
for x = 1:length(onsets);
    disp(['nanning data surrounding blink ' num2str(x) ' out of ', num2str(length(onsets))])
    for ch = 2:4
        n = length(onsets(x)-nsamp2corr:offsets(x)+nsamp2corr);
        edata.trial{1}(ch,onsets(x)-nsamp2corr:offsets(x)+nsamp2corr) = nan(1,n);
    end
end

if plotting     subplot(2,1,2); hold on; ylim(ylim2keep1);  plot(edata.time{1}(tsel1), squeeze(edata.trial{1}([2,3],tsel1))); ylim(ylim2keep1); title('after'); drawnow; end

data_out = edata;

