clear all
close all
clc

%% set parameters and loops
display_percentage_premature = 0;
display_percentage_unbroken = 1;
plot_individuals = 0;
plot_averages = 1;

pp2do = [2:25, 1:2,5:9,11,13:24, 26:29];
xlabels = string(pp2do);
xlabels(1:24) = append(xlabels(1:24), " E1");
xlabels(25:end) = append(xlabels(25:end), " E2");
p = 0;


[bar_size, bright_colours, colours, light_colours, SOA_colours, dark_colours, subplot_size, labels, percentageok, overall_dt, overall_error] = setBehaviourParam(pp2do);
orientation_bins = [-85:16:-5, 5:16:85];
trial_lengths = 500:300:3200;

missed_trial_lengths = zeros(size(pp2do, 2), size(trial_lengths, 2));
trial_orientations = zeros(size(pp2do, 2), (size(orientation_bins, 2) - 1));
missed_orientations = zeros(size(pp2do, 2), (size(orientation_bins, 2) - 1));

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    figure_nr = 1;
    figure_nr =  figure_nr+5;
    
    if p <=24
        param = getSubjParam1(pp);
        experiment = 'M1';
    else
        param = getSubjParam2(pp);
        experiment = 'M2';
    end

    disp(['getting data from ', param.subjName, ' - ', experiment]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);
    
    %% display percentage prematurely pressed trials
    if display_percentage_premature
        fprintf('%s has %.2f%% premature responses\n\n', param.subjName, nanmean(ismember(behdata.premature_pressed, {'True'}))*100)
    end

    %% check unbroken trials
    if p <=24
        oktrials = ones(size(behdata,1),1);
        
    else
        oktrials = ismember(behdata.broke_fixation, {'False'});
    
        % select trials broken after target change
        also_oktrials = ismember(behdata.exit_stage, {'orientation_change'});
        
        % save percentage
        percentageok(p,1) = (sum(oktrials+also_oktrials) / max(behdata.trial_number))*100;
        
        % save oktrials
        oktrials = logical(oktrials + also_oktrials);
    end

    % display percentage unbroken trials
    if display_percentage_unbroken
        fprintf('%s has %.2f%% unbroken trials\n\n', param.subjName, percentageok(p,1))
    end
    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        
        h = histogram(behdata.response_time_in_ms, 50, 'FaceColor', [192, 192, 192]/255);
        
        title(['response time - pp ', num2str(pp2do(p))]);
        ylim([0 150]);
        xlim([0 2010]);
    end
    
    %% trial selections
    valid_trials = ismember(behdata.trial_condition, {'valid'});
    invalid_trials = ismember(behdata.trial_condition, {'invalid'});
    
    correct_trials = ismember(behdata.feedback, {'correct'});
    incorrect_trials = ismember(behdata.feedback, {'incorrect'});
    missed_trials = ismember(behdata.feedback, {'missed'});
    
    blue_target_trials = ismember(behdata.target_colour, {'[-0.8515625, 0.140625, 0.609375]'});
    green_target_trials = ismember(behdata.target_colour, {'[-0.2109375, 0.15625, -0.890625]'});
    orange_target_trials = ismember(behdata.target_colour, {'[0.859375, -0.1875, -0.53125]'});
    pink_target_trials = ismember(behdata.target_colour, {'[0.6953125, -0.1953125, 0.8828125]'});
    
    clockwise_trials = ismember(behdata.change_direction, {'clockwise'});
    anticlockwise_trials = ismember(behdata.change_direction, {'anticlockwise'});
    
    left_trials = ismember(behdata.target_bar, {'left'});
    right_trials = ismember(behdata.target_bar, {'right'});
    
    
    %% extract data of interest
    overall_dt(p,1) = nanmean(behdata.response_time_in_ms(oktrials));
    overall_error(p,1) = sum(ismember(behdata.feedback, 'correct')&oktrials) / sum(oktrials);

    labels = {'valid','invalid'};
    
    reaction_time_validity(p,1) = nanmean(behdata.response_time_in_ms(valid_trials));
    reaction_time_validity(p,2) = nanmean(behdata.response_time_in_ms(invalid_trials));
    
    error_validity(p,1)      = nanmean(correct_trials(valid_trials));
    error_validity(p,2)      = nanmean(correct_trials(invalid_trials));
        
    %% get reaction time as function of SOA
    for i = 1:size(trial_lengths, 2)
        reaction_time_per_soa_valid(p,i) = nanmean(behdata.response_time_in_ms(valid_trials&behdata.static_duration==trial_lengths(i)));
        reaction_time_per_soa_invalid(p,i) = nanmean(behdata.response_time_in_ms(invalid_trials&behdata.static_duration==trial_lengths(i)));
    end
    
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        
        hold on
        plot(trial_lengths, reaction_time_per_soa_valid(p,:), 'Color', bright_colours(1,:), 'LineWidth', 1.5);
        plot(trial_lengths, reaction_time_per_soa_invalid(p,:), 'Color', bright_colours(2,:), 'LineWidth', 1.5);
        hold off
        
        title([num2str(pp2do(p))]);
        ylim([400 1700]);
        xlim([min(trial_lengths) max(trial_lengths)]);
        xticks(trial_lengths);
        xlabel('SOA (ms)');
        ylabel('Response time (ms)');
    end
    % legend(labels);
    
    
    %% get accuracy as function of SOA
    for i = 1:size(trial_lengths, 2)
        accuracy_per_soa_valid(p,i) = nanmean(correct_trials(valid_trials&behdata.static_duration==trial_lengths(i)));
        accuracy_per_soa_invalid(p,i) = nanmean(correct_trials(invalid_trials&behdata.static_duration==trial_lengths(i)));
    end
    
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        
        hold on
        plot(trial_lengths, accuracy_per_soa_valid(p,:), 'Color', bright_colours(1,:), 'LineWidth', 1.5);
        plot(trial_lengths, accuracy_per_soa_invalid(p,:), 'Color', bright_colours(2,:), 'LineWidth', 1.5);
        hold off
        
        title([num2str(pp2do(p))]);
        ylim([0.2 1]);
        xlim([min(trial_lengths) max(trial_lengths)]);
        xticks(trial_lengths);
        xlabel('SOA (ms)');
        ylabel('Accuracy');
    end
    % legend(labels);
    
    
end

if plot_averages
 %% check performance
    figure; 
    subplot(3,1,1);
    bar(xlabels, overall_dt(:,1));
    title('overall decision time');
    % ylim([0 900]);
    xlabel('pp #');

    subplot(3,1,2);
    bar(xlabels, overall_error(:,1));
    title('overall accuracy');
    line([1 48], [0.5 0.5])
    ylim([0.2 1]);
    xlabel('pp #');

    subplot(3,1,3);
    bar(xlabels, percentageok);
    title('percentage ok trials');
    % ylim([90 100]);
    xlabel('pp #');

%% show grand average line graphs of data as function of SOA

    figure(figure_nr)
    figure_nr = figure_nr+1;
    % subplot(1,2,2);
    hold on
    
    l1 = plot(trial_lengths, nanmean(reaction_time_per_soa_valid), 'Color', bright_colours(1,:), 'LineWidth', 3.5, 'Marker', 'o', 'MarkerFaceColor', bright_colours(1,:));
    p1 = frevede_errorbarplot(trial_lengths, reaction_time_per_soa_valid, bright_colours(1,:), 'se');
    l2 = plot(trial_lengths, nanmean(reaction_time_per_soa_invalid), 'Color', bright_colours(2,:), 'LineWidth', 3.5, 'Marker', 'o', 'MarkerFaceColor', bright_colours(2,:));
    p2 = frevede_errorbarplot(trial_lengths, reaction_time_per_soa_invalid, bright_colours(2,:), 'se');
    
    
    if exist('stat_r') == 1
        invalid = nanmean(reaction_time_per_soa_invalid)
        valid = nanmean(reaction_time_per_soa_valid)
        
        for X = trial_lengths(stat_r.mask)
            Y = find(trial_lengths == X);
            plot([X X], [valid(Y) invalid(Y)], '--', 'Color', 'k', 'LineWidth', 2.5)
        end
    end
    
    legend([l1, l2], labels, 'EdgeColor', 'w');
    ylim([500 1500]);
    ylabel('Time (ms)');
    xlabel('SOA (ms)');
    yticks([500 1000 1500]);
    xticks([500 1400 2300 3200]);
    xlim([min(trial_lengths) max(trial_lengths)]);
    fontsize(30, "points");
    % set(gcf,'position',[0,0, 700,1080])
    
    figure;
    % subplot(1,2,2);
    hold on
    
    l3 = plot(trial_lengths, nanmean(accuracy_per_soa_valid)*100, 'Color', bright_colours(1,:), 'LineWidth', 3.5, 'Marker', 'o', 'MarkerFaceColor', bright_colours(1,:));
    p3 = frevede_errorbarplot(trial_lengths, accuracy_per_soa_valid*100, bright_colours(1,:), 'se');
    l4 = plot(trial_lengths, nanmean(accuracy_per_soa_invalid)*100, 'Color', bright_colours(2,:), 'LineWidth', 3.5, 'Marker', 'o', 'MarkerFaceColor', bright_colours(2,:));
    p4 = frevede_errorbarplot(trial_lengths, accuracy_per_soa_invalid*100, bright_colours(2,:), 'se');
    
    if exist('stat_a') == 1
        invalid = nanmean(accuracy_per_soa_invalid)*100
        valid = nanmean(accuracy_per_soa_valid)*100
        
        for X = trial_lengths(stat_a.mask)
            Y = find(trial_lengths == X);
            plot([X X], [valid(Y) invalid(Y)], '--', 'Color', 'k', 'LineWidth', 2.5)
        end
    end
    
    legend([l3, l4], labels, 'EdgeColor', 'w');
    ylim([50 100]);
    ylabel('Correct (%)');
    yticks([50 75 100]);
    xlim([min(trial_lengths) max(trial_lengths)]);
    xticks([500 1400 2300 3200]);
    xlabel('SOA (ms)');
    % title('Accuracy', 'fontsize', 28)
    
    % subplot(1,2,1);
    xlabel('SOA (ms)');
    % title('Response time', 'fontsize', 28)
    fontsize(30, "points");
    
    % set(gcf,'position',[0,0, 700,1080])
    
    % subplot(1,2,1)
    
end

%% show grand average bar graphs of data as function of validity

if plot_averages
    
    figure(figure_nr);
    figure_nr = figure_nr+1;
    % subplot(1,2,1);
    hold on
    
    b1 = bar([1], [nanmean(reaction_time_validity(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    % b2 = bar([2], [nanmean(reaction_time_validity(:,2))], bar_size, FaceColor=colours(2,:), FaceAlpha=0.5, EdgeColor=colours(2,:), EdgeAlpha=0.5);
    b2 = bar([2], [nanmean(reaction_time_validity(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    errorbar([1], [nanmean(reaction_time_validity(:,1))], [std(reaction_time_validity(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    % errorbar([2], [nanmean(reaction_time_validity(:,2))], [std(reaction_time_validity(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', light_colours(2,:));
    errorbar([2], [nanmean(reaction_time_validity(:,2))], [std(reaction_time_validity(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    plot([1,2], [reaction_time_validity(:,1:2)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    
    % legend(labels, 'Location', 'southeast');
    ylim([0 1500]);
    ylabel('Time (ms)');
    yticks([500 1000 1500]);
    xlim([0.2 2.8]);
    xticks([1,2]);
    xticklabels(labels);
    % title('Response time', 'fontsize', 28)
    fontsize(30, "points");
    % set(gcf,'position',[0,0, 540,1600])
    
    figure;
    hold on
    
    b3 = bar([1], [nanmean(error_validity(:,1))*100], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b4 = bar([2], [nanmean(error_validity(:,2))*100], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    % b4 = bar([2], [nanmean(error_validity(:,2))*100], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:), FaceAlpha=0.5, EdgeAlpha=0.5);
    errorbar([1], [nanmean(error_validity(:,1))*100], [(std(error_validity(:,1)) ./ sqrt(p))*100], 'LineWidth', 3, 'Color', dark_colours(1,:));
    % errorbar([2], [nanmean(error_validity(:,2))*100], [(std(error_validity(:,2)) ./ sqrt(p))*100], 'LineWidth', 3, 'Color', light_colours(1,:));
    errorbar([2], [nanmean(error_validity(:,2))*100], [(std(error_validity(:,2)) ./ sqrt(p))*100], 'LineWidth', 3, 'Color', dark_colours(2,:));
    plot([1,2], [error_validity(:,1:2)*100]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);
    
    % legend(labels, 'Location', 'southeast');
    ylim([50 100]);
    ylabel('Correct (%)');
    yticks([25 50 75 100]);
    xlim([0.2 2.8]);
    xticks([1,2]);
    xticklabels(labels);
    fontsize(30, "points");
    % title('Accuracy', 'fontsize', 28)
    
    % subplot(1,2,1)
    
    % set(gcf,'position',[0,0, 540,1600])
    
end
