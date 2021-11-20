%%
% A collection of functions to clean data and compile into 
% processed mat files

%%

goodrawfiles = {'2021-10-01_1_f25', '2021-10-04_1_f25',...
    '2021-10-05_1_f25', '2021-10-06_1_f25'};

clear all
close all;
matfilenames = {'allData_extracted_e57_030321pix.mat',...
    'allData_extracted_f01_030921pix.mat',...
    'allData_extracted_f02_030321pix.mat',...
    'allData_extracted_f02_030421pix.mat',...
    'allData_extracted_f02_043021pix.mat',...
    'allData_extracted_f03_031921pix.mat',...
    'allData_extracted_f03_041921pix.mat',...
    'allData_extracted_f03_042021pix.mat',...
    'allData_extracted_f03_042121pix.mat',...
    'allData_extracted_f04_030321pix.mat',...
    'allData_extracted_f04_031921pix.mat',...
    'allData_extracted_f04_042821pix.mat',...
    'allData_extracted_f25_100121pix.mat',...
    'allData_extracted_f25_100421pix.mat',...
    'allData_extracted_f25_100521pix.mat',...
    'allData_extracted_f25_100621pix.mat'};

h5filenames = {
            'allData_extracted_e57_030421pix.h5',...
            'allData_extracted_f01_030421pix.h5',...
            'allData_extracted_f01_043021pix.h5',...
            'allData_extracted_f02_030221pix.h5',...
            'allData_extracted_f03_030121pix.h5',...
            'allData_extracted_f04_030221pix.h5'};

id = 7;
filename = h5filenames{id};

if strcmp(filename(end-4:end), '.mat')
    filedir = '/Volumes/KEJI_DATA_1/nhat/processed-WF';
    load(fullfile(filedir, filename), 'allData');
    data = allData.data;
else
    filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5';
    data = h5read(fullfile(filedir, filename), '/allData/data');
end

figure(1);
ax = axes;
imagesc(ax, mean(data, [3,4]))
colormap(redblue);
hold on
[x,y] = custom_ginput(12, ax);

traces = [];
roisize = 9;

for i = 1:numel(x)
    xi = x(i);
    yi = y(i);
    meanroi = get_single_trace(data, xi, yi, roisize);
    traces(:,:, i) = meanroi;
%     plot(meanroi)
end

% Save the data
[~,stem,~] = fileparts(filename);
refImg = mean(data, [3,4]);
savefilename = [stem '-extracted.mat'];
save(fullfile('data', savefilename), 'traces', 'x', 'y', 'refImg')
fprintf('File saved: %s\n', savefilename);



%% Get the params and block identities

matfilenames = {'allData_extracted_e57_030321pix.mat',...
    'allData_extracted_f01_030921pix.mat',...
    'allData_extracted_f02_030321pix.mat',...
    'allData_extracted_f02_030421pix.mat',...
    'allData_extracted_f02_043021pix.mat',...
    'allData_extracted_f03_031921pix.mat',...
    'allData_extracted_f03_041921pix.mat',...
    'allData_extracted_f03_042021pix.mat',...
    'allData_extracted_f03_042121pix.mat',...
    'allData_extracted_f04_030321pix.mat',...
    'allData_extracted_f04_031921pix.mat',...
    'allData_extracted_f04_042821pix.mat',...
    'allData_extracted_f25_100121pix.mat',...
    'allData_extracted_f25_100421pix.mat',...
    'allData_extracted_f25_100521pix.mat',...
    'allData_extracted_f25_100621pix.mat'};

allfiles = dir(fullfile('data', '*.mat'));
opts.zdir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata';
opts.date = '111821';
filedir = '/Volumes/KEJI_DATA_1/nhat/processed-WF';

for i = 7 :numel(matfilenames)
    fprintf('Processing file %d of %d...\n', i, numel(matfilenames));
    sourcefile = matfilenames{i};
    load(fullfile(filedir, sourcefile), 'trialInfo');
    parts = strsplit(sourcefile, '_');   
    opts.animal = parts{3};
    opts.sessid = parts{4}(1:6);
    [zstates, params] = utils.get_zstates(opts);
    
    [~,stem,~] = fileparts(sourcefile);
    savefilename = [stem '-extracted.mat'];
    destination = fullfile('data', savefilename);
    save(destination, 'zstates', 'trialInfo', 'params', '-append');
end

%%
h5filenames = {
            'allData_extracted_e57_030421pix.h5',...
            'allData_extracted_f01_030421pix.h5',...
            'allData_extracted_f01_043021pix.h5',...
            'allData_extracted_f02_030221pix.h5',...
            'allData_extracted_f03_030121pix.h5',...
            'allData_extracted_f04_030221pix.h5'};
opts.zdir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata';
opts.date = '111821';
for i = 1 :numel(h5filenames)
    trialInfo = struct;
    fprintf('Processing file %d of %d...\n', i, numel(h5filenames));
    sourcefile = h5filenames{i};
    filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5';
    trialInfo.responses = h5read(fullfile(filedir, sourcefile), '/trialInfo/responses');
    trialInfo.feedback = h5read(fullfile(filedir, sourcefile), '/trialInfo/feedback');
    trialInfo.target = h5read(fullfile(filedir, sourcefile), '/trialInfo/target');
    
    parts = strsplit(sourcefile, '_');   
    opts.animal = parts{3};
    opts.sessid = parts{4}(1:6);
    [zstates, params] = utils.get_zstates(opts);
    
    [~,stem,~] = fileparts(sourcefile);
    savefilename = [stem '-extracted.mat'];
    destination = fullfile('data', savefilename);
    save(destination, 'zstates', 'trialInfo', 'params', '-append');
end

%%
for i = 1:numel(allfiles)
    filename = allfiles(i).name;
    % get the zstates and params
    parts = strsplit(filename, '_');   
    opts.animal = parts{3};
    opts.sessid = parts{4}(1:6);
    [zstates, params] = utils.get_zstates(opts);
    
end


%%
% Go through files and flatten the zstates so that we know which states
% are each trial (for easy slicing of the array)

files = dir(fullfile('data', '*extracted.mat'));
for id = 1:numel(files)
    fprintf('Processing file %d of %d: %s...\n', id, numel(files), files(id).name);
    load(fullfile(files(id).folder, files(id).name));
    trialside = trialInfo.target;
    blockstarts = find(diff(trialside));
    blockstarts = [1 blockstarts + 1 numel(trialside) + 1];
    bsizes = diff(blockstarts);
    assert(sum(bsizes) == numel(trialside));
    assert(numel(bsizes) == numel(zstates));

    ztrials = [];
    for i = 1:numel(zstates)
        ztrials = [ztrials ones(1, bsizes(i)) * double(zstates(i))];
    end
    assert(numel(ztrials) == numel(trialside));
    save(fullfile(files(id).folder, files(id).name), 'ztrials', '-append');
end




function [x, y] = custom_ginput(n, ax)
x = [];
y = [];
for i = 1:n
    [xi,yi] = ginput(1);
    text(xi, yi, num2str(i));
    hold(ax, 'on');
    x(i) = xi;
    y(i) = yi;
end


end


function meanroi = get_single_trace(data, xCenter, yCenter, roisize)
xrange = ceil([xCenter - roisize/2, xCenter + roisize/2]);
yrange = ceil([yCenter - roisize/2, yCenter + roisize/2]);
roiactivity = data(yrange(1):yrange(2), xrange(1):xrange(2), :, :);
meanroi = squeeze(mean(roiactivity, [1, 2]));
% singletrace = mean(meanroi(20:end, :), 1);
end



