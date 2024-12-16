%% Reaction time
% Create table out of data arrays
Participant = repmat([1:24],1,20);
ReactionTime = [reshape(reaction_time_per_soa_valid, [1,240]), reshape(reaction_time_per_soa_invalid, [1,240])];
Condition = [repmat(["valid"], 1, 240), repmat(["invalid"], 1, 240)];
SOA = [sort(repmat(trial_lengths, 1, 24)), sort(repmat(trial_lengths, 1, 24))];

soa_table_rt = table(Participant', Condition', SOA', ReactionTime', VariableNames=["Participant", "Condition", "SOA", "ReactionTime"]);
soa_table_rt.Condition = categorical(soa_table_rt.Condition);
soa_table_rt.Participant = categorical(soa_table_rt.Participant);

% Run Linear Mixed-Effects Model on SOA data
lme = fitlme(soa_table_rt, 'ReactionTime ~ Condition * SOA + (1 + SOA | Participant)')
lme = fitlme(soa_table_rt, 'ReactionTime ~ Condition * SOA + (1 | Participant)')

%% Accuracy
% Create table out of data arrays
Participant = repmat([1:24],1,20);
Accuracy = [reshape(accuracy_per_soa_valid, [1,240]), reshape(accuracy_per_soa_invalid, [1,240])];
Condition = [repmat(["valid"], 1, 240), repmat(["invalid"], 1, 240)];
SOA = [sort(repmat(trial_lengths, 1, 24)), sort(repmat(trial_lengths, 1, 24))];

soa_table_acc = table(Participant', Condition', SOA', Accuracy', VariableNames=["Participant", "Condition", "SOA", "Accuracy"]);
soa_table_acc.Condition = categorical(soa_table_acc.Condition);
soa_table_acc.Participant = categorical(soa_table_acc.Participant);

% Run Linear Mixed-Effects Model on SOA data
lme = fitlme(soa_table_acc, 'Accuracy ~ Condition * SOA + (1 + SOA | Participant)')
lme = fitlme(soa_table_acc, 'Accuracy ~ Condition * SOA + (1 | Participant)')
