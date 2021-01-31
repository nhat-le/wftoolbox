function tform = alignImages(opts)
%% Load the reference and data iamges
img = TIFFStack(opts.refImgPath);
refImg = img(:,:,1);

dataImg = TIFFStack(fullfile(opts.datafiles(1).folder, opts.datafiles(1).name));
singleImg = dataImg(:,:,1);

%% Get points for alignment
figure('Position', [39 378 961 420]);
subplot(121)
imagesc(refImg);
hold on
title('Select landmarks on the reference, then press enter');
[x1,y1] = getpts;
refPoints=[x1 y1];
plot(refPoints(:,1),refPoints(:,2),'xw','linewidth',2);

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
borders = imwarp(borders,tform,'OutputView',imref2d(size(refImg)));
subplot(122)
imagesc(singleImg + uint16(borders) * 1000)
hold on
plot(rotpoints(:,1),rotpoints(:,2),'xw','linewidth',2);
plot(imgPoints(:,1),imgPoints(:,2),'xr','linewidth',2);


end