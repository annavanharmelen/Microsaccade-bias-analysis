function [bar_size, bright_colours, colours, dark_colours, labels, percentageok, decisiontime, decisiontime_std, error, overall_dt, overall_error, ppnum, subplot_size] = setBehaviourParam(pp2do)
%SETBEHAVIOURPARAM Summary of this function goes here
%   Detailed explanation goes here
bar_size = 0.8;

bright_colours=[84, 206, 116;...
                156, 138, 238];
bright_colours = bright_colours/255;

colours = [120, 186, 137;...
           161, 153, 196];
colours = colours/255;

dark_colours = [46, 71, 52;...
                63, 55, 102];
dark_colours = dark_colours/255;

labels = {'valid','invalid'};
percentageok = zeros(size(pp2do));
decisiontime = zeros(size(pp2do, 2), size(labels, 2) + 1);
decisiontime_std = zeros(size(pp2do, 2), size(labels, 2) + 1);
error = zeros(size(pp2do, 2), size(labels, 2) + 1);
overall_dt = zeros(size(pp2do));
overall_error = zeros(size(pp2do));
ppnum = zeros(size(pp2do));

subplot_size = ceil(sqrt(size(pp2do, 2)));
end

