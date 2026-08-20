function S_cross = compute_cross_psd(channels, fs, nfft)
%COMPUTE_CROSS_PSD İki ölçüm kanalının tek taraflı Cross-PSD'sini hesaplar.
%   S_CROSS = COMPUTE_CROSS_PSD(CHANNELS, FS, NFFT), iki kolonlu CHANNELS
%   matrisine doğrudan FFT tabanlı korelasyon uygular. Çıktı komplekstir;
%   bağımsız referansların sönmesi için magnitude alınmadan ortalanmalıdır.

%% ---------------- CORRELATION INPUTS ----------------
% Cross-correlation ölçümü tam olarak iki kanal gerektirir.
if size(channels, 2) ~= 2
    error("Cross-PSD hesabi icin channels tam olarak iki kolonlu olmalidir.");
end
channel_length = size(channels, 1);

%% ---------------- FFT CROSS-CORRELATION ----------------
% X1*conj(X2), iki kanalda ortak DUT bileşenini korur. Birbirinden bağımsız
% Ref1 ve Ref2 bileşenleri iterasyonlar kompleks olarak ortalandıkça söner.
channel_spectra = fft(channels, nfft, 1);
S_cross_two_sided = channel_spectra(:, 1) ...
    .* conj(channel_spectra(:, 2)) / (fs*channel_length);

%% ---------------- ONE-SIDED CROSS-PSD ----------------
% Gerçek zaman sinyallerinde negatif frekans gücünü pozitif tarafa taşı.
% Eşleniği olmayan DC ve Nyquist kutuları ikiyle çarpılmaz.
number_of_positive_points = floor(nfft/2) + 1;
S_cross = S_cross_two_sided(1:number_of_positive_points);
S_cross(2:end-1) = 2*S_cross(2:end-1);

end
