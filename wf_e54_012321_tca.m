%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

% example 1
% opts.filePath = '/Users/minhnhatle/Dropbox (MIT)/wfdata/e50_011021';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e50/2021-01-10/2';

% example 2
opts.filePath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/Dec2020/e54-12272020/e54blockworld';
opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2020-12-27/1';

% example 3 (with hemocorrection)
% opts.filePath = '/Users/minhnhatle/Dropbox (MIT)/wfdata/e54_012321';
% opts.trialDataPath = '/Users/minhnhatle/Dropbox (MIT)/Nhat/Rigbox/e54/2021-01-23/3';

opts.refImgPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/surfaceRotated2.tif';
opts.refAtlasPath = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e54Template/atlas_E54.mat';

opts.alignBorders = 1; % to return
opts.motionCorrect = 0;
opts.hemoCorrect = 0;
opts.ignoreFirstTrial = 1;

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
load e54_012321_tca_nonneg.mat
% Trial factor
for id = 1:5
    figure;
    plot(find(trialInfo.responses == 1), W(trialInfo.responses == 1,id), 'o');
    hold on
    plot(find(trialInfo.responses == -1), W(trialInfo.responses == -1,id), 'o');
end


%% Display the factors
for id = 1:5
    figure;
    subplot(311)
    bar(U(:,id))
    xticks(1:78)
    xticklabels(areaStrings)
    xtickangle(45)
    ylabel('Neuron factor')

    subplot(312)
    plot(find(trialInfo.feedback == 1), W(trialInfo.feedback == 1,id), 'o');
    hold on
    plot(find(trialInfo.feedback == 0), W(trialInfo.feedback == 0,id), 'o');
    xlabel('Trial number')
    ylabel('Trial factor')

    subplot(313)
    tpoints = linspace(-0.5, 1, 15);
    plot(tpoints, V(:,id))
    ylabel('Temporal factor')
    xlabel('Time (s)')
end


%% Clustering based on the neuron factor
idx = kmeans(U, 5);
[ids,idsort] = sort(idx);
idcount = find(diff(ids));
Usort = U(idsort,:);
areaStringSort = areaStrings(idsort);
imagesc(Usort)
hold on
for i = 1:numel(idcount)
    hline(idcount(i) + 0.5, 'w');
end
    
yticks(1:numel(areaid));
yticklabels(areaStringSort);
ytickangle(45)

xlabel('Factor')
ylabel('Area ID')
set(gca, 'FontSize', 16)



%%
% TODO: visualize ROI activity
% roiCentroids = floor([202 119; 171 146; 280 195]);
roiCentroids = floor([202 119; 171 146; 280 195]/5);

pointerSize = 10;
figure('Position', [43, 406, 1086, 392]);
a1 = subplot(131);
plotROIAverages(allData.bData(:,:,:,trialInfo.feedback == 0), roiCentroids, ...
    pointerSize, opts, timingInfo, allData.window)
title('Blue, correct')

a2 = subplot(132);
plotROIAverages(allData.vData(:,:,:,trialInfo.feedback == 0), roiCentroids, ...
    pointerSize, opts, timingInfo, allData.window)
title('Violet, correct')

a3 = subplot(133);
plotROIAverages(allData.data(:,:,:,trialInfo.feedback == 0), roiCentroids, ...
    pointerSize, opts, timingInfo, allData.window)
title('Corrected, correct')

linkaxes([a1, a2, a3])

%% Get the aggregate area information
% Alignment
if opts.alignBorders
    template = alignImages(opts, allData);
end


%% Browsing the raw data and average stack
% compareMovie(filteredIncorr); %use this GUI to browse the widefield data stack
compareMovie(allData.bData);

%% Split into left or right trials
criterion1.feedback = 0; %1 or 0; filter only rewarded/non-rewarded trials
criterion1.response = nan; %-1 or 1; filter only left/right trials
criterion1.delay = nan; %'early' or 'late'; filter trials with or without delay
criterion1.trialSubset = nan;

criterion2.feedback = 1; %1 or 0; filter only rewarded/non-rewarded trials
criterion2.response = nan; %-1 or 1; filter only left/right trials
criterion2.delay = nan; %'early' or 'late'; filter trials with or without delay
criterion2.trialSubset = nan;


[filteredIncorr, avgIncorr] = filterTrials(allData.data, criterion1, trialInfo);
[filteredCorr, avgCorr] = filterTrials(allData.data, criterion2, trialInfo);

%%
visualizePeakInfo(avgIncorr, opts, timingInfo)



%% Visualize the areal summary
templateOpts.brainSide = 'left'; % 'left' or 'right'
templateOpts.sortBy = 'pks'; %'pks' or 'pkTimes'
templateOpts.normalize = 0;

[idx, sortedTimes] = visualizeAreaSummary(allData, avgCorr, templateOpts, template, timingInfo);

templateOpts.sortBy = idx; % sort by the same order as previous
[idx2,sortedTimes2] = visualizeAreaSummary(allData, avgIncorr, templateOpts, template, timingInfo);



