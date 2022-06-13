% For visualizing the coefs classified by mode
classification = struct;
classification(1).name = 'e57';
classification(1).mode = [0 0 2 0];
classification(2).name = 'f01';
classification(2).mode = [0 1 2 3];
classification(3).name = 'f02';
classification(3).mode = [0 1 3 1];
classification(4).name = 'f03';
classification(4).mode = [0 1 2 0];
classification(5).name = 'f04';
classification(5).mode = [0 0 3 0];
classification(6).name = 'f25';
classification(6).mode = [0 0 3 0];

maskdir = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/regression-split';
maskfiles = dir(fullfile(maskdir, '*reduced2.mat'));
decodefiles = dir(fullfile('data', '*extracted.mat'));

mask_aggregates = {{}, {}, {}, {}};
name_aggregates =  {{}, {}, {}, {}};

for i = 1:numel(decodefiles)
    
    filename = decodefiles(i).name;
    load(fullfile(decodefiles(i).folder, decodefiles(i).name));
    load(fullfile(maskdir, [filename(1:end-13) 'regression-reduced2.mat']));
    assert(size(his_coef_arr, 4) == numel(unique(zstates)));
    parts = strsplit(filename, '_');
    animal = lower(parts{3});
    datename = parts{4}(1:6);
    
    idstruct = find(contains({classification.name}, animal));
    mode = classification(idstruct).mode;
    
    
    for j = 1:4
        if ~ismember(j-1, unique(zstates))
            continue
        else
            zpos = find(unique(zstates) == j-1);
            mask_aggregates{j}{end+1} = his_coef_arr(:,:,:,zpos);
            name_aggregates{j}{end+1} = [animal '_' datename];
        end
    end
    
    
end



%% visualize all
for i = 1:4
    figure(i)
    clf;
    for j = 1:numel(mask_aggregates{i})
        subplot(3,6,j)
        imagesc(mask_aggregates{i}{j}(:,:,2));
        caxis([-0.02 0.02])
        colormap(redblue);
        title(name_aggregates{i}{j});
    end
    
    
    
    
end




