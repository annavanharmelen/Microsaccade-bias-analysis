function [bar_size, colours, dark_colours, labels, percentageok, decisiontime, decisiontime_std, error, overall_dt, overall_error, ppnum, subplot_size] = setBehaviourParam(pp2do)
%SETBEHAVIOURPARAM Summary of this function goes here
%   Detailed explanation goes here
bar_size = 0.8;

colours = [114, 182, 161;...
           149, 163, 192;...
           233, 150, 117;...
           194, 102, 162];
colours = colours/255;

dark_colours = [50, 79, 70;
                58, 67, 88;
                105, 67, 52;
                92, 49, 77];

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

