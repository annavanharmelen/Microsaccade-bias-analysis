%% Script for doing stats on saccade and gaze bias data.
% So run those scripts first.
% by Anna, 04-07-2023
%% Saccade bias data - stats
statcfg.xax = saccade.time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

ft_size = 26;
timeframe = [451:1851]; %this is 0 to 1400 ms post-cue

data_cond1 = saccade_data(:,1,:);
data_cond2 = saccade_data(:,3,:);
data_cond3 = saccade_data(:,5,timeframe);
data_cond4 = zeros(size(data_cond3));

stat = frevede_ftclusterstat1D(statcfg, data_cond3, data_cond4)
% stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond4)
% stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, data_cond4)
%% Saccade bias data - plot only effect
mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure;
hold on
p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,5,:)), [0.6, 0.6, 0.6], 'se');
p1.LineWidth = 2.5;
sig = plot(saccade.time(timeframe), mask_xxx*-0.01, 'Color', 'k', 'LineWidth', 5); % verticaloffset for positioning of the "significance line"

fontsize(23, 'points')
xlim(xlimtoplot);
ylim([-0.02 0.06]);
yticks([0 0.05]);
plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylim, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
% legend([p7], 'effect', 'EdgeColor', 'w', 'Fontsize', 28);
ylabel('Saccade bias (ΔHz)', 'Fontsize', 28);
xlabel('Time (ms)', 'Fontsize', 28);
set(gcf,'position',[0,0, 1800,900])
xlabel('Time (ms)');
hold off

% set(gcf,'position',[0,0, 1800,900])
% fontsize(ft_size*1.5,"points")

%% Saccade bias data - plot both
mask1_xxx = double(stat1.mask);
mask1_xxx(mask1_xxx==0) = nan; % nan data that is not part of mark

mask2_xxx = double(stat2.mask);
mask2_xxx(mask2_xxx==0) = nan; % nan data that is not part of mark

figure; hold on;

p1 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,1,:)), bright_colours(1,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,3,:)), bright_colours(2,:), 'se');

p1.LineWidth = 3.5;
p2.LineWidth = 3.5;

% plot(xlim, [0,0], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], [-0.5, 1], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
xlim(xlimtoplot);

% sig1 = plot(saccade.time, mask1_xxx*0.02, 'Color', colours(1,:), 'LineWidth', 5); % verticaloffset for positioning of the "significance line"
% sig2 = plot(saccade.time, mask2_xxx*0.01, 'Color', colours(2,:), 'LineWidth', 5);

ylim([0 0.25]);
yticks([0.1 0.2]);
ylabel('Saccade bias (ΔHz)', 'Position', [-892.5697 0.1250 -1]);
xlabel('Time (ms)');
set(gcf,'position',[0,0, 2000,900])
fontsize(ft_size*1.5,"points")
legend([p1,p2], {'Target', 'Non-target'}, 'EdgeColor', 'w', 'Location', 'northeast');

