% Script for loading the averaged template data by brain region,
% with simple analyses and visualization
% + pre-processing for GLM analysis

paths = pathsetup('wftoolbox');

% f01, 03.04.21
animal = 'e57';
expdate = '030221';

% load trialinfo from raw data (containing info about reward/error etc)
filepath = sprintf('%s/%s/allData_extracted_%s_%spix.mat', paths.rawdatapath,...
    animal, animal, expdate);
assert(exist(filepath, 'file') > 0);
load(filepath, 'trialInfo');

% load template file
template_path = sprintf('%s/templates/%s_%s_template.mat', paths.surface_path,...
    animal, expdate);
load(template_path);


% extract the individual brain areas
area_string = 'VISp1';
plot_averaged_areal_response(area_string, template, trialInfo)

%%
% area_to_plot = find(strcmp(template.areaStrings, 'L-VISp1'));
[~, sig_arr] = extract_trace_from_template(area_string, template);

% averaged by correct/incorrect
corr = sig_arr(:, trialInfo.feedback);
incorr = sig_arr(:, ~trialInfo.feedback);

corr_mean = mean(corr, 2);
incorr_mean = mean(incorr, 2);
corr_std = std(corr, [], 2) / sqrt(numel(corr));
incorr_std = std(incorr, [], 2) / sqrt(numel(incorr));

figure;
errorbar(1:numel(corr_mean), corr_mean, corr_std, 'b')
hold on
errorbar(1:numel(incorr_mean), incorr_mean, incorr_std, 'r')






%% GLM!




function [sig, sig_arr] = extract_trace_from_template(area_string, template)
% Given area_string: the name of the area,
% returns sig: 1-d the signal averaged across the area
% and sig_arr: T x Ntrials matrix of the signal
area_to_plot = find(strcmp(template.areaStrings, area_string));
assert(numel(area_to_plot) == 1);
sig_arr = squeeze(template.aggData(area_to_plot,:,:));
sig = reshape(sig_arr, 1, []);


end


function plot_averaged_areal_response(area_string, template, trialInfo)
% area_string: a string, like 'VISp1'
% will create a plot with two subplots, 'L-VISp1' and 'R-VISp1'
% each will plot the response to reward and error trials
% template: the template as saved in the paths.surface_path/templates
% folder

% Plot the left response
[~, sig_arr] = extract_trace_from_template(['L-' area_string], template);

% averaged by correct/incorrect
corr = sig_arr(:, trialInfo.feedback);
incorr = sig_arr(:, ~trialInfo.feedback);

corr_mean = mean(corr, 2);
incorr_mean = mean(incorr, 2);
corr_std = std(corr, [], 2) / sqrt(numel(corr));
incorr_std = std(incorr, [], 2) / sqrt(numel(incorr));

figure;
ax1 = subplot(121);
errorbar(1:numel(corr_mean), corr_mean, corr_std, 'b')
hold on
errorbar(1:numel(incorr_mean), incorr_mean, incorr_std, 'r')

% Plot the right response
[~, sig_arr] = extract_trace_from_template(['R-' area_string], template);

% averaged by correct/incorrect
corr = sig_arr(:, trialInfo.feedback);
incorr = sig_arr(:, ~trialInfo.feedback);

corr_mean = mean(corr, 2);
incorr_mean = mean(incorr, 2);
corr_std = std(corr, [], 2) / sqrt(numel(corr));
incorr_std = std(incorr, [], 2) / sqrt(numel(incorr));

ax2 = subplot(122);
errorbar(1:numel(corr_mean), corr_mean, corr_std, 'b')
hold on
errorbar(1:numel(incorr_mean), incorr_mean, incorr_std, 'r')


linkaxes([ax1, ax2]);

end






