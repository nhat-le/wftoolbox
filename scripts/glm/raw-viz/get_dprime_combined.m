function [dprime, template] = get_dprime_combined(animal, dates_to_extract, areaname, opts)
% Get the dprime between correct and incorrect trials
% INputs: animal: string, animal name
% dates_to_extract: cell array: array of session names to extract
% areaname: string, area name, in the format like 'VISp1_R'
% opts: misc options
% Returns: dprime array, of size T x 1
% atlas: N1 x N2, annotated atlas of the region id's

[regionsCorr_arr, regionsIncorr_arr, ~, ~] = ...
    get_aligned_responses(animal, dates_to_extract, areaname, opts);

% Get the dprime value
meanCorr = nanmean(regionsCorr_arr, 2);
meanIncorr = nanmean(regionsIncorr_arr, 2);
stdCorr = nanstd(regionsCorr_arr, [], 2);
stdIncorr = nanstd(regionsIncorr_arr, [], 2);
stdPooled = sqrt((stdCorr .^ 2 + stdIncorr .^ 2) / 2);
dprime = (meanIncorr - meanCorr) ./ stdPooled;

% also return a copy of the annotated atlas
root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/%s/*.mat', root, animal));
idlst = find(contains({files.name}, dates_to_extract)); %[17 20 21 28];

% Load the template file
load(fullfile(files(idlst(1)).folder, files(idlst(1)).name), 'template');
