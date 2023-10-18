# MICROSACCADE BIAS ANALYSIS
# ***[work in progress]***
Analysis scripts (in MATLAB) for the data acquired from the microsaccade-bias experiment (in Python). For the experiment, see: [Microsaccade-bias-main](https://github.com/annavanharmelen/Microsaccade-bias-experiment).

## Author
Made by Anna van Harmelen in 2023, with scripts from Dr. Freek van Ede.

## Installation
Some of these analysis scripts are dependent on the [Fieldtrip toolbox](https://www.fieldtriptoolbox.org), and were originally built using the 2020.10.23 version of Fieldtrip.

## Configuration
To make sure the scripts run correctly, open the getSubjParam.m file to either...:
- Enter the randomised participant numbers (in order of session number), if your filing system is the same as mine.
- Change the code, so this function can find the data corresponding to each participant.

## Running
The analysis runs in multiple parts, some of which are dependent on each other.

All main behavioural data is analysed in getBehaviour.m.

All eye-tracking data is analysed by entering the desired participantnumbers into these scripts, and then running them in precisely this sequence:
1. epochEyeData.m
2. get_GazePositionBias.m and get_SaccadeBias.m, these scripts respectively calculate the average gaze and saccade biases per participant.
3. GA_GazePositionBias.m and GA_SaccadeBias.m, these scripts respectively calculate the grand average gaze and saccade biases, where each participant is weighted equally, independent of the number of trials they completed.

Note that most of these eye-tracking analysis scripts are dependent on the 'frevede_' functions in the repository, and also on the [Fieldtrip toolbox](https://www.fieldtriptoolbox.org/download.php). 
