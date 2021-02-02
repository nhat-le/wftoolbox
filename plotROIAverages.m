function plotROIAverages(data, roiCentroids, pointerSize, opts, timingInfo, window)
[xx,yy] = meshgrid(1:size(data,2),1:size(data,1)); %isolate index for selected area
selData = nan(size(roiCentroids, 1), size(data,3) * size(data, 4));

% Assemble the roi averages
for iData = 1:size(roiCentroids, 1)
    
    cPos = roiCentroids(iData, :);

    mask = hypot(xx - cPos(1), yy - cPos(2)) <= pointerSize;

    flatData = reshape(data,size(data,1) * size(data, 2),[]); %merge x and y dimension based on mask size and remaining dimensions.
    mask = reshape(mask,numel(mask),1); %reshape mask to vector
    selData(iData,:) = nanmean(flatData(mask,:)); %merge selected pixels

end

colorOrder = get(gca,'ColorOrder');
selData = reshape(selData, size(roiCentroids, 1), size(data,3), []);
lines = [];


if opts.hemoCorrect
    tarr = (window(1) : window(2)) / (timingInfo.fs / 2);
else
    tarr = (window(1) : window(2)) / (timingInfo.fs);
end

for iData = 1:size(roiCentroids, 1)
    singleData = squeeze(selData(iData,:,:))';
    % Plot the mean
    amean = nanmean(singleData,1);
    lines(iData) = plot(tarr, amean,'linewidth',3,'color',colorOrder(iData, :));
    hold on

    % Plot std
    amean(isnan(amean)) = 0;
    asem = nanstd(double(singleData),[],1)/sqrt(size(singleData, 1));
    asem(isnan(asem)) = 0;

    fill([tarr fliplr(tarr)],[amean+asem fliplr(amean-asem)], colorOrder(iData,:), 'FaceAlpha', 0.5,'linestyle','none');
end

set(gca,'FontSize', 16);
xlabel('Time (s)')
ylabel('df/f')
legend(lines, {'S1', 'ACC', 'V1'}, 'Location', 'southwest');
end