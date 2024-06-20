function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [65, 34, 56, 26, 97, 15, 78, 70, 44]; %needs to be in the right order

param.path = '\\labsdfs.labs.vu.nl\labsdfs\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\m2 - microsaccade bias shift vs. sustain with fixational control\';

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

log_string = sprintf('data_session_%d.csv', pp);
param.log = [param.path, log_string];

eds_string = sprintf('%d_%d.asc', pp, unique_numbers(pp));
param.eds = [param.path, eds_string];
