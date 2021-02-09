function idx = visualizeAreaSummary(data, avgArr, side, sortBy, template, timingInfo)
% data: allData structure returned from alignTrials
% side: 'left' or 'right': side of the brain
% sortBy: 'pks' for peak amplitudes, or 'pkTimes' for peak times
% if sortBy is a list, will sort the area based on the indices in the list
% template, timingInfo: options as returned
% Returns: idx, the sorted indices


window = data.window;
% Get the mean for each area
areaMeans = mean(template.aggData(:,:,logical(avgArr.filterIdx)), 3);
if strcmp(side, 'left')
    side = 1; %-1 for right side, 1 for left side
elseif strcmp(side, 'right')
    side = -1;
else
    error('Invalid side. Must be "left" or "right"');
end
areaFilt = areaMeans(template.areaid * side > 0, :);
% areas = template.areaid(template.areaid * side > 0, :);
areaStringFilt = template.areaStrings(template.areaid * side > 0);

% sort by peak times
[pks, pkTimes] = max(areaFilt, [], 2);
if strcmp(sortBy, 'pks')
    [~,idx] = sort(pks, 'descend');
elseif strcmp(sortBy, 'pkTimes')
    [~,idx] = sort(pkTimes, 'descend');
else
    idx = sortBy;
end

areaSort = areaFilt(idx,:);
figure;
imagesc(areaSort, 'XData', ((window(1):window(2))) / timingInfo.fs);
colormap gray
yticks(1:numel(pks))
yticklabels(areaStringFilt(idx))
end