% Load the data
filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';
files = dir(fullfile(filedir, '*reduced2.mat'));

for id = 1:numel(files)
    process_and_save(id, files);
end

function process_and_save(id, files)
load(fullfile(files(id).folder, files(id).name));
disp(files(id).name);

savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split/plots3';

%%
for i = 1:numel(zs1)
    figure(i);
    for j = 1:6
        subplot(2,3,j)
        imagesc(his_coef_arr(:,:,j+1,i))
        caxis([-0.02 0.02])
        colormap(redblue)
    end
    
    % Save image
    saveas(gcf, fullfile(savedir, sprintf('%s_cluster%d.png', files(id).name(1:end-4), zs1(i))));
end
end



