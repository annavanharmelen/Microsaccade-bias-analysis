function [data_outputX, data_outputY, data_outputVelocity, time_output] = PBlab_gazepos2shift_2D(cfg, data_inputX, data_inputY, time_input)

% Description: convert gaze position into gaze shift, considering gaze position along aling one axis (e.g. x or y).
%
% for more detail 
% data_inputX = eye_data X:  matrix trial x time
% data_inputY = eye_data Y:  matrix trial x time
% data_outputX = eye_shift X: matrix trial x time (0 means the no gaze shift, non-zero values indicate the displacement of detected gaze shifts (position after shift minus position before shift))
% data_outputY = eye_shift Y: matrix trial x time 
% time_input = time vector in gaze position data
% time_output = time vector for gaze shift data
%
% cfg can contain:
% cfg.smooth_der    = 'true' or 'false' (default = 'true'); whether to smooth velocity data
% cfg.smooth_step   = number (default = 7); length of gaussian smoothing window, in samples (i.e. if Fs = 1000, smooth_step=7 equals 7 ms)
% cfg.winbef        = time range (default = [50 0]); time window for detecting gaze postion before threshold crossing, in samples
% cfg.winaft        = time range  (default = [50 100]); time window for detecting gaze postion after threshold crossing, in samples
% cfg.minISI        = number (default = 100); the minimal time after threshold crossing before considering the next possible gaze shift (and to avoid counting the same shift multiple times)
% cfg.threshold     = number (default = 5); the velocity threshold (n*median velocity) for detecting gaze shifts 
% cfg.euclidean     = 'true' or 'false' (default = 'true'); whether to use euclidian distance to find 2D velocity profile (alternative is to find velocity in X and Y separately, and average them)
%
% Baiwei Liu and Freek van Ede | Proactive Brain lab | Amsterdam | 2021 
%
% last update 19 dec 2021, 15.50 CET by Freek van Ede.
% minor tweak 6 oct 2022.

% set default value, if user did not specify
if isfield(cfg,  'smooth_der');     else cfg.smooth_der = true;  end
if isfield(cfg,  'smooth_step');    else cfg.smooth_step = 7;    end
if isfield(cfg,  'winbef');         else cfg.winbef = [50 0];    end
if isfield(cfg,  'winaft');         else cfg.winaft = [50 100];  end
if isfield(cfg,  'minISI');         else cfg.minISI = 100;       end
if isfield(cfg,  'threshold');      else cfg.threshold = 5;      end
if isfield(cfg,  'euclidean');      else cfg.euclidean = true;   end

% create data 
data = [];
data.gaze_rawX = squeeze(data_inputX);
data.gaze_rawY = squeeze(data_inputY);

%% get  derivative to turn to velocity, and possibly smooth velocity profile

% get 2D velocity
if cfg.euclidean
        ntrl = size(data_inputX,1);
        ntime = length(time_input);
        for trl = 1:ntrl
            for time = 2:ntime
                G = [data.gaze_rawX(trl,time-1),data.gaze_rawY(trl,time-1)]; % x and y time A
                G2 = [data.gaze_rawX(trl,time),data.gaze_rawY(trl,time)]; % x and y time A+1
                eucDis(trl,time)  = sqrt(sum((G - G2) .^ 2)); % euclidean distance: how much change in gaze position from time A-1 to A, in 2D plane
            end
        end
    data.absder = eucDis; % use euclidean distance between neighboring samples as the 'abs_der' 2D velocity vector.
else
    data.derX = diff(data.gaze_rawX,1,2);
    data.derY = diff(data.gaze_rawY,1,2);
    data.absderX = abs(data.derX);
    data.absderY = abs(data.derY);
    data.absder = (data.absderX + data.absderY) ./ 2; % combine x and y, simply by merging abs derivatives
end

% smooth?
if cfg.smooth_der
    data.absder_sm = smoothdata(data.absder,2,'gaussian', cfg.smooth_step);
else
    data.absder_sm = data.absder;
end

%% mark shifts
gaze_shiftX = zeros(size(data.gaze_rawX)); % start with matrix with zeros
gaze_shiftY = zeros(size(data.gaze_rawY)); % start with matrix with zeros
gaze_shift_velocity = zeros(size(data.gaze_rawX)); % start with matrix with zeros


for i = 1:size(data.gaze_rawX,1)
        
    med1 = nanmedian(data.absder_sm(i,:));
    
    % set data to use        
    dat2use = data.absder_sm(i,:); % velocity data
    datorigX = data.gaze_rawX(i,:);  % position data    
    datorigY = data.gaze_rawY(i,:);  % position data   
    ntime = size(dat2use,2);       % number of time samples per trial  
    
    usabletimevec = 1+cfg.winbef(1):ntime-cfg.winaft(2);
    for t = usabletimevec;  % loop over all usable time points, taking into account that we need a window before and after threshold crossings to extract shift size.         
        
        if dat2use(t) >= med1 * cfg.threshold;  % find threshold crossing
                       
            % get position before and after in X
            dbefX = nanmean(datorigX([(t-cfg.winbef(1)):(t-cfg.winbef(2))])); % data before
            daftX = nanmean(datorigX([(t+cfg.winaft(1)):(t+cfg.winaft(2))])); % data after          
            gaze_shiftX(i, t) = daftX - dbefX;
            
            % get position before and after in Y
            dbefY = nanmean(datorigY([(t-cfg.winbef(1)):(t-cfg.winbef(2))])); % data before
            daftY = nanmean(datorigY([(t+cfg.winaft(1)):(t+cfg.winaft(2))])); % data after          
            gaze_shiftY(i, t) = daftY - dbefY;            
            
            % velocity
            gaze_shift_velocity(i, t) = max(dat2use(t:t+20)); % for peak velocity within 20 samples of threshold crossing
            
            % set minimal delay before allowing threshold crossing again
            if t+ cfg.minISI > ntime                 dat2use(t+1:end) = 0; % if min ISI beyond available window, fill with zeros til end. Else, fill zeros min ISI.
            else dat2use(t+1:t+ cfg.minISI) = 0; 
            end 
            
        end
    end
end

data_outputX = gaze_shiftX(:,usabletimevec);
data_outputY = gaze_shiftY(:,usabletimevec);
data_outputVelocity = gaze_shift_velocity(:,usabletimevec);
time_output = time_input(usabletimevec);
