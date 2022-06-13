% For comparing the ITIs between correct and incorrect trials within 
% a behavioral session
filepath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/f02/2021-02-23/1';
files = dir(fullfile(filepath, '*Block.mat'));
assert(numel(files) == 1);
load(fullfile(files(1).folder, files(1).name))

choices = block.events.responseValues;
feedback = block.events.feedbackValues;
fbtimes = block.events.feedbackTimes;

trialstarttimes = block.events.newTrialTimes;

ITIs = trialstarttimes(2:end) - fbtimes(1:end);

figure;
plot(ITIs(feedback == 1))
hold on
plot(ITIs(feedback == 0))
