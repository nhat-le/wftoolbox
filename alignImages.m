function template = alignImages(opts, data)
%% Load the reference and data images
img = TIFFStack(opts.refImgPath);
refImg = img(:,:,1);

dataImg = TIFFStack(fullfile(opts.datafiles(1).folder, opts.datafiles(1).name));
singleImg = dataImg(:,:,5);
% singleImg = squeeze(data.data(:,:,1,1));


% Resize singleImg to match dimensions of reference
singleImg = imresize(singleImg, size(refImg));

%% Get points for alignment
figure('Position', [39 378 961 420]);
subplot(121)
imagesc(refImg);
hold on
title('Select landmarks on the reference, then press enter');
[x1,y1] = getpts;
refPoints=[x1 y1];
plot(refPoints(:,1),refPoints(:,2),'xw','linewidth',2);
labelArr = {};
for i = 1:size(refPoints, 1)
    labelArr{i} = num2str(i);
end
text(refPoints(:,1) + 10,refPoints(:,2) + 10, labelArr, 'Color', 'w');

subplot(122)
imagesc(singleImg);
hold on
title('Select landmarks on the data, then press enter');
[x2,y2] = getpts;
imgPoints=[x2 y2];
plot(imgPoints(:,1),imgPoints(:,2),'xw','linewidth',2);


%% Align the images
affine = 0;
if affine, affinestr='affine'; else, affinestr='nonreflectivesimilarity'; end
tform = fitgeotrans(refPoints, imgPoints, affinestr);
rotpoints = transformPointsForward(tform,refPoints);
subplot(121)
imagesc(singleImg)
title('Raw image')

%% Now we can overlay the atlas
load(opts.refAtlasPath, 'borders');
load(opts.refAtlasPath, 'atlas', 'areanames');
borders = imwarp(borders,tform,'OutputView',imref2d(size(refImg)));
atlas = imwarp(atlas,tform,'nearest', 'OutputView',imref2d(size(refImg)));
subplot(122)
imagesc(uint16(singleImg) + uint16(borders) * 1000)
hold on
plot(rotpoints(:,1),rotpoints(:,2),'xw','linewidth',2);
plot(imgPoints(:,1),imgPoints(:,2),'xr','linewidth',2);

atlas = imresize(atlas, 1/opts.resizeFactor, 'nearest');


% % Round the transformed atlas to the nearest area Idx
% fieldIDs = fieldnames(areanames);
% areaIdxList = [];
% for i = 1:numel(fieldIDs)
%     areaIdxList(i) = areanames.(fieldIDs{i});
% end
% areaIdxList = areaIdxList(areaIdxList > 0);
% 
% atlasFlat = atlas(:);
% aDiff = atlasFlat - areaIdxList;
% atlasRound = argmin(abs(aDiff'));
% atlasRound = areaIdxList(atlasRound);
% atlasRound(atlasFlat == 0) = 0;
% atlasRound = reshape(atlasRound, size(atlas));

% Outputs
template.borders = imresize(borders, 1/opts.resizeFactor, 'nearest');
template.atlas = atlas;
template.areanames = areanames;

%% Extract the area information
areaid = unique(template.atlas(:));
areaid = areaid(areaid ~= 0);

aggAllAreas = [];
% fprintf('Extracting area data...\n');

load('allenDorsalMapSM.mat', 'dorsalMaps');
tbl = dorsalMaps.labelTable;
template.areaStrings = {};
f = waitbar(0, 'Extracting area data...');
resizedData = imresize(data.data, size(refImg) / opts.resizeFactor);
resizedData2 = reshape(resizedData, size(resizedData, 1) * size(resizedData, 2), []);
for i = 1:numel(areaid)
    waitbar(i/numel(areaid), f, 'Extracting area data...');
    idx = areaid(i);
    % Get the area name
    aName = tbl.abbreviation(tbl.id == abs(idx));
    aName = aName{1};
    template.areaStrings{i} = aName;
    
    mask = template.atlas == idx;
    maskUnroll = reshape(mask, [], 1);
%     areaData = resizedData .* mask;
%     areaData = reshape(areaData, size(areaData, 1) * size(areaData, 2), []);
    areaData = resizedData2(mask,:);
    aggData = sum(areaData, 1) / sum(maskUnroll);
    aggAllAreas(i,:) = aggData;
end 
close(f);


% aggAllAreas has shape nAreas x nTimepoints x nTrials
aggAllAreas = reshape(aggAllAreas, numel(areaid), size(data.bData, 3), []);
template.aggData = aggAllAreas;
template.areaid = areaid;

end