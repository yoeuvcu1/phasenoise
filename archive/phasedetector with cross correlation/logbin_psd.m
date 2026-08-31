function [f_binned, P_binned, bin_edges, bin_counts] = logbin_psd(f, P, num_bins)
%LOGBIN_PSD  Logarithmic binning of PSD data
%   [f_binned, P_binned, bin_edges, bin_counts] = logbin_psd(f, P, num_bins)
%   Bins PSD data (f, P) into num_bins logarithmically spaced bins.
%   Returns geometric mean frequency and arithmetic mean power per bin.
%
%   f: frequency vector (Hz)
%   P: power vector (linear scale, not dB)
%   num_bins: number of log-spaced bins (default 100)

if nargin < 3
    num_bins = 100;
end

% Keep only positive frequencies
valid = f > 0;
f = f(valid);
P = P(valid);

% Log-spaced bin edges
f_min = min(f);
f_max = max(f);
bin_edges = logspace(log10(f_min), log10(f_max), num_bins + 1);

f_binned = zeros(num_bins, 1);
P_binned = zeros(num_bins, 1);
bin_counts = zeros(num_bins, 1);

for i = 1:num_bins
    mask = f >= bin_edges(i) & f < bin_edges(i+1);
    if i == num_bins
        mask = f >= bin_edges(i) & f <= bin_edges(i+1);
    end

    count = sum(mask);
    bin_counts(i) = count;

    if count > 0
        f_binned(i) = exp(mean(log(f(mask))));  % geometric mean
        P_binned(i) = max(P(mask));            % arithmetic mean (linear power)
    else
        f_binned(i) = NaN;
        P_binned(i) = NaN;
    end
end

% Remove empty bins
valid_bins = ~isnan(f_binned);
f_binned = f_binned(valid_bins);
P_binned = P_binned(valid_bins);
bin_edges = bin_edges(1:end-1);  % keep left edges for valid bins
bin_edges = bin_edges(valid_bins);
bin_counts = bin_counts(valid_bins);

end
