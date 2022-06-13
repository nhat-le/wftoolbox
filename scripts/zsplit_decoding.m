% Perform a decoding analysis of the past choice/reward information

set(0,'DefaultFigureWindowStyle','docked')

clear 
close all;
files = dir(fullfile('data', '*extracted.mat'));
regression_split_folder = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';

window = 20;
roisize = 9;
xgrid = 10:3:110;
ygrid = 10:3:110;
[xx, yy] = meshgrid(xgrid, ygrid);


for id = 2
    load(fullfile(files(id).folder, files(id).name));
    zunique = unique(zstates);
    zunique = sort(zunique);
    
    % Display the distribution of ntrials and let user decide how many
    % trials to select
    fprintf('**** Ntrial selection ****\n')
    counts = [];
    for j = 1:numel(zunique)
        counts(j) = sum(ztrials(window+1:end) == zunique(j));
        
        fprintf('cluster %d, ntrials = %d\n', j, counts(j));
    end
    ntrials = max(min(counts), 30);
%     ntrials = input('Select number of trials?');
%     ntrials = 50;
    decoding_results = nan(numel(zunique), window);
    for j = 1:numel(zunique)
        for shift = 1:window %history decoding
            shifttrace = traces(:,shift:end,:);
            ztrialsshift = ztrials(shift:end);
            
            zid = zunique(j);

            X = shifttrace(20:end, ztrialsshift == zid, :);
            X = squeeze(mean(X, 1));

            % pick ntrials randomly from X
            if size(X,1) < ntrials
                continue
            end
            sel = randperm(size(X, 1));
            sel = sel(1:ntrials);
            Xsel = X(sel, :);

            y = trialInfo.feedback(ztrialsshift == zid);
            
            count0 = sum(y==0);
            count1 = sum(y==1);
            fprintf('%d positive examples, %d negative examples\n', count1, count0);
            
            ysel = y(sel);
            SVMModel = fitcsvm(Xsel,ysel, 'KernelFunction', 'linear', 'Standardize', true);
            CVSVMModel = crossval(SVMModel);
            crossvalperf = kfoldLoss(CVSVMModel);

            lbl = predict(SVMModel, Xsel);
            perf = sum(lbl == ysel') / numel(ysel);

            fprintf('****\n');
            fprintf('cluster %d: cross-validation performance is %.2f\n', j, 1-crossvalperf);
            
            decoding_results(j, shift) = 1 - crossvalperf;
        end
    end
    
    
%     imagesc(decoding_results);
    save(fullfile(files(id).folder, files(id).name), 'decoding_results', '-append');
    
end