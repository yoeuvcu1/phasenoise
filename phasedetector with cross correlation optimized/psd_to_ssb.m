function L = psd_to_ssb(P)
% Tek taraflı faz PSD'sini dBc/Hz cinsinden SSB faz gürültüsüne çevirir.

% L = 10*log10(P/2) formülü ile tek yan bant değerine dön (realmin log güvenliği).
L = 10*log10(0.5*P + realmin);

end