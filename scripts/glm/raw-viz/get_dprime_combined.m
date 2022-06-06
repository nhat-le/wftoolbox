function dprime = get_dprime_combined(animal, dates_to_extract, areaname, opts)
% Get the dprime between correct and incorrect trials
% INputs: animal: string, animal name
% dates_to_extract: cell array: array of session names to extract
% areaname: string, area name, in the format like 'VISp1_R'
% opts: misc options
% Returns: dprime array, of size T x 1

[regionsCorr_arr, regionsIncorr_arr, ~, ~] = ...
    get_aligned_responses(animal, dates_to_extract, areaname, opts);

% Get the dprime value
meanCorr = mean(regionsCorr_arr, 2);
meanIncorr = mean(regionsIncorr_arr, 2);
stdCorr = std(regionsCorr_arr, [], 2);
stdIncorr = std(regionsIncorr_arr, [], 2);
stdPooled = sqrt((stdCorr .^ 2 + stdIncorr .^ 2) / 2);
dprime = (meanIncorr - meanCorr) ./ stdPooled;