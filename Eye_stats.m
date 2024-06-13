%% Script for doing stats on saccade and gaze bias data.
% So run those scripts first.
% by Anna, 04-07-2023
%% Saccade bias data - stats
statcfg.xax = saccade.time;
statcfg.npermutations = 1000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

ft_size = 26;

data_cond1 = saccade_data(:,1,:);
data_cond2 = saccade_data(:,3,:);
data_cond4 = zeros(size(data_cond1));

stat = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)
stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond4)
stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, data_cond4)
%% Saccade bias data - plot only effect
mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure; hold on;
ylimit = [-0.02, 0.06];

p3 = frevede_errorbarplot(saccade.time, squeeze(saccade_data(:,7,:)), [0.6, 0.6, 0.6], 'se');
p3.LineWidth = 3.5;


% p3 = frevede_errorbarplot(saccade.time(1:651), squeeze(saccade_data(:,7,1:651)), [0.6, 0.6, 0.6], 'se');
% p3.LineWidth = 3.5;
% p3 = frevede_errorbarplot(saccade.time(1051:1451), squeeze(saccade_data(:,7,1051:1451)), [0.6, 0.6, 0.6], 'se');
% p3.LineWidth = 3.5;
% p3 = frevede_errorbarplot(saccade.time(3451:end), squeeze(saccade_data(:,7,3451:end)), [0.6, 0.6, 0.6], 'se');
% p3.LineWidth = 3.5;
% p3 = frevede_errorbarplot(saccade.time(651:1051), squeeze(saccade_data(:,7,651:1051)), bright_colours(3,:), 'se');
% p3.LineWidth = 3.5;
% p3 = frevede_errorbarplot(saccade.time(1451:3451), squeeze(saccade_data(:,7,1451:3451)), bright_colours(4,:), 'se');
% p3.LineWidth = 3.5;

plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylimit, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
% plot([200,200], ylimit, '--', 'LineWidth',4, 'Color', bright_colours(3,:));
% plot([600,600], ylimit, '--', 'LineWidth',4, 'Color', bright_colours(3,:));
% plot([1000,1000], ylimit, '--', 'LineWidth',4, 'Color', bright_colours(4,:));
% plot([3000,3000], ylimit, '--', 'LineWidth',4, 'Color', bright_colours(4,:));
% 

xlim(xlimtoplot);
sig = plot(saccade.time, mask_xxx*-0.01, 'Color', 'k', 'LineWidth', 5); % verticaloffset for positioning of the "significance line"
% ylim(ylimit+[0 0.0001]);
ylabel('Saccade bias (ΔHz)', 'Position', [-892.5697 0.0200 -1]);
xlabel('Time (ms)');
% xticks([200 600 1000 3000])
yticks([0 0.05]);
set(gcf,'position',[0,0, 1800,900])
fontsize(ft_size*1.5,"points")
% legend([p1,p2,p3], saccade.label(2:4));

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

