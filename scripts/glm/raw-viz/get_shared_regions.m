function common = get_shared_regions(animal, dates_to_extract)
% animal: string, animal to extract
% dates_to_extract: cell array: sessions of interest
% returns: common: cell array, list of regions that are shared 
% between all sessions
root = '/Volumes/GoogleDrive/Other computers/ImagingDESKTOP-AR620FK/processed/raw';
files = dir(sprintf('%s/templateData/%s/*.mat', root, animal));

idlst = find(contains({files.name}, dates_to_extract)); %[17 20 21 28];

common = {};

for i = 1:numel(idlst) %id of file to investigate
    id = idlst(i);
    parts = strsplit(files(id).name, '_');
    animal = parts{2};
    expdate = parts{end}(1:end-7);

    assert(strcmp(expdate, dates_to_extract{i}))

    
    % Load the template file
    load(fullfile(files(id).folder, files(id).name));

    if i == 1
        common = template.areaStrings;
    else
        common = intersect(common, template.areaStrings);
    end


end









end