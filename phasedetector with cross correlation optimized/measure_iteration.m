function S_cross_iteration = measure_iteration( ...
    x_dut, A, quadrature_phase, ...
    phase_rms_ref1, phase_rms_ref2, ...
    b_lpf, a_lpf, K_pd, settling_samples, fs, nfft_cross)
% Tek bir iterasyonda iki referansla cross-PSD ölçümünü döndürür.
% x_dut run boyunca sabittir; bu çağrıda Ref1/Ref2 yeniden üretilir.
% Çıktı kompleks tek taraflı cross spektrumdur ve run_simulation tarafından
% diğer iterasyonlarla kompleks olarak ortalanır.

N = length(x_dut);

% İki referans faz dizisi aynı hedef spektrum modelinden ayrı çağrılarla üretilir.
phase_noise_ref1 = generate_phase_noise(N, phase_rms_ref1);
phase_noise_ref2 = generate_phase_noise(N, phase_rms_ref2);

% Referans taşıyıcıları DUT'ye göre 90 derece faz kaydırılmış merkez fazda kur.
x_ref1 = A*cos(quadrature_phase + phase_noise_ref1);
x_ref2 = A*cos(quadrature_phase + phase_noise_ref2);

% Çarpım faz detektörü iki kanal üretir; LPF toplam-frekans bileşenini bastırır,
% K_pd bölümü ise çıkışı yaklaşık faz hatası (rad) ölçeğine getirir.
pd_raw = [x_dut .* x_ref1, x_dut .* x_ref2];
phase_error = filter(b_lpf, a_lpf, pd_raw) / K_pd;
channels = phase_error(settling_samples + 1:end, :);

% Başlangıç geçicisi atıldıktan sonra her kanalın sabit ofsetini temizle.
channels = remove_dc(channels);
channel_length = size(channels, 1);

% X1*conj(X2), iki kanalda ortak olan DUT bileşenini korurken bağımsız referans
% bileşenlerinin iterasyon ortalamasında sönmesini sağlar.
channel_spectra = fft(channels, nfft_cross, 1);
S_cross_two_sided = channel_spectra(:, 1) ...
    .* conj(channel_spectra(:, 2)) / (fs*channel_length);

% Gerçek zaman sinyali için negatif frekans gücünü pozitif tarafa taşı;
% eşleniği olmayan DC ve Nyquist kutuları ikiyle çarpılmaz.
number_of_positive_points = floor(nfft_cross/2) + 1;
S_cross_iteration = S_cross_two_sided(1:number_of_positive_points);
S_cross_iteration(2:end-1) = 2*S_cross_iteration(2:end-1);

end
