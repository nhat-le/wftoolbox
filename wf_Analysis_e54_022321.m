%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

% opts.filePath = '/Volumes/2P1DATA/data/Feb2021/02222021/e54blockworldrolling2';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2021-02-22/2';
opts.filePath = '/Volumes/2P1DATA/data/Mar2021/031721/E54';
opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2021-03-17/1';

opts.refImgPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/surfaceRotated2.tif';
opts.refAtlasPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/atlas_E54.mat';

opts.alignBorders = 1; % to return
opts.motionCorrect = 0;
opts.hemoCorrect = 1;
opts.ignoreFirstTrial = 1;
opts.pickSide = 0;

opts.resizeFactor = 2;
opts.dt = [-2 1]; %what window (secs) to take around the alignment point
% two dt's for delays
opts.alignedBy = 'reward'; %'reward' or 'response': which epoch to align to
opts.computeDFF = 1;

opts.datafiles = dir(fullfile(opts.filePath, '*.tif'));
opts.stem = opts.datafiles(1).name(1:end-4);




%% Parse the trial structure and arrange in a convenient output format
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
compareMovie(filteredCorr);

%% Split into left or right trials
criterion1.feedback = 0; %1 or 0; filter only rewarded/non-rewarded trials
criterion1.response = nan; %-1 or 1; filter only left/right trials
criterion1.delay = 'late'; %'early' or 'late'; filter trials with or without delay
criterion1.trialSubset = nan;

criterion2.feedback = 1; %1 or 0; filter only rewarded/non-rewarded trials
criterion2.response = nan; %-1 or 1; filter only left/right trials
criterion2.delay = 'late'; %'early' or 'late'; filter trials with or without delay
criterion2.trialSubset = nan;


[filteredIncorr, avgIncorr] = filterTrials(allData.data, criterion1, trialInfo);
[filteredCorr, avgCorr] = filterTrials(allData.data, criterion2, trialInfo);

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
% save('f03_extracted_030121.mat', 'allData', 'trialInfo', 'timingInfo', '-v7.3')
%% Save the pix array
bData = allData.bData;
vData = allData.vData;
data = allData.data;
feedback = trialInfo.feedback;
response = trialInfo.responses;
target = trialInfo.target;
atlas = template.atlas;
save('regionData_e54_031721pix.mat', 'bData', 'vData', 'data',...
    'feedback', 'response', 'target', 'atlas', 'trialInfo', 'timingInfo',...
    'template', 'opts', '-v7.3')
