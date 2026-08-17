function [f_binned, P_binned, bin_edges, bin_counts] = logbin_psd(f, P, num_bins)
% PSD verisini logaritmik aralıklarda ortalayarak seyreltir.

if nargin < 3
    num_bins = 100;
end

% Sıfır ve negatif frekansları at.
valid = f > 0;
f = f(valid);
P = P(valid);

% Logaritmik eş aralıklı bin kenarlarını oluştur.
f_min = min(f);
f_max = max(f);
bin_edges = logspace(log10(f_min), log10(f_max), num_bins + 1);

f_binned = zeros(num_bins, 1);
P_binned = zeros(num_bins, 1);
bin_counts = zeros(num_bins, 1);

% Her bin için frekans (geometrik ortalama) ve güç (aritmetik ortalama) al.
for bin_index = 1:num_bins
    mask = f >= bin_edges(bin_index) & f < bin_edges(bin_index + 1);
    if bin_index == num_bins
        mask = f >= bin_edges(bin_index) & f <= bin_edges(bin_index + 1);
    end

    count = sum(mask);
    bin_counts(bin_index) = count;

    if count > 0
        f_binned(bin_index) = exp(mean(log(f(mask))));
        P_binned(bin_index) = mean(P(mask));
    else
        f_binned(bin_index) = NaN;
        P_binned(bin_index) = NaN;
    end
end

% Boş kalan binleri sonuçtan çıkar.
valid_bins = ~isnan(f_binned);
f_binned = f_binned(valid_bins);
P_binned = P_binned(valid_bins);
bin_edges = bin_edges(1:end-1);
bin_edges = bin_edges(valid_bins);
bin_counts = bin_counts(valid_bins);

end