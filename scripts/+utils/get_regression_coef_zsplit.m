function [b, CI, zs, zblock_partitions] = get_regression_coef_zsplit(data, xCenter, yCenter, ...
    roisize, Xmat, window, zstates, blockstarts)
% for computing the regression coefficients given the design matrix Xmat
% and the observations y
% Xmat and y will be split according to the states specified in zstates
% b and CI are cell arrays containing the coefficient estimates for each
% of the splits
% xCenter, yCenter
% roisize
% Xmat
% window
% zstates: array of the zstates of each block as 
% blockstarts

zs = unique(zstates);

assert(numel(zstates) <= numel(blockstarts));

traces = utils.get_single_trace(data, xCenter, yCenter, roisize);


b = [];
CI = {};

% Split the y and Xmat
trial_partitions = {};
Xmat_partitions = {};
zblock_partitions = {};
for i = 1:numel(zs)
    z = zs(i);
    zblocks = find(zstates == z);
    zblock_partitions{i} = zblocks;
    trials = [];
    for j = 1:numel(zblocks)
        blockidx = zblocks(j);
        start_id = blockstarts(blockidx);
        if blockidx == numel(blockstarts)
            end_id = numel(traces);
        else
            end_id = blockstarts(blockidx + 1) - 1;
        end
        trials = [trials (start_id : end_id)];
    end
    
    trials(trials <= window) = [];
%     disp(trials);
    trace_singlez = traces(trials);
    X_singlez = Xmat(trials - window,:);
    trial_partitions{i} = trace_singlez;
    Xmat_partitions{i} = X_singlez;
    
    
    % Fit the model for the partition
    if numel(trials) <= 1
        b(:,i) = nan;
        CI{i} = nan;
    else
        mdl = fitlm(X_singlez, trace_singlez, 'Intercept', false);
        b(:,i) = mdl.Coefficients.Estimate;
        CI{i} = mdl.coefCI;
    end
end





end