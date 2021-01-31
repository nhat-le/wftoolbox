function [timingInfo, trialInfo] = getTrialStructure(opts)
% Compute the idx of the relevant frames
files = dir(fullfile(opts.trialDataPath, '*Timeline.mat'));
load(fullfile(files(1).folder, files(1).name), 'Timeline');

bfile = dir(fullfile(opts.trialDataPath, '*Block.mat'));
load(fullfile(bfile(1).folder, bfile(1).name), 'block');

syncsignal = Timeline.rawDAQData(:,3);
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
trialInfo.target = target(2:N);
trialInfo.feedback = feedback(2:N);
trialInfo.responses = responses(2:N);
trialInfo.rewardDelays = rewardDelays(2:N);
trialInfo.responseTimes = responseTimes(2:N);
trialInfo.feedbackTimes = feedbackTimes(2:N);
trialInfo.feedbackTimesFromTimeline = feedbackTimesFromTimeline(2:N);
trialInfo.feedbackFrameIdxFromTimeline = feedbackFrameIdxFromTimeline(2:N)';


% Find closest frames to tstarts
difftResp = abs(trialInfo.responseTimes - timg');
trialInfo.responseFrameIdx = argmin(difftResp);

difftFb = abs(trialInfo.feedbackTimes - timg');
trialInfo.feedbackFrameIdx = argmin(difftFb);
trialInfo.ntrials = numel(trialInfo.responseTimes);



end