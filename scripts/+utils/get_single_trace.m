function singletrace = get_single_trace(data, xCenter, yCenter, roisize)
xrange = ceil([xCenter - roisize/2, xCenter + roisize/2]);
yrange = ceil([yCenter - roisize/2, yCenter + roisize/2]);
roiactivity = data(yrange(1):yrange(2), xrange(1):xrange(2), :, :);
meanroi = squeeze(mean(roiactivity, [1, 2]));
singletrace = mean(meanroi(20:end, :), 1);
end