files = dir(fullfile('data', '*extracted.mat'));


for id = 1:numel(files)
    load(fullfile(files(id).folder, files(id).name));
    feedback = trialInfo.feedback;

    clf;
    % Split traces by zstates
    zs = unique(zstates);
    zsplits = {};
    handles = [];
    for i = 1:numel(zs)
        ax = subplot(4,3,3 * i - 2);
        subtrace = squeeze(mean(traces(:,ztrials == zs(i) & feedback == 0,:), 2));
        plot(subtrace(:,1:2:end));
    %     title(2*i-1)
        handles = [handles ax];

        ax = subplot(4,3,3 * i -1);
        subtrace = squeeze(mean(traces(:,ztrials == zs(i) & feedback == 1,:), 2));
        plot(subtrace(:,1:2:end));
        handles = [handles ax];
    %     title(2*i)


        % Switching dynamics
        zparams = params(:, zs(i) + 1);
        xvals = 1:20;
        yvals = mathfuncs.sigmoid(xvals, zparams(1), zparams(2), zparams(3));
        subplot(4,3,3*i)
        plot(xvals, yvals);
        ylim([0, 1]);



    end
    linkaxes(handles);


    saveas(gcf, fullfile('plots', [files(id).name(1:end-4) '.png']));
end