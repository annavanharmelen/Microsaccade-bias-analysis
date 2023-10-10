clear all
close all
clc

%% set parameters and loops
see_performance = 0;
display_percentageok = 1;
plot_individuals = 0;
plot_averages = 1;

pp2do = 1; 
p = 0;

[bar_size, colours, dark_colours, labels, percentageok, decisiontime, decisiontime_std, error, overall_dt, overall_error, ppnum] = setBehaviourParam(pp2do)

for pp = pp2do
p = p+1;

param = getSubjParam(pp);
disp(['getting data from ', param.subjName]);

%% load actual behavioural data
behdata = readtable(param.log);

%% basic data checks, each pp in own subplot
if plot_individuals
    figure(1); subplot(5,5,p); hist(behdata.response_time_in_ms(oktrials),50);            title(['response time - pp ', num2str(pp2do(p))]);  xlim([0 1500]);
    figure(2); subplot(5,5,p); hist(behdata.idle_reaction_time_in_ms(oktrials),50);       title(['decision time - pp ', num2str(pp2do(p))]);  
    figure(3); subplot(5,5,p); hist(behdata.idle_reaction_time_in_ms(oktrials),50);       title(['decision time - pp ', num2str(pp2do(p))]);  xlim([0 2000]);
    figure(4); subplot(5,5,p); hist(behdata.signed_difference(oktrials),50);              title(['signed error - pp ', num2str(pp2do(p))]);   xlim([-100 100]);
    figure(5); subplot(5,5,p); hist(behdata.absolute_difference(oktrials),50);            title(['error - pp ', num2str(pp2do(p))]);          xlim([0 100]);
end

%% trial selections
congruent_trials = ismember(behdata.trial_condition, {'congruent'});
neutral_trials = ismember(behdata.trial_condition, {'neutral'});
incongruent_trials = ismember(behdata.trial_condition, {'incongruent'});

%% mixture models of target error
% get non-target orientations
non_target_orientations = zeros(size(behdata.trial_number));
right_target_trials = find(strcmp(behdata.target_bar,'right'));
left_target_trials = find(strcmp(behdata.target_bar,'left'));
non_target_orientations(right_target_trials) = behdata.left_orientation(right_target_trials);
non_target_orientations(left_target_trials) = behdata.right_orientation(left_target_trials);

% turn all orientations to radians...
non_target_orientations = (non_target_orientations/90*pi);
behdata.report_orientation = behdata.report_orientation/90*pi;
behdata.target_orientation = behdata.target_orientation/90*pi;

% create model for each condition
conditions = [1 : size(labels, 2)];

for condition = conditions
    [B, LL] = mixtureFit(behdata.report_orientation(eval(sprintf('%s_trials', labels{condition}))&oktrials), behdata.target_orientation(eval(sprintf('%s_trials', labels{condition}))&oktrials), non_target_orientations(eval(sprintf('%s_trials', labels{condition}))&oktrials));
    precision(p, condition) = B(1);
    pT(p, condition) = B(2);
    pNT(p, condition) = B(3);
    pU(p, condition) = B(4);
end

%% extract data of interest
decisiontime(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&oktrials));
decisiontime(p,2) = mean(behdata.idle_reaction_time_in_ms(neutral_trials&oktrials));
decisiontime(p,3) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&oktrials));
decisiontime(p,4) = mean(behdata.idle_reaction_time_in_ms(oktrials));

decisiontime_std(p,1) = std(behdata.idle_reaction_time_in_ms(congruent_trials&oktrials));
decisiontime_std(p,2) = std(behdata.idle_reaction_time_in_ms(neutral_trials&oktrials));
decisiontime_std(p,3) = std(behdata.idle_reaction_time_in_ms(incongruent_trials&oktrials));
decisiontime_std(p,4) = std(behdata.idle_reaction_time_in_ms(oktrials));

error(p,1) = mean(behdata.absolute_difference(congruent_trials&oktrials));
error(p,2) = mean(behdata.absolute_difference(neutral_trials&oktrials));
error(p,3) = mean(behdata.absolute_difference(incongruent_trials&oktrials));
error(p,4) = mean(behdata.absolute_difference(oktrials));

overall_dt(p) = mean([behdata.idle_reaction_time_in_ms]);
overall_error(p) = mean([behdata.absolute_difference]);
ppnum(p) = pp;

decisiontimes_meansubtracted = decisiontime(:,1:3) - decisiontime(:, 4);
error_meansubtracted = error(:,1:3) - error(:, 4);

%% calculate capture effect on RT and error and save significance
[h, pvalue, ci, stats] = ttest2(behdata.idle_reaction_time_in_ms(congruent_trials&oktrials), behdata.idle_reaction_time_in_ms(incongruent_trials&oktrials));
capture_rt(p,1) = pvalue;
capture_rt(p,2) = h;
capture_rt(p,3) = decisiontime(p,3) - decisiontime(p,1);

[h, pvalue, ci, stats] = ttest2(behdata.absolute_difference(congruent_trials&oktrials), behdata.absolute_difference(incongruent_trials&oktrials));
capture_error(p,1) = pvalue;
capture_error(p,2) = h;
capture_error(p,3) = error(p,3) - error(p,1);

capture_effectsize(p, 1) = capture_rt(p,3);
capture_effectsize(p, 2) = capture_error(p,3);
%% calculate proportion of wrong-key uses
correct_key_trials = strcmp(behdata.correct_key, 'True');
wrong_key_trials = strcmp(behdata.correct_key, 'False');
different_key_trials = (behdata.right_orientation > 0) ~= (behdata.left_orientation > 0);

for condition = conditions
    total_correct(p, condition) = sum(different_key_trials&correct_key_trials&oktrials&eval(sprintf('%s_trials', labels{condition})));
    total_wrong(p, condition) = sum(different_key_trials&wrong_key_trials&oktrials&eval(sprintf('%s_trials', labels{condition})));
    proportion_correct(p, condition) = total_correct(p, condition)/sum(different_key_trials&oktrials&eval(sprintf('%s_trials', labels{condition})));
    proportion_wrong(p, condition) = total_wrong(p, condition)/sum(different_key_trials&oktrials&eval(sprintf('%s_trials', labels{condition})));
end

total_correct(p, 4) = sum(different_key_trials&correct_key_trials&oktrials);
total_wrong(p, 4) = sum(different_key_trials&wrong_key_trials&oktrials);
proportion_correct(p, 4) = total_correct(p, 4)/sum(different_key_trials&oktrials);
proportion_wrong(p, 4) = total_wrong(p, 4)/sum(different_key_trials&oktrials);

total_correct_capture(p, 1) = sum(different_key_trials&correct_key_trials&oktrials&congruent_trials);
total_correct_capture(p, 3) = sum(different_key_trials&wrong_key_trials&oktrials&incongruent_trials);
total_correct_capture(p, 4) = sum(different_key_trials&correct_key_trials&oktrials&congruent_trials) + sum(different_key_trials&wrong_key_trials&oktrials&incongruent_trials);
proportion_correct_capture(p, 1) = total_correct_capture(p, 1)/sum(different_key_trials&oktrials&congruent_trials);
proportion_correct_capture(p, 3) = total_correct_capture(p, 3)/sum(different_key_trials&oktrials&incongruent_trials);
proportion_correct_capture(p, 4) = total_correct_capture(p, 4)/sum(different_key_trials&oktrials);

%% plot
if plot_individuals
    figure(6); subplot(5,5,p); bar([1,2,3], decisiontime(p,1:3));  xticks([1,2,3]); xticklabels(labels); ylim([0 1300]); title(['decision time - pp', num2str(pp)]);
    figure(7); subplot(5,5,p); bar([1,2,3], error(p,1:3));         xticks([1,2,3]); xticklabels(labels); ylim([0 25]);    title(['error - pp', num2str(pp)]);
end
end

%% calculate relative effect sizes per pp
capture_effectsize(:,3) = (capture_effectsize(:,1)/max(capture_effectsize(:,1)) + capture_effectsize(:,2)/max(capture_effectsize(:,2))) / 2;

%% display percentage OK
if display_percentageok
    percentageok
end

%% all pp plot
if plot_averages

    figure; 
    subplot(3,1,1); bar(ppnum, overall_dt);     title('overall decision time'); ylim([0 900]);  xlabel('pp #');
    subplot(3,1,2); bar(ppnum, overall_error);  title('overall error');         ylim([0 25]);   xlabel('pp #');
    subplot(3,1,3); bar(ppnum, percentageok);  title('percentage ok trials');   ylim([90 100]); xlabel('pp #');
    
    %% grand average bar graphs of data as function of condition

    figure;  
    subplot(1,2,1); hold on;
    b1 = bar([1], [mean(decisiontime(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(decisiontime(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    b3 = bar([3], [mean(decisiontime(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:));
    title('Decision time')
    ylim([0 1300]);
    errorbar([1], [mean(decisiontime(:,1))],[std(decisiontime(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(decisiontime(:,2))],[std(decisiontime(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    errorbar([3], [mean(decisiontime(:,3))],[std(decisiontime(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(3,:));
    % for i = [1 : length(decisiontime)]
    %     plot([1,2,3], [decisiontime(:,1:3)]', '-o');
    % end
    plot([1,2,3], [decisiontime(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylabel('Decision time (ms)');
    set(gcf,'position',[0,0, 1080,1600])
    fontsize(23, "points");
    
    subplot(1,2,2); hold on;
    b1 = bar([1], [mean(error(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(error(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    b3 = bar([3], [mean(error(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:));
    errorbar([1], [mean(error(:,1))],[std(error(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(error(:,2))],[std(error(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    errorbar([3], [mean(error(:,3))],[std(error(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(3,:));    % for i = [1 : length(error)];
    %     plot([1,2,3], [error(:,1:3)]', '-o');
    % end
    title('Reproduction error')
    ylim([0 27])
    plot([1,2,3], [error(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylabel('Error (degrees)');
    fontsize(23, "points");
    
    %% grand average bar graphs of data as function of condition - with mean subtraction per participant
    figure;
    subplot(1,2,1); hold on;
    b1 = bar([1], [mean(decisiontimes_meansubtracted(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(decisiontimes_meansubtracted(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    b3 = bar([3], [mean(decisiontimes_meansubtracted(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:));
    errorbar([1], [mean(decisiontimes_meansubtracted(:,1))],[std(decisiontimes_meansubtracted(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(decisiontimes_meansubtracted(:,2))],[std(decisiontimes_meansubtracted(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    errorbar([3], [mean(decisiontimes_meansubtracted(:,3))],[std(decisiontimes_meansubtracted(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(3,:));
    % for i = [1 : length(decisiontimes_meansubtracted)]
    %     plot([1,2,3], [decisiontimes_meansubtracted(:,1:3)]', '-o');
    % end
    title('Decision time')
    plot([1,2,3], [decisiontimes_meansubtracted(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylim([-70 60]);
    ylabel('Decision time (ms)');
    set(gcf,'position',[0,0, 1080,1600])
    fontsize(23, "points");

    subplot(1,2,2); hold on;
    b1 = bar([1], [mean(error_meansubtracted(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(error_meansubtracted(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    b3 = bar([3], [mean(error_meansubtracted(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:));
    errorbar([1], [mean(error_meansubtracted(:,1))],[std(error_meansubtracted(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(error_meansubtracted(:,2))],[std(error_meansubtracted(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    errorbar([3], [mean(error_meansubtracted(:,3))],[std(error_meansubtracted(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(3,:));
    % for i = [1 : length(error_meansubtracted)]
    %     plot([1,2,3], [error_meansubtracted(:,1:3)]', '-o');
    % end
    title('Reproduction error')
    ylim([-2 2]);
    plot([1,2,3], [error_meansubtracted(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    ylabel('Error (degrees)');  
    fontsize(23, "points");

    %% grand average bar graphs for mixture model data
    figure;
    set(gcf,'position',[0,0, 1100,1600])

    % precision
    subplot(2,2,1); hold on;
    title('Precision');
    bar([1], [mean(precision(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:)); 
    bar([2], [mean(precision(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:)); 
    bar([3], [mean(precision(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:)); 
    errorbar([1], [mean(precision(:,1))], [std(precision(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(1,:));
    errorbar([2], [mean(precision(:,2))], [std(precision(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(2,:));
    errorbar([3], [mean(precision(:,3))], [std(precision(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(3,:));
    % for i = [1 : length(precision)]
    %     plot([1,2,3], [precision(:,1:3)]', '-o');
    % end
    plot([1,2,3], [precision(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    % yticklabels([0, 5, 10, 15], 'FontSize',10);
    y1 = ylabel('Precision (k)');
    xlim([0.2 3.8]);


    % pT
    subplot(2,2,2); hold on;
    title('Target response');
    bar([1], [mean(pT(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:)); 
    bar([2], [mean(pT(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:)); 
    bar([3], [mean(pT(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:)); 
    errorbar([1], [mean(pT(:,1))], [std(pT(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(1,:));
    errorbar([2], [mean(pT(:,2))], [std(pT(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7,'Color', dark_colours(2,:));
    errorbar([3], [mean(pT(:,3))], [std(pT(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(3,:));
    ylim([0.6 1]);
    % for i = [1 : length(pT)]
    %     plot([1,2,3], [pT(:,1:3)]', '-o');
    % end
    plot([1,2,3], [pT(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    y2 = ylabel('Probability');

    
    % pNT
    subplot(2,2,3); hold on;
    title('Non-target response');
    bar([1], [mean(pNT(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:)); 
    bar([2], [mean(pNT(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:)); 
    bar([3], [mean(pNT(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:)); 
    errorbar([1], [mean(pNT(:,1))], [std(pNT(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(1,:));
    errorbar([2], [mean(pNT(:,2))], [std(pNT(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(2,:));
    errorbar([3], [mean(pNT(:,3))], [std(pNT(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(3,:));
    ylim([0 0.2]);
    % for i = [1 : length(pNT)]
    %     plot([1,2,3], [pNT(:,1:3)]', '-o');
    % end
    plot([1,2,3], [pNT(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    y3 = ylabel('Probability');

    % pU
    subplot(2,2,4); hold on;
    title('Random response');
    bar([1], [mean(pU(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:)); 
    bar([2], [mean(pU(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:)); 
    bar([3], [mean(pU(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:)); 
    errorbar([1], [mean(pU(:,1))], [std(pU(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(1,:));
    errorbar([2], [mean(pU(:,2))], [std(pU(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(2,:));
    errorbar([3], [mean(pU(:,3))], [std(pU(:,3)) ./ sqrt(p)], 'LineWidth', 3, 'CapSize',7, 'Color', dark_colours(3,:));
    ylim([0 0.2]);
    % for i = [1 : length(pU)]
    %     plot([1,2,3], [pU(:,1:3)]', '-o');
    % end
    plot([1,2,3], [pU(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    y4 = ylabel('Probability');
    
    fontsize(27, "points");

    % y1.FontSize = 30;
    % y2.FontSize = 22;
    % y3.FontSize = 22;
    % y4.FontSize = 22;
    %% (grand) average bar graph for wrong-key uses
    % figure;
    % subplot(1,2,1); hold on;
    % bar([1,2,3], [mean(proportion_correct(:,1:3))], FaceColor='w');
    % title('Proportion of correct key presses'); ylim([0.7 1]);
    % errorbar([1,2,3], [mean(proportion_correct(:,1:3))], [std(proportion_correct(:,1:3)) ./ sqrt(p)], '.k', 'LineWidth', 2);
    % % for i = [1 : length(proportion_correct(:,1:3))]
    % %     plot([1,2,3], [proportion_correct(:,1:3)]', '-o');
    % % end
    % plot([1,2,3], [proportion_correct(:,1:3)]', 'Color', [0.5 0.5 0.5]);
    % xticks([1,2,3]); xticklabels(labels);
    % ylabel('Proportion correct key presses');
    % 
    
    figure;
    hold on;
    title('Incorrect key usage'); ylim([0 0.3]);
    bar([1], [mean(proportion_wrong(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:)); 
    bar([2], [mean(proportion_wrong(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:)); 
    bar([3], [mean(proportion_wrong(:,3))], bar_size, FaceColor=colours(3,:), EdgeColor=colours(3,:)); 
    errorbar([1], [mean(proportion_wrong(:,1))], [std(proportion_wrong(:,1)) ./ sqrt(p)], 'LineWidth', 4, 'CapSize',8, 'Color', dark_colours(1,:));
    errorbar([2], [mean(proportion_wrong(:,2))], [std(proportion_wrong(:,2)) ./ sqrt(p)], 'LineWidth', 4, 'CapSize',8, 'Color', dark_colours(2,:));
    errorbar([3], [mean(proportion_wrong(:,3))], [std(proportion_wrong(:,3)) ./ sqrt(p)], 'LineWidth', 4, 'CapSize',8, 'Color', dark_colours(3,:));
    % for i = [1 : length(proportion_wrong(:,1:3))]
    %     plot([1,2,3], [proportion_wrong(:,1:3)]', '-o');
    % end
    plot([1,2,3], [proportion_wrong(:,1:3)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    xticks([1,2,3]); xticklabels(labels);
    xlim([0.2 3.8]);
    set(gcf,'position',[0,0, 740,1600])
    fontsize(30, "points");
    ylabel('Proportion of wrong key presses');

end

%% see performance per block (for fun for participants)
if see_performance
    x = (1:16);
    block_performance = zeros(1, length(x));
    block_performance_std = zeros(1, length(x));
    block_speed = zeros(1, length(x));
    block_speed_std = zeros(1, length(x));
    
    for i = x
        block_performance(i) = mean(behdata.performance(behdata.block == i));
        block_performance_std(i) = std(behdata.performance(behdata.block == i));
        block_speed(i) = mean(behdata.idle_reaction_time_in_ms(behdata.block == i));
        block_speed_std(i) = std(behdata.idle_reaction_time_in_ms(behdata.block == i));
    end
    
    figure;
    hold on
    plot(block_performance)
    %errorbar(block_performance, block_performance_std)
    ylim([50 100])
    xlim([1 16])
    ylabel('Performance score')
    yyaxis right
    plot(block_speed)
    %errorbar(block_speed, block_speed_std)
    ylim([100 2000])
    ylabel('Reaction time (ms)')
    xlabel('Block number')
    xticks(x)
end
