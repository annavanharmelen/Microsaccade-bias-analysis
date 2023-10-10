function [dva_x, dva_y] = frevede_pixel2dva(pixeldata_x, pixeldata_y);

% our lab screens: 1920x1080p = 526x296mm
pixelwidth = 526/1920; centrepixel_x = 1920/2;
pixelheight = 296/1080; centrepixel_y = 1080/2;
eye2screen = 700; % in mm

% get pixel to dva from centre of screen
dva_x = atan(   (    (pixeldata_x-centrepixel_x)*pixelwidth) / eye2screen);
dva_y = atan(   (    (pixeldata_y-centrepixel_y)*pixelheight) / eye2screen);

% radians to degrees
dva_x = dva_x * 180/pi'; 
dva_y = dva_y * 180/pi';

end
