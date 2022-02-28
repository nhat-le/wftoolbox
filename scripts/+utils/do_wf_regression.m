function do_wf_regression(opts)
filedir = opts.filedir;
savedir = opts.savedir;
filename = opts.filename;
window = opts.window;
roisize = opts.roisize;
xgrid = opts.xgrid;
ygrid = opts.ygrid;
if ~isfield(opts, 'trialsubset')
    subset = nan;
else
    subset = opts.trialsubset;
end

% filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5/';
% savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regressionCoefs/';
% filename = 'allData_extracted_e57_030421pix.h5';

fprintf('Loading data...\n');
[~,namestem,ext] = fileparts(filename);
savefilename = fullfile(savedir, [namestem '-regression.mat']);


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

blocktrans = find(diff(trialside));
fprintf('done\n');



%% History regression
% window = 5;
% roisize = 9;
% xgrid = 10:3:110;
% ygrid = 10:3:110;

% Two modes: Xmat: doing a history regression of N trials back (N specified
% by window), for each, include choice, feedback, choice x feedback
% XmatQ: fitted a reinforcement learning model to the choice sequences and
% performs a regression on the Q values.

Xmat = utils.historyXmat(choices, feedback, window);
[XmatQ, mdl] = utils.qfitXmat(choices, feedback);

his_coef_arr = [];
qcoef_arr = [];
his_coef_CI = [];
qcoef_CI = [];

% History regression
f = waitbar(0, 'Performing history regression');
for i = 1:numel(xgrid)
    waitbar(i/numel(xgrid), f);
    yc = ygrid(i);
    for j = 1:numel(ygrid)
        xc = xgrid(j);
        [coef, CI] = utils.get_regression_coef(data, xc, yc, roisize, Xmat, window);
        his_coef_arr(i,j,:) = coef;
        his_coef_CI(i,j,:,:) = CI;
        
    end
end

close(f);

%% Q regression
f = waitbar(0, 'Performing Q regression');
for i = 1:numel(xgrid)
    waitbar(i/numel(xgrid), f);
    yc = ygrid(i);
    for j = 1:numel(ygrid)
        xc = xgrid(j);
        [coef, CI] = utils.get_regression_coef(data, xc, yc, roisize, XmatQ, 0);
        qcoef_arr(i,j,:) = coef;
        qcoef_CI(i,j,:,:) = CI;
    end
end

close(f);

%% Save the processed coefficients
fprintf('Saving results...\n')
save(savefilename, 'his_coef_arr', 'his_coef_CI', 'qcoef_CI', 'qcoef_arr',...
    'opts', 'mdl');
end
