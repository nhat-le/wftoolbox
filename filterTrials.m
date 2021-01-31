function [filteredArr, avgArr] = filterTrials(allData, criterion, trialInfo)
% criterion.feedback = 1; %1 or 0; filter only rewarded/non-rewarded trials
% criterion.response = 1; %-1 or 1; filter only left/right trials
% criterion.delay = 'early'; %'early' or 'late'; filter trials with or without delay

%% First, parse the criterion structure
if ~isfield(criterion, 'feedback')
    criterion.feedback = nan;
end

if ~isfield(criterion, 'response')
    criterion.response = nan;
end

if ~isfield(criterion, 'delay')
    criterion.delay = nan;
end

% Warnings for invalid values
if ~isnan(criterion.feedback) && ~ismember(criterion.feedback, [0 1])
    error('Invalid feedback criterion. Must be 0 or 1')
end

if ~isnan(criterion.response) && ~ismember(criterion.response, [-1 1])
    error('Invalid response criterion. Must be 0 or 1')
end

if isnan(criterion.delay)
    
elseif ~ismember(criterion.delay, {'early', 'late'})
    error('Invalid delay criterion. Must be "early" or "late"')
end
    

%% Now filter the trials
feedbackIdx = ones(1, size(allData, 4));
responseIdx = ones(1, size(allData, 4));
delayIdx = ones(1, size(allData, 4));


if ~isnan(criterion.feedback)
    feedbackIdx = trialInfo.feedback == criterion.feedback;
end

if ~isnan(criterion.response)
    responseIdx = trialInfo.responses == criterion.response;
end

if ~isnan(criterion.delay)
    maxdelay = max(trialInfo.rewardDelays);
    if strcmp(criterion.delay, 'late')
        delayIdx = trialInfo.rewardDelays == maxdelay;
    elseif strcmp(criterion.delay, 'early')
        delayIdx = trialInfo.rewardDelays == 0;     
    end
end

filterIdx = feedbackIdx .* responseIdx .* delayIdx;

filteredArr = allData(:,:,:,logical(filterIdx));
avgArr.arr = mean(filteredArr, 4);
avgArr.criterion = criterion;

   

end