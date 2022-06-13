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


f = waitbar(0);
for id = 1:numel(files)
    waitbar(id/numel(files), f, 'Processing');
    load(fullfile(files(id).folder, files(id).name));
    zunique = unique(zstates);
    zunique = sort(zunique);
    
    % Display the distribution of ntrials and let user decide how many
    % trials to select
    fprintf('**** Ntrial selection ****\n')
    counts = [];
    counts1 = [];
    counts0 = [];
    for j = 1:numel(zunique)
        counts(j) = sum(ztrials(window+1:end) == zunique(j));
        fbtrim = trialInfo.feedback(window+1:end);
        ztrim = ztrials(window+1:end);
        counts1(j) = sum(fbtrim == 1 & ztrim == zunique(j));
        counts0(j) = sum(fbtrim == 0 & ztrim == zunique(j));
        
        fprintf('cluster %d, ntrials = %d, pos examples = %d, neg examples = %d\n',...
            j, counts(j), counts1(j), counts0(j));
    end
%     ntrials = input('ntrials?');
%     neach = floor(ntrials/2);
    neach = max(min([counts1(:); counts0(:)]), 20);
%     ntrials = max(min(counts), 30);
%     ntrials = input('Select number of trials?');
%     ntrials = 50;
    decoding_results = nan(numel(zunique), window);
    for j = 1:numel(zunique)
        for shift = 1:window %history decoding
            shifttrace = traces(:,shift:end,:);
            ztrialsshift = ztrials(shift:end);
            
            zid = zunique(j);

            X = shifttrace(20:end, ztrialsshift == zid,:);
            X = squeeze(mean(X, 1));

            
            

            y = trialInfo.feedback(ztrialsshift == zid);
            
            %pick neach examples from positive/negative
            ids1 = find(y == 1);
            ids0 = find(y == 0);
            
            
            if numel(ids1) < 15 || numel(ids0) < 15
                continue
            end
            
            neach_trial = min([neach, numel(ids1) numel(ids0)]);
            idsel1 = randsample(ids1, neach_trial);
            idsel0 = randsample(ids0, neach_trial);
            
            sel = [idsel0, idsel1];%randperm(size(X, 1));
%             sel = sel(1:ntrials);
            Xsel = X(sel, :);
            ysel = y(sel);
            
            
            SVMModel = fitcsvm(Xsel,ysel, 'KernelFunction', 'polynomial', 'Standardize', true);
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
    decoding_results_balanced_polynomial_full = decoding_results;
    save(fullfile(files(id).folder, files(id).name), 'decoding_results_balanced_polynomial_full', '-append');
    
end
close(f);