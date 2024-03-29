set(0,'DefaultFigureWindowStyle','docked')

%% load data

sessid = '030421';
filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5';
filename = sprintf('allData_extracted_f01_%spix.h5', sessid);
data = h5read(fullfile(filedir, filename), '/allData/data');
choices = h5read(fullfile(filedir, filename), '/trialInfo/responses');
feedback = h5read(fullfile(filedir, filename), '/trialInfo/feedback');
trialside = h5read(fullfile(filedir, filename), '/trialInfo/target');

%%
blocktrans = find(diff(trialside));
blockstarts = [1 blocktrans + 1];


%% Get the zstates for the blocks in the session
opts.filedir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata';
opts.animal = 'f01';
opts.date = '111821';
opts.sessname = '030421';

[zstates, params] = utils.get_zstates(opts);

%%

% rootdir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed';
% filename = 'allData_extracted_f01_043021pix.mat';
% tic;
% load(fullfile(rootdir, filename), 'allData');
% t = toc;

%%
% choices = trialInfo.responses;
% feedback = trialInfo.feedback;
% trialside = trialInfo.target;
% find block transitions
% blocktrans = find(diff(trialside));


%% Visualization
f = figure;
refIm = mean(data, [3,4]);

imagesc(refIm);
[xi,yi] = getpts();
close(f)
% roi = drawrectangle;
% bounds = ceil(roi.Position);

%%
traces = [];
figure(1)
for i = 1:numel(xi)
    x = xi(i);
    y = yi(i);
    
%     x = 87;
%     y = 40;
    roisize = 9;
    trace = get_single_trace(data, x, y, roisize);
    traces(:, i) = trace;
    plot(trace)
end

%% Average based on blocks
bactivity = [];
for i = 1:10
    extract = traces(blocktrans + i - 1, :);
    bactivity(i,:,:) = extract;
end

mean_bactivity = squeeze(mean(bactivity, 2));



%% 
window = 5;
roi_id = 1;
% currchoice = choices(window + 1:end);
% currRew = feedback(window + 1:end);
prevChoices = [];
prevRew = [];
for i = 0:window
    prevChoices(i+1,:) = choices(window - i + 1:end-i);
    prevRew(i+1,:) = feedback(window - i + 1:end-i);
end
RewC = prevChoices .* prevRew;
UnrC = prevChoices .* (1 - prevRew);

Xmat = [prevRew' RewC' UnrC' ones(size(prevChoices, 2), 1)];

% Regression
y = traces(window + 1:end, roi_id);
b = Xmat \ y;

% split into parts
mdl = fitlm(Xmat, y, 'Intercept', false);
CI = mdl.coefCI;
b = mdl.Coefficients.Estimate;
disp(b(1));

choicecoefs = b(1:window+1);
choiceCI = CI(1:window+1,:);
rewCcoefs = b(window+2: window+2 + window);
rewCI = CI(window+2: window+2 + window, :);
unrCcoefs = b(window+2+window+1:end-1);
unrCI = CI(window+2+window+1:end-1, :);



figure(6);
clf;
l1 = subplot(131);
errorbar(1:6, choicecoefs, choiceCI(:,1), choiceCI(:,2), 'o');
xlim([0, window+2])
l2 = subplot(132);
errorbar(1:6, rewCcoefs, rewCI(:,1), rewCI(:,2), 'o');
xlim([0, window+2])
l3 = subplot(133);
errorbar(1:6, unrCcoefs, unrCI(:,1), unrCI(:,2), 'o');
xlim([0, window+2])

linkaxes([l1, l2, l3])


%% where are the selected points?
figure(2)
imagesc(refIm)
hold on
% plot(xi, yi, 'ro')
labels = {};
for i = 1:numel(xi)
    labels{i} = num2str(i);
end
text(xi, yi, labels)


%% visualize
figure(3);
plot(traces(:,7))
hold on
plot(traces(:,8))
vline(blocktrans);
scatter(1:numel(choices), ones(1,numel(choices)) * 8, 10, choices)

%%
roisize = 9;
xgrid = 10:3:110;
ygrid = 10:3:110;
coef_arr = [];

f = waitbar(0);
for i = 1:numel(xgrid)
    waitbar(i/numel(xgrid), f);
    yc = ygrid(i);
    for j = 1:numel(ygrid)
        xc = xgrid(j);
        [b, CI, zs] = utils.get_regression_coef_zsplit(data, xc, yc, ...
            roisize, Xmat, window, zstates, blockstarts);
        coef_arr(i,j,:,:) = b;
    end
end

close(f);

%% visualize with zstates
for i = 1:4
    figure(i);
    for j = 1:6
        subplot(2,3,j)
        imagesc(coef_arr(:,:,j,i))
        caxis([-0.02, 0.02])
        colormap(redblue)
    end
end


%%
savefilename = 'test.mat';
save(savefilename, 'his_coef_arr', 'his_coef_CI', 'qcoef_CI', 'qcoef_arr',...
    'opts', 'mdl');

%% visualize the coefficients
figure(1);
for i = 1:6
    subplot(2,3,i)
    imagesc(squeeze(coef_arr(:,:,i)))
    caxis([-0.02, 0.02])
    colormap(redblue)
end


figure(2);
for i = 1:6
    subplot(2,3,i)
    imagesc(squeeze(coef_arr(:,:,i+6)))
    caxis([-0.02, 0.02])
    colormap(redblue)
end

figure(3);
for i = 1:6
    subplot(2,3,i)
    imagesc(squeeze(coef_arr(:,:,i+12)))
    caxis([-0.02, 0.02])
    colormap(redblue)
end

figure(4)
imagesc(squeeze(coef_arr(:,:,end)))
caxis([-0.02, 0.02])
colormap(redblue)


%% From reward history to RL model
%Note: what can we say about the non-linear integration in different cortical areas?
% a model of inference?
mdl = rl.fit(choices, feedback);

%delta Q and sum Q features
dq = mdl.values0 - mdl.values1; %value difference
sumq = mdl.values0 + mdl.values1; %value sum

% chosen value feature
qch = ones(size(dq)) * nan;
qch(choices == 1) = mdl.values1(choices == 1);
qch(choices == -1) = mdl.values0(choices == -1);

% reward and choice features
choices = trialInfo.responses;
feedback = trialInfo.feedback;
rewc = feedback .* choices;
unrc = (1 - feedback) .* choices;
rew = feedback;

% form the X matrix for regression
XmatQ = [rewc' unrc' rew' qch dq sumq ones(size(dq))];

roisize = 9;
xgrid = 10:3:110;
ygrid = 10:3:110;
coef_arr = [];
window = 0;

f = waitbar(0);
for i = 1:numel(xgrid)
    waitbar(i/numel(xgrid), f);
    yc = ygrid(i);
    for j = 1:numel(ygrid)
        xc = xgrid(j);
        coef = get_regression_coef(allData.data, xc, yc, roisize, XmatQ, window);
        coef_arr(i,j,:) = coef;
    end
end

close(f);


%% visualize the coefficients
figure(7);
for i = 1:6
    subplot(2,3,i)
    imagesc(squeeze(coef_arr(:,:,i)))
    caxis([-0.02, 0.02])
    colormap(redblue)
    title(i)
end



%%
get_regression_coef(allData.data, 87, 42, roisize, Xmat, window)

function singletrace = get_single_trace(data, xCenter, yCenter, roisize)
xrange = ceil([xCenter - roisize/2, xCenter + roisize/2]);
yrange = ceil([yCenter - roisize/2, yCenter + roisize/2]);
roiactivity = data(yrange(1):yrange(2), xrange(1):xrange(2), :, :);
meanroi = squeeze(mean(roiactivity, [1, 2]));
singletrace = mean(meanroi(20:end, :), 1);
end

function b = get_regression_coef(data, xCenter, yCenter, roisize, Xmat, window)
traces = get_single_trace(data, xCenter, yCenter, roisize);
y = traces(window + 1:end);
% split into parts
mdl = fitlm(Xmat, y, 'Intercept', false);
b = mdl.Coefficients.Estimate;

end








