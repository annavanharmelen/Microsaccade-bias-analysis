% this is all random stuff I don't need but never want to have to ever type
% again

pre_neg_85_69_trials(p) = ismember(behdata.target_pre_orientation, [-85:-69]);
pre_neg_69_53_trials(p) = ismember(behdata.target_pre_orientation, [-69:-53]);
pre_neg_53_37_trials(p) = ismember(behdata.target_pre_orientation, [-53:-37]);
pre_neg_37_21_trials(p) = ismember(behdata.target_pre_orientation, [-37:-21]);
pre_neg_21_5_trials(p) = ismember(behdata.target_pre_orientation, [-21:-5]);
pre_pos_85_69_trials(p) = ismember(behdata.target_pre_orientation, [69:85]);
pre_pos_69_53_trials(p) = ismember(behdata.target_pre_orientation, [53:69]);
pre_pos_53_37_trials(p) = ismember(behdata.target_pre_orientation, [37:53]);
pre_pos_37_21_trials(p) = ismember(behdata.target_pre_orientation, [21:37]);
pre_pos_21_5_trials(p) = ismember(behdata.target_pre_orientation, [5:21]);

post_neg_85_69_trials(p) = ismember(behdata.target_post_orientation, [-87:-69]);
post_neg_69_53_trials(p) = ismember(behdata.target_post_orientation, [-69:-53]);
post_neg_53_37_trials(p) = ismember(behdata.target_post_orientation, [-53:-37]);
post_neg_37_21_trials(p) = ismember(behdata.target_post_orientation, [-37:-21]);
post_neg_21_5_trials(p) = ismember(behdata.target_post_orientation, [-21:-3]);
post_pos_85_69_trials(p) = ismember(behdata.target_post_orientation, [69:87]);
post_pos_69_53_trials(p) = ismember(behdata.target_post_orientation, [53:69]);
post_pos_53_37_trials(p) = ismember(behdata.target_post_orientation, [37:53]);
post_pos_37_21_trials(p) = ismember(behdata.target_post_orientation, [21:37]);
post_pos_21_5_trials(p) = ismember(behdata.target_post_orientation, [3:21]);

length_500_trials(p) = ismember(behdata.static_duration, 500);
length_800_trials(p) = ismember(behdata.static_duration, 800);
length_1100_trials(p) = ismember(behdata.static_duration, 1100);
length_1400_trials(p) = ismember(behdata.static_duration, 1400);
length_1700_trials(p) = ismember(behdata.static_duration, 1700);
length_2000_trials(p) = ismember(behdata.static_duration, 2000);
length_2300_trials(p) = ismember(behdata.static_duration, 2300);
length_2600_trials(p) = ismember(behdata.static_duration, 2600);
length_2900_trials(p) = ismember(behdata.static_duration, 2900);
length_3200_trials(p) = ismember(behdata.static_duration, 3200);