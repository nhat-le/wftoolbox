%% Change the directory of this path to locanmf-preprocess/utils
% addpath('/Users/minhnhatle/Documents/ExternalCode/locaNMF-preprocess/utils/');

%% Load the overlaid image
% For E53
% fdir = 'templates/e53Template/';
% Y = imread(fullfile(fdir, 'serenoOverlay.png'));

% For E54
% fdir = 'templates/e54Template/';
% Y = imread(fullfile(fdir, 'serenoOverlay.png'));

% For E57
fdir = 'templates/e57Template/';
Y = imread(fullfile(fdir, 'e57surface.png'));

% For F01
% fdir = 'templates/f01Template/';
% Y = imread(fullfile(fdir, 'f01surface.png'));

% For F02
% fdir = 'templates/f02Template/';
% Y = imread(fullfile(fdir, 'f02surface.tif'));

% For F03
% fdir = 'templates/f03Template/';
% Y = imread(fullfile(fdir, 'f03surface.tif'));

% For F04
% fdir = 'templates/f04Template/';
% Y = imread(fullfile(fdir, 'f04surface.png'));

%% Get brainmask
% can set to 'docked' if we prefer
% set(0,'DefaultFigureWindowStyle','normal'); warning('off','images:imshow:magnificationMustBeFitForDockedFigure')

% fprintf('Click the vertices to define a brainmask.\nRight click to finish and close polygon.\nDouble-click inside polygon to accept it.\n');
% % R=roipoly(max(Y,[],3)./max(Y(:)));
% R = roipoly(Y);
% % For a circular roi, use the code below
% % imshow(Y);
% % R = images.roi.Circle(gca, 'Center', [300 300], 'Radius', 100);
% brainmask=double(R);
% brainmask(brainmask==0)=NaN;
% Y=repmat(brainmask,1,1,size(Y,3)).*double(Y);
% imshow(max(Y,[],3)./max(Y(:)))

%% Align data to atlas + get inverse atlas
load('allenDorsalMap.mat')
atlas = dorsalMaps.dorsalMapScaled;

% Multiply left side by -1 to have side information
[xx,yy] = meshgrid(1:size(atlas, 1), 1:size(atlas, 2));
atlas(xx < size(atlas, 1) / 2) = atlas(xx < size(atlas, 1) / 2) * -1;

borders = dorsalMaps.edgeMapScaled;
load('templates/atlasStandard.mat', 'areanames');
% tform = align_recording_to_allen(max(Y,[],3), {'R VISp1'}); % align <-- input any function of data here
tform = align_recording_to_allen(max(Y,[],3));
invT=pinv(tform.T); % invert the transformation matrix
invT(1,3)=0; invT(2,3)=0; invT(3,3)=1; % set 3rd dimension of rotation artificially to 0
invtform=tform; invtform.T=invT; % create the transformation with invtform as the transformation matrix
atlas=imwarp(atlas,invtform,'interp','nearest','OutputView',imref2d(size(Y(:,:,1)))); % setting the 'OutputView' is important
borders=imwarp(borders,invtform,'interp','nearest','OutputView',imref2d(size(Y(:,:,1)))); % setting the 'OutputView' is important
atlas=round(atlas);
borders = round(borders);
%% Plot the warped atlas
figure; subplot(1,2,1); imagesc(max(Y,[],3) + uint16(borders) * 10000); axis image
% hold on
% h = imshow(borders * 255);
% set(h, 'AlphaData', 0.4);
subplot(1,2,2); imagesc(atlas); axis image

%% Save the warped atlas

save(fullfile(fdir,'atlas_E57.mat'),'atlas','areanames','invtform', 'borders');

