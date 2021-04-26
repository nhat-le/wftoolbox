function output = getAlignedTrials(opts, trialInfo, timingInfo)
window = floor(opts.dt * timingInfo.fs); %frames to extract from alignment point
nframes = window(2) - window(1) + 1;
ntrials = trialInfo.ntrials;
nFiles = numel(opts.datafiles);
stem = opts.stem;

if ~isfield(opts, 'pickSide')
    opts.pickSide = 0;
end

% For hemocorrect, make sure window is even num of elements
if opts.hemoCorrect
    if mod(nframes, 2) == 1
        window(2) = window(2) + 1;
        nframes = nframes + 1;
    end
end

output.window = window;


% Check if Thorcam is old or new version by checking if 'stem_0.tif' exists
fileCheck = sprintf('%s_0.tif', opts.stem);
dirCheck = dir(fullfile(opts.filePath, fileCheck));
if isempty(dirCheck)
    thorNewVersion = 1;
else
    thorNewVersion = 0;
end

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
    if opts.hemoCorrect
        % For two channels, make sure that we always start on an even frame
        if mod(refPts(i) + window(1), 2) == 1
            frameids(i,:) = (refPts(i) + window(1) + 1) : (refPts(i) + window(2) + 1);    
        else
            frameids(i,:) = (refPts(i) + window(1)) : (refPts(i) + window(2));
        end
    else
        frameids(i,:) = (refPts(i) + window(1)) : (refPts(i) + window(2));
    end
end


%% Perform the extraction
currimg = 1;
fprintf('Processing file %d of %d\n', 1, numel(opts.datafiles));
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
            filename = sprintf('%s_%d.tif', stem, currimg-2 + thorNewVersion);
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
                prevFilename = sprintf('%s_%d.tif', stem, currimg-2+thorNewVersion);
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

side = 0;
%% Hemodynamic correction
if opts.hemoCorrect
    bData = allData(:,:,1:2:end,:);
    vData = allData(:,:,2:2:end,:);
    
    
    % visualize the channels if user wants
    if opts.pickSide
        bres = reshape(bData, [size(bData,1)*size(bData, 2), size(bData,3)*size(bData,4)]);
        vres = reshape(vData, [size(vData,1)*size(vData, 2), size(vData,3)*size(vData,4)]);

        h = figure;
        plot(mean(bres,1), 'b')
        hold on
        plot(mean(vres,1), 'r')


        side = input('Blue = blue channel; red = violet channel? 1-yes; 2-no; 0-skip\n Enter side: ');
    %     fprintf('Performing hemodynamic correction...\n');
        close(h);
    else
        side = 2;
    end
    
    if side == 2
        % Initial guess was wrong, flip back blue and violet
        temp = bData;
        bData = vData; %allData(:,:,2:2:end,:); %TODO: just copy 
        vData = temp; %allData(:,:,1:2:end,:);
        clear temp
    end
    
    % Perform low-pass filter on the violet data
    
    f = waitbar(0, 'Performing hemodynamic correction...');
    if side > 0
        baselineDur = 1:floor(-floor(window(1)/2));
        data = nan(size(bData), 'single');
        for i = 1:ntrials
            waitbar(i/ntrials, f);
            bSingle = bData(:,:,:,i);
            vSingle = vData(:,:,:,i);
            data(:,:,:,i) = Widefield_HemoCorrect(bSingle,vSingle,baselineDur,5);
        end
        close(f)
    end
end


%% Compute df/f
if opts.computeDFF
    if opts.hemoCorrect && side > 0
        fprintf('Frames extracted. Computing df/f...\n');
        %df/f for blue
        baselineDur = 1:floor(-floor(window(1)/2));
        baselineAvg = nanmean(nanmean(bData(:,:, baselineDur, :),3), 4);
        bData = reshape(bData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor, []); %merge all frames to subtract and divide baseline
        bData = bsxfun(@minus, bData, baselineAvg); % subtract baseline
        bData = bsxfun(@rdivide, bData, baselineAvg); % divide baseline
        bData = reshape(bData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor,nframes/2,ntrials); %shape back to initial form

        % df/f for violet
        baselineAvg = nanmean(nanmean(vData(:,:, baselineDur, :),3), 4);
        vData = reshape(vData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor, []); %merge all frames to subtract and divide baseline
        vData = bsxfun(@minus, vData, baselineAvg); % subtract baseline
        vData = bsxfun(@rdivide, vData, baselineAvg); % divide baseline
        vData = reshape(vData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor,nframes/2,ntrials); %shape back to initial form
        
        output.data = data;
        output.bData = bData;
        output.vData = vData;
    else
        % just df/f for blue
        fprintf('Frames extracted. Computing df/f...\n');
        baselineDur = 1:floor(-floor(window(1)/2));
        baselineAvg = nanmean(nanmean(allData(:,:, baselineDur, :),3), 4);
        allData = reshape(allData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor, []); %merge all frames to subtract and divide baseline
        allData = bsxfun(@minus, allData, baselineAvg); % subtract baseline
        allData = bsxfun(@rdivide, allData, baselineAvg); % divide baseline
        allData = reshape(allData, imgDim(1)/opts.resizeFactor, imgDim(2)/opts.resizeFactor,nframes,ntrials); %shape back to initial form
        
        output.data = allData;
        output.bData = allData;
        output.vData = nan;
    end
end
end