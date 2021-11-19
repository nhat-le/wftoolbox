%% Load the data
filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression_coefs';

files = dir(fullfile(filedir, '*.mat'));
id = 8;
filename = files(id).name;
load(fullfile(filedir, filename));
disp(filename)


%% visualize the coefficients
figure(4);
for i = 1:6
    subplot(2,3,i)
    imagesc(squeeze(his_coef_arr(:,:,i)))
    caxis([-0.02, 0.02])
    colormap(redblue)
end


% figure(2);
% for i = 1:6
%     subplot(2,3,i)
%     imagesc(squeeze(his_coef_arr(:,:,i+6)))
%     caxis([-0.02, 0.02])
%     colormap(redblue)
% end
% 
% figure(3);
% for i = 1:6
%     subplot(2,3,i)
%     imagesc(squeeze(his_coef_arr(:,:,i+12)))
%     caxis([-0.02, 0.02])
%     colormap(redblue)
% end
% 
% figure(4)
% imagesc(squeeze(his_coef_arr(:,:,end)))
% caxis([-0.02, 0.02])
% colormap(redblue)
