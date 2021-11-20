set(0,'DefaultFigureWindowStyle','docked')

clear 
close all;
files = dir(fullfile('data', '*extracted.mat'));
regression_split_folder = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';

window = 5;
roisize = 9;
xgrid = 10:3:110;
ygrid = 10:3:110;
[xx, yy] = meshgrid(xgrid, ygrid);


for id = 1 :numel(files)
    xmins = [];
    ymins = [];
    extracted_coefs = [];
    
    filename = files(id).name;
    load(fullfile(files(id).folder, files(id).name));
    
    regfile = sprintf('%s-regression-reduced2.mat', filename(1:end-14));
    load(fullfile(regression_split_folder, regfile));
    
    
    %match (x,y) to the nearest point
    for k = 1:numel(x)
        dist = (xx - x(k)).^2 + (yy - y(k)).^2;
        val = min(dist(:));
        [xmin, ymin] = find(dist == val);
        xmins(k) = xmin(1);
        ymins(k) = ymin(1);
        
        extracted_coefs(k,:,:) = his_coef_arr(xmin(1), ymin(1),:,:);
    end
    
    % extract the coefficients at the locations of interest
    %%
    figure(1)
    clf;

    handles = [];
    N = numel(zs1);
    for i = 1:N
        ax = subplot(N, 2, 2*i - 1);
        plot(extracted_coefs(:,2:end,i)')
        handles = [handles ax];

        % Plot the switch dynamics
        subplot(N, 2, 2*i)
        zparams = params(:, zs1(i) + 1);
        xvals = 1:20;
        yvals = mathfuncs.sigmoid(xvals, zparams(1), zparams(2), zparams(3));
        plot(xvals, yvals);
        ylim([0, 1]);
    end
    
    linkaxes(handles);
    
%     save(fullfile(files(id).folder, files(id).name,  
    
    savefilename = [filename(1:end-4) '-zsplit-coef.png'];
    saveas(gcf, fullfile('plots/regression-coefs-zsplits/', savefilename));
    
    
end




% a2 = subplot(1,2,2);
% plot(extracted_coefs(:,:,2)')


linkaxes(handles);