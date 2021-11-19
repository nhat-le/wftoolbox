% opts.filedir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata';
% opts.animal = 'f01';
% opts.date = '111821';
% opts.sessname = '030421';
% 
% [zstates, params] = get_zstates_helper(opts);
% 
% 


function [states, params] = get_zstates(opts)
filedir = opts.zdir;
animal = opts.animal;
date = opts.date;
sessname = opts.sessid;

load(fullfile(filedir, [animal '_all_sessions_', date '.mat']));
load(fullfile(filedir, [animal '_hmmblockfit_', date '.mat']));

formatted_name = sprintf('20%s-%s-%s', sessname(5:6), sessname(1:2), sessname(3:4));

sess_idx = find(contains(session_names, formatted_name));
include_idx = find(fitrange == sess_idx - 1);

nprevdays = sum(lengths(1:include_idx-1));
states = zstates(nprevdays + 1 : nprevdays + lengths(include_idx)); 
end

% figure;
% for i = 1:4
%     subplot(2,2,i)
%     imagesc(obs(zstates == i-1,:))
%     title(i)
% end
% 
% 
% %%
% zfrag = zstates(329:355);
% obsfrag = obs(329:355,:);
% figure(1)
% imagesc(obsfrag);
% hold on
% for i =1:27
%     text(15, i, num2str(zfrag(i)))
% end
% 





