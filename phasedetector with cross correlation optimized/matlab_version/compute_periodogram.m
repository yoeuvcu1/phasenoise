function [f, P] = compute_periodogram(x, fs, nfft)
% Çift uzunluklu FFT ile dikdörtgen pencereli tek taraflı PSD hesaplar.
% x zaman dizisi, fs örnekleme frekansı, nfft ise run_simulation tarafından
% seçilen çift radix-2 FFT boyudur; P birimi giriş_birimi^2/Hz olur.

%% ---------------- INPUT ORIENTATION ----------------
% Satır/sütun giriş farkını kaldırarak FFT yönünü sabitle.
x = x(:);
signal_length = length(x);

%% ---------------- TWO-SIDED PERIODOGRAM ----------------
% Sıfır doldurma gerçek örnek sayısını değiştirmediği için normalizasyonda
% nfft değil signal_length kullanılır.
X = fft(x, nfft);
P_two_sided = abs(X).^2 / (fs*signal_length);

%% ---------------- ONE-SIDED PSD ----------------
% Gerçek sinyalin negatif frekans gücünü pozitif tarafa ekle; DC ve Nyquist'i koru.
number_of_positive_points = floor(nfft/2) + 1;
P = P_two_sided(1:number_of_positive_points);
P(2:end-1) = 2*P(2:end-1);

f = (0:number_of_positive_points-1)' * fs/nfft;

end
