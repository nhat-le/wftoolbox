%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

opts.filePath = '/Volumes/2P1DATA/data/april2021/040221/f04';
opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/f04/2021-04-02/1';

opts.refImgPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/f04Template/f04surface.tif';
opts.refAtlasPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/f04Template/atlas_f04.mat';

opts.alignBorders = 1; % to return
opts.motionCorrect = 0;
opts.hemoCorrect = 1;
opts.ignoreFirstTrial = 1;

opts.resizeFactor = 2;
opts.dt = [-1 2]; %what window (secs) to take around the alignment point
% two dt's for delays
opts.alignedBy = 'response'; %'reward' or 'response': which epoch to align to
opts.computeDFF = 1;

opts.datafiles = dir(fullfile(opts.filePath, '*.tif'));
opts.stem = opts.datafiles(1).name(1:end-4);




%% Parse the trial structure and arrange in a convenient output format
% TODO: Fix the channel id for the sync signal (changed!)
[timingInfo, trialInfo] = getTrialStructure(opts);
fprintf('Sampling rate: %.4f, n trials = %d\n', timingInfo.fs, trialInfo.ntrials);


%% Get the aligned trials
allData = getAlignedTrials(opts, trialInfo, timingInfo);


%% If blue and violet are mixed up, run this line
allData = flipBlueViolet(allData, opts, timingInfo);

%% Get the aggregate area information
% Alignment
if opts.alignBorders
    template = alignImages(opts, allData);
end


%% Browsing the raw data and average stack
% compareMovie(filteredIncorr); %use this GUI to browse the widefield data stack
compareMovie(filteredIncorr);

%% Split into left or right trials
criterion1.feedback = 0; %1 or 0; filter only rewarded/non-rewarded trials
criterion1.response = nan; %-1 or 1; filter only left/right trials
criterion1.delay = 'late'; %'early' or 'late'; filter trials with or without delay
criterion1.trialSubset = nan;

criterion2.feedback = 1; %1 or 0; filter only rewarded/non-rewarded trials
criterion2.response = nan; %-1 or 1; filter only left/right trials
criterion2.delay = 'late'; %'early' or 'late'; filter trials with or without delay
criterion2.trialSubset = nan;


[filteredIncorr, avgIncorr] = filterTrials(data, criterion1, trialInfo);
[filteredCorr, avgCorr] = filterTrials(data, criterion2, trialInfo);

%%
visualizePeakInfo(avgIncorr, opts, timingInfo);



%% Visualize the areal summary
templateOpts.brainSide = 'left'; % 'left' or 'right'
templateOpts.sortBy = 'pks'; %'pks' or 'pkTimes'
templateOpts.normalize = 0;

[idx, sortedTimes] = visualizeAreaSummary(allData, avgCorr, templateOpts, template, timingInfo);

templateOpts.sortBy = idx; % sort by the same order as previous
[idx2,sortedTimes2] = visualizeAreaSummary(allData, avgIncorr, templateOpts, template, timingInfo);

%% Save the processed data
% save('f01_extracted_030321.mat', 'allData', 'trialInfo', 'timingInfo', '-v7.3')



%% Save the pix array
bData = allData.bData;
vData = allData.vData;
data = allData.data;
feedback = trialInfo.feedback;
response = trialInfo.responses;
target = trialInfo.target;
atlas = template.atlas;
save('regionData_f04_040221pix.mat', 'bData', 'vData', 'data',...
    'feedback', 'response', 'target', 'atlas', 'trialInfo', 'timingInfo',...
    'template', 'opts', '-v7.3')


