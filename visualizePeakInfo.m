function visualizePeakInfo(data, opts, timingInfo)
reshapedData = reshape(data, [], size(data, 3));
window = floor(opts.dt * timingInfo.fs); %frames to extract from alignment point
fs = timingInfo.fs;

% Find the peak times
[maxresp, idx] = max(reshapedData, [], 2);

idx = reshape(idx, [size(data, 1), size(data, 2)]);
maxresp = reshape(maxresp, [size(data, 1), size(data, 2)]);

%% Show the peak time plots
figure;
imagesc((idx - window(1)) / fs);
colormap hot
set(gca, 'FontSize', 16)
title('Correct, no delay')
c = colorbar;
% caxis([0, 2])
c.Label.String = 'Time of peak (s)';
axis off

%% Plot the max responses
figure;
imagesc(maxresp);
colormap hot
set(gca, 'FontSize', 16)
title('Correct response')
c = colorbar;
% caxis([0, 0.15])
c.Label.String = 'df/f at peak';
axis off


