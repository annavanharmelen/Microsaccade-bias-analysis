clear all
close all
clc

%% set parameters and loops
display_percentage_premature = 1;
plot_individuals = 1;
plot_averages = 1;

pp2do = [1:17]; 
p = 0;


[bar_size, bright_colours, colours, dark_colours, subplot_size, labels, percentageok, decisiontime, decisiontime_std, error, overall_dt, overall_error, ppnum] = setBehaviourParam(pp2do);

orientation_bins = [-85:16:-5, 5:16:85];
trial_lengths = 500:300:3200;

missed_trial_lengths = zeros(size(pp2do, 2), size(trial_lengths, 2));
trial_orientations = zeros(size(pp2do, 2), (size(orientation_bins, 2) - 1));
missed_orientations = zeros(size(pp2do, 2), (size(orientation_bins, 2) - 1));


for pp = pp2do
    p = p+1;
    figure_nr = 1;
    
    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);
    
    %% display percentage prematurely pressed trials
    if display_percentage_premature
        fprintf('%s has %.2f%% premature responses\n\n', param.subjName, mean(ismember(behdata.premature_pressed, {'True'}))*100)
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
    labels = {'valid','invalid'};
    
    reaction_time_validity(p,1) = mean(behdata.response_time_in_ms(valid_trials));
    reaction_time_validity(p,2) = mean(behdata.response_time_in_ms(invalid_trials));
    
    error_validity(p,1)      = mean(correct_trials(valid_trials));
    error_validity(p,2)      = mean(correct_trials(invalid_trials));
    %% get reaction time as function of SOA
    for i = 1:size(trial_lengths, 2)
        reaction_time_per_soa_valid(p,i) = mean(behdata.response_time_in_ms(valid_trials&behdata.static_duration==trial_lengths(i)));
        reaction_time_per_soa_invalid(p,i) = mean(behdata.response_time_in_ms(invalid_trials&behdata.static_duration==trial_lengths(i)));
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
        ylim([600 1700]);
        xlim([min(trial_lengths) max(trial_lengths)]);
        xticks(trial_lengths);
        xlabel('SOA (ms)');
        ylabel('Response time (ms)');
    end
   % legend(labels);

    
    %% get accuracy as function of SOA
    for i = 1:size(trial_lengths, 2)
        accuracy_per_soa_valid(p,i) = mean(correct_trials(valid_trials&behdata.static_duration==trial_lengths(i)));
        accuracy_per_soa_invalid(p,i) = mean(correct_trials(invalid_trials&behdata.static_duration==trial_lengths(i)));
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
        ylim([0.4 1]);
        xlim([min(trial_lengths) max(trial_lengths)]);
        xticks(trial_lengths);
        xlabel('SOA (ms)');
        ylabel('Accuracy');
    end
    % legend(labels);


end

%% show grand average line graphs of data as function of SOA
if plot_averages

    figure(figure_nr)
    figure_nr = figure_nr+1;
    subplot(1,2,1);
    hold on

    l1 = plot(trial_lengths, mean(reaction_time_per_soa_valid), 'Color', bright_colours(1,:), 'LineWidth', 1.5);
    p1 = frevede_errorbarplot(trial_lengths, reaction_time_per_soa_valid, bright_colours(1,:), 'se');
    l2 = plot(trial_lengths, mean(reaction_time_per_soa_invalid), 'Color', bright_colours(2,:), 'LineWidth', 1.5);
    p2 = frevede_errorbarplot(trial_lengths, reaction_time_per_soa_invalid, bright_colours(2,:), 'se');

    title('Response times (ms) per SOA'); 
    legend([l1, l2], labels);
    ylim([600 1500]);
    xlim([min(trial_lengths) max(trial_lengths)]);
    xticks(trial_lengths);
    xlabel('SOA in ms');

    subplot(1,2,2);
    hold on

    l3 = plot(trial_lengths, mean(accuracy_per_soa_valid), 'Color', bright_colours(1,:), 'LineWidth', 1.5);
    p3 = frevede_errorbarplot(trial_lengths, accuracy_per_soa_valid, bright_colours(1,:), 'se');
    l4 = plot(trial_lengths, mean(accuracy_per_soa_invalid), 'Color', bright_colours(2,:), 'LineWidth', 1.5);
    p4 = frevede_errorbarplot(trial_lengths, accuracy_per_soa_invalid, bright_colours(2,:), 'se');

    title('Correct (%) per SOA'); 
    legend([l3, l4], labels);
    ylim([0.5 1]);
    xlim([min(trial_lengths) max(trial_lengths)]);
    xticks(trial_lengths);
    xlabel('SOA in ms');
end

%% show grand average bar graphs of data as function of validity
 
if plot_averages

    figure(figure_nr);
    figure_nr = figure_nr+1;
    subplot(1,2,1);
    hold on

    b1 = bar([1], [mean(reaction_time_validity(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b2 = bar([2], [mean(reaction_time_validity(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    errorbar([1], [mean(reaction_time_validity(:,1))], [std(reaction_time_validity(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(reaction_time_validity(:,2))], [std(reaction_time_validity(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    plot([1,2], [reaction_time_validity(:,1:2)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);

    title('Decision time (ms)')
    legend(labels);
    ylim([0 1600]);
    xticks([1,2]);
    xticklabels(labels);

    subplot(1,2,2);
    hold on

    b3 = bar([1], [mean(error_validity(:,1))], bar_size, FaceColor=colours(1,:), EdgeColor=colours(1,:));
    b4 = bar([2], [mean(error_validity(:,2))], bar_size, FaceColor=colours(2,:), EdgeColor=colours(2,:));
    errorbar([1], [mean(error_validity(:,1))], [std(error_validity(:,1)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(1,:));
    errorbar([2], [mean(error_validity(:,2))], [std(error_validity(:,2)) ./ sqrt(p)], 'LineWidth', 3, 'Color', dark_colours(2,:));
    plot([1,2], [error_validity(:,1:2)]', 'Color', [0, 0, 0, 0.25], 'LineWidth', 1);

    title('Correct (%)')
    legend(labels);
    ylim([0 1]);
    xticks([1,2]);
    xticklabels(labels);

end
