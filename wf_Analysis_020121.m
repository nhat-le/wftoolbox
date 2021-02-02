%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

% example 1
% opts.filePath = '/Volumes/My Passport/2p1/Jan2021/011021/e50blockworld';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e50/2021-01-10/2';

% example 2
% opts.filePath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/Dec2020/e54-12272020/e54blockworld';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2020-12-27/1';

% example 3 (with hemocorrection)
opts.filePath = '/Volumes/My Passport/2p1/Jan2021/e54blockworld2';
opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2021-01-23/3';
% opts.filePath = '/Volumes/2P1DATA/data/Feb2021/02012021/e54blockworld2';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2021-02-01/3';


opts.refImgPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/surfaceRotated2.tif';
opts.refAtlasPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/atlas_E54.mat';
opts.alignBorders = 1;
opts.motionCorrect = 0;
opts.hemoCorrect = 1;

opts.resizeFactor = 5;
opts.dt = [-0.5 1]; %what window (secs) to take around the alignment point
opts.alignedBy = 'reward'; %'reward' or 'response': which epoch to align to
opts.computeDFF = 1;

opts.datafiles = dir(fullfile(opts.filePath, '*.tif'));
opts.stem = opts.datafiles(1).name(1:end-4);




%% Parse the trial structure and arrange in a convenient output format
[timingInfo, trialInfo] = getTrialStructure(opts);


%% Get the aligned trials
allData = getAlignedTrials(opts, trialInfo, timingInfo);


%%
roiCentroids = floor([202 119; 171 146; 280 195]);
pointerSize = 10;
figure('Position', [43, 406, 1086, 392]);
a1 = subplot(131);
plotROIAverages(allData.bData(:,:,:,trialInfo.feedback == 1), roiCentroids, pointerSize)
title('Blue, correct')

a2 = subplot(132);
plotROIAverages(allData.vData(:,:,:,trialInfo.feedback == 1), roiCentroids, pointerSize)
title('Violet, correct')

a3 = subplot(133);
plotROIAverages(allData.data(:,:,:,trialInfo.feedback == 1), roiCentroids, pointerSize)
title('Corrected, correct')

linkaxes([a1, a2, a3])

%% Get the aggregate area information
% Alignment
if opts.alignBorders
    template = alignImages(opts, allData);
end


%% Browsing the raw data and average stack
compareMovie(allData.data); %use this GUI to browse the widefield data stack


%% Split into left or right trials
criterion1.feedback = 0; %1 or 0; filter only rewarded/non-rewarded trials
criterion1.response = nan; %-1 or 1; filter only left/right trials
criterion1.delay = nan; %'early' or 'late'; filter trials with or without delay

criterion2.feedback = 1; %1 or 0; filter only rewarded/non-rewarded trials
criterion2.response = nan; %-1 or 1; filter only left/right trials
criterion2.delay = nan; %'early' or 'late'; filter trials with or without delay


[filteredIncorr, avgCorr] = filterTrials(allData.data, criterion1, trialInfo);
[filteredCorr, avgIncorr] = filterTrials(allData.data, criterion2, trialInfo);

%%
visualizePeakInfo(avgIncorr, opts, timingInfo)


function plotROIAverages(data, roiCentroids, pointerSize)
[xx,yy] = meshgrid(1:size(data,2),1:size(data,1)); %isolate index for selected area
selData = nan(size(roiCentroids, 1), size(data,3) * size(data, 4));

% Assemble the roi averages
for iData = 1:size(roiCentroids, 1)
    
    cPos = roiCentroids(iData, :);

    mask = hypot(xx - cPos(1), yy - cPos(2)) <= pointerSize;

    flatData = reshape(data,size(data,1) * size(data, 2),[]); %merge x and y dimension based on mask size and remaining dimensions.
    mask = reshape(mask,numel(mask),1); %reshape mask to vector
    selData(iData,:) = nanmean(flatData(mask,:)); %merge selected pixels

end

colorOrder = get(gca,'ColorOrder');
selData = reshape(selData, 3, 9, []);
lines = [];
tarr = (-3:5) / 5.8;
for iData = 1:size(roiCentroids, 1)
    singleData = squeeze(selData(iData,:,:))';
    % Plot the mean
    amean = nanmean(singleData,1);
    lines(iData) = plot(tarr, amean,'linewidth',3,'color',colorOrder(iData, :));
    hold on

    % Plot std
    amean(isnan(amean)) = 0;
    asem = nanstd(double(singleData),[],1)/sqrt(size(singleData, 1));
    asem(isnan(asem)) = 0;

    fill([tarr fliplr(tarr)],[amean+asem fliplr(amean-asem)], colorOrder(iData,:), 'FaceAlpha', 0.5,'linestyle','none');
end

set(gca,'FontSize', 16);
xlabel('Time (s)')
ylabel('df/f')
legend(lines, {'S1', 'ACC', 'V1'}, 'Location', 'southwest');
end

