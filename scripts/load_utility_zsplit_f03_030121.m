% a specific instance of load_utility_zsplit but for a single file of f03

h5filenames = {'allData_extracted_f03_030121pix.h5'};

batch_names = h5filenames;

       
opts.date = '111821';

if strcmp(batch_names{1}(end-3:end), '.mat')
    opts.filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed';
else
    opts.filedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5';
end
opts.zdir = '/Users/minhnhatle/Dropbox (MIT)/Sur/MatchingSimulations/expdata'; %directory that stores the zstate data
opts.savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';
opts.window = 5;
opts.roisize = 9;
opts.xgrid = 10:110;
opts.ygrid = 10:110;
opts.subset = -1;

%%

for i = 1
    tic
    
        fprintf('------- Processing file %d of %d: %s... ------\n', i, ...
            numel(batch_names), batch_names{i});
        opts.filename = batch_names{i};
        parts = strsplit(opts.filename, '_');
        opts.animal = lower(parts{3});
        opts.sessid = parts{4}(1:6);
        
        utils.do_wf_regression_zsplit_f03_030121(opts);
        
     
        fprintf('Error loading file %s\n', opts.filename);
        continue
        
    
    toc
end

