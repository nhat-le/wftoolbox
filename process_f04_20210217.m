load rawData_f04_20210217.mat

%% For visualizing the data in the structure
% roiinfo.type = 'bData';
% 
% figure;
% imagesc(bData(:,:,1, 1));
% 
% hold on;
% [x1,y1] = getpts;
% refPoints=[x1 y1];
% plot(refPoints(:,1),refPoints(:,2),'xw','linewidth',2);


%% Get the df/f
baseline = 1:10;
[A,B,C,D] = size(bData);

bData = single(bData);
dataAvg = mean(bData(:,:,baseline,:),[3,4]);
% bData = bsxfun(@minus, bData, dataAvg); % subtract baseline mean
bData = bsxfun(@rdivide, bData, dataAvg); % divide by baseline mean
% bData = reshape(bData,[],C);

vData = single(vData);
hemoAvg = mean(vData(:,:,baseline,:),[3,4]);
% vData = bsxfun(@minus, vData, hemoAvg); % subtract baseline mean
vData = bsxfun(@rdivide, vData, hemoAvg); % divide by baseline mean

% vData = reshape(vData,[],C);

%% Divisive normalization
data = bData ./ vData;

% bData = reshape(bData, A, B, 28, 267);
% vData = reshape(vData, A, B, 28, 267);


%%
% Eliminate trials where blue/violet were mixed
sel = ones(1,267);
invalidtrials = [172, 244, 262];
sel(invalidtrials) = 0;
sel = logical(sel);

if size(bData, 4) == 267
    bData = bData(:,:,:,sel);
end

if size(vData, 4) == 267
    vData = vData(:,:,:,sel);
end
% bData = bData(:,:,:,mean(bsqueeze) < 1900);
% vData = vData(:,:,:,mean(bsqueeze) < 1900);


% roiinfo.xcenter = x1;
% roiinfo.ycenter = y1;
% roiinfo.radius = 3;
% roimat = allData.(roiinfo.type);
% roimat = bData;
% roidims = size(roimat);
% 
% id = 1;
% xcenter = roiinfo.xcenter(id);
% ycenter = roiinfo.ycenter(id);
% [xx,yy] = meshgrid(1:size(roimat, 1), 1:size(roimat, 2));
% 
% dist = sqrt((xx-xcenter).^2 + (yy-ycenter).^2);
% mask = dist < roiinfo.radius;
% 
% roimat = reshape(roimat, size(roimat,1)* size(roimat,2), size(roimat, 3) * size(roimat,4));
% maskUnroll = reshape(mask, 1, []);
% roifilt = roimat(maskUnroll, :);
% roitrace = mean(roifilt);
% roitrace = reshape(roitrace, roidims(3), roidims(4));


%% Get the value of each pixel
% xcenter = floor(roiinfo.xcenter(id));
% ycenter = floor(roiinfo.ycenter(id));

x1 = 144.3;
y1 = 117.7;

% x1 = 185;
% y1 = 120.6;

xcenter = 117;
ycenter = 144;

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


% linkaxes([h1 h2]);


%lowpass filter
vsqueeze2 = highpass(vsqueeze(:), 0.01, timingInfo.fs/2);
vsqueeze3 = lowpass(vsqueeze2(:), 8, timingInfo.fs/2);
% plot(vsqueeze3(:) + 0.2)

% highpass filter
bsqueeze2 = highpass(bsqueeze(:), 0.01, timingInfo.fs/2);

figure;
% h1 = subplot(121);
plot(bsqueeze2(:))
hold on
% h2 = subplot(122);
plot(vsqueeze3(:))


%% linear regression
% selected = yori < 2100;
barr = bsqueeze2;
varr = vsqueeze3;
Xori = [varr ones(numel(varr), 1)];
% X = [xarr ones(numel(xarr), 1)];
% w = X \ yarr;

w = do_regression(varr, barr);

figure;
plot(barr)
hold on
% plot(varr + 0.2)
plot(varr * w(1) + w(2));

%%
ydiff = barr - Xori * w;
yres = reshape(ydiff, size(bsqueeze));
plot(yres, 'b')
hold on
plot(mean(yres, 2), 'r', 'LineWidth', 2);


%% Do a trial-by-trial regression
w_all = [];
ypred = [];

for i = 1:size(bsqueeze, 2)
    varr = bsqueeze(:,i);
    barr = vsqueeze(:,i);
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
vlowpass = 0;
vhighpass = 0;
bhighpass = 0;


bData = reshape(bData, [], size(bData, 3)*size(bData ,4));
vData = reshape(vData, size(bData));


if vlowpass
    vData = lowpass(vData', 8, 37/2)';
end
disp('V lowpass done');

if vhighpass
    vData = highpass(vData', 0.01, 37/2)';
end
disp('V highpass done');


if bhighpass
    bData = highpass(bData', 0.01, 37/2)';
end
disp('B highpass done');

%%
data = nan(size(bData));
for i = 1:size(bData, 1)
    if mod(i, 1000) == 0
        disp(i)
    end
    varr = bData(i,:);
    
    %lowpass
%     varr = lowpass(varr, 10, 37);
    
    barr = vData(i,:);
    w = do_regression(barr', varr');
    xcorr = varr - barr * w(1) - w(2);
    
    % detrend by linear regression
    xvals = 1:numel(xcorr);
    wdetrend = do_regression(xvals', xcorr');
    xpred2 = barr * w(1) + w(2) + xvals * wdetrend(1) + wdetrend(2);
    
    xcorr2 = varr - xpred2;
    
    
    
    data(i,:) = xcorr2;
    
end
data = reshape(data, [252,252,28,264]);

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
datawindow = datacorr(:,:,13:15,:);
datawindow = reshape(datawindow, size(datawindow, 1), size(datawindow, 2), []);
datawindow = mean(datawindow, 3);


%% Find the peak times
arr = mean(datacorr, 4);
reshapedData = reshape(arr, [], size(arr, 3));
% window = floor(opts.dt * timingInfo.fs); %frames to extract from alignment point
% fs = timingInfo.fs;

% Find the peak times
[maxresp, idx] = max(reshapedData, [], 2);

idx = reshape(idx, [size(arr, 1), size(arr, 2)]);
maxresp = reshape(maxresp, [size(arr, 1), size(arr, 2)]);

function w = do_regression(xarr, yarr)

X = [xarr ones(numel(xarr), 1)];
w = X \ yarr;


end




