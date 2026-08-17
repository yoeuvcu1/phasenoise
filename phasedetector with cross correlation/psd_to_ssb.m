function L = psd_to_ssb(P)
%PSD_TO_SSB Convert single-sided phase PSD to SSB phase noise in dBc/Hz.

L = 10*log10(0.5*P + realmin);

end
