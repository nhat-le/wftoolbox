% paper figure 2 section 2: visualizing the raw traces averaged by region.

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
[regionsCorr_arr, regionsIncorr_arr, corr_norm_all, incorr_norm_all] = ...
    get_aligned_responses(animal, dates_to_extract, areaname, opts);


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





function [regionsCorr_arr, regionsIncorr_arr, corr_norm_all, incorr_norm_all] = ...
    get_aligned_responses(animal, dates_to_extract, areaname, opts)
% Get correct and incorrect responses given animal and a set of dates
% animal: string, animal name
% dates_to_extract: cell of strings, dates of sessions of interest
% areaname: string, name of area of interest
% opts: options, include: removeoutliers, normalize_mode
root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/%s/*.mat', root, animal));

idlst = find(contains({files.name}, dates_to_extract)); %[17 20 21 28];
Nframes = [];
Ntrials_corr = [];
Ntrials_incorr = [];

regionsCorr_all = {};
regionsIncorr_all = {};

% areaname = 'VISp1_R';
% areaname = 'SSp_bfd1_R';

removeoutliers = opts.removeoutliers;
normalize_mode = opts.normalize_mode;



for i = 1:numel(idlst) %id of file to investigate
    id = idlst(i);
    parts = strsplit(files(id).name, '_');
    animal = parts{2};
    expdate = parts{end}(1:end-7);

    assert(strcmp(expdate, dates_to_extract{i}))

    
    % Load the template file
    load(fullfile(files(id).folder, files(id).name));
    fprintf('%d: %s\n', id, files(id).name)
    disp(size(template.aggData))

    [Nareas, T, Ntrials] = size(template.aggData);

    % Load the trial information, split into correct and incorrect
    try
        [trialInfo, opts, ~] = helper.load_trial_info(animal, expdate);
    catch
        fprintf('%s: file does not exist\n', files(id).name)
    end


    if opts.dt(1) == -1 % delay = 0s, just split into corr / incorr
        regionCorr = template.aggData(:, :, trialInfo.feedback == 1);
        regionIncorr = template.aggData(:, :, trialInfo.feedback == 0);
    else
        regionCorr = template.aggData(:, :, trialInfo.feedback == 1 & trialInfo.rewardDelays > 0);
        regionIncorr = template.aggData(:, :, trialInfo.feedback == 0 & trialInfo.rewardDelays > 0);
    end

    % Extract the area of interest
    areaid = template.areanames.(areaname);
    area_idx = find(template.areaid == areaid);
    assert(numel(area_idx) == 1);

    areaCorr = squeeze(regionCorr(area_idx, :, :));
    areaIncorr = squeeze(regionIncorr(area_idx, :, :));

    if removeoutliers
        areaCorr = rmoutliers(areaCorr')';
        areaIncorr = rmoutliers(areaIncorr')';
    end

    regionsCorr_all{i} = areaCorr;
    regionsIncorr_all{i} = areaIncorr;

    Nframes(i) = T;
    Ntrials_corr(i) = size(areaCorr, 2);
    Ntrials_incorr(i) = size(areaIncorr, 2);

end

[regionsCorr_arr, regionsIncorr_arr, corr_norm_all, incorr_norm_all] = combine_matrices(regionsCorr_all, ...
    regionsIncorr_all, normalize_mode);

end












function [regionsCorr_arr, regionsIncorr_arr, corr_norm_all, incorr_norm_all] = combine_matrices(regionsCorr_all, ...
    regionsIncorr_all, normalize_mode)
% combine the correct and incorrect information from different sessions
% into a giant matrix
% Inputs: regionsCorr_all: an Nsessions x 1 cell array, each has dimension
% T x Ntrials in the session
% regionsIncorr_all: same dimensions, but for incorrect trials
% normalize_mode: 'peaktrough' or 'meanstd'
% Returns: regionsCorr_arr: an Ntrials (correct) x T array with combined
% correct trials from all sessions
% regionsIncorr_arr: an Ntrials (incorrect) x T array with combined incorrect
% trials from all sessions
% corr_norm_all: same dimensions as regionsCorr_all, but normalized
% incorr_norm_all: same dimesnions as regionsIncorr_all, but normalized

% calculate the number of frames and trials
Nframes = [];
Ntrials_corr = [];
Ntrials_incorr = [];
for i = 1:numel(regionsCorr_all)
    Nframes(i) = size(regionsCorr_all{i}, 1);
    Ntrials_corr(i) = size(regionsCorr_all{i}, 2);
    Ntrials_incorr(i) = size(regionsIncorr_all{i}, 2);
end



Nframes_max = max(Nframes);
regionsCorr_arr = nan(Nframes_max, sum(Ntrials_corr));
regionsIncorr_arr = nan(Nframes_max, sum(Ntrials_incorr));
corr_norm_all = {};
incorr_norm_all = {};

ctr = 1;
for i = 1:numel(regionsCorr_all)
    % normalization constants
    if strcmp(normalize_mode, 'peaktrough')
        combined_arr = [regionsCorr_all{i} regionsIncorr_all{i}]; %dimensions: T x Ntrials
        meantrace = mean(combined_arr, 2);
        trough = min(meantrace(1:20));
        peak = nanmax(meantrace(10:37));
        corr_norm = (regionsCorr_all{i} - trough) / (peak - trough);
    elseif strcmp(normalize_mode, 'meanstd')
        combined_arr = [regionsCorr_all{i} regionsIncorr_all{i}]; %dimensions: T x Ntrials
        meanimg = mean(combined_arr(:));
        stdimg = std(combined_arr(:));
        corr_norm = (regionsCorr_all{i} - meanimg) / stdimg;

    end

    corr_norm_all{i} = corr_norm;
    currNtrials = Ntrials_corr(i);
    regionsCorr_arr(1:Nframes(i), ctr:ctr+currNtrials-1) = corr_norm;
    ctr = ctr + currNtrials;
end

ctr = 1;
for i = 1:numel(regionsIncorr_all)
    % normalization constants
    if strcmp(normalize_mode, 'peaktrough')
        combined_arr = [regionsCorr_all{i} regionsIncorr_all{i}]; %dimensions: T x Ntrials        
        meantrace = mean(combined_arr, 2);
        trough = min(meantrace(1:20));
        peak = nanmax(meantrace(10:37));
        incorr_norm = (regionsIncorr_all{i} - trough) / (peak - trough);
    elseif strcmp(normalize_mode, 'meanstd')
        combined_arr = [regionsCorr_all{i} regionsIncorr_all{i}]; %dimensions: T x Ntrials
        meanimg = mean(combined_arr(:));
        stdimg = std(combined_arr(:));
        incorr_norm = (regionsIncorr_all{i} - meanimg) / stdimg;
    end

    incorr_norm_all{i} = incorr_norm;
    currNtrials = Ntrials_incorr(i);
    regionsIncorr_arr(1:Nframes(i), ctr:ctr+currNtrials-1) = incorr_norm;
    ctr = ctr + currNtrials;
end


end












