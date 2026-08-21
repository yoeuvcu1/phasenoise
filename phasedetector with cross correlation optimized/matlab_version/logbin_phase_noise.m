function [f_binned, L_binned] = logbin_phase_noise(f, P, number_of_bins)
% Tek taraflı faz PSD'sini logaritmik binleyip SSB dBc/Hz'e çevirir.
% Her binin frekansı geometrik, lineer PSD gücü aritmetik ortalamayla hesaplanır.

%% ---------------- VALID POSITIVE DATA ----------------
% Yalnızca logaritması ve dB dönüşümü tanımlı olan sonlu, pozitif veriyi kullan.
f = f(:);
P = P(:);
valid = isfinite(f) & isfinite(P) & f > 0 & P >= 0;
f = f(valid);
P = P(valid);

if numel(f) < 2 || min(f) >= max(f)
    error("Logaritmik binleme icin en az iki farkli frekans gereklidir.");
end

%% ---------------- LOGARITHMIC BIN EDGES ----------------
% Logaritmik eş aralıklı kenarlar düşük frekansta daha yüksek çözünürlük sağlar.
bin_edges = logspace(log10(min(f)), log10(max(f)), number_of_bins + 1);
f_binned = NaN(number_of_bins, 1);
P_binned = NaN(number_of_bins, 1);

%% ---------------- LINEAR PSD AVERAGING ----------------
% Her frekansı yalnızca bir bine al; son bin sağ uç değerini de kapsar.
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

%% ---------------- SSB DBC/HZ CONVERSION ----------------
% FFT çözünürlüğü düşükse bazı log-binler boş kalabilir; bunları grafikten çıkar.
nonempty_bins = isfinite(f_binned);
f_binned = f_binned(nonempty_bins);
P_binned = P_binned(nonempty_bins);
% Tek taraflı faz PSD'sinden SSB faz gürültüsüne geçiş P/2 ile yapılır;
% realmin, sıfır güçte log10(0) oluşmasını önler.
L_binned = 10*log10(0.5*P_binned + realmin);

end
