% For visualizing the data in the structure
roiinfo.type = 'bData';

figure;
imagesc(bData(:,:,1, 1));

hold on;
[x1,y1] = getpts;
refPoints=[x1 y1];
plot(refPoints(:,1),refPoints(:,2),'xw','linewidth',2);

%%
roiinfo.xcenter = x1;
roiinfo.ycenter = y1;
roiinfo.radius = 3;
% roimat = allData.(roiinfo.type);
roimat = bData;
roidims = size(roimat);

id = 1;
xcenter = roiinfo.xcenter(id);
ycenter = roiinfo.ycenter(id);
[xx,yy] = meshgrid(1:size(roimat, 1), 1:size(roimat, 2));

dist = sqrt((xx-xcenter).^2 + (yy-ycenter).^2);
mask = dist < roiinfo.radius;

roimat = reshape(roimat, size(roimat,1)* size(roimat,2), size(roimat, 3) * size(roimat,4));
maskUnroll = reshape(mask, 1, []);
roifilt = roimat(maskUnroll, :);
roitrace = mean(roifilt);
roitrace = reshape(roitrace, roidims(3), roidims(4));


%% Get the value of each pixel
xcenter = floor(roiinfo.xcenter(id));
ycenter = floor(roiinfo.ycenter(id));

bsqueeze = squeeze(bData(xcenter, ycenter, :, :));
vsqueeze = squeeze(vData(xcenter, ycenter, :, :));
% sData = squeeze(allData.data(xcenter, ycenter, :, :));

figure;
subplot(131);
plot(bsqueeze, 'b')
hold on
plot(mean(bsqueeze, 2), 'r', 'LineWidth', 2)
% ylim([-0.5 0.5])

subplot(132);
plot(vsqueeze, 'b')
hold on
plot(mean(vsqueeze, 2), 'r', 'LineWidth', 2)
% ylim([-0.5 0.5])


% subplot(133);
% plot(sData, 'b')
% hold on
% plot(mean(sData, 2), 'r', 'LineWidth', 2)
% ylim([-0.5 0.5])




%% Just concat everything
figure;
plot(bsqueeze(:))
hold on
plot(vsqueeze(:))

%% linear regression
yori = bsqueeze(:);
xori = vsqueeze(:);

plot(xori, yori, '.')
%%
selected = yori < 2600;
yarr = yori(selected);
xarr = xori(selected);
Xori = [xori ones(numel(xori), 1)];
X = [xarr ones(numel(xarr), 1)];
w = X \ yarr;

figure;
plot(yarr)
hold on
plot(xarr)
plot(X * w);

%%
ydiff = yori - Xori * w;
yres = reshape(ydiff, size(bsqueeze));
plot(yres, 'b')
hold on
plot(mean(yres, 2), 'r', 'LineWidth', 2);






