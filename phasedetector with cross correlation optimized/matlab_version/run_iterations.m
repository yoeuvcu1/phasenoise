% Yalnız cross-PSD iterasyon sayısını tarayan karşılaştırma scripti.
%
% Her test değeri için diğer bütün fiziksel ve sayısal ayarlar sabit tutulur.
% Sonuçlar results/<timestamp>_iterations/ altında raw MAT, summary ve PNG
% olarak saklanır.

%% ---------------- FIXED SIMULATION PARAMETERS ----------------
default_config = struct();
default_config.N = 1000000;                 % Örnek sayısı
default_config.fs = 1e6;                   % Örnekleme frekansı (Hz)
default_config.A = 1;                      % Taşıyıcı genliği
default_config.f0 = 200e3;                  % Taşıyıcı frekansı (Hz)
default_config.settling_samples = 0;     % LPF geçici rejimi için atılan örnek
default_config.lpf_cutoff = 100e3;          % LPF kesim frekansı (Hz)
default_config.lpf_order = 4;              % LPF derecesi
default_config.phase_rms_dut = 0.02;       % DUT faz gürültüsü RMS (rad)
default_config.phase_rms_ref1 = 0.05;      % Referans 1 RMS (rad)
default_config.phase_rms_ref2 = 0.05;      % Referans 2 RMS (rad)
default_config.number_of_iterations = 100; % Grafikte (orig) işaretlenecek değer
default_config.number_of_log_bins = 100;   % Logaritmik bin sayısı

%% ---------------- ITERATION SWEEP VALUES ----------------
iteration_values = [1, 10, 100, 250, 500, 1000, 5000, 10000, 20000];
% Daha kısa deneme için alternatif: iteration_values = [1, 10, 50, 100, 200, 500];

%% ---------------- RUN ITERATION SWEEP ----------------
% Mevcut karşılaştırma yöneticisine yalnız iterations taramasını açarak gönder.
test_values = struct();
test_values.lpf_cutoff = [];
test_values.rms_dut = [];
test_values.rms_ref = [];
test_values.iterations = iteration_values;
test_values.log_bins = [];

show_figures = false; % Uzun MATLAB batch koşusunda figürleri kaydet ve kapat

% Script başka bir çalışma klasöründen başlatılsa da proje fonksiyonlarını bul.
project_dir = fileparts(mfilename("fullpath"));
addpath(project_dir);

run_comparisons_main(default_config, test_values, show_figures, project_dir);

fprintf("\nHazir. Iterasyon sonuclari: %s\n", ...
    fullfile(project_dir, "results"));
