function S_cross_iteration = measure_iteration( ...
    x_dut, A, reference_phase, ...
    phase_rms_ref1, phase_rms_ref2, ...
    fs, lpf_cutoff, lpf_order, K_pd, settling_samples, nfft_cross)
% Tek bir iterasyonda iki referansla cross-PSD ölçümünü döndürür.
% x_dut bu iterasyona aittir; bu çağrıda Ref1/Ref2 yeniden üretilir.
% Çıktı kompleks tek taraflı cross spektrumdur ve run_simulation tarafından
% diğer iterasyonlarla kompleks olarak ortalanır.

%% ---------------- REFERENCE SIGNAL GENERATION ----------------
N = length(x_dut);

% İki referans faz dizisi aynı hedef spektrum modelinden ayrı çağrılarla üretilir.
phase_noise_ref1 = generate_phase_noise(N, phase_rms_ref1);
phase_noise_ref2 = generate_phase_noise(N, phase_rms_ref2);

% Referans taşıyıcıları DUT'ye göre istenen merkez faz farkında kurulur.
% 90 derecede bu klasik quadrature faz dedektörüdür.
x_ref1 = A*cos(reference_phase + phase_noise_ref1);
x_ref2 = A*cos(reference_phase + phase_noise_ref2);

%% ---------------- MIXER ----------------
% İki bağımsız referansı kolonlarda birleştir; mixer her referansı ortak DUT
% sinyaliyle çarparak iki paralel faz detektörü kanalı üretir.
reference_signals = [x_ref1, x_ref2];
mixed_signals = mixer(x_dut, reference_signals);

%% ---------------- LOW-PASS FILTER ----------------
% LPF, çarpımdan gelen toplam-frekans bileşenini bastırır. K_pd bölümü filtre
% çıkışını sin(faz hatası) ölçeğine getirir.
phase_sine = lowpass_filter( ...
    mixed_signals, fs, lpf_cutoff, lpf_order) / K_pd;

% Sayısal veya filtre geçicisi kaynaklı küçük taşmaları gerçek asin aralığına
% sınırla; asin, sinüzoidal detektör karakteristiğini faz hatasına geri çevirir.
phase_sine = min(max(phase_sine, -1), 1);
phase_error = asin(phase_sine);

%% ---------------- CHANNEL PREPARATION ----------------
% IIR filtrenin başlangıç geçicisini at, ardından her kanalın sabit ofsetini
% korelasyon hesabından önce ayrı ayrı temizle.
channels = phase_error(settling_samples + 1:end, :);
channels = remove_dc(channels);

%% ---------------- CROSS-CORRELATION / CROSS-PSD ----------------
% Korelasyon bloğu kompleks tek taraflı spektrumu hesaplar; magnitude alma ve
% iterasyon ortalaması run_simulation içinde daha sonra yapılır.
S_cross_iteration = compute_cross_psd(channels, fs, nfft_cross);

end
