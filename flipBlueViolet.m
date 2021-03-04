function output = flipBlueViolet(data, opts, timingInfo)
window = floor(opts.dt * timingInfo.fs); %frames to extract from alignment point

%% Hemodynamic correction
bData = data.vData;
vData = data.bData;
baselineDur = 1:floor(-floor(window(1)/2));
data = nan(size(bData), 'single');
ntrials = size(bData, 4);
f = waitbar(0, 'Flipping blue and violet...');
for i = 1:ntrials
    waitbar(i/ntrials, f);
    bSingle = bData(:,:,:,i);
    vSingle = vData(:,:,:,i);
    data(:,:,:,i) = Widefield_HemoCorrect(bSingle,vSingle,baselineDur,5);
end
close(f)

output.data = data;
output.bData = bData;
output.vData = vData;


end