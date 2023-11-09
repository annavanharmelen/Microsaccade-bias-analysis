function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [99, 26, 32, 19, 62, 28, 55, 15, 89, 31, 22, 44, 59, 45, 27, 30, 10, 81, 88, 16, 49, 87]; %needs to be in the right order

param.path = 'C:\Users\annav\Documents\Jottacloud\Neuroscience PhD\Experiments\Microsaccade bias experiments\Data\';

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

log_string = sprintf('data_session_%d.csv', pp);
param.log = [param.path, log_string];

eds_string = sprintf('%d_%d.asc', pp, unique_numbers(pp));
param.eds = [param.path, eds_string];