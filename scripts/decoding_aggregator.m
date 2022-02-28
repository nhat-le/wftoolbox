% For aggregating the results of the decoding (balanced)set(0,'DefaultFigureWindowStyle','docked')

clear 
close all;
files = dir(fullfile('data', '*extracted.mat'));
regression_split_folder = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';

window = 20;
roisize = 9;
xgrid = 10:3:110;
ygrid = 10:3:110;
[xx, yy] = meshgrid(xgrid, ygrid);

classification = struct;
classification(1).name = 'e57';
classification(1).mode = [0 0 2 0];
classification(2).name = 'f01';
classification(2).mode = [0 1 2 3];
classification(3).name = 'f02';
classification(3).mode = [0 1 3 1];
classification(4).name = 'f03';
classification(4).mode = [0 1 2 0];
classification(5).name = 'f04';
classification(5).mode = [0 0 3 0];
classification(6).name = 'f25';
classification(6).mode = [0 0 3 0];




% f = waitbar(0);
%% Let's visualize and classify the clusters..
for id = 1:numel(files)
%     waitbar(id/numel(files), f, 'Processing');
    load(fullfile(files(id).folder, files(id).name), 'params');
    parts = strsplit(files(id).name, '_');
    animal = lower(parts{3});
    
    idstruct = find(contains({classification.name}, 'f01'));
    mode = classification(idstruct).mode;
    
    figure(1);
    for i = 1:4
        subplot(1,4,i)
        xvals = 1:20;
        yvals = mathfuncs.sigmoid(xvals, params(1,i), params(2,i), params(3,i));
        plot(xvals, yvals);
        ylim([0,1]);
        if i == 1
            title(files(id).name);
        end
        
        
        
    end
    pause
    
end

%% Aggregate decoding results..

classification = struct;
classification(1).name = 'e57';
classification(1).mode = [0 0 2 0];
classification(2).name = 'f01';
classification(2).mode = [0 1 2 3];
classification(3).name = 'f02';
classification(3).mode = [0 1 3 1];
classification(4).name = 'f03';
classification(4).mode = [0 1 2 0];
classification(5).name = 'f04';
classification(5).mode = [0 0 3 0];
classification(6).name = 'f25';
classification(6).mode = [0 0 3 0];
files = dir(fullfile('data', '*extracted.mat'));

aggregate_decoding = {[], [], [], []};

colors = brewermap(4, 'Set1');

% decoding_results
% decoding_results_balanced_gaussian
% decoding_results_balanced_linear
% decoding_results_balanced_linear_full %use this
% decoding_results_balanced_polynomial
% decoding_results_balanced_polynomial_full
% decoding_results_balanced_rbf
% decoding_results_balanced_rbf_full

for id = 1:numel(files)
    load(fullfile(files(id).folder, files(id).name));
    decoding_arr = decoding_results_balanced_linear_full;
    assert(numel(unique(zstates)) == size(decoding_arr, 1));
    parts = strsplit(files(id).name, '_');
    animal = lower(parts{3});
    
    idstruct = find(contains({classification.name}, animal));
    mode = classification(idstruct).mode;
    
    for j = 1:4
        if ~ismember(j-1, unique(zstates))
            continue
        else
            zpos = find(unique(zstates) == j-1);
            aggregate_decoding{j} = [aggregate_decoding{j}; decoding_arr(zpos,:)];
        end
    end


end

% Plot the performance for each mode
figure(1)
clf
colors = colors([2, 1, 3, 4], :);
colors(4,:) = [0, 0, 0];
hold on
h = [];
for i =1:4
%     subplot(1,4,i)
    nvalid = sum(~isnan(aggregate_decoding{2}(:,1)));
%     plot(nanmean(aggregate_decoding{i}, 1));
    l = errorbar((0:19) + 0.1 * i - 0.2, nanmean(aggregate_decoding{i}, 1), ...
        nanstd(aggregate_decoding{i}, [], 1) / sqrt(nvalid), 'o-',...
        'Color', colors(i,:), 'MarkerFaceColor', colors(i,:));
    ylim([0.4, 0.8])
    h = [h l];
%     imagesc(aggregate_decoding{i})
    
end
xlim([-1, 5])

mymakeaxis('x_label', 'Trials', 'y_label', 'Decoding performance', 'xticks', 0:5)
c = legend(h, {'1', '2', '3', '4'});
c.Title.String = 'HMM mode';
c.Title.FontSize = 16;
c.FontSize = 16;





