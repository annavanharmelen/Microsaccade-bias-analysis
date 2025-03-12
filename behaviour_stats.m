%% Bar stats
[h,p,i,stats] = ttest(reaction_time_validity(:,1), reaction_time_validity(:,2))
[h,p,i,stats] = ttest(error_validity(:,1), error_validity(:,2))

%% SOA stats
statcfg.xax = trial_lengths;
statcfg.npermutations = 1000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = 24;
statcfg.statMethod = 'analytic';

data_cond1 = accuracy_per_soa_valid;
data_cond2 = accuracy_per_soa_invalid;
data_cond3 = reaction_time_per_soa_valid;
data_cond4 = reaction_time_per_soa_invalid;

stat_a = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)
stat_r = frevede_ftclusterstat1D(statcfg, data_cond3, data_cond4)

%% Correlational analysis
rt_effect = reaction_time_validity(:,1) - reaction_time_validity(:,2);
acc_effect = error_validity(:,1) - error_validity(:,2);

z_rt = zscore(rt_effect);
z_acc = zscore(acc_effect);

z_beh = z_acc - z_rt;

datamat = [avg_saccade_effect, rt_effect, acc_effect, z_beh];
labels = {'shift saccades', 'sustain saccades', 'total saccade effect', 'dt effect', 'accuracy effect', 'behaviour effect'};
frevede_allbyall_correlations_new(datamat, labels)

%% Make correlation plot
figure;
hold on
scatter(-rt_effect, avg_saccade_effect(:,1), 100, 'k', 'filled');
l1 = lsline;
l1.LineWidth = 2.5;
l1.Color = [0.6, 0.6, 0.6];
xlim([-30 600]);
ylim([-0.02 0.1]);
plot([0,0], ylim, '--', 'Color', [0.6, 0.6, 0.6], 'LineWidth', 2);
plot(xlim, [0,0], '--', 'Color', [0.6, 0.6, 0.6], 'LineWidth', 2);
xticks([0 600]);
yticks([0 0.1]);
xlabel('RT benefit (ms)');
ylabel('Saccade bias (ΔHz)');
fontsize(39, 'points');
set(gcf,'position',[0,0, 850, 800]);

figure;
hold on
scatter(acc_effect*100, avg_saccade_effect(:,1), 100, 'k', 'filled');
l2 = lsline;
l2.LineWidth = 2.5;
l2.Color = [0.6, 0.6, 0.6];
ylim([-0.02 0.1]);
xlim([-6, 32]);
plot([0,0], ylim, '--', 'Color', [0.6, 0.6, 0.6], 'LineWidth', 2);
plot(xlim, [0,0], '--', 'Color', [0.6, 0.6, 0.6], 'LineWidth', 2);
xticks([0 30]);
yticks([0 0.1]);
xlabel('Accuracy effect (%)');
ylabel('Saccade bias (ΔHz)');
fontsize(39, 'points');
set(gcf,'position',[0,0, 850, 800]);

%% Correlation stats
[r, p] = corr(-rt_effect, avg_saccade_effect(:,3));
disp(['Pearson, RT: ', sprintf('r=%f ', r), sprintf('p=%f', p)]);

[r, p] = corr(acc_effect, avg_saccade_effect(:,3));
disp(['Pearson, ACC: ', sprintf('r=%f ', r), sprintf('p=%f', p)]);

[r, p] = corr(rt_effect, avg_saccade_effect(:,3), 'Type', 'Spearman');
disp(['Spearman, RT: ', sprintf('r=%f ', r), sprintf('p=%f', p)]);

[r, p] = corr(acc_effect, avg_saccade_effect(:,3), 'Type', 'Spearman');
disp(['Spearman, ACC: ', sprintf('r=%f ', r), sprintf('p=%f', p)]);
