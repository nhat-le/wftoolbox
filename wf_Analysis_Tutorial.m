%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

%TODO: make computer-general
opts.filePath = 'E:/data/april2021/042821/f04';
opts.trialDataPath = 'D:/Dropbox (MIT)/Nhat/Rigbox/f04/2021-04-28/1';
opts.saveFolder = nan; % if nan, will save in the same folder as filePath
opts.animal = 'f04';
opts = configurePaths(opts);


opts.alignBorders = 1; % if borders should be aligned using Allen atlas template, usually 1
opts.motionCorrect = 0; 
opts.hemoCorrect = 1;
opts.ignoreFirstTrial = 1; % if 1, skip first trial (timing issues)
opts.pickSide = 0; % if pickside = 0, default order for blue & violet, otherwise, let user decide which channel is blue
opts.quickSave = 1; % if 1, skip visualization, save the processed data

opts.resizeFactor = 2;
opts.dt = [-0.5 1]; %what window (secs) to take around the alignment point
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
    criterion1.response = nan; %-1 or 1; filter only left/right trials
    criterion1.delay = 'late'; %'early' or 'late'; filter trials with or without delay
    criterion1.trialSubset = nan;

    criterion2.feedback = 1; %1 or 0; filter only rewarded/non-rewarded trials
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
atlas = template.atlas;
fullsaveName = sprintf('regionData_%s_%spix.mat', opts.animal, opts.datestring);

save(fullfile(opts.saveFolder, fullsaveName), 'bData', 'vData', 'data',...
    'feedback', 'response', 'target', 'atlas', 'trialInfo', 'timingInfo',...
    'template', 'opts', '-v7.3')




function opts = configurePaths(opts)
if isnan(opts.saveFolder)
    opts.saveFolder = opts.filePath;
end


masterPath = 'templates';
switch opts.animal
    case 'e53'
        fileRefImgPath = 'e53Template/e53surface.tif';
        fileRefAtlasPath = 'e53Template/atlas_E53.mat';
    case 'e54'
        fileRefImgPath = 'e54Template/e54surface.tif';
        fileRefAtlasPath = 'e54Template/atlas_E54.mat';
    case 'f01'
        fileRefImgPath = 'f01Template/f01surface.tif';
        fileRefAtlasPath = 'f01Template/atlas_F01.mat';
    case 'f02'
        fileRefImgPath = 'f02Template/f02surface.tif';
        fileRefAtlasPath = 'f02Template/atlas_F02.mat';
    case 'f03'
        fileRefImgPath = 'f03Template/f03surface.tif';
        fileRefAtlasPath = 'f03Template/atlas_F03.mat';
    case 'f04'
        fileRefImgPath = 'f04Template/f04surface.tif';
        fileRefAtlasPath = 'f04Template/atlas_F04.mat';
        
        
end

opts.refImgPath = fullfile(masterPath, fileRefImgPath);
opts.refAtlasPath = fullfile(masterPath, fileRefAtlasPath);

% Get the parts
fileparts = strsplit(opts.filePath, '/');
opts.datestring = fileparts{end-1};

end