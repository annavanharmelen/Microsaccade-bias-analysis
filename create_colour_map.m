function [colour_map] = create_colour_map(n_steps)
%CREATE_COLOUR_MAP creates a colour map of a specified amount of colours.
if mod(n_steps, 2) ~= 1
    error("number of steps should be an uneven number")
end

start_colour = [36, 70, 167];
mid_colour = [255, 255, 255];
end_colour = [222, 66, 91];

colour_map = zeros([n_steps 3]);

step_size = 1/((n_steps-1)/2);
r_step = (mid_colour(1) - start_colour(1)) * step_size;
g_step = (mid_colour(2) - start_colour(2)) * step_size;
b_step = (mid_colour(3) - start_colour(3)) * step_size;
for i = 1:(n_steps/2)
    colour_map(i, 1) = round(start_colour(1) + (i-1)*r_step);
    colour_map(i, 2) = round(start_colour(2) + (i-1)*g_step);
    colour_map(i, 3) = round(start_colour(3) + (i-1)*b_step);
end

colour_map(ceil(size(colour_map, 1)/2), :) = mid_colour;

r_step = (end_colour(1) - mid_colour(1)) * step_size;
g_step = (end_colour(2) - mid_colour(2)) * step_size;
b_step = (end_colour(3) - mid_colour(3)) * step_size;
for i = ceil(n_steps/2 + 1):(n_steps)
    colour_map(i, 1) = round(mid_colour(1) + (i-ceil(n_steps/2))*r_step);
    colour_map(i, 2) = round(mid_colour(2) + (i-ceil(n_steps/2))*g_step);
    colour_map(i, 3) = round(mid_colour(3) + (i-ceil(n_steps/2))*b_step);
end

if any(colour_map(end, :) ~= end_colour) || any(colour_map(1,:) ~= start_colour)
    error("wait, something went wrong, start or end colour is not correct")
end

colour_map = colour_map/255;

end