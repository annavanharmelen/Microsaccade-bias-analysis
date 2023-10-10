clear all
close all
clc

%% set parameters and loops
see_performance = 0;
display_percentageok = 1;
plot_individuals = 1;
plot_averages = 1;

pp2do = 1; 
p = 0;

[bar_size, colours, dark_colours, labels, percentageok, decisiontime, decisiontime_std, error, overall_dt, overall_error, ppnum, subplot_size] = setBehaviourParam(pp2do)

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

pre_neg_85_69_trials = ismember(behdata.target_pre_orientation, [-85:-69]);
pre_neg_69_53_trials = ismember(behdata.target_pre_orientation, [-69:-53]);
pre_neg_53_37_trials = ismember(behdata.target_pre_orientation, [-53:-37]);
pre_neg_37_21_trials = ismember(behdata.target_pre_orientation, [-37:-21]);
pre_neg_21_5_trials = ismember(behdata.target_pre_orientation, [-21:-5]);
pre_pos_85_69_trials = ismember(behdata.target_pre_orientation, [69:85]);
pre_pos_69_53_trials = ismember(behdata.target_pre_orientation, [53:69]);
pre_pos_53_37_trials = ismember(behdata.target_pre_orientation, [37:53]);
pre_pos_37_21_trials = ismember(behdata.target_pre_orientation, [21:37]);
pre_pos_21_5_trials = ismember(behdata.target_pre_orientation, [5:21]);

post_neg_85_69_trials = ismember(behdata.target_post_orientation, [-87:-69]);
post_neg_69_53_trials = ismember(behdata.target_post_orientation, [-69:-53]);
post_neg_53_37_trials = ismember(behdata.target_post_orientation, [-53:-37]);
post_neg_37_21_trials = ismember(behdata.target_post_orientation, [-37:-21]);
post_neg_21_5_trials = ismember(behdata.target_post_orientation, [-21:-3]);
post_pos_85_69_trials = ismember(behdata.target_post_orientation, [69:87]);
post_pos_69_53_trials = ismember(behdata.target_post_orientation, [53:69]);
post_pos_53_37_trials = ismember(behdata.target_post_orientation, [37:53]);
post_pos_37_21_trials = ismember(behdata.target_post_orientation, [21:37]);
post_pos_21_5_trials = ismember(behdata.target_post_orientation, [3:21]);
%% extract data of interest
missed_valid_trials = sum(valid_trials&missed_trials) / sum(valid_trials);
missed_invalid_trials = sum(invalid_trials&missed_trials) / sum(invalid_trials);

missed_blue_trials = sum(blue_target_trials&missed_trials) / sum(blue_target_trials);
missed_green_trials = sum(green_target_trials&missed_trials) / sum(green_target_trials);
missed_orange_trials = sum(orange_target_trials&missed_trials) / sum(orange_target_trials);
missed_pink_trials = sum(pink_target_trials&missed_trials) / sum(pink_target_trials);

missed_orientations = [
    sum(pre_neg_85_69_trials&missed_trials) / sum(pre_neg_85_69_trials), sum(post_neg_85_69_trials&missed_trials) / sum(post_neg_85_69_trials);
    sum(pre_neg_69_53_trials&missed_trials) / sum(pre_neg_69_53_trials), sum(post_neg_69_53_trials&missed_trials) / sum(post_neg_85_69_trials);
    ];
% Anna dit moet gewoon een forloop worden

end
