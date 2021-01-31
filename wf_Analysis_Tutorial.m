%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

% opts.filePath = '/Volumes/My Passport/2p1/Jan2021/011021/e50blockworld';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e50/2021-01-10/2';
opts.resizeFactor = 5;
opts.dt = [-0.5 1]; %what window (secs) to take around the alignment point
opts.alignedBy = 'reward'; %'reward' or 'response': which epoch to align to
opts.computeDFF = 1;

opts.datafiles = dir(fullfile(opts.filePath, '*.tif'));
opts.stem = opts.datafiles(1).name(1:end-4);

%% Reference image
% Load the surface image
imgFile = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/surfaceRotated2.tif';
img = TIFFStack(imgFile);

refImg = img(:,:,1);



%% Image registration
if trialNr == 1
    bData = single(squeeze(bData));
    blueRef = fft2(median(bData,3)); %blue reference for motion correction

    vData = single(squeeze(vData));
    violetRef = fft2(median(vData,3)); %violet reference for motion correction
end

%perform motion correction for both channels
for iFrames = 1:size(bData,3)
    [~, temp] = dftregistration(blueRef, fft2(bData(:, :, iFrames)), 10);
    bData(:, :, iFrames) = abs(ifft2(temp));

    [~, temp] = dftregistration(violetRef, fft2(vData(:, :, iFrames)), 10);
    vData(:, :, iFrames) = abs(ifft2(temp));
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



