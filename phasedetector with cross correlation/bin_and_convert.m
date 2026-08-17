function [f_binned, L_binned] = bin_and_convert(f, P, num_bins)
%BIN_AND_CONVERT Log-bin a linear PSD and convert it to SSB phase noise.

if nargin < 3
    num_bins = 80;
end

[f_binned, P_binned] = logbin_psd(f, P, num_bins);
L_binned = psd_to_ssb(P_binned);

end
