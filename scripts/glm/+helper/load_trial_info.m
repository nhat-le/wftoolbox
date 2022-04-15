function [trialInfo, opts, timingInfo] = load_trial_info(animal, expdate)
% animal: string
% expdate: like 040322
% will load the trial info data from raw WF data folder 

paths = pathsetup('wftoolbox');

if numel(expdate) > 6
    assert(numel(expdate) == 8)
    expdate = datetime(expdate, 'InputFormat', 'MMddyyyy');
    expdate.Format = 'MMddyy';
end

% load trialinfo from raw data (containing info about reward/error etc)
filepath = sprintf('%s/%s/allData_extracted_%s_%spix.mat', paths.rawdatapath,...
    animal, animal, expdate);

load(filepath, 'trialInfo', 'opts', 'timingInfo');

end