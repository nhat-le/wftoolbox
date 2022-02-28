## WF regression analysis README

Here are some important files to run the regression and history analysis of the widefield data during dynamic foraging. Basic pipelines of analysis that was submitted for COSYNE 2022.

Script `keypoint_visualize.m`

- Reads from data stored in the folder `data`, file names `*extracted.mat`
- Saves the plots of regression coefficients & visualizing the mode transition function, in `plots/regression-coefs-zsplits`

Script `coef_batch_visualize.m`

- Reads from `processed\regression-split` from the GDrive folder (to determine the mask that is applied + the regression coefficient is stored in the structure `his_coef_arr)`, size 34 x 34 x 7 x 2
- Reads from `data/*extracted.mat`
- Visualize the regression coefficients in the spatial domain

Script `zsplit_visualize.m`

- Similar to the above (`coef_batch_visualize.m`): visualizing the regression coefficients in the spatial domain, but also with the transition function on the first plot.
- This splits across the different animals and different modes, unlike the coef_batch_visualize script which lumps all together

Script `ztrial_visualize.m`

- For visualizing the individual trials with given transition function, split by z states and feedback type (correct or incorrect), plot the trial-averaged dynamic of the trial of the 12 regions selected, good for raw data visualization!

Script `coordinate_picker.m`

- Loads the raw aligned data (`allData`) from the disk, `processed`, extracts the ROIs, then save in the `data\*extracted.mat` structures.
- 12 regions (6 x 2 hemispheres), `traces` has shape T x Ntrials x Nregions
    - `traces` has shape T x Ntrials x Npoints
    - Save in `data/*extracted.mat` the following variables:
        - traces, trialInfo (from the `processed` data)
        - zstates, params (from the HMM block data info), params represent the parameters of the transition function of each mode
        - ztrials: same shape as `choices/outcomes/feedback` flattened zstates so that each trial has a zstate now (same dimension as number of trials)
- Note: `data` has shape Nx x Ny x T x Ntrials

Script `data_explore.m`

- Basic exploration, single file only, does not loop through all files..

Script `decoding_aggregator`

- Read from `data/*extracted.mat`
- Visualize the transition functions of each file
- Make use of `decoding_results...` in the extracted files (different types of kernels, Gaussian, rbf, linear etc)
- For plotting the aggregate decoding performance
- `aggregate_decoding` represents four states, in each state, we get a N x 20 array representing the decoding performance for 20 time points (regression of 20 trials back).

Script `load_utility`, calls `utils/do_wf_regression.m`

- Loads the data from xxx
- Performs the regression, two modes: history X mat (regression based on previous choices, feedback, choices x feedback)
- `his_coef_arr` and `his_coef_CI` represents the result of the first regression
- `qcoef_arr` and `qcoef_CI` represents the result of fitting the reinforcement learning model
    - Q includes: chosen value
    - Features include: reward, unrewarded choice, reward, Qchosen, dq, sumq
- Saves all four variables mentioned above, together with `opts` and `mdl`(reinforcement learning model, fitted, with params and Q-values) in `processed/regression_coefs`

Script `load_utility_zsplit.m`

- Very similar to `load_utility.m`, but saving files with suffix `processed/regression-split/*regression_reduced2.mat` .
- Difference with previous: split data into z-blocks with the same z states and performing regression individually for these states

Script `plot_regression_utility.m` is for visualizing the spatial coefficients of the history regression

Script `zsplit_decoding.m` performs decoding analysis on files in `data/*extracted.mat`, and saving decoding results to the same file (under the variable called `decoding_results`)

Script `zsplit_decoding_balanced.m` performs the same decoding but ensures that the datasets are balanced across the different z-states, saves into the same files but with variable name `decoding_results_balanced_polynomial_full`