% Tek simülasyon çalıştırıp sonucunu çizen script.
% Batch klasörü veya dosya üretmez; sonuçlar workspace'teki results yapısına gelir.

%% Tek koşu parametreleri
% Bu bölüm yalnızca bu script tarafından çalıştırılan tek koşuyu etkiler.
config = struct();
config.N = 100000;                 % Örnek sayısı
config.fs = 1e6;                   % Örnekleme frekansı (Hz)
config.A = 1;                      % Taşıyıcı genliği
config.f0 = 50e3;                  % Taşıyıcı frekansı (Hz)
config.settling_samples = 600;     % LPF geçici rejimi için atılan örnek
config.lpf_cutoff = 10e3;          % LPF kesim frekansı (Hz)
config.lpf_order = 4;              % LPF derecesi
config.phase_rms_dut = 0.2;        % DUT faz gürültüsü RMS (rad)
config.phase_rms_ref1 = 0.05;      % Referans 1 RMS (rad)
config.phase_rms_ref2 = 0.05;      % Referans 2 RMS (rad)
config.number_of_iterations = 100; % Cross-PSD ortalama sayısı
config.number_of_log_bins = 100;   % Logaritmik bin sayısı

%% Simülasyon
% run_simulation hem Cross-PSD tahminini hem aynı DUT'nin periodogramını döndürür.
results = run_simulation(config);

%% Grafik
% İki eğri aynı koşuya aittir: mavi ölçüm tahmini, kırmızı DUT karşılığıdır.
fig = figure("name", "Single Cross-PSD Run");
semilogx(results.cross.frequency_binned, ...
    results.cross.phase_noise_binned, ...
    "b-", "LineWidth", 2, ...
    "DisplayName", "Cross-PSD estimate");
hold on;
semilogx(results.dut_fft.frequency_binned, ...
    results.dut_fft.phase_noise_binned, ...
    "r--", "LineWidth", 1.5, ...
    "DisplayName", "LPF-filtered DUT periodogram");

grid on;
xlabel("Offset Frequency (Hz)");
ylabel("Phase Noise (dBc/Hz)");
% İlk başlık satırı fiziksel ayarları, ikinci satır sonuç metriklerini gösterir.
title({sprintf( ...
    "f_c %.1f kHz | DUT %.2f rad | Ref %.2f/%.2f rad", ...
    config.lpf_cutoff/1e3, config.phase_rms_dut, ...
    config.phase_rms_ref1, config.phase_rms_ref2), ...
    sprintf("%d iter | %d bins | MAE %.3f dB | correction %.4f", ...
    config.number_of_iterations, config.number_of_log_bins, ...
    results.mean_absolute_error_fft_db, results.correction_factor)}, ...
    "Interpreter", "none");
legend("location", "southwest");
hold off;
