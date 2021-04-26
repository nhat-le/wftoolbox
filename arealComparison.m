% load('/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/processed/regionData_f04_040121pix.mat', 'template', 'trialInfo',...
%     'feedback', 'timingInfo')
% load('rawData_e54_20210223.mat', 'template', 'trialInfo', 'timingInfo', 'opts');
load('regionData_e54_031721pix.mat', 'template', 'trialInfo', 'timingInfo', 'opts', 'feedback');

delays = trialInfo.rewardDelays;
feedback = trialInfo.feedback;

% trialfile = dir(fullfile(opts.trialDataPath, '*Block.mat'));
% load(fullfile(trialfile.folder, trialfile.name));
% 
% feedback = block.events.feedbackValues(2:end);
% delays = [block.paramsValues.rewardDelay];
% delays = delays(2:end-1);

%% Plot 
% For this dataset: V1 = 18 and 56;
% SSp-ul1 = 29 and 44
% M1 = 35 and 38
% M2 = 34 and 39
% ORBm1 = 63, 11

RVISp1_id = find(strcmp(template.areaStrings, 'R-VISp1'));
LVISp1_id = find(strcmp(template.areaStrings, 'L-VISp1'));
RSSp_id = find(strcmp(template.areaStrings, 'R-SSp-ul1'));
LSSp_id = find(strcmp(template.areaStrings, 'L-SSp-ul1'));
RM1 = find(strcmp(template.areaStrings, 'R-MOp1'));
LM1 = find(strcmp(template.areaStrings, 'L-MOp1'));
RM2 = find(strcmp(template.areaStrings, 'R-MOs1'));
LM2 = find(strcmp(template.areaStrings, 'L-MOs1'));
RORBm1 = find(strcmp(template.areaStrings, 'R-ORBm1'));
LORBm1 = find(strcmp(template.areaStrings, 'L-ORBm1'));
LACC = find(strcmp(template.areaStrings, 'L-ACAd1'));
RACC = find(strcmp(template.areaStrings, 'R-ACAd1'));


%%
plotRegion(RM1, 'M1', template, feedback, delays, opts, timingInfo)
saveas(gcf, 'figures/e54_031721/M1-reward-modulation6.pdf');

plotRegion(RVISp1_id, 'VISp', template, feedback, delays, opts, timingInfo)
saveas(gcf, 'figures/e54_031721/V1-reward-modulation6.pdf');

plotRegion(RACC, 'ACC', template, feedback, delays, opts, timingInfo)
saveas(gcf, 'figures/e54_031721/ACC-reward-modulation6.pdf');

plotRegion(RORBm1, 'ORBm', template, feedback, delays, opts, timingInfo)
saveas(gcf, 'figures/e54_031721/ORBm-reward-modulation6.pdf');






function plotRegion(regionID, plotName, template, feedback, delays, opts, timingInfo)
regiondata = squeeze(template.aggData(regionID,:,:));
regionlatecorr = regiondata(:,delays > 0 & feedback == 1);
regionlateincorr = regiondata(:,delays > 0 & feedback == 0);

% Plot!
% plot(mean(v1latecorr, 2))
window = floor(opts.dt * timingInfo.fs);
zeroFrameID = floor(-window(1) / 2);
tpoints = ((1:size(regiondata, 1)) - zeroFrameID) / (timingInfo.fs / 2);
figure('Position', [0 0 250 200]);
l1 = stdshade(regionlatecorr' * 100,0.2,'b', tpoints);
hold on
l2 = stdshade(regionlateincorr' * 100,0.2,'r', tpoints);
title(plotName)
legend([l1, l2], {'Correct', 'Incorrect'}, 'FontSize', 10, 'Location', 'southeast')
xlabel('Time (s)')
ylabel('Mean df/f (%)')
ylim([-2,2])
xlim([-2 1])
set(gca, 'FontSize', 16)
vline(0, 'k--')
vline(-1, 'k--')
set(gca,'box','off');
% plot(mean(v1lateincorr, 2))

end





