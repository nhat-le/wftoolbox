# wftoolbox
A toolbox for widefield imaging analysis

### Instructions for setting up
- Set up MATLAB with Image Processing toolbox
- Download the TIFFStack toolbox according to the instructions at https://github.com/DylanMuir/TIFFStack
- Download musall WideFieldImager code: download the ``Analysis'' folder from https://github.com/musall/WidefieldImager/tree/master/Analysis and add to the MATLAB path
- Download the wftoolbox (this repositiory) or clone from Github and add to the MATLAB path

### Instructions for setting up animal templates
- Download the locaNMF-prepocess toolbox from https://github.com/ss5513/locaNMF-preprocess
- Add the locaNMF/utils folder to the MATLAB path
- Open wftoolbox/makeBrainTemplate and follow the instructions
- Go to align_recording_to_allen.mat, change line 21 to load('allenDorsalMap.mat')

### Instructions for batch processing:
- Create an excel spreadsheet .xlsx with 5 columns: 
(1) filepath: path to the .tif files containing the imaging data
(2) trialdatapath: path to the rigbox behavioral data
(3) dtstart: start of time window for extraction (in secs)
(4) dtend: end of time window for extraction (in secs) - usually for ITI of 1s this should be [-1 1]
(5) animal: animal name
- Modify path and run `compile_allData.m`: this will extract the data and save in allData_extracted*.m
    - Note that the files are saved in the folder specified in `opts.saveFolder`
- Modify path and run `save_allData.m`: this will align the template and save in template_extracted*.m
