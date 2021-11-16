function do_wf_regression(opts)
filedir = opts.filedir;
savedir = opts.savedir;
filename = opts.filename;
window = opts.window;
roisize = opts.roisize;
xgrid = opts.xgrid;
ygrid = opts.ygrid;

% filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5/';
% savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regressionCoefs/';
% filename = 'allData_extracted_e57_030421pix.h5';
savefilename = fullfile(savedir, [filename(1:end-3) '-regression.mat']);

fprintf('Loading data...\n');
data = h5read(fullfile(filedir, filename), '/allData/data');
choices = h5read(fullfile(filedir, filename), '/trialInfo/responses');
feedback = h5read(fullfile(filedir, filename), '/trialInfo/feedback');
trialside = h5read(fullfile(filedir, filename), '/trialInfo/target');
blocktrans = find(diff(trialside));
fprintf('done\n');


%% History regression
% window = 5;
% roisize = 9;
% xgrid = 10:3:110;
% ygrid = 10:3:110;

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
