function map = make_dprime_atlas(dprime, frame_idx, template, regions)
% dprime: array of size Nregions x T
% frame_idx, int, frame of interest to build atlas
% template: the template object as stored in the raw mat file
% regions: string arrays of region names
% Returns: map: N1 x N2 array showing the dprime values mapped
% to the atlas regions

map = template.atlas * 0;
for i = 1:numel(regions)
    area_idx = find(strcmp(template.areaStrings, regions{i}));
    assert(numel(area_idx) == 1);

    map(template.atlas == template.areaid(area_idx)) = dprime(i, frame_idx);

end



end