opts.filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5/';
opts.savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression_coefs/';
opts.filename = 'allData_extracted_e57_030421pix.h5';
opts.window = 5;
opts.roisize = 9;
opts.xgrid = 10:3:110;
opts.ygrid = 10:3:110;

files = dir(fullfile(opts.filedir, '*.h5'));


%%
for i = 4 
    fprintf('------- Processing file %d of %d: %s... ------\n', i, ...
        numel(files), files(i).name); 
    opts.filename = files(i).name;
    utils.do_wf_regression(opts);
end
