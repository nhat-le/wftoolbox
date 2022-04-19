% Perform history regression using the averaged template data
% Will aggregate the templates, and regress against R(t-1)

root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/e57/*.mat', root));

agg_trials_master = [];
agg_incorr_master = [];
Ncorr_all = [];
Nincorr_all = [];

areaid_lst = [-653  -651  -335  -301  -300  -282  -275  -268  -261  -255  -249  -217  -198  -186  -178  -171, ...
     -164  -157  -150  -143  -136  -129  -121  -114  -107  -100   -92   -78   -71   -64   -57   -50, ...
     -43   -36   -29   -21   -15    -8     8    15    21    29    36    43    50    57    64    71, ...
     78    92   100   107   114   121   129   136   143   150   157   164   171   178   186   198, ...
     217 249   255   261   268   275   282   295 300   301   335   651   653];
 
agg_trials_master = [];
Ntrials_all = [];
reward_t_all = [];
reward_t1_all = [];
reward_t2_all = [];
reward_t3_all = [];
reward_t4_all = [];
reward_t5_all = [];

visited_area_ids = []; %keep track of which areas have been filled in the matrix
 
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
    
    % Only extract trials with delays
    dt_all = trialInfo.feedbackTimes - trialInfo.responseTimes;
    delaytrials = dt_all > max(dt_all) / 2;
    delaytrials(1:5) = 0; %skip first trial since no previous trials

    
    % Extract the mean for all delay trials
    agg_trials = template.aggData(:,end-nframes-10:end,delaytrials);
    
    [~,nfr,Ntrials] = size(agg_trials);

    currdim = size(agg_trials_master, 3);
    
    if currdim == 1
        currdim = 0;
    end
    
    % Gather the reward / past reward information
    trialidx = find(delaytrials);
    reward_t = trialInfo.feedback(trialidx);
    reward_t1 = trialInfo.feedback(trialidx - 1);
    reward_t2 = trialInfo.feedback(trialidx - 2);
    reward_t3 = trialInfo.feedback(trialidx - 3);
    reward_t4 = trialInfo.feedback(trialidx - 4);
    reward_t5 = trialInfo.feedback(trialidx - 5);
    
     
    if currdim == 0
        agg_trials_master = nan(numel(areaid_lst), nfr, Ntrials);
    else
        agg_trials_master(1:numel(areaid_lst),1:nfr,end+1:end+Ntrials) = nan;
    end
    assert(max([numel(reward_t) numel(reward_t1) numel(reward_t2) ...
        numel(reward_t3) numel(reward_t4) numel(reward_t5)]) == Ntrials);
    assert(min([numel(reward_t) numel(reward_t1) numel(reward_t2) ...
        numel(reward_t3) numel(reward_t4) numel(reward_t5)]) == Ntrials);

    reward_t_all = [reward_t_all reward_t];
    reward_t1_all = [reward_t1_all reward_t1];
    reward_t2_all = [reward_t2_all reward_t2];
    reward_t3_all = [reward_t3_all reward_t3];
    reward_t4_all = [reward_t4_all reward_t4];
    reward_t5_all = [reward_t5_all reward_t5];
    
    
    Ntrials_all(end+1) = Ntrials;
    
    % place into the master array
    for j = 1:numel(template.areaid)
        areaid = find(areaid_lst == template.areaid(j));
        assert(numel(areaid) > 0);
        agg_trials_master(areaid, :,currdim + 1 : currdim + Ntrials) = ...
            agg_trials(j,:,:);
    end
    
    
    assert(size(agg_trials_master, 3) == numel(reward_t_all));
    
    fprintf('%d, done: %s, %d\n', id, files(id).name, numel(template.areaid));
    if sum(~ismember(template.areaid, areaid_lst)) > 0
        fprintf('### flag:%s\n', files(id).name);
    end
 
end

%%
% save('processed/e57_data.mat', 'agg_trials_master', 'reward_t1_all', ...
%     'reward_t2_all', 'reward_t3_all', 'reward_t4_all', 'reward_t5_all', ...
%     'reward_t_all');

%% Perform the regression for each region and for each time point
[Nareas, T, Ntrials] = size(agg_trials_master);
CoefsR = nan(Nareas, T);
CoefsR1 = nan(Nareas, T);
CoefsR2 = nan(Nareas, T);
CoefsR3 = nan(Nareas, T);
CoefsR4 = nan(Nareas, T);
CoefsR5 = nan(Nareas, T);
CoefsI = nan(Nareas, T);

h = waitbar(0);
for areaID = 1:Nareas
    waitbar(areaID / Nareas, h);
    for t = 1:T
        y = squeeze(agg_trials_master(areaID, t, :));
        X = [reward_t_all' reward_t1_all' reward_t2_all' reward_t3_all' reward_t4_all'...
            reward_t5_all'];
        mdl = fitlm(X, y);
        
        CoefsI(areaID, t) = mdl.Coefficients.Estimate(1);
        CoefsR(areaID, t) = mdl.Coefficients.Estimate(2);
        CoefsR1(areaID, t) = mdl.Coefficients.Estimate(3);
        CoefsR2(areaID, t) = mdl.Coefficients.Estimate(4);
        CoefsR3(areaID, t) = mdl.Coefficients.Estimate(5);
        CoefsR4(areaID, t) = mdl.Coefficients.Estimate(6);
        CoefsR5(areaID, t) = mdl.Coefficients.Estimate(7);
        
        
    end
end
close(h)

%% Plot!
rot_angle = 0;
for t = 1:T
    diff_map = brainmap * 0;
    for i = 1:numel(areaid_lst)       
        areaID = areaid_lst(i);
        diff_map(brainmap == areaID) = CoefsR(i, t);
    end
    
    subplot(5, 6, t);
    diff_map = imrotate(diff_map, rot_angle);  
    rot_brainmap = imrotate(brainmap, rot_angle);
    diff_map(rot_brainmap == 0) = 0;
    
    imagesc(diff_map);
    colormap redblue
    caxis([-0.01 0.01])
    axis off

end

























