function allData = getAlignedTrials(opts, trialInfo, timingInfo)
window = floor(opts.dt * timingInfo.fs); %frames to extract from alignment point
nframes = window(2) - window(1) + 1;
ntrials = trialInfo.ntrials;
nFiles = numel(opts.datafiles);
stem = opts.stem;

% Define what reference points to take
if strcmp(opts.alignedBy, 'reward')
    refPts = trialInfo.feedbackFrameIdxFromTimeline;
elseif strcmp(opts.alignedBy, 'response')
    refPts = trialInfo.responseFrameIdx;
else
    error('opts.alignedBy not recognized. Should be either "reward" or "response"'); 
end

% Idx of frames to extract
frameids = [];
for i = 1:ntrials
    frameids(i,:) = (refPts(i) + window(1)) : (refPts(i) + window(2));
end


%% Perform the extraction
currimg = 1;
frames = TIFFStack(fullfile(opts.datafiles(1).folder, opts.datafiles(1).name));
imgDim = size(frames);

allData = nan(imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor, nframes, ntrials);

fileNframes = nan(1, nFiles);
fileNframes(1) = size(frames, 3);

for i = 1:trialInfo.ntrials
    framesToExtract = frameids(i,:);
    modFramesToExtract = mod(framesToExtract, imgDim(3)) + 1;
    if framesToExtract(end) > sum(fileNframes(1:currimg))
        % Extract until the end of the current file
        idxEnd = find(modFramesToExtract == 1);
        extractedFrames1 = frames(:,:,modFramesToExtract(1:idxEnd-1));
        allData(:,:,1:idxEnd-1,i) = arrayResize(extractedFrames1, opts.resizeFactor);

        fprintf('Processing file %d of %d\n', currimg + 1, numel(opts.datafiles));
        currimg = currimg + 1;
        
        if currimg == 1
            filename = sprintf('%s.tif', stem);
        else
            filename = sprintf('%s_%d.tif', stem, currimg-2);
        end
        
        frames = TIFFStack(fullfile(opts.datafiles(currimg).folder, filename));
        fileNframes(currimg) = size(frames, 3);
        
        if isempty(idxEnd)
            extractedFrames2 = frames(:,:,modFramesToExtract);
            allData(:,:,:,i) = arrayResize(extractedFrames2, opts.resizeFactor);
        else
            extractedFrames2 = frames(:,:,modFramesToExtract(idxEnd:end));
            allData(:,:,idxEnd:end,i) = arrayResize(extractedFrames2, opts.resizeFactor);
        end
              
    else
        % For the case of 'overcompensation', read the previous file again
        if max(modFramesToExtract) > size(frames, 3)
            idPrev = modFramesToExtract(modFramesToExtract > size(frames, 3));
            idCurr = modFramesToExtract(modFramesToExtract <= size(frames, 3));
            fprintf('Warning: backtracking...\n');
            if currimg - 1 == 1
                prevFilename = sprintf('%s.tif', stem);
            else
                prevFilename = sprintf('%s_%d.tif', stem, currimg-2);
            end
            prevFrames = TIFFStack(fullfile(opts.datafiles(currimg-1).folder, prevFilename));
            allData(:,:,modFramesToExtract > size(frames, 3),i) = ...
                arrayResize(prevFrames(:,:,idPrev), opts.resizeFactor);
            allData(:,:,modFramesToExtract <= size(frames, 3),i) = ...
                arrayResize(frames(:,:,idCurr), opts.resizeFactor);
        else
            extractedFrames = frames(:,:,modFramesToExtract);
            allData(:,:,:,i) = arrayResize(extractedFrames, opts.resizeFactor);
        end
        
    end

end

clear frames prevFrames

%% Perform dfft alignment for motion correction if requested
if opts.motionCorrect
    fprintf('Performing motion correction...\n')
    refImg = allData(:,:,1,1);
    refdft = fft2(refImg);

    %perform motion correction 
    for i = 1:size(allData, 3)
        for j = 1:size(allData, 4)
            [~, temp] = dftregistration(refdft, fft2(allData(:, :, i,j)), 10);
            allData(:,:,i,j) = abs(ifft2(temp));
        end
    end
else
    fprintf('Skipping motion correction...\n')
end


%% Compute df/f
if opts.computeDFF
    fprintf('Frames extracted. Computing df/f...\n');
    baselineDur = 1:floor(-window(1));
    baselineAvg = nanmean(nanmean(allData(:,:, baselineDur, :),3), 4);
    allData = reshape(allData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor, []); %merge all frames to subtract and divide baseline
    allData = bsxfun(@minus, allData, baselineAvg); % subtract baseline
    allData = bsxfun(@rdivide, allData, baselineAvg); % divide baseline
    allData = reshape(allData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor,nframes,ntrials); %shape back to initial form
end


end