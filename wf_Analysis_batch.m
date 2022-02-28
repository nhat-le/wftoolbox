%% Get the files from the master database
[~,data,~] = xlsread('e54fileinfo.xlsx');



for i = 2:size(data, 1)
    filePath = data{i,1};
    trialDataPath = data{i,2};
    fprintf('Extracting file %d of %d: %s\n', i - 1, size(data, 1) - 1,...
        filePath);
    dt = [-1 1];
    parseSingleFile(filePath, trialDataPath, 'e54', dt);
    
end



function parseSingleFile(filePath, trialDataPath, animal, dt)


%% Input the settings for the analysis here
warning('off', 'imageio:tiffmexutils:libtiffWarning')

%Note: code will add the root for you, only need to specify relative path
opts.filePath = filePath;
opts.trialDataPath = trialDataPath;


opts.saveFolder = nan; % if nan, will save in the same folder as filePath
opts.animal = animal; % if nan, code will figure out what animal from file path
opts = configurePaths(opts);

opts.alignBorders = 1; % if borders should be aligned using Allen atlas template, usually 1
opts.motionCorrect = 0; 
opts.hemoCorrect = 1;
opts.ignoreFirstTrial = 1; % if 1, skip first trial (timing issues)
opts.pickSide = 0; % if pickside = 0, default order for blue & violet, otherwise, let user decide which channel is blue
opts.quickSave = 0; % if 1, skip visualization, save the processed data

opts.resizeFactor = 2;

%!!IMPORTANT: CHANGE THIS FOR EACH SESSION TO BE ANALYZED!!
opts.dt = dt; %what window (secs) to take around the alignment point

% two dt's for delays
opts.alignedBy = 'reward'; %'reward' or 'response': which epoch to align to
opts.computeDFF = 1;

opts.datafiles = dir(fullfile(opts.filePath, '*.tif'));
opts.stem = opts.datafiles(1).name(1:end-4);




%% Parse the trial structure and arrange in a convenient output format
[timingInfo, trialInfo] = getTrialStructure(opts);


%% Get the aligned trials
allData = getAlignedTrials(opts, trialInfo, timingInfo);



%% Save the pix array
bData = allData.bData;
vData = allData.vData;
data = allData.data;
feedback = trialInfo.feedback;
response = trialInfo.responses;
target = trialInfo.target;
% atlas = template.atlas;
fullsaveName = sprintf('regionData_%s_%spix.mat', opts.animal, opts.datestring);

fprintf('Saving extracted data...\n')
save(fullfile(opts.saveFolder, fullsaveName), 'bData', 'vData', 'data',...
    'feedback', 'response', 'target', 'trialInfo', 'timingInfo',...
    'opts', '-v7.3')

end


function opts = configurePaths(opts)
% Get the parts
if ismember('/', opts.filePath)
    fileparts = strsplit(opts.filePath, '/');
    opts.datestring = fileparts{end-1};
else
    fileparts = strsplit(opts.filePath, '\');
    opts.datestring = fileparts{end-1};
end

if isnan(opts.animal)
    opts.animal = lower(fileparts{end});
end

% Append computer-dependent root to file paths
compname = getenv('computername');
switch compname
    case 'DESKTOP-AR62OFK'
        filerootpath = 'E:/';
        trialDataRootPath = 'D:/Dropbox (MIT)/Nhat';
end

% Save in the same folder as the file path
if isnan(opts.saveFolder)
    opts.saveFolder = opts.filePath;
end

masterPath = 'templates';
switch lower(opts.animal)
    case 'e53'
        fileRefImgPath = 'e53Template/e53surface.tif';
        fileRefAtlasPath = 'e53Template/atlas_E53.mat';
    case 'e54'
        fileRefImgPath = 'e54Template/e54surface.tif';
        fileRefAtlasPath = 'e54Template/atlas_E54.mat';
    case 'e57'
        fileRefImgPath = 'e57Template/e57surface.tif';
        fileRefAtlasPath = 'e57Template/atlas_E57.mat';
    case 'f01'
        fileRefImgPath = 'f01Template/f01surface.tif';
        fileRefAtlasPath = 'f01Template/atlas_F01.mat';
    case 'f02'
        fileRefImgPath = 'f02Template/f02surface.tif';
        fileRefAtlasPath = 'f02Template/atlas_F02.mat';
    case 'f03'
        fileRefImgPath = 'f03Template/f03surface.tif';
        fileRefAtlasPath = 'f03Template/atlas_F03.mat';
    case 'f04'
        fileRefImgPath = 'f04Template/f04surface.tif';
        fileRefAtlasPath = 'f04Template/atlas_F04.mat';
    otherwise
        error('Animal template not found');
        
        
end

opts.refImgPath = fullfile(masterPath, fileRefImgPath);
opts.refAtlasPath = fullfile(masterPath, fileRefAtlasPath);



end