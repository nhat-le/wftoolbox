% For combining all sessions of a given animal
% and compute the dprime value between reward and error trials



root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/e57/*.mat', root));

agg_corr_master = [];
agg_incorr_master = [];
Ncorr_all = [];
Nincorr_all = [];

areaid_lst = [-653  -651  -335  -301  -300  -282  -275  -268  -261  -255  -249  -217  -198  -186  -178  -171, ...
     -164  -157  -150  -143  -136  -129  -121  -114  -107  -100   -92   -78   -71   -64   -57   -50, ...
     -43   -36   -29   -21   -15    -8     8    15    21    29    36    43    50    57    64    71, ...
     78    92   100   107   114   121   129   136   143   150   157   164   171   178   186   198, ...
     217 249   255   261   268   275   282   295 300   301   335   651   653];

for id = 1:numel(files)
    

    
    parts = strsplit(files(id).name, '_');
    animal = parts{2};
    expdate = parts{end}(1:end-7);
    
    % Load the template file
    load(fullfile(files(id).folder, files(id).name));
    
    % Load the trial info if exists
    try
        [trialInfo, opts, timingInfo] = helper.load_trial_info(animal, expdate);
    catch
        fprintf('%s: file does not exist\n', files(id).name)
        continue
    end
    
    fs = timingInfo.fs;
    nframes = floor(opts.dt(2) * fs / 2);

    if ~strcmp(animal, 'f25')
        assert(opts.dt(2) == 1); %1-second window post-reward to extract
    end

    switch animal
        case 'e57'
            idbrainmap = 33;
        case 'f01'
            idbrainmap = 39;
        case 'f02'
            idbrainmap = 22;
        case {'f03', 'f04', 'f25'}
            idbrainmap = 4;
    end

    % e57: 33, f01: 39, f02: 22, f03:4 
    if id == idbrainmap
        brainmap = template.atlas;
        
    end

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
%     delaytrials = dt_all > max(dt_all) / 2;
    delaytrials = logical(dt_all * 0 + 1);
    

    
    % Extract the mean for correct and incorrect
    agg_corr = [];
    agg_corr = template.aggData(:,end-nframes-10:end, ...
        delaytrials & trialInfo.feedback);
    agg_incorr = template.aggData(:,end-nframes-10:end,...
        delaytrials & ~trialInfo.feedback);
    [~,nfr,Ncorr] = size(agg_corr);


    Nincorr = size(agg_incorr, 3);
    
    
    currdim_corr = size(agg_corr_master, 3);
    currdim_incorr = size(agg_incorr_master, 3);
    
    if currdim_corr == 1
        currdim_corr = 0;
    end
    
    if currdim_incorr == 1
        currdim_incorr = 0;
    end
       
    
    agg_corr_master(1:numel(areaid_lst),1:nfr,end+1:end+Ncorr) = nan;
    agg_incorr_master(1:numel(areaid_lst),1:nfr,end+1:end+Nincorr) = nan;
    
    Ncorr_all(end+1) = Ncorr;
    Nincorr_all(end+1) = Nincorr;
    
    % place into the master array
    for j = 1:numel(template.areaid)
        areaid = find(areaid_lst == template.areaid(j));
        agg_corr_master(areaid, :,currdim_corr + 1 : currdim_corr + Ncorr) = ...
            agg_corr(j,:,:);
        agg_incorr_master(areaid, :,currdim_incorr + 1 : currdim_incorr + Nincorr) = ...
            agg_incorr(j,:,:);
    end
    
    
    fprintf('%d, done: %s, %d\n', id, files(id).name, numel(template.areaid));
    if sum(~ismember(template.areaid, areaid_lst)) > 0
        fprintf('### flag:%s\n', files(id).name);
    end
    
end

fprintf('ncorr = %d, Nincorr = %d\n', size(agg_corr_master, 3), size(agg_incorr_master, 3));

%% Visualize average activity
meancorr = nanmean(agg_corr_master, 3);
mean_incorr = nanmean(agg_incorr_master, 3);


Ncorr = size(agg_corr_master, 3);
std_corr = nanstd(agg_corr_master, [], 3);
Nincorr = size(agg_incorr_master, 3);
std_incorr = nanstd(agg_incorr_master, [], 3);

std_group = sqrt((std_corr.^2 * (Ncorr - 1) + std_incorr.^2 * (Nincorr - 1)) / ...
        (Ncorr + Nincorr - 2));
meandiff_all = (mean_incorr - meancorr) ./ std_group;


figure('Position', [399,191,556,511]);
rot_angle = 36;

% plot
for tid = 1:size(meancorr, 2)
    t = tid;
    diff_map = brainmap * 0;
    for i = 1:numel(areaid_lst)       
        areaID = areaid_lst(i);
        diff_map(brainmap == areaID) = meandiff_all(i, t);
    end
    
%     nexttile
    diff_map = imrotate(diff_map, rot_angle);  
    rot_brainmap = imrotate(brainmap, rot_angle);
    diff_map(rot_brainmap == 0) = 0;
    
    imagesc(diff_map);
    colormap(redblue);
%     l.S
    caxis([-0.5 0.5])
    l = colorbar;
%     l
    axis off

end












     
