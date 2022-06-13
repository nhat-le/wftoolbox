% (Deprecated: for reading from mat files and saving to an h5 file for
% faster subsequent loads, was not successful...)

rootdir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed';
savedir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/hdf5';
files = dir(fullfile(rootdir, 'allData*.mat'));

%%
% filenames = {'allData_extracted_f02_030221pix', ...
%     'allData_extracted_f01_043021pix',...
%     'allData_extracted_f04_030221pix',...
%     'allData_extracted_f03_030121pix'};
filenames = {'allData_extracted_f01_030921pix',...
    'allData_extracted_f02_030321pix.mat',...
    'allData_extracted_f02_030421pix.mat'};

f = waitbar(0);

%%
tic
for i = 1:numel(filenames)
    waitbar(i/numel(filenames), f);
    filename = filenames{i};
    fprintf('Processing file %s...\n', filename);
    stem = filename(1:end-4);
    h5filename = fullfile(savedir, [stem '.h5']);
    % Load original dataset
%     if ~ismember(filename(1:end-4), filenames)
%         continue;
%     end
    
    try
        load(fullfile(rootdir, filename));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:load:notBinaryFile')
            fprintf('Failed to load file %s, continuing...\n', filename);
            continue
        end
    end
        
    fprintf('Dataset loaded: %s..\n', filename)

    %%
    % Save to h5 file
    h5utils.h5_batch_save(h5filename, {'/allData/data', '/allData/bData', '/allData/vData'},...
        {allData.data, allData.bData, allData.vData});
%     h5utils.h5_save_struct(h5filename, 'allData', allData);
    h5utils.h5_save_struct(h5filename, 'trialInfo', trialInfo);

    % Save attributes
    h5writeatt(h5filename, '/', 'origin', filename);
    h5writeatt(h5filename, '/', 'fs', timingInfo.fs);
    h5writeatt(h5filename, '/', 'filePath', opts.filePath);
    h5writeatt(h5filename, '/', 'trialDataPath', opts.trialDataPath);
    h5writeatt(h5filename, '/', 'dt', opts.dt);
    h5writeatt(h5filename, '/', 'folder', files(1).folder);
    
    clear allData timingInfos;

end
toc
