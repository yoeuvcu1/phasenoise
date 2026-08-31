function [f_binned, L_binned] = logbin_phase_noise(f, P, number_of_bins)
% Tek taraflı faz PSD'sini logaritmik binleyip SSB dBc/Hz'e çevirir.
f = f(:);
P = P(:);
valid = isfinite(f) & isfinite(P) & f > 0 & P >= 0;
f = f(valid);
P = P(valid);
if numel(f) < 2 || min(f) >= max(f)
    error("Logaritmik binleme icin en az iki farkli frekans gereklidir.");
end

bin_edges = logspace(log10(min(f)), log10(max(f)), number_of_bins + 1);
f_binned = NaN(number_of_bins, 1);
P_binned = NaN(number_of_bins, 1);
for bin_index = 1:number_of_bins
    in_bin = f >= bin_edges(bin_index) & f < bin_edges(bin_index + 1);
    if bin_index == number_of_bins
        in_bin = f >= bin_edges(bin_index) & f <= bin_edges(bin_index + 1);
    end
    if any(in_bin)
        f_binned(bin_index) = exp(mean(log(f(in_bin))));
        P_binned(bin_index) = mean(P(in_bin));
    end
end
nonempty_bins = isfinite(f_binned);
f_binned = f_binned(nonempty_bins);
P_binned = P_binned(nonempty_bins);
L_binned = 10*log10(0.5*P_binned + realmin);
end
