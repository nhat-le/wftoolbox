% For combining *specific sessions* of a given animal
% and compute the dprime value between reward and error trials
addpath('/Users/minhnhatle/Documents/ExternalCode/wftoolbox/scripts/glm/raw-viz');

animal = 'f03';

load('data/default_template.mat', 'template');

root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/%s/*.mat', root, animal));

agg_corr_master = {};
agg_incorr_master = {};
maxoffset = 90;

session_lst = get_session_dates(animal, 0, 'half');


areaid_lst = [-653  -651  -335  -301  -300  -282  -275  -268  -261  -255  -249  -217  -198  -186  -178  -171, ...
     -164  -157  -150  -143  -136  -129  -121  -114  -107  -100   -92   -78   -71   -64   -57   -50, ...
     -43   -36   -29   -21   -15    -8     8    15    21    29    36    43    50    57    64    71, ...
     78    92   100   107   114   121   129   136   143   150   157   164   171   178   186   198, ...
     217 249   255   261   268   275   282   295 300   301   335   651   653];

% corresponding region names
region_names = {};
for i = 1:numel(areaid_lst)
    idx = find(template.areaid == areaid_lst(i));
    if numel(idx) < 1
        % for area names not listed
        switch areaid_lst(i)
            case -651
                regions_names{i} = ' ';
            case -217
                region_names{i} = 'R-ORBm1';
            case -92
                region_names{i} = 'R-VISC1';
            case 295
                region_names{i} = 'L-ECT1';
            otherwise
                error('unknown region')
        end

    else
        assert(numel(idx) == 1)
        region_names{i} = template.areaStrings{idx};
    end



end



%%
for id = 1:numel(files)

    parts = strsplit(files(id).name, '_');
    animal = parts{2};
    expdate = parts{end}(1:end-7);

    if ~ismember(expdate, session_lst)
        continue
    end

%     if ~ismember(expdate, {'040121', '040221', '040621', '040721', '040921'})
%         continue
%     end
    
    % Load the template file
    load(fullfile(files(id).folder, files(id).name));
    
    % Load the trial info if exists
    try
        [trialInfo, opts, timingInfo] = helper.load_trial_info(animal, expdate);
    catch
        error('Raw data load failed')
        fprintf('%s: file does not exist\n', files(id).name)
        continue
    end
    
    assert(opts.dt(2) == 1); %1-second window post-reward to extract
    fs = timingInfo.fs;
    % note: for f25: need to use window = 0.7s
    nframes = floor(opts.dt(2) * fs / 2);
    
    % e57: 33, f01: 39, f02: 22, f03:4 
    brainmap = template.atlas;
        
    % compute the position in the block
    currpos = 0;
    pos_arr = 0;
    for k = 2:numel(trialInfo.target)
        if (trialInfo.target(k - 1) == trialInfo.target(k))
            currpos = currpos + 1;
            pos_arr(end+1) = currpos;
        else
            currpos = 0;
            pos_arr(end+1) = currpos;
        end
    end
    
    
    % Only extract trials with delays
    dt_all = trialInfo.feedbackTimes - trialInfo.responseTimes;

    if opts.dt(1) == -1 %no delay, keep all
        delaytrials = ones(1, numel(dt_all));
    else
        delaytrials = trialInfo.rewardDelays == -opts.dt(1) - 1;
    end
   
    
    % Extract the mean for correct and incorrect, for all offsets
    % for the current session
    % agg_corr has Noffsets cells, each cell has dimension Nareas x T x
    % Ntrials
    agg_corr = {};
    agg_incorr = {};
    for offsetid = 1:maxoffset
        agg_corr{offsetid} = template.aggData(:,:, ...
            delaytrials & trialInfo.feedback & pos_arr == offsetid);
        agg_incorr{offsetid} = template.aggData(:,:,...
            delaytrials & ~trialInfo.feedback & pos_arr == offsetid);
    end

    % agg_corr_master has Noffsets cells, each cells has dimesnion
    % Nareas x T x Ntrials
    % Update the master arrays for all offsets
    for offsetid = 1:maxoffset
        [~,nfr,Ncorr] = size(agg_corr{offsetid});
        Nincorr = size(agg_incorr{offsetid}, 3);

        if numel(agg_corr_master) < offsetid
            currdim_corr = 0;
            currdim_incorr = 0;
            
            agg_corr_master{offsetid} = [];
            agg_incorr_master{offsetid} = [];


        else

            currdim_corr = size(agg_corr_master{offsetid}, 3);
            currdim_incorr = size(agg_incorr_master{offsetid}, 3);
        end
        

        agg_corr_master{offsetid}(1:numel(areaid_lst),1:nfr,end+1:end+Ncorr) = nan;
        agg_incorr_master{offsetid}(1:numel(areaid_lst),1:nfr,end+1:end+Nincorr) = nan;
        
        
        % place into the master array
        % TODO: handle case where the areaid is not found on the list;
        % currently entry is left as nan which is not ideal
        for j = 1:numel(template.areaid)
            areaid = find(areaid_lst == template.areaid(j));
            agg_corr_master{offsetid}(areaid, :,currdim_corr + 1 : currdim_corr + Ncorr) = ...
                agg_corr{offsetid}(j,:,:);
            agg_incorr_master{offsetid}(areaid, :,currdim_incorr + 1 : currdim_incorr + Nincorr) = ...
                agg_incorr{offsetid}(j,:,:);
        end

    end


    fprintf('%d, done: %s, %d\n', id, files(id).name, numel(template.areaid));
    if sum(~ismember(template.areaid, areaid_lst)) > 0
        fprintf('### flag:%s\n', files(id).name);
    end
   
        
    
    
end

%%
% corr_all has shape Nareas x T x Ntrials (combined for all sessions)
corr_all = [];
incorr_all = [];
for i = 1:numel(agg_corr_master)
    corr_all = cat(3, corr_all, agg_corr_master{i});
    incorr_all = cat(3, incorr_all, agg_incorr_master{i});
end

%% plot dprime, sorted by the mean dprime 1s after reward

sort_id = 1;
dprime = visualize_dprime(corr_all, incorr_all, brainmap, areaid_lst);
tpoints = ((1:size(dprime, 2)) - (37/2 * (-opts.dt(1)))) / (37/2);

dprime_means = nanmean(dprime(:, end-36/2:end), 2);

if sort_id
    [~,idsort] = sort(dprime_means(1:38,:)); %1-38 corresponds to R side
else
    idsort = 1:size(dprime_means, 1);
end

% fine-tune (eliminate 'nan' regions)
good_idx = [];
good_region_names = {};
for i = 1:numel(idsort)
    region = region_names{idsort(i)};
    if ~isempty(region) && sum(dprime(idsort(i),:)) ~= 0
        good_idx = [good_idx i];
        good_region_names{end+1} = region_names{idsort(i)}(3:end);
    end
end

idsort = idsort(good_idx);

figure('Position', [327,14,500,784]);
imagesc(dprime(idsort, :), 'XData', tpoints)
yticks(1:numel(good_region_names))
yticklabels(good_region_names)
colormap redblue
caxis([-1 1])
l = vline(0);
set(l, 'LineStyle', '--', 'Color', 'k')
colorbar();
set(gca, 'FontSize', 14)
xlabel('Time (s)')

%% plot mean correct/incorrect activities for each region
corr_mean = squeeze(nanmean(corr_all, 3));
incorr_mean = squeeze(nanmean(incorr_all, 3));

cmap = getPyPlot_cMap('gray_r');

figure('Position', [440,157,613,641]);
subplot(121)
imagesc(corr_mean(idsort,:), 'XData', tpoints)
yticks(1:numel(good_region_names))
yticklabels(good_region_names)
l = vline(0);
set(l, 'LineStyle', '--', 'Color', 'k')
colormap(cmap)
xlabel('Time (s)')
set(gca, 'FontSize', 14)
title('Correct')


caxis([-0 0.01])


subplot(122)
imagesc(incorr_mean(idsort,:), 'XData', tpoints)
yticks(1:numel(good_region_names))
yticklabels(good_region_names)
l = vline(0);
set(l, 'LineStyle', '--', 'Color', 'k')

colormap(cmap)
caxis([-0 0.01])
xlabel('Time (s)')
title('Incorrect')


set(gca, 'FontSize', 14)



%% plot activity for individual regions
region_single = 'R-SSp-ll1';
id_region = find(strcmp(region_names, region_single));

regionCorrArr = squeeze(corr_all(id_region, :, :));
regionIncorrArr = squeeze(incorr_all(id_region, :, :));

figure;
plot(nanmean(regionCorrArr, 2))
hold on
plot(nanmean(regionIncorrArr, 2))


%%
[xC,yC] = find(isnan(regionCorrArr));
[xI,yI] = find(isnan(regionIncorrArr));

idCall = 1:size(regionCorrArr, 2);
idIall = 1:size(regionIncorrArr, 2);
yCbad = unique(yC);
yIbad = unique(yI);

idCall(yCbad) = [];
idIall(yIbad) = [];


figure;
subplot(121)
imagesc(regionCorrArr(:,idCall)')
caxis([-0.005, 0.005])

subplot(122)
imagesc(regionIncorrArr(:,idIall)');
caxis([-0.005, 0.005])







function dprime = visualize_dprime(corr_arr, incorr_arr, brainmap, areaid_lst, varargin)
%corr_arr: array of correct responses, size nareas x T x ntrials
%incorr_arr: array of incorrect responses, size nareas x T x ntrials
% plots the dprime of each region over the course of the trial
% brainmap: xpix x ypix array containing the region annotation
% (incorrect - correct) responses

if numel(varargin) == 0
    showplot = 0;
else
    showplot = varargin{1};
end

meancorr = nanmean(corr_arr, 3);
mean_incorr = nanmean(incorr_arr, 3);

Ncorr = size(corr_arr, 3);
std_corr = nanstd(corr_arr, [], 3);
Nincorr = size(incorr_arr, 3);
std_incorr = nanstd(incorr_arr, [], 3);

std_group = sqrt((std_corr.^2 * (Ncorr - 1) + std_incorr.^2 * (Nincorr - 1)) / ...
        (Ncorr + Nincorr - 2));
dprime = (mean_incorr - meancorr) ./ std_group;
dprime(std_group == 0) = 0;  % handle division by zero case


rot_angle = 34;
% cmap = getPyPlot_cMap(Reds, 256);

% plot
if showplot
    figure;

    for tid = 1:size(meancorr, 2)
        t = tid;
        diff_map = brainmap * 0;
        for i = 1:numel(areaid_lst)       
            areaID = areaid_lst(i);
            diff_map(brainmap == areaID) = dprime(i, t);
        end
        
        nexttile
        diff_map = imrotate(diff_map, rot_angle);  
        rot_brainmap = imrotate(brainmap, rot_angle);
        diff_map(rot_brainmap == 0) = 0;
        
        imagesc(diff_map);
        colormap redblue
        caxis([-0.5 0.5])
        axis off
    
    end
end

end








     
