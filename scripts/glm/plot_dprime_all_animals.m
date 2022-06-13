files = dir('processed/dprime_master/*.mat');


m1act = [];
v1act = [];
barrel_act = [];
rsc_act = [];


for i = 1:numel(files)
    load(fullfile(files(i).folder, files(i).name)); 


    if size(meandiff_all, 2) < 29
        meandiff_all(:, end+1:29) = nan;

    end

    %M2/v1/barrel activity
    m2Lidx = find(areaid_lst == -21);

    v1Lidx = find(areaid_lst == -150);

    bLidx = find(areaid_lst == -36);

    rscLidx = find(areaid_lst == -255);

    % pad with nan's if too short

    m1act(i,:) = meandiff_all(m2Lidx, :);
    v1act(i,:) = meandiff_all(v1Lidx, :);
    barrel_act(i,:) = meandiff_all(bLidx, :);
    rsc_act(i,:) = meandiff_all(rscLidx, :);

end




%%
region_act = {m1act, rsc_act, barrel_act, v1act};
regiontitles = {'M1', 'RSC', 'Barrel', 'V1'};

figure('Position', [440,457,977,341]);
axall = [];
xvals = ((1:size(m1act, 2)) - 10) / 36.9 * 2;

for i = 1:numel(region_act)
    axall(i) = subplot(1,4,i);
    plot(xvals, region_act{i}', 'k');
    hold on
    plot(xvals, mean(region_act{i}, 1), 'r', 'LineWidth', 2)
    title(regiontitles{i})
    
    xlabel('Time from outcome (s)')

    if i == 1
        ylabel("d' (Error - Reward)")
    end

    ylim([-1, 1])

    vline(0, 'k--')
    set(gca, 'FontSize', 16, 'FontName', 'helvetica')
end

linkaxes(axall)
    












