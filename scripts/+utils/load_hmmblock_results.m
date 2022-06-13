

filedir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata';
animal = 'f01';
date = '111821';
load(fullfile(filedir, [animal '_all_sessions_', date '.mat']));
load(fullfile(filedir, [animal '_hmmblockfit_', date '.mat']));

sessname = '030421';
month = str2double(sessname(1:2));
day = str2double(sessname(3:4));
year = 2000 + str2double(sessname(5:6));
formatted_name = sprintf('20%s-%s-%s', sessname(5:6), sessname(1:2), sessname(3:4));

sess_idx = find(contains(session_names, formatted_name));
include_idx = find(fitrange == sess_idx - 1);

nprevdays = sum(lengths(1:include_idx-1));
states = zstates(nprevdays + 1 : nprevdays + lengths(include_idx)); 

%%
figure;
for i = 1:4
    subplot(2,2,i)
    imagesc(obs(zstates == i-1,:))
    title(i)
end


%%
zfrag = zstates(329:355);
obsfrag = obs(329:355,:);
figure(1)
imagesc(obsfrag);
hold on
for i =1:27
    text(15, i, num2str(zfrag(i)))
end






