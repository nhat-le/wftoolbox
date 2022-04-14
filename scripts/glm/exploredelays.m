% for browsing the behavioral files and conditions for extracted
% sessions and animals

root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/surface_imgs/templates';
files = dir(fullfile(root, '*.mat'));

for i = 1:numel(files)
    parts = strsplit(files(i).name, '_');
    animal = parts{1};
    expdate = parts{2};
    out = get_trialInfo(expdate, animal);
    fprintf('i = %d, Animal: %s, date: %s, dt = %.2f\n', i, animal, expdate, mean(out.dt));
    
end



function out = get_trialInfo(expdate, animal)
% expdate: a date string such as 030122
% animal: string, animal of interest
% returns the trial info structure for that animal on that date
% out.trialInfo: trialInfo obtained from the raw session
% out.dt: difference between feedback and reward times for all trials,
% as an array

paths = pathsetup('wftoolbox');

filepath = sprintf('%s/%s/allData_extracted_%s_%spix.mat', paths.rawdatapath,...
    animal, animal, expdate);
assert(exist(filepath, 'file') > 0);
load(filepath, 'trialInfo');

out.dt = trialInfo.feedbackTimes - trialInfo.responseTimes;

out.trialInfo = trialInfo;




end