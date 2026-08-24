function filtered_signal = lowpass_filter( ...
        input_signal, fs, cutoff_frequency, filter_order)
%LOWPASS_FILTER Apply the same cached Butterworth LPF as the active project.

if cutoff_frequency <= 0 || cutoff_frequency >= fs/2
    error("cutoff_frequency, (0, fs/2) araliginda olmalidir.");
end
if filter_order <= 0 || filter_order ~= fix(filter_order)
    error("filter_order pozitif bir tamsayi olmalidir.");
end

persistent cached_fs cached_cutoff cached_order cached_b cached_a;
settings_changed = isempty(cached_b) || cached_fs ~= fs || ...
    cached_cutoff ~= cutoff_frequency || cached_order ~= filter_order;
if settings_changed
    normalized_cutoff = cutoff_frequency / (fs/2);
    [cached_b, cached_a] = butter(filter_order, normalized_cutoff, "low");
    cached_fs = fs;
    cached_cutoff = cutoff_frequency;
    cached_order = filter_order;
end

filtered_signal = filter(cached_b, cached_a, input_signal);

end
