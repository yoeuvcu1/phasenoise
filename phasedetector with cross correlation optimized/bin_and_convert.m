function [f_binned, L_binned] = bin_and_convert(f, P, num_bins)
% Doğrusal PSD'yi log-binler ve SSB dBc/Hz birimine çevirir.

if nargin < 3
    num_bins = 80;
end

[f_binned, P_binned] = logbin_psd(f, P, num_bins);
L_binned = psd_to_ssb(P_binned);

end