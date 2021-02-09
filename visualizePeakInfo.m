function visualizePeakInfo(data, opts, timingInfo)
arr = data.arr;
criterion = data.criterion;

% Make a title for the plot
if ~isnan(criterion.feedback)
    if criterion.feedback
        feedbackStr = 'rewarded';
    else
        feedbackStr = 'no reward';
    end
else
    feedbackStr = '';
end

if ~isnan(criterion.response)
    if criterion.response == 1
        responseStr = 'right';
    else
        responseStr = 'left';
    end
else
    responseStr = '';
end

if ~isnan(criterion.delay)
    delayStr = criterion.delay;
else
    delayStr = '';
end

titleStr = sprintf('%s, %s, %s', feedbackStr, responseStr, delayStr);
titleStr = strip(titleStr, 'both', ',');

reshapedData = reshape(arr, [], size(arr, 3));
window = floor(opts.dt * timingInfo.fs); %frames to extract from alignment point
fs = timingInfo.fs;

% Find the peak times
[maxresp, idx] = max(reshapedData, [], 2);

idx = reshape(idx, [size(arr, 1), size(arr, 2)]);
maxresp = reshape(maxresp, [size(arr, 1), size(arr, 2)]);

%% Show the peak time plots
figure;
imagesc((idx + window(1)/2) / (fs/2));
colormap hot
set(gca, 'FontSize', 16)
title(titleStr)
c = colorbar;
% caxis([0, 2])
c.Label.String = 'Time of peak (s)';
axis off

%% Plot the max responses
figure;
imagesc(maxresp);
colormap hot
set(gca, 'FontSize', 16)
title(titleStr)
c = colorbar;
% caxis([0, 0.15])
c.Label.String = 'df/f at peak';
axis off


