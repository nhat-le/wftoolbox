% For combining all sessions of a given animal
% and compute the dprime value between reward and error trials



root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/e57/*.mat', root));

agg_corr_master = {};
agg_incorr_master = {};
maxoffset = 90;


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
    
    assert(opts.dt(2) == 1); %1-second window post-reward to extract
    fs = timingInfo.fs;
    % note: for f25: need to use window = 0.7s
    nframes = floor(opts.dt(2) * fs / 2);
    
    % e57: 33, f01: 39, f02: 22, f03:4 
    if id == 33
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
    delaytrials = dt_all > max(dt_all) / 2;
   
    
    % Extract the mean for correct and incorrect, for all offsets
    % for the current session
    agg_corr = {};
    for offsetid = 1:maxoffset
        agg_corr{offsetid} = template.aggData(:,end-nframes-10:end, ...
            delaytrials & trialInfo.feedback & pos_arr == offsetid);
        agg_incorr{offsetid} = template.aggData(:,end-nframes-10:end,...
            delaytrials & ~trialInfo.feedback & pos_arr == offsetid);
    end


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

lencorrs = cellfun(@(x) size(x, 3), agg_corr_master);
lenincorrs = cellfun(@(x) size(x, 3), agg_incorr_master);

plot(lencorrs)
hold on
plot(lenincorrs)


% fprintf('ncorr = %d, Nincorr = %d\n', size(agg_corr_master, 3), size(agg_incorr_master, 3));

%% Visualize average activity - note deprecated, 
% execute next cell instead
meancorr = nanmean(agg_corr_master, 3);
mean_incorr = nanmean(agg_incorr_master, 3);


Ncorr = size(agg_corr_master, 3);
std_corr = nanstd(agg_corr_master, [], 3);
Nincorr = size(agg_incorr_master, 3);
std_incorr = nanstd(agg_incorr_master, [], 3);

std_group = sqrt((std_corr.^2 * (Ncorr - 1) + std_incorr.^2 * (Nincorr - 1)) / ...
        (Ncorr + Nincorr - 2));
meandiff_all = (mean_incorr - meancorr) ./ std_group;


rot_angle = 34;

% plot
for tid = 1:size(meancorr, 2)
    t = tid;
    diff_map = brainmap * 0;
    for i = 1:numel(areaid_lst)       
        areaID = areaid_lst(i);
        diff_map(brainmap == areaID) = meandiff_all(i, t);
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



%%
corr_all = [];
incorr_all = [];
for i = 50:90
    corr_all = cat(3, corr_all, agg_corr_master{i});
    incorr_all = cat(3, incorr_all, agg_incorr_master{i});
end

%%
for i = 1:3
    visualize_dprime(agg_corr_master{i}, agg_incorr_master{i}, brainmap, areaid_lst)
end



function visualize_dprime(corr_arr, incorr_arr, brainmap, areaid_lst)
%corr_arr: array of correct responses, size nareas x T x ntrials
%incorr_arr: array of incorrect responses, size nareas x T x ntrials
% plots the dprime of each region over the course of the trial
% brainmap: xpix x ypix array containing the region annotation
% (incorrect - correct) responses

meancorr = nanmean(corr_arr, 3);
mean_incorr = nanmean(incorr_arr, 3);

figure;
Ncorr = size(corr_arr, 3);
std_corr = nanstd(corr_arr, [], 3);
Nincorr = size(incorr_arr, 3);
std_incorr = nanstd(incorr_arr, [], 3);

std_group = sqrt((std_corr.^2 * (Ncorr - 1) + std_incorr.^2 * (Nincorr - 1)) / ...
        (Ncorr + Nincorr - 2));
meandiff_all = (mean_incorr - meancorr) ./ std_group;


rot_angle = 34;
cmap = getPyPlot_cMap(Reds, 256);

% plot
for tid = 1:size(meancorr, 2)
    t = tid;
    diff_map = brainmap * 0;
    for i = 1:numel(areaid_lst)       
        areaID = areaid_lst(i);
        diff_map(brainmap == areaID) = meandiff_all(i, t);
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








     
