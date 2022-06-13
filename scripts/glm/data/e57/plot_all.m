delays = [0, 0.5, 1, 2];
figure;
subplot(121)
hold on
for i = 1:numel(delays)
    fname = sprintf('e57data_%.1fs-delay', delays(i));
    load(fname)

    trough = min(mean_correct(1:20));
    peak = max(mean_correct(1:30));
    plot(tstamps, (mean_correct - trough) / (peak - trough));

end

subplot(122)
hold on
for i = 1:numel(delays)
    fname = sprintf('e57data_%.1fs-delay', delays(i));
    load(fname)

    trough = min(mean_incorrect(1:20));
    peak = max(mean_incorrect(1:30));
%     plot(tstamps, mean_incorrect)
    plot(tstamps, (mean_incorrect - trough) / (peak - trough));

end