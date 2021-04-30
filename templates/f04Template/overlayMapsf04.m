% Read the retmapping results
directory = '/Volumes/My Passport/retmapping/12012020/E53-stimleft/Results';
files = dir(fullfile(directory, '*Maps.mat'));

load(fullfile(files(1).folder, files(1).name));


% Load the surface image
imgFile = '/Users/minhnhatle/Dropbox (MIT)/Sur/2p1/e53Template/AVG_e53-stimleft_19.tif';
img = TIFFStack(imgFile);

slice = img(:,:,1);



%%
rgbimg = ind2rgb(slice/10, gray);
rdblueimg = ind2rgb(uint16(MapSereno/2 * 255), redblue);
imshow(rdblueimg)

%%
% Show the images
figure;
h = imshow(rgbimg);
% colormap gray;
% caxis([0 3000])
% cvals = h.CData;

hold on
h = imshow(rdblueimg);
% colormap(redblue)
% caxis([0 2]);
% hold off

% Set transparency
alpha = (MapSereno > 0) * 0.4;
set(h, 'AlphaData', alpha);
% export_fig serenoOverlay.png -native
