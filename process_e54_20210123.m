load rawData_e54_20210123.mat

% For visualizing the data in the structure
roiinfo.type = 'bData';

figure;
imagesc(bData(:,:,1, 1));

hold on;
[x1,y1] = getpts;
refPoints=[x1 y1];
plot(refPoints(:,1),refPoints(:,2),'xw','linewidth',2);

%%
% Eliminate trials where blue/violet were mixed
% sel = ones(1,267);
% invalidtrials = [172, 244, 262];
% sel(invalidtrials) = 0;
% sel = logical(sel);
% 
% if size(bData, 4) == 267
%     bData = bData(:,:,:,sel);
% end
% 
% if size(vData, 4) == 267
%     vData = vData(:,:,:,sel);
% end
% bData = bData(:,:,:,mean(bsqueeze) < 1900);
% vData = vData(:,:,:,mean(bsqueeze) < 1900);

x1 = 272.8;
y1 = 275.4;
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
% plot(bsqueeze(:))
% hold on
% plot(vsqueeze(:))


%highpass filter
bsqueeze2 = highpass(bsqueeze(:), 0.1, 11.6/2);
vsqueeze2 = highpass(vsqueeze(:), 0.1, 11.6/2);

plot(bsqueeze(:))
hold on
plot(vsqueeze(:) - 100)

% vsqueeze2 = lowpass(vsqueeze, 10, 37);
% plot(vsqueeze(:))


%% linear regression
bori = bsqueeze2;
vori = vsqueeze2;

plot(vori, bori, '.')
%%
% selected = yori < 2100;
barr = bori;
varr = vori;
Xori = [vori ones(numel(vori), 1)];
% X = [xarr ones(numel(xarr), 1)];
% w = X \ yarr;

w = do_regression(varr, barr);

figure;
plot(barr)
hold on
% plot(varr)
plot(varr * w(1) + w(2));

%%
ydiff = bori - Xori * w;
yres = reshape(ydiff, size(bsqueeze));
plot(yres, 'b')
hold on
plot(mean(yres, 2), 'r', 'LineWidth', 2);


%% Do a trial-by-trial regression
w_all = [];
ypred = [];

for i = 1:size(bsqueeze, 2)
    barr = bsqueeze(:,i);
    varr = vsqueeze(:,i);
    w = do_regression(varr, barr);
    ypred(:,i) = varr * w(1) + w(2);
    w_all(i,:) = w;
    
    
    
end


figure;
plot(bsqueeze(:))
hold on
plot(vsqueeze(:))
plot(ypred(:))



%% Correct everything
bflat = reshape(bData, [], 28*264);
vflat = reshape(vData, [], 28*264);
vflat = lowpass(vflat', 10, 37)';

data = nan(size(bflat));
for i = 1:size(bflat, 1)
    if mod(i, 1000) == 0
        disp(i)
    end
    varr = bflat(i,:);
    
    %lowpass
%     varr = lowpass(varr, 10, 37);
    
    barr = vflat(i,:);
    w = do_regression(barr', varr');
    xcorr = varr - barr * w(1) - w(2);
    
    % detrend by linear regression
    xvals = 1:numel(xcorr);
    wdetrend = do_regression(xvals', xcorr');
    xpred2 = barr * w(1) + w(2) + xvals * wdetrend(1) + wdetrend(2);
    
    xcorr2 = varr - xpred2;
    
    
    
    data(i,:) = xcorr;
    
end
data = reshape(data, size(bData));

%%
datacorr = nan(size(data));
baseline = 1:10;
% Correct baseline offset
f = waitbar(0, 'Baseline correction');
for i = 1:size(data, 4)
    waitbar(i/size(data, 4), f, [num2str(i) '/' num2str(size(data,4))]);
    dataTrial = squeeze(data(:,:,:,i));
    dataAvg = mean(dataTrial(:,:,baseline),3);
    dataTrial = bsxfun(@minus, dataTrial, dataAvg); % correct baseline offset
    datacorr(:,:,:,i) = dataTrial;
end
close(f);


%%
compareMovie(datacorr);

%%
% Average
datawindow = datacorr(:,:,13:18,:);
datawindow = reshape(datawindow, size(datawindow, 1), size(datawindow, 2), []);
datawindow = mean(datawindow, 3);

function w = do_regression(xarr, yarr)

X = [xarr ones(numel(xarr), 1)];
w = X \ yarr;


end




