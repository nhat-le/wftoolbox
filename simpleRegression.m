filedir = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/processed';
filename = 'regionData_f04_040121pix.mat';

% filedir = '/Users/minhnhatle/Documents/ExternalCode/wftoolbox';
% filename = 'regionData_e54_031721pix.mat';
load(fullfile(filedir, filename), 'data', 'feedback', 'response', 'target',...
    'opts', 'timingInfo', 'trialInfo');


%%
fs = timingInfo.fs;
dt = opts.dt;
window = floor(opts.dt * timingInfo.fs); %frames to extract from alignment point
nframes = window(2) - window(1) + 1;
if mod(nframes, 2) == 1
    window(2) = window(2) + 1;
    nframes = nframes + 1;
end

rewardDelay = max(trialInfo.rewardDelays);

%% IMPORTANT: Define these frame IDs depending on the window we selected during extraction
zeroFrameID = floor(-window(1) / 2) + 1;
rewardFrameID = floor(-window(1) / 2 + rewardDelay * fs / 2) + 1;


% Define the window to take for reward period
twindowToAverage = [0, 1]; %sec, window to average activity
tframesToAverage = floor(twindowToAverage * fs / 2);
tframes = tframesToAverage(2) - tframesToAverage(1);
% twindow = 1; %sec
% tframes = floor(twindow * fs / 2);

% When should we start taking the response
delays = trialInfo.rewardDelays;
frameidxStart = nan(1, numel(delays));
frameidxStart(delays == 0) = zeroFrameID;
frameidxStart(delays == 1) = rewardFrameID;

% frameidxEnd = frameidxStart + tframes;

% Get the frames
dataWindow = nan(size(data, 1), size(data, 2), tframes + 1, size(data, 4));
dataWindow(:,:,:,delays == 0) = data(:,:,zeroFrameID + tframesToAverage(1):zeroFrameID + tframesToAverage(2),delays == 0);
dataWindow(:,:,:,delays == 1) = data(:,:,rewardFrameID + tframesToAverage(1):rewardFrameID + tframesToAverage(2),delays == 1);

% Average!
dataWindowMean = squeeze(mean(dataWindow, 3));

%% Start the regression
% Let's build the regressors!
rewRegressor = feedback;

convolveWindow = 10;
valueRegressor = conv(response, ones(1,convolveWindow) / convolveWindow, 'same');

switchWindow = 10;
switchRegressor = buildSwitchRegressor(response, switchWindow);
%%
X = [rewRegressor' valueRegressor' switchRegressor' ones(numel(response), 1)];
Xsmall = X(delays > 0, :);
dataWindowFlat = reshape(dataWindowMean, [], size(dataWindowMean, 3));
dataFlatsmall = dataWindowFlat(:, delays > 0);

B = nan(4, size(dataWindowFlat, 1));
Rvals = nan(2, size(dataWindowFlat, 1));
Pvals = nan(4, size(dataWindowFlat, 1));

%%
tic
for i = 1:size(dataWindowFlat, 1)
    pixelData = dataWindowFlat(i,:);
    mdl = fitlm(X, pixelData','Intercept', false);
%     b = X \ pixelData';
    
    B(:,i) = mdl.Coefficients.Estimate;
    Pvals(:,i) = mdl.Coefficients.pValue;
    Rvals(:,i) = [mdl.Rsquared.Ordinary; mdl.Rsquared.Adjusted];
end
toc
    
%% B = X\dataWindowFlat';

Bmap = reshape(B, size(X,2), size(data,1), size(data,2));
Pmap = reshape(Pvals, [], size(data,1), size(data,2));
Rmap = reshape(Rvals, [], size(data,1), size(data,2));



for i = 1 :size(Bmap, 1)
    figure;
    imagesc(squeeze(Pmap(i,:,:) < 0.01))
%     colormap gray
    axis off
    colorbar
end




%% Visualization of the regressors
trialRange = 130:167;
figure;
subplot(411)
window_response = response(trialRange);
window_fb = feedback(trialRange);
trial_n = 1:numel(window_response);
plot(trial_n(window_fb == 1), window_response(window_fb == 1)/2 + 1/2, 'bo',...
    'MarkerFaceColor', 'b')
hold on
plot(trial_n(window_fb == 0), window_response(window_fb == 0)/2 + 1/2, 'rx')
vline(13, 'k--')
set(gca, 'FontSize', 16)



subplot(412)
plot(rewRegressor(trialRange), 'LineWidth', 2)
vline(13, 'k--')
set(gca, 'FontSize', 16)

subplot(413)
plot(valueRegressor(trialRange), 'LineWidth', 2)
vline(13, 'k--')
set(gca, 'FontSize', 16)

subplot(414)
plot(switchRegressor(trialRange), 'LineWidth', 2)
vline(13, 'k--')
xlabel('Trial #')
set(gca, 'FontSize', 16)



%% Make a long behavior to visualize the different regressors
rng(1234);
tpoints = 1:50;
rate = 1 ./ (1 + exp((-tpoints + 20) / 2));
% plot(rate)

choiceSim = rand(1, numel(tpoints)) < rate;
choiceSim = choiceSim * 2 - 1;

switchRegressor = buildSwitchRegressor(choiceSim, 6);
valueRegressor = nan(1, numel(tpoints));
currVal = 0;
gamma = 0.1;
for i = 1:numel(tpoints)
    valueRegressor(i) = currVal;
    if choiceSim(i) == -1
        currVal = currVal + gamma * (1 - currVal); 
    else
        currVal = currVal + gamma * (1 - currVal); 
    end
end

figure;
subplot(311)
window_response = choiceSim;
window_fb = choiceSim == 1;
trial_n = 1:numel(window_response);
plot(trial_n(window_fb == 1), window_response(window_fb == 1)/2 + 1/2, 'bo',...
    'MarkerFaceColor', 'b')
hold on
plot(trial_n(window_fb == 0), window_response(window_fb == 0)/2 + 1/2, 'rx')
vline(1, 'k--')
ylabel('Choices')
set(gca, 'FontSize', 16)



subplot(312)
plot(valueRegressor, 'LineWidth', 2)
vline(1, 'k--')
set(gca, 'FontSize', 16)
ylabel('Value')

subplot(313)
plot(switchRegressor, 'LineWidth', 2)
vline(1, 'k--')
set(gca, 'FontSize', 16)
ylabel('Switch prob')
xlabel('Trial #')









function switchRegressor = buildSwitchRegressor(response, switchWindow)
% switch regressor
% switchWindow: a window to count the number of switches

switchRegressor = nan(1, numel(response));

for i = 1:numel(response)
    lower = max(i - floor(switchWindow/2), 1);
    upper = min(i + floor(switchWindow/2), numel(response));
    windowForSwitches = response(lower:upper);
    windowForSwitches(windowForSwitches == 0) = nan;
    switchCounts = nansum(~isnan(diff(windowForSwitches)) & ...
        diff(windowForSwitches) ~= 0);
    switchRegressor(i) = switchCounts / (upper - lower + 1);
   
    
end

end






