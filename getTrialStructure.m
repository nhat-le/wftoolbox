function [timingInfo, trialInfo] = getTrialStructure(opts)
% Compute the idx of the relevant frames
files = dir(fullfile(opts.trialDataPath, '*Timeline.mat'));
load(fullfile(files(1).folder, files(1).name), 'Timeline');

bfile = dir(fullfile(opts.trialDataPath, '*Block.mat'));
load(fullfile(bfile(1).folder, bfile(1).name), 'block');

%TODO: Fix the channel id for the sync signal (changed!)
syncsignal = Timeline.rawDAQData(:,5);
dsync = diff(syncsignal);
feedbackTimesFromTimeline = Timeline.rawDAQTimestamps(dsync > 2);
frametimesIdx = find(diff(Timeline.rawDAQData(:,2)));
feedbackFrameIdxFromTimeline = Timeline.rawDAQData(dsync > 2, 2);

timg = Timeline.rawDAQTimestamps(frametimesIdx(1:end));
timingInfo.timg = timg;
timingInfo.fs = (numel(timg) - 1) / (timg(end) - timg(1));


% get alignment time from block file
%-1 for left movement, +1 for right target (target == responses for correct trials)
target = block.events.contrastLeftValues * (-2) + 1; %1 for leftmovement target,
feedback = block.events.feedbackValues;
responses = block.events.responseValues;
rewardDelays = [block.paramsValues.rewardDelay]; % trial delays
responseTimes = block.events.responseTimes;
feedbackTimes = block.events.feedbackTimes;

% Reduce to the smallest size, and eliminate the first trial(bad timing)
N = min([numel(target), numel(feedback), numel(responses), numel(rewardDelays),...
    numel(feedbackTimesFromTimeline)]);

if opts.ignoreFirstTrial
    firstidx = 2;
else
    firstidx = 1;
end
trialInfo.target = target(firstidx:N);
trialInfo.feedback = feedback(firstidx:N);
trialInfo.responses = responses(firstidx:N);
trialInfo.rewardDelays = rewardDelays(firstidx:N);
trialInfo.responseTimes = responseTimes(firstidx:N);
trialInfo.feedbackTimes = feedbackTimes(firstidx:N);
trialInfo.feedbackTimesFromTimeline = feedbackTimesFromTimeline(firstidx:N);
trialInfo.feedbackFrameIdxFromTimeline = feedbackFrameIdxFromTimeline(firstidx:N)';


% Find closest frames to tstarts
difftResp = abs(trialInfo.responseTimes - timg');
trialInfo.responseFrameIdx = argmin(difftResp);

difftFb = abs(trialInfo.feedbackTimes - timg');
trialInfo.feedbackFrameIdx = argmin(difftFb);
trialInfo.ntrials = numel(trialInfo.responseTimes);



end