function Xmat = rewardhistoryXmat(choices, feedback, window)
prevChoices = [];
prevRew = [];
for i = 0:window
    prevChoices(i+1,:) = choices(window - i + 1:end-i);
    prevRew(i+1,:) = feedback(window - i + 1:end-i);
end
RewC = prevChoices .* prevRew;
UnrC = prevChoices .* (1 - prevRew);

Xmat = [ones(size(prevChoices, 2), 1) prevRew'];

end