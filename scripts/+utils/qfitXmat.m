function [XmatQ, mdl] = qfitXmat(choices, feedback)
% Function for forming a design matrix for regression
% with fitting to a RL model, infering the Q values
% the matrix contains six columns: (1) rewarded choice, (2) unrewarded choice 
% (3) reward, (4) chosen q, (5) difference in q, (6) sum of Q's

mdl = rl.fit(choices, feedback);

%delta Q and sum Q features
dq = mdl.values0 - mdl.values1; %value difference
sumq = mdl.values0 + mdl.values1; %value sum

% chosen value feature
qch = ones(size(dq)) * nan;
qch(choices == 1) = mdl.values1(choices == 1);
qch(choices == -1) = mdl.values0(choices == -1);

% reward and choice features
rewc = feedback .* choices;
unrc = (1 - feedback) .* choices;
rew = feedback;

% form the X matrix for regression
XmatQ = [rewc' unrc' rew' qch dq sumq ones(size(dq))];