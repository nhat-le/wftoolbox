function out = do_wf_regression_zsplit(opts)

% zstates (second output) refers to the classified zstates, Q1-4, IB5-6
[~, zstates, ~] = utils.get_zstates(opts);
out.zstates = zstates;

%%
filedir = opts.filedir;
savedir = opts.savedir;
filename = opts.filename;
window = opts.window;
roisize = opts.roisize;
xgrid = opts.xgrid;
ygrid = opts.ygrid;


fprintf('Loading data...\n');
[~,namestem,ext] = fileparts(filename);
savefilename = fullfile(savedir, [namestem '-regression-reduced2.mat']);


if strcmp(ext, '.mat')
    load(fullfile(filedir, filename), 'allData', 'trialInfo');
    data = allData.data;
    choices = trialInfo.responses;
    feedback = trialInfo.feedback;
    trialside = trialInfo.target;    
    
else
    data = h5read(fullfile(filedir, filename), '/allData/data');
    choices = h5read(fullfile(filedir, filename), '/trialInfo/responses');
    feedback = h5read(fullfile(filedir, filename), '/trialInfo/feedback');
    trialside = h5read(fullfile(filedir, filename), '/trialInfo/target');
end

% Break into blocks
blocktrans = find(diff(trialside));
blockstarts = [1 blocktrans + 1];
block_partitions = [blockstarts numel(trialside) + 1];
trialidx = 1:numel(feedback);
feedback_blocks = {};
choices_blocks = {};
trialidx_blocks = {};
for i = 1:numel(blockstarts)
    feedback_blocks{end+1} = feedback(block_partitions(i) : block_partitions(i+1) - 1);
    choices_blocks{end+1} = choices(block_partitions(i) : block_partitions(i+1) - 1);
    trialidx_blocks{end+1} = trialidx(block_partitions(i) : block_partitions(i+1) - 1);
end

%%

assert(numel(blockstarts) == numel(zstates))

fprintf('done\n');

out.data = data;
out.feedback = feedback_blocks;
out.choice = choices_blocks;
out.zstates = zstates;
out.trialidx = trialidx_blocks;

%% History regression

% Xmat = utils.historyXmat(choices, feedback, window);
% Xmat = utils.rewardhistoryXmat(choices, feedback, window);
% [XmatQ, mdl] = utils.qfitXmat(choices, feedback);
% 
% his_coef_arr = [];
% qcoef_arr = [];
% his_coef_CI = {};
% qcoef_CI = [];
% 
% % History regression
% f = waitbar(0, 'Performing history regression');
% for i = 1:numel(xgrid)
%     waitbar(i/numel(xgrid), f);
%     yc = ygrid(i);
%     for j = 1:numel(ygrid)
%         xc = xgrid(j);
%         
%         [b, CI, zs1, zblocks1] = utils.get_regression_coef_zsplit(data, xc, yc, ...
%             roisize, Xmat, window, zstates, blockstarts);
%         his_coef_arr(i,j,:,:) = b;
%         his_coef_CI{i,j} = CI;
%     end
% end
% 
% 
% close(f);

%% Q regression
% f = waitbar(0, 'Performing Q regression');
% for i = 1:numel(xgrid)
%     waitbar(i/numel(xgrid), f);
%     yc = ygrid(i);
%     for j = 1:numel(ygrid)
%         xc = xgrid(j);
%         [b, CI, zs2, zblocks2] = utils.get_regression_coef_zsplit(data, xc, yc, ...
%             roisize, XmatQ, 0, zstates, blockstarts);
%         qcoef_arr(i,j,:,:) = b;
%         qcoef_CI{i,j} = CI;
% 
%     end
% end


% close(f);

%% Save the processed coefficients
% fprintf('Saving results...\n')
% save(savefilename, 'his_coef_arr', 'his_coef_CI', 'qcoef_CI', 'qcoef_arr',...
%     'opts', 'mdl', 'zs1', 'zblocks1');
