%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

%Note: code will add the root for you, only need to specify relative path
opts.filePath = 'E:\1p\exp22an1';
opts.trialDataPath = 'C:\LocalExpData\exp22an2\2022-02-23\1';


opts.saveFolder = nan; % if nan, will save in the same folder as filePath
opts.animal = 'exp22an2'; % if nan, code will figure out what animal from file path
opts = configurePaths(opts);

opts.alignBorders = 1; % if borders should be aligned using Allen atlas template, usually 1
opts.motionCorrect = 0; 
opts.hemoCorrect = 1;
opts.ignoreFirstTrial = 1; % if 1, skip first trial (timing issues)
opts.pickSide = 0; % if pickside = 0, default order for blue & violet, otherwise, let user decide which channel is blue
opts.quickSave = 0; % if 1, skip visualization, save the processed data

opts.resizeFactor = 2;

%!!IMPORTANT: CHANGE THIS FOR EACH SESSION TO BE ANALYZED!!
opts.dt = [-2 2]; %what window (secs) to take around the alignment point

% two dt's for delays
opts.alignedBy = 'reward'; %'reward' or 'response': which epoch to align to
opts.computeDFF = 1;

opts.datafiles = dir(fullfile(opts.filePath, '*.tif'));
opts.stem = opts.datafiles(1).name(1:end-4);




%% Parse the trial structure and arrange in a convenient output format
[timingInfo, trialInfo] = getTrialStructure(opts);


%% Get the aligned trials
allData = getAlignedTrials(opts, trialInfo, timingInfo);

%% Get the aggregate area information
% Alignment
if opts.alignBorders
    template = alignImages(opts, allData);
end


%% Split into left or right trials
if ~opts.quickSave
    criterion1.feedback = 0; %1 or 0; filter only rewarded/non-rewarded trials
    criterion1.response = -1; %-1 or 1; filter only left/right trials
    criterion1.delay = 'late'; %'early' or 'late'; filter trials with or without delay
    criterion1.trialSubset = nan;

    criterion2.feedback = 0; %1 or 0; filter only rewarded/non-rewarded trials
    criterion2.response = nan; %-1 or 1; filter only left/right trials
    criterion2.delay = 'late'; %'early' or 'late'; filter trials with or without delay
    criterion2.trialSubset = nan;


    [filteredIncorr, avgIncorr] = filterTrials(allData.data, criterion1, trialInfo);
    [filteredCorr, avgCorr] = filterTrials(allData.data, criterion2, trialInfo);
end
%% Browsing the raw data and average stack
% compareMovie(filteredIncorr); %use this GUI to browse the widefield data stack
if ~opts.quickSave
    compareMovie(filteredCorr);
end

%% Visualize the areal summary
if ~opts.quickSave
    [maxresp, respTimes] = visualizePeakInfo(avgCorr, opts, timingInfo);

    templateOpts.brainSide = 'left'; % 'left' or 'right'
    templateOpts.sortBy = 'pks'; %'pks' or 'pkTimes'
    templateOpts.normalize = 0;

    [idx, sortedTimes] = visualizeAreaSummary(allData, avgCorr, templateOpts, template, timingInfo);

    templateOpts.sortBy = idx; % sort by the same order as previous
    [idx2,sortedTimes2] = visualizeAreaSummary(allData, avgIncorr, templateOpts, template, timingInfo);
end

%% Save the pix array
bData = allData.bData;
vData = allData.vData;
data = allData.data;
feedback = trialInfo.feedback;
response = trialInfo.responses;
target = trialInfo.target;
atlas = nan; %template.atlas;
template = nan;
fullsaveName = sprintf('regionData_%s_%spix.mat', opts.animal, opts.datestring);

save(fullfile(opts.saveFolder, fullsaveName), 'bData', 'vData', 'data',...
    'feedback', 'response', 'target', 'atlas', 'trialInfo', 'timingInfo',...
    'template', 'opts', '-v7.3')
fprintf('Data saved\n');



