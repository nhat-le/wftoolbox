goodrawfiles = {'2021-10-01_1_f25', '2021-10-04_1_f25',...
    '2021-10-05_1_f25', '2021-10-06_1_f25'};


%%
opts.filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/';
opts.savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression_coefs/';
opts.filename = 'allData_extracted_e57_030421pix.h5';
opts.window = 5;
opts.roisize = 9;
opts.xgrid = 10:3:110;
opts.ygrid = 10:3:110;
opts.subset = -1;

%%

for i = 1:numel(goodrawfiles)
    tic
    try
        fprintf('------- Processing file %d of %d: %s... ------\n', i, ...
            numel(goodrawfiles), goodrawfiles{i});
        rawfile = goodrawfiles{i};
        parts = strsplit(rawfile, '_');
        dateparts = strsplit(parts{1}, '-');

        opts.filename = sprintf('allData_extracted_%s_%s%s%spix.mat', parts{3},...
            dateparts{2}, dateparts{3}, dateparts{1}(3:4));
        utils.do_wf_regression(opts);
        
    catch ME
        if strcmp(ME.identifier, 'x')
            fprintf('Unable to load file %s\n', rawfile);
        else
            fprintf('Error: %s\n', ME.identifier);
            error(ME.identifier, 'unexpected error');
        end
        
    end
    toc
end

