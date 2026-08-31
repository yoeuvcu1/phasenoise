function [filtered_signal, b, a] = lowpass_filter(input_signal, fs, cutoff_frequency, filter_order)

    if cutoff_frequency <= 0 || cutoff_frequency >= fs/2
        error('Kesim frekansı 0 ile fs/2 arasında olmalı.');
    end

    normalized_cutoff = cutoff_frequency / (fs/2);

    [b, a] = butter(filter_order, normalized_cutoff, 'low');

    filtered_signal = filter(b, a, input_signal);

end
