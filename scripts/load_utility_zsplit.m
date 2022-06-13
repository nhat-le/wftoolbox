% Script for loading wf imaging data
% Performs a spliting based on the z-states of the blockHMM results
% then performs logistic regression on previous trial history

batch_names = {'allData_extracted_e57_030221pix.mat',... % badfile since split across many sub sessions
    'allData_extracted_e57_030321pix.mat',...
    'allData_extracted_e57_030421pix.mat',...
    'allData_extracted_f01_030421pix.mat',...
    'allData_extracted_f01_030921pix.mat',...
    'allData_extracted_f01_043021pix.mat',...
    'allData_extracted_F02_030121pix.mat',... % badfile (split in 2 sessions, assertion error)
    'allData_extracted_f02_030221pix.mat',...
    'allData_extracted_f02_030321pix.mat',...
    'allData_extracted_f02_030421pix.mat',...
    'allData_extracted_f02_043021pix.mat',...
    'allData_extracted_f03_030121pix.mat',...
    'allData_extracted_f03_031921pix.mat',...
    'allData_extracted_f03_032221pix.mat',... % badfile (split in 2 sessions, assertion error)
    'allData_extracted_f03_041921pix.mat',...
    'allData_extracted_f03_042021pix.mat',...
    'allData_extracted_f03_042121pix.mat',...
    'allData_extracted_f04_030221pix.mat',...
    'allData_extracted_f04_030321pix.mat',...
    'allData_extracted_f04_031921pix.mat',...
    'allData_extracted_f04_042821pix.mat',...
    'allData_extracted_f25_100121pix.mat',...
    'allData_extracted_f25_100421pix.mat',...
    'allData_extracted_f25_100521pix.mat',...
    'allData_extracted_f25_100621pix.mat'};

paths = pathsetup('wftoolbox');
       
opts.date = '022822_wf';

% directory with the extracted imaging data files (.mat)
% opts.filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw/extracted/f25';
opts.filedir = paths.keji_path;
% opts.filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw/extracted/e57';

%directory that stores the zstate data
% opts.zdir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/processed_data/expdata/111821'; 
opts.zdir = fullfile('/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/processed_data/blockhmmfit',...
    opts.date);

% directory with the _all_data files
opts.alldata_dir = fullfile('/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/processed_data/expdata', ...
    opts.date);

% directory to save regression coefficients
opts.savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';
opts.window = 5;
opts.roisize = 9;
opts.xgrid = 10:3:110;
opts.ygrid = 10:3:110;
opts.subset = -1;
opts.daysession = 1; %3rd session in the day TODO: push this in the parent function


%%

for i = 4 %:numel(batch_names)
    
    fprintf('------- Processing file %d of %d: %s... ------\n', i, ...
        numel(batch_names), batch_names{i});
    opts.filename = batch_names{i};
    parts = strsplit(opts.filename, '_');
    opts.animal = lower(parts{3});

    opts.sessid = parts{4}(1:6);


    out = utils.do_wf_regression_zsplit(opts);
           
end

%% Visualize the feedback/choices split by zstates
figure;
maxN = max(cellfun(@(x) numel(x), out.feedback));
for i = 1:4
    subplot(2,2,i)
    trial_subset = find(out.zstates == i);
    feedbackarr = zeros(numel(trial_subset), maxN) + 2;
    for j = 1:numel(trial_subset)
        fbsingle = out.feedback{trial_subset(j)};
        feedbackarr(j, 1:numel(fbsingle)) = fbsingle;
    end
    imagesc(feedbackarr)
    
    
end


%% Let's split the data into trial position in block
Nmax = 15;

zstates = out.zstates;
zsingles = unique(zstates);
datameans = {};
block_subsets = {};
for zid = 1:numel(zsingles)
    zval = zsingles(zid);
    fprintf('Processing z state %d...\n', zval);
    datamean = nan(size(out.data, 1), size(out.data, 2), size(out.data, 3), Nmax);

    block_subset = find(zstates == zval);


    for window = 1:Nmax
        trial_subset = get_trialidx_from_blocks(out.trialidx, block_subset, window);
        datamean(:,:,:,window) = average_data_by_trial_subsets(out.data, trial_subset);

    end
    
    datameans{end+1} = datamean;
    block_subsets{end+1} = block_subset;
end


%% Let's visualize the datamean


trials_plot = 1:15;
times_plot = 1:5:37;

for blockid = 1:numel(datameans)
    datamean = datameans{blockid};
    figure;
    count = 1;
    for i = trials_plot
        for j = times_plot
            subplot(numel(trials_plot), numel(times_plot), count)
            imagesc(datamean(:,:,j,i))

            if j == 1
                ylabel(num2str(i))          
            end

            if i == 1
                title(num2str((j - 18) / 37))
            end

            caxis([-0.03, 0.03])

            count = count + 1;
        end
    end
end
    

%% Save the data when requested
opts.savefile = 1;
savefilename = fullfile(paths.processed_path, ...
    sprintf('zsplit_averaged/030322/%s_%s_trialdata_zaveraged_030322.mat', opts.animal, opts.sessid));
if opts.savefile && ~exist(savefilename, 'file')
    out.data = [];
    save(savefilename, 'opts', 'out', 'datameans', 'block_subsets');
    fprintf('File saved!\n')
end


function trial_subset = get_trialidx_from_blocks(trialidx, block_ids, position)
% trialidx: cell array consisting of trial idx split by block
% block_ids: ids of blocks of interest, if -1, will include all blocks
% position: trial position to include

trial_subset = [];

if block_ids == -1
    block_ids = 1:numel(trialidx);   
end


for i = 1:numel(block_ids)
    trials = trialidx{block_ids(i)};
    if numel(trials) >= position
        trial_subset(end+1) = trials(position);
    end
     
end


end



function out = average_data_by_trial_subsets(data, trialidx)
% data: shape nX x nY x T x Ntrials
% trialidx: array of indices to average over
% Returns: out: shape nX x nY x T (averaged over the trials specified in 
% the trialidx structure

out = mean(data(:,:,:,trialidx), 4);



end












