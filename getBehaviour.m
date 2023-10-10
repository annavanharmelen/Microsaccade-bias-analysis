clear all
close all
clc

%% set parameters and loops
see_performance = 0;
display_percentageok = 1;
plot_individuals = 1;
plot_averages = 1;

pp2do = [1:2]; 
p = 0;

[bar_size, colours, dark_colours, labels, percentageok, decisiontime, decisiontime_std, error, overall_dt, overall_error, ppnum, subplot_size] = setBehaviourParam(pp2do);

orientation_bins = [-85:16:-5, 5:16:85];
trial_lengths = 500:300:3200;

missed_trial_lengths = zeros(size(pp2do, 2), size(trial_lengths, 2));
trial_orientations = zeros(size(pp2do, 2), (size(orientation_bins, 2) - 1));
missed_orientations = zeros(size(pp2do, 2), (size(orientation_bins, 2) - 1));


for pp = pp2do
p = p+1;

param = getSubjParam(pp);
disp(['getting data from ', param.subjName]);

%% load actual behavioural data
behdata = readtable(param.log);

%% check oktrials
% todo?

%% basic data checks, each pp in own subplot
if plot_individuals
    figure(1);
    subplot(subplot_size,subplot_size,p);
    histogram(behdata.response_time_in_ms,50);           
    title(['response time - pp ', num2str(pp2do(p))]); 
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

%% extract data of interest - missed
% order: valid, invalid
missed_valid_trials(p, 1) = sum(valid_trials&missed_trials) / sum(valid_trials);
missed_valid_trials(p, 2) = sum(invalid_trials&missed_trials) / sum(invalid_trials);

% order: blue, green, orange, pink
missed_colour_trials(p, 1) = sum(blue_target_trials&missed_trials) / sum(blue_target_trials);
missed_colour_trials(p, 2) = sum(green_target_trials&missed_trials) / sum(green_target_trials);
missed_colour_trials(p, 3) = sum(orange_target_trials&missed_trials) / sum(orange_target_trials);
missed_colour_trials(p, 4) = sum(pink_target_trials&missed_trials) / sum(pink_target_trials);

% order: clockwise, anticlockwise
missed_direction_trials(p, 1) = sum(clockwise_trials&missed_trials) / sum(clockwise_trials);
missed_direction_trials(p, 2) = sum(anticlockwise_trials&missed_trials) / sum(anticlockwise_trials);

% order: left, right
missed_position_trials(p,1) = sum(left_trials&missed_trials) / sum(left_trials);
missed_position_trials(p,2) = sum(right_trials&missed_trials) / sum(right_trials);

for i = 1:(size(orientation_bins, 2) - 1)
    if i < 5 || (i < 11 && i > 6)
        idx = ismember(behdata.target_pre_orientation, orientation_bins(i):(orientation_bins(i+1) - 1));
    elseif i == 5 || i == 11
        idx = ismember(behdata.target_pre_orientation, orientation_bins(i):orientation_bins(i+1));
    else
        idx = ismember(behdata.target_pre_orientation, (orientation_bins(i) + 1):(orientation_bins(i+1) - 1));
    end
    
    missed_orientations(p, i) = sum(idx&missed_trials) / sum(idx);
    trial_orientations(p, i) = sum(idx);
end

for i = 1:size(trial_lengths, 2)
     idx = ismember(behdata.static_duration, trial_lengths(i));
     missed_trial_lengths(p, i) = sum(idx&missed_trials) / sum(idx);
end

%% extract data of interest - correct
% order: valid, invalid
correct_valid_trials(p, 1) = sum(valid_trials&correct_trials) / sum(valid_trials);
correct_valid_trials(p, 2) = sum(invalid_trials&correct_trials) / sum(invalid_trials);

% order: blue, green, orange, pink
correct_colour_trials(p, 1) = sum(blue_target_trials&correct_trials) / sum(blue_target_trials);
correct_colour_trials(p, 2) = sum(green_target_trials&correct_trials) / sum(green_target_trials);
correct_colour_trials(p, 3) = sum(orange_target_trials&correct_trials) / sum(orange_target_trials);
correct_colour_trials(p, 4) = sum(pink_target_trials&correct_trials) / sum(pink_target_trials);

% order: clockwise, anticlockwise
correct_direction_trials(p, 1) = sum(clockwise_trials&correct_trials) / sum(clockwise_trials);
correct_direction_trials(p, 2) = sum(anticlockwise_trials&correct_trials) / sum(anticlockwise_trials);

% order: left, right
correct_position_trials(p,1) = sum(left_trials&correct_trials) / sum(left_trials);
correct_position_trials(p,2) = sum(right_trials&correct_trials) / sum(right_trials);

for i = 1:(size(orientation_bins, 2) - 1)
    if i < 5 || (i < 11 && i > 6)
        idx = ismember(behdata.target_pre_orientation, orientation_bins(i):(orientation_bins(i+1) - 1));
    elseif i == 5 || i == 11
        idx = ismember(behdata.target_pre_orientation, orientation_bins(i):orientation_bins(i+1));
    else
        idx = ismember(behdata.target_pre_orientation, (orientation_bins(i) + 1):(orientation_bins(i+1) - 1));
    end
    
    correct_orientations(p, i) = sum(idx&correct_trials) / sum(idx);
    trial_orientations(p, i) = sum(idx);
end

for i = 1:size(trial_lengths, 2)
     idx = ismember(behdata.static_duration, trial_lengths(i));
     correct_trial_lengths(p, i) = sum(idx&correct_trials) / sum(idx);
end

%% extract data of interest - incorrect
% order: valid, invalid
incorrect_valid_trials(p, 1) = sum(valid_trials&incorrect_trials) / sum(valid_trials);
incorrect_valid_trials(p, 2) = sum(invalid_trials&incorrect_trials) / sum(invalid_trials);

% order: blue, green, orange, pink
incorrect_colour_trials(p, 1) = sum(blue_target_trials&incorrect_trials) / sum(blue_target_trials);
incorrect_colour_trials(p, 2) = sum(green_target_trials&incorrect_trials) / sum(green_target_trials);
incorrect_colour_trials(p, 3) = sum(orange_target_trials&incorrect_trials) / sum(orange_target_trials);
incorrect_colour_trials(p, 4) = sum(pink_target_trials&incorrect_trials) / sum(pink_target_trials);

% order: clockwise, anticlockwise
incorrect_direction_trials(p, 1) = sum(clockwise_trials&incorrect_trials) / sum(clockwise_trials);
incorrect_direction_trials(p, 2) = sum(anticlockwise_trials&incorrect_trials) / sum(anticlockwise_trials);

% order: left, right
incorrect_position_trials(p,1) = sum(left_trials&incorrect_trials) / sum(left_trials);
incorrect_position_trials(p,2) = sum(right_trials&incorrect_trials) / sum(right_trials);

for i = 1:(size(orientation_bins, 2) - 1)
    if i < 5 || (i < 11 && i > 6)
        idx = ismember(behdata.target_pre_orientation, orientation_bins(i):(orientation_bins(i+1) - 1));
    elseif i == 5 || i == 11
        idx = ismember(behdata.target_pre_orientation, orientation_bins(i):orientation_bins(i+1));
    else
        idx = ismember(behdata.target_pre_orientation, (orientation_bins(i) + 1):(orientation_bins(i+1) - 1));
    end
    
    incorrect_orientations(p, i) = sum(idx&incorrect_trials) / sum(idx);
    trial_orientations(p, i) = sum(idx);
end

for i = 1:size(trial_lengths, 2)
     idx = ismember(behdata.static_duration, trial_lengths(i));
     incorrect_trial_lengths(p, i) = sum(idx&incorrect_trials) / sum(idx);
end

end
