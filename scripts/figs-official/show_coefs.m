% For figure plotting of paper fig
fpath = '../data';
filename = 'allData_extracted_f03_030121pix-regression-f03.mat';
maskdir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';
maskfilename = 'allData_extracted_f03_030121pix-regression-f03.mat';

load(fullfile(maskdir, maskfilename));
figure(1);
clf;
center = [1150, 1085];
radius = 833;
angle = 25;
for i = 1:3
    for j = 1:4
        subplot(3,4, 4*(i-1) + j)
        im = his_coef_arr(:,:,j+1,i);
        im3 = transform_im(im, center, radius, angle);
        imagesc(im3);
        caxis([-0.02 0.02])
        colormap(redblue)
        colorbar
        axis off
        
    end
end


%% Rotate and crop image

figure(2);
clf
im = his_coef_arr(:,:,2,2);
im2 = imrotate(im, 30, 'bilinear');
% im3 = interp2(1: size(im2,1), 1:size(im2,2), im2, linspace(1, size(im2,1), 300),...
%     linspace(1, size(im2,2), 300));
im3 = interp2(im2, 4);

% imagesc(im3)
% caxis([-0.02 0.02])
% colormap(redblue)
% 
% roi = drawcircle;

center = [1099, 1085];
radius = 833;

% center = [69.5, 69.7];
% radius = 51.7;
xvals = 1:size(im3, 1);
yvals = 1:size(im3, 2);
[xx,yy] = meshgrid(xvals, yvals);
mask = sqrt((xx - center(1)).^2 + (yy - center(2)).^2) < radius;
imagesc(mask .* im3);


%%
figure(2)
im3 = transform_im(im);
imagesc(im3);
caxis([-0.02 0.02])
colormap(redblue)

function res = transform_im(im, center, radius, angle)
im2 = imrotate(im, angle, 'bilinear');
im3 = interp2(im2, 4);

% center = [1099, 1085];
% radius = 833;

xvals = 1:size(im3, 1);
yvals = 1:size(im3, 2);
[xx,yy] = meshgrid(xvals, yvals);
mask = sqrt((xx - center(1)).^2 + (yy - center(2)).^2) < radius;
res = mask .* im3;


end



