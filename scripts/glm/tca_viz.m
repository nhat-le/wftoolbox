% Visualize the results of the TCA analysis
load('processed/e57_data.mat')
load('processed/tcamatrices_e57b.mat');

%% Visualize W matrix
figure;

for mode = 1:size(W, 2)
    Wmode = W(:, mode);

    brainim = brainmap * 0;

    subplot(2,5,mode);
    for i = 1:numel(Wmode)

        idarea = selareas(i);

        brainim(brainmap == areaid_lst(i)) = Wmode(i); 


    end

    imagesc(brainim);
    caxis([0, 1])
    colormap hot
end
