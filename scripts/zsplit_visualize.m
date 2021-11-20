set(0,'DefaultFigureWindowStyle','docked')


%% Custom visualization
animal = 'f25';
expdate = '100421';
filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';
filename = sprintf('allData_extracted_%s_%spix-regression-reduced2.mat', animal, expdate);
savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split/plots3';
load(fullfile(filedir, filename));

% get the zstates and params
opts.zdir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata';
opts.animal = animal;
opts.date = '111821';
opts.sessid = expdate;
[zstates, params] = utils.get_zstates(opts);
xvals = 1:20;

for i = 1:numel(zs1)
    figure(i);
    subplot(2,4,1);
    zparams = params(:, zs1(i) + 1);
    ylim([0, 1]);
    yvals = mathfuncs.sigmoid(xvals, zparams(1), zparams(2), zparams(3));
    plot(xvals, yvals);
    
    for j = 1:6
        subplot(2,4,j+1)
        imagesc(his_coef_arr(:,:,j+1,i))
        caxis([-0.02 0.02])
        colormap(redblue)
    end
    
    % Save image
%     saveas(gcf, fullfile(savedir, sprintf('%s_cluster%d.png', files(id).name(1:end-4), zs1(i))));
end












%% Batch process and save visualization
files = dir(fullfile(filedir, '*reduced2.mat'));

for id = 1:numel(files)
    process_and_save(id, files);
end

function process_and_save(id, files)
load(fullfile(files(id).folder, files(id).name));
disp(files(id).name);
filename = files(id).name;
fileparts = strsplit(filename, '_');


savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split/plots3';

opts.zdir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata';
opts.animal = fileparts{3};
opts.date = '111821';
opts.sessid = fileparts{4}(1:6);
[~, params] = utils.get_zstates(opts);
xvals = 1:20;

%%
for i = 1:numel(zs1)
    figure(i);
    % Plot the transition function for the mode
    subplot(2,4,1);
    zparams = params(:, zs1(i) + 1);
    yvals = mathfuncs.sigmoid(xvals, zparams(1), zparams(2), zparams(3));
    plot(xvals, yvals);
    ylim([0, 1]);
    
    for j = 1:6
        subplot(2,4,j+1)
        imagesc(his_coef_arr(:,:,j+1,i))
        caxis([-0.02 0.02])
        colormap(redblue)
    end
    
    % Save image
    saveas(gcf, fullfile(savedir, sprintf('%s_cluster%d.png', files(id).name(1:end-4), zs1(i))));
end
end



