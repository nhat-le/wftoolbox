% paper figure 2 section 2: visualizing the raw traces averaged by region.
% for visualizing the responses across regions, pooled across
% multiple sessions with the same delay conditions
addpath('/Users/minhnhatle/Documents/ExternalCode/wftoolbox/scripts/glm')

root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/e57/*.mat', root));

areaid_lst = [-653  -651  -335  -301  -300  -282  -275  -268  -261  -255  -249  -217  -198  -186  -178  -171, ...
     -164  -157  -150  -143  -136  -129  -121  -114  -107  -100   -92   -78   -71   -64   -57   -50, ...
     -43   -36   -29   -21   -15    -8     8    15    21    29    36    43    50    57    64    71, ...
     78    92   100   107   114   121   129   136   143   150   157   164   171   178   186   198, ...
     217 249   255   261   268   275   282   295 300   301   335   651   653];


% files with 0s, 0.5s, 1s, 2s delay
% dates_to_extract = {'030421', '030821', '030921', '032221'};

% e57, no delays
% dates_to_extract = {'021721', '021821', '021921', '022321', '022621', '030221', '030321', '030421'};

% e57, 0.5s delays
% dates_to_extract = {'030521', '030621', '030821'};
% dates_to_extract = {'030621', '030821'};

% e57, 1s delays
% dates_to_extract = {'030921', '031021', '031221', '031621', '031721', '031921'};

% e57, 2s delays
% dates_to_extract = {'032221', '032321', '032521', '032621', '032921', '033021'};



%%
animal = 'e57';
delayT = 1;
dates_to_extract = get_session_dates('e57', delayT, 'half');
areaname = 'MOp1_R';
opts.removeoutliers = 1;
opts.normalize_mode = 'meanstd';
%%

% Get the common regions
regions = get_shared_regions(animal, dates_to_extract);

dprime_all = [];
for i = 1:numel(regions)
    areaname = regions{i};
    
    dprime_all(i,:) = get_dprime_combined(animal, dates_to_extract, areaname, opts);
end










%% responses aligned to choice
nFramesPre = floor(37 / 2);
tstamps = ((1:size(regionsCorr_arr, 1)) - nFramesPre) / (37 / 2);
figure('Position', [440,440,870,358])
subplot(131)
imagesc(regionsCorr_arr', 'XData', tstamps)
l = hline(cumsum(Ntrials_corr), 'w--');
set(l, 'LineWidth', 2)
vline([0 delayT], 'w--')
caxis([-2, 2])

subplot(132)
imagesc(regionsIncorr_arr', 'XData', tstamps)
l = hline(cumsum(Ntrials_incorr), 'w--');
set(l, 'LineWidth', 2)
vline([0 delayT], 'w--')
caxis([-2, 2])


subplot(133)
mean_correct = mean(regionsCorr_arr, 2);
mean_incorrect = mean(regionsIncorr_arr, 2);
plot(tstamps, mean_correct)
hold on
plot(tstamps, mean_incorrect);

% filename = 'data/e57/e57data_2s-delay.mat';
% if ~exist(filename)
%     save(filename, 'tstamps', 'mean_incorrect', 'mean_correct')
% else
%     fprintf('File exists, skipping save...\n');
% end
% caxis([-0.08, 0.08])








