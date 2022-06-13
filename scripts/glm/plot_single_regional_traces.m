% for plotting regional traces from trial to trial
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

dmat_path = '/Users/minhnhatle/Documents/ExternalCode/GLM_clustering';
load(sprintf('%s/Dmatrix_%s_%s.mat', dmat_path, animal, expdate));


area_string = 'R-VISp1';
areaID = find(strcmp(template.areaStrings, area_string));

% L-VISp1 = 56; R-VISp1 = 17
area_agg_data = squeeze(template.aggData(areaID, :, :));


corr_area_data = area_agg_data(:, trialInfo.feedback);

incorr_area_data = area_agg_data(:, ~trialInfo.feedback);

%%
figure;
a1 = subplot(121);
plot(corr_area_data, 'b')
hold on
plot(mean(corr_area_data, 2), 'r')


a2 = subplot(122);
plot(incorr_area_data, 'b')
hold on
plot(mean(incorr_area_data, 2), 'r')


linkaxes([a1, a2]);


%% plot all trials (corr + incorr) in single plots
figure;
for i = 1:100 %size(area_agg_data, 2)
    subplot(10, 10, i)
    if trialInfo.feedback(i)
        plot(area_agg_data(:, i), 'b')
        
    else
        plot(area_agg_data(:, i), 'r')
        
    end
    
    hold on
    
    wheeltrace = wheelspeeds(i,:);
    wheeltrace = wheeltrace / max(abs(wheeltrace)) * 0.02;
    plot(wheeltrace, 'k--');
    
    ylim([-0.03 0.03])
    
end

%% Plot the wheel trace
% gather the wheel trace
wheelspeeds = [];
for i = 1:numel(D.dm.trial)
    wheelspeeds(i,:) = D.dm.trial{i}(66, :);
end


%%
wheelspeed_all = reshape(wheelspeeds', 1, []);
aggdata_all = reshape(area_agg_data, 1, []);
plot((1:numel(wheelspeed_all)) / 37, wheelspeed_all / max(wheelspeed_all))
hold on
plot((1:numel(wheelspeed_all)) / 37, aggdata_all / max(aggdata_all))



% extract the individual brain areas
% area_string = 'VISp1';
% plot_averaged_areal_response(area_string, template, trialInfo)

