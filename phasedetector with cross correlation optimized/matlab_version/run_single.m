% Tek simülasyon çalıştırıp sonucunu çizen script.
% Batch klasörü veya dosya üretmez; sonuçlar workspace'teki results yapısına gelir.

%% ---------------- SINGLE-RUN PARAMETERS ----------------
% Bu bölüm yalnızca bu script tarafından çalıştırılan tek koşuyu etkiler.
config = struct();
config.N = 100000;                 % Örnek sayısı
config.fs = 1e6;                   % Örnekleme frekansı (Hz)
config.A = 1;                      % Taşıyıcı genliği
config.f0 = 200e3;                 % Taşıyıcı frekansı (Hz)
config.settling_samples = 100;     % LPF geçici rejimi için atılan örnek
config.lpf_cutoff = 50e3;          % LPF kesim frekansı (Hz)
config.lpf_order = 4;              % LPF derecesi
config.phase_rms_dut = 0.2;        % DUT faz gürültüsü RMS (rad)
config.phase_rms_ref1 = 0.5;       % Referans 1 RMS (rad)
config.phase_rms_ref2 = 0.5;       % Referans 2 RMS (rad)
config.number_of_iterations = 200; % Cross-PSD ortalama sayısı
config.number_of_log_bins = 100;   % Logaritmik bin sayısı

%% ---------------- SIMULATION ----------------
% Script başka bir çalışma klasöründen başlatılsa da proje fonksiyonlarını bul.
project_dir = fileparts(mfilename("fullpath"));
addpath(project_dir);

% run_simulation ortalama Cross-PSD ile iterasyonların ortalama DUT periodogramını döndürür.
results = run_simulation(config);

%% ---------------- RESULT PLOT ----------------
% İki eğri aynı koşuya aittir: mavi ölçüm tahmini, kırmızı filtrelenmemiş DUT'tur.
fig = figure("name", "Single Cross-PSD Run");
semilogx(results.cross.frequency_binned, ...
    results.cross.phase_noise_binned, ...
    "b-", "LineWidth", 2, ...
    "DisplayName", "Cross-PSD estimate");
hold on;
semilogx(results.dut_fft_unfiltered.frequency_binned, ...
    results.dut_fft_unfiltered.phase_noise_binned, ...
    "r--", "LineWidth", 1.5, ...
    "DisplayName", "Averaged unfiltered DUT periodogram");

grid on;
xlabel("Offset Frequency (Hz)");
ylabel("Phase Noise (dBc/Hz)");
% İlk başlık satırı fiziksel ayarları, ikinci satır sonuç metriklerini gösterir.
title({sprintf( ...
    "f_c %.1f kHz | DUT %.2f rad | Ref %.2f/%.2f rad", ...
    config.lpf_cutoff/1e3, config.phase_rms_dut, ...
    config.phase_rms_ref1, config.phase_rms_ref2), ...
    sprintf("%d iter | %d bins | MAE %.3f dB", ...
    config.number_of_iterations, config.number_of_log_bins, ...
    results.mean_absolute_error_fft_db)}, ...
    "Interpreter", "none");
legend("location", "southwest");
hold off;
