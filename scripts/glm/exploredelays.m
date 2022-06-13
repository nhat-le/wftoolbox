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

%%
root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw/templateData/*';

tbl = crawl_folder(root);

% writetable(tbl, 'template_sessions.csv');


function tbl = crawl_folder(folder)
% crawl through the folder and prints out information related to the
% experiment on the date of the session
% returns: table containing the information about the template files in the
% folder

files = dir(fullfile(folder, '*.mat'));
paths = pathsetup('wftoolbox');
animals = {};
expdates = {};
maxdt = [];
mindt = [];
meandt = [];

for i = 1:numel(files)
    if contains(folder, 'surface_imgs')
        parts = strsplit(files(i).name, '_');
        animal = parts{1};
        expdate = parts{2};
    else
        parts = strsplit(files(i).name, '_');
        animal = parts{2};
        expdate = parts{3}(1:end-7);       
    end
    
    if numel(expdate) == 6
        expdate_datetime = datetime(expdate, 'InputFormat', 'MMddyy');
    elseif numel(expdate) == 8
        expdate_datetime = datetime(expdate, 'InputFormat', 'MMddyyyy');
    else
        error('Unrecognized date format')
    end
    
    expdate = expdate_datetime;
    expdate.Format = 'MMddyy';
    
    filepath = sprintf('%s/%s/allData_extracted_%s_%spix.mat', paths.rawdatapath,...
        animal, animal, expdate);
    if ~exist(filepath, 'file')
        continue;  
    end
    
    out = get_trialInfo(expdate, animal);
    fprintf('i = %d, Animal: %s, date: %s, dt = %.2f\n', i, animal, expdate, mean(out.dt));
    
    animals{end+1} = animal;
    expdates{end+1} = expdate_datetime;
    mindt(end+1) = round(min(out.dt), 1);
    maxdt(end+1) = round(max(out.dt), 1);
    meandt(end+1) = round(mean(out.dt), 2);
    
    
    
    
end

ids = 1:numel(animals);
tbl = table(ids', animals', expdates', mindt', maxdt', meandt', ...
    'VariableNames', {'ID', 'Animal', 'Expdate', 'Min dt', 'Max dt',...
    'Mean dt'});


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