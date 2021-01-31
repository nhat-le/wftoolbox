%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

% opts.filePath = '/Volumes/My Passport/2p1/Jan2021/011021/e50blockworld';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e50/2021-01-10/2';
opts.filePath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/Dec2020/e54-12272020/e54blockworld';
opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2020-12-27/1';
opts.refImgPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/surfaceRotated2.tif';
opts.refAtlasPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/atlas_E54.mat';
opts.alignBorders = 1;
opts.motionCorrect = 1;

opts.resizeFactor = 5;
opts.dt = [-0.5 1]; %what window (secs) to take around the alignment point
opts.alignedBy = 'reward'; %'reward' or 'response': which epoch to align to
opts.computeDFF = 1;

opts.datafiles = dir(fullfile(opts.filePath, '*.tif'));
opts.stem = opts.datafiles(1).name(1:end-4);


%% Alignment
if opts.alignBorders
    tform = alignImages(opts);
end

%% Parse the trial structure and arrange in a convenient output format
[timingInfo, trialInfo] = getTrialStructure(opts);


%% Get the aligned trials
allData = getAlignedTrials(opts, trialInfo, timingInfo);

%% Browsing the raw data and average stack
compareMovie(allData); %use this GUI to browse the widefield data stack


%% Split into left or right trials
criterion.feedback = 0; %1 or 0; filter only rewarded/non-rewarded trials
criterion.response = nan; %-1 or 1; filter only left/right trials
criterion.delay = nan; %'early' or 'late'; filter trials with or without delay

[filteredArr, avgArr] = filterTrials(allData, criterion, trialInfo);

%%
visualizePeakInfo(avgArr, opts, timingInfo)



