function [states, states_classified, params] = get_zstates(opts)
% fields in opts:
% - zdir: directory where the combined log file (_all_sessions_) are saved
% - animal: animal id
% - date: version of the saved log file, e.g if the file is called
% _all_sessions_111921 then the date is '111921'
% - sessid:  date of experiment, in format like 030121 (for march 1, 2021)
% Returns:
% -states: array of blockHMM mode (raw)
% -states_classified: decoded array of zstates (Q1-4, IB5-6)
% -params: params of the transition functions, ordered with respect to raw states 


animal = opts.animal;
date = opts.date;
sessname = opts.sessid;
daysession = opts.daysession;

load('/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/PaperFigures/code/blockhmm/opto_hmm_info_wf.mat');
% load(fullfile(opts.alldata_dir, [animal '_all_sessions_', date '.mat']));
% load(fullfile(opts.zdir, [animal '_hmmblockfit_', date '.mat']));

formatted_name = sprintf('20%s-%s-%s', sessname(5:6), sessname(1:2), sessname(3:4));

animalID = find(contains({animalinfo.animal}, animal));
sessID = find(contains(cellstr(animalinfo(animalID).sessnames), formatted_name));
states = animalinfo(animalID).zraw{sessID};
states_classified = animalinfo(animalID).zclassified{sessID};
params = animalinfo(animalID).params;


% Handle cases where single day has multiple sessions,
% In this case, extract the relevant session from the concatenated
% structure
animal_folder = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/processed_data/expdata/022822_wf';
all_sessions_file = dir(fullfile(animal_folder, [animal '*2.mat']));
load(fullfile(all_sessions_file(1).folder, all_sessions_file(1).name));
all_sessions_id = find(contains(session_names, formatted_name));
assert(numel(all_sessions_id) == 1)

sesscounts = sesscounts_cell{all_sessions_id};

% Determine the blocks of interest in the session
blocktrans = find(diff(targets_cell{all_sessions_id})); %trials where the transition take place
blocktrans(end+1) = numel(targets_cell{all_sessions_id}) + 1;
trials_in_session = find(sesscounts == daysession);

[first_block_id, last_block_id] = find_block_indices(trials_in_session, blocktrans);

states = states(first_block_id:last_block_id);
states_classified = states_classified(first_block_id:last_block_id);


% include_idx = find(fitrange == sess_idx - 1);
if numel(sessID) == 0
    warning('Session %s %s not found in log', animal, formatted_name);
end

end


function [first_block_id, last_block_id] = find_block_indices(trials_in_session, blocktrans)

% Determine the first and last block id's in the session
first_trial_session = trials_in_session(1);
last_trial_session = trials_in_session(end);

for i = 1:numel(blocktrans)
    if blocktrans(i) > first_trial_session
        first_block_id = i;
        break
    end     
end


for i = 1:numel(blocktrans)
    if blocktrans(i) > last_trial_session
        last_block_id = i;
        break
    end     
end


end






