load e54_022221pix_tca_nonneg_10comp.mat
% load Murat_tca_jobtalk/e54_122720pix_tca_nonneg_10comp_forMurat.mat

%%
ens_map_all(ens_map_all == 0) = nan;
for i = [3,4,6,10]%1:size(ens_map_all,3)
    figure;
    imagesc(ens_map_all(:,:,i))
    axis square
    axis off
    colormap hot
%     savefig(gcf, sprintf('cluster_%d.fig', i))
%     saveas(gcf, sprintf('cluster_%d.pdf', i))
end


%% Plot time factors
for i = 1:size(ens_map_all,3)
    figure;
    plot(linspace(-0.5, 1, size(B,1)), B(:,i), 'LineWidth', 2)
    l = vline(0, 'k--');
    set(l, 'LineWidth', 2)
    
    set(gca, 'FontSize', 16)
    xlabel('Time (s)')
    ylabel('df/f')
%     savefig(gcf, sprintf('cluster_%d_time_factor.fig', i))
%     saveas(gcf, sprintf('cluster_%d_time_factor.pdf', i))
end




%% Plot trial factors
% Find trial transition
transpts = find(diff(target) ~= 0);

for i = 1 %1:size(ens_map_all,3)
    figure('Position', [0, 0, 600, 350]);
    tfactor = A(:,i);
    plot(find(feedback == 1), tfactor(feedback == 1), 'bo', 'MarkerFaceColor','b')
    hold on
    plot(find(feedback == 0), tfactor(feedback == 0), 'ro', 'MarkerFaceColor', 'r')
    
    vline(transpts, 'k--')
    set(gca, 'FontSize', 16)
    xlabel('Trial number')
    ylabel('Trial factor')
%     savefig(gcf, sprintf('cluster_%d_trial_factor.fig', i))
%     saveas(gcf, sprintf('cluster_%d_trial_factor.png', i))
%     saveas(gcf, sprintf('cluster_%d_trial_factor.pdf', i))
end



%% Grouped into correct and incorrect trials
for i = [3, 4, 6, 10]
    figure('Position', [0, 0, 600, 400]);
    tfactor = A(:,i);
    
    % Split into correct and incorr
    corrfac = tfactor(feedback == 1);
    incorrfac = tfactor(feedback == 0);
    
%     plot(ones(1, numel(corrfac)) + rand(1, numel(corrfac)) * 0.1, corrfac, 'bo', 'MarkerFaceColor','b')
%     hold on
%     plot(ones(1, numel(incorrfac)) * 2 + rand(1, numel(incorrfac)) * 0.1, incorrfac, 'ro', 'MarkerFaceColor', 'r')
    violin({corrfac, incorrfac});
    
%     errorbar(1.5, mean(corrfac), std(corrfac) / sqrt(numel(corrfac)), 'o')
%     errorbar(2.5, mean(incorrfac), std(incorrfac) / sqrt(numel(corrfac)), 'o')
    
    set(gca, 'FontSize', 16)
    xticks([1,2])
    xticklabels({'Correct', 'Incorrect'})
    xlim([0 3])
    ylabel('Trial factor')
    
%     saveas(gcf, sprintf('cluster_%d_trial_factor_corr_incorr.pdf', i))
    
    pval = ranksum(corrfac, incorrfac);
    fprintf('i = %d, pval = %.4f\n', i, pval);
    
end



