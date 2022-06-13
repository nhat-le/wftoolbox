% Script for loading the averaged template data by brain region,
% with simple analyses and visualization
% + pre-processing for GLM analysis

paths = pathsetup('wftoolbox');

animal = 'f04';
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

%%

% L-VISp1 = 56; R-VISp1 = 17
% determine the 'dprime' score for each brain area
% meandiff_all has dimension T x nregions
meandiff_all = [];
for i = 1:numel(template.areaid)
    area_agg_data = squeeze(template.aggData(i, :, :));

    corr_area_data = area_agg_data(:, trialInfo.feedback);
    incorr_area_data = area_agg_data(:, ~trialInfo.feedback);


    mean_corr = mean(corr_area_data, 2);
    std_corr = std(corr_area_data, [], 2);
    mean_incorr = mean(incorr_area_data, 2);
    std_incorr = std(incorr_area_data, [], 2);

    meandiff_all(:,i) = (mean_incorr - mean_corr) ./ std_corr;
end

%% color in the brain data
figure('Position', [52,589,1221,113]);
rot_angle = 38;
borders = template.borders;
borders(borders > 0) = 1;
se = offsetstrel('ball',5,5);
borders = imdilate(borders, se);
borders(borders <= 5) = 0;
borders(borders > 5) = 1;


tarr = 2:4:size(meandiff_all, 1);
for tid = 1:numel(tarr)
    t = tarr(tid);
    diff_map = template.atlas * 0;
    for i = 1:numel(template.areaid)       
        areaID = template.areaid(i);
        diff_map(template.atlas == areaID) = meandiff_all(t, i);
    end
%     diff_map = diff_map + borders;
    
    subplot(1, numel(tarr), tid);
    diff_map = imrotate(diff_map, rot_angle);
    borders_rot = imrotate(borders, rot_angle);
    
%     imAlpha=ones(size(borders_rot));
%     imAlpha(borders_rot > 0)=0;
%     imagesc(diff_map,'AlphaData',imAlpha);
%     set(gca,'color',0*[1 1 1]);
    
    imagesc(diff_map);
    colormap redblue
    caxis([-1.5 1.5])
    axis off

end


