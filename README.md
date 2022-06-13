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
- To set up the animal template, run `/Users/minhnhatle/Documents/ExternalCode/locaNMF-preprocess`
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

### Instructions for setting templates for opto alignment:
- Modify the script `laserGalvoControl/classes/animalList.m` and update with new animal and paths to data etc
- First capture ref image using the galvoGUI, the images will be saved in the corresponding animal folder in C:/Data/{animal}.
- Note: if use the refImage, need to flip the image with ImageJ/Fiji twice: once horizontally and once vertically. Save this as `_Flip.tif`, also save the transpose of this as `_trans_flip.tif` version.
- On personal computer, run the script `/Users/minhnhatle/Documents/ExternalCode/locaNMF-preprocess/process_dataset1p.m` to align the animal template. Make sure to do Y = Y' for transposing the refIm.Note image will be upside-down, but assume it is not mirrored (left side = left side of image as viewed upside-down)
- This creates an animal template folder (for e.g. `wftoolbox/templates/f32Template/f32_atlas.m`). Copy this to the opto galvo computer folder (`Opto galvo/Data (1)/f32`, then transfer to `Documents/wftoolbox/templates/{animal}`
- Copy the transposed image (Y = Y', then imwrite(Y, ...)) , then copy th to galvo computer, folder Documents/wftoolbox/templates/{animal}. Also copy the cluster_points.mat file from f32 here (note that f26, 27 cluster points will not work!)

- Then modify the `atlas.m` file to ensure opts.imgPath points to the location of the trans_flip.tif image generated earlier (C:/Data/{animal}/..._trans_flip.tif).
