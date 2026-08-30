% Sunum icin istenen bagimsiz zaman ve frekans domeni grafiklerini uretir.
%
% Ciktilar:
%   1. DUT FFT spektrumu
%   2. Tek referans sinyalinin FFT spektrumu
%   3. DUT ve iki referansin zaman domeninde ust uste gosterimi
%   4. Bir mixer cikisinin FFT spektrumu
%   5. LPF, K_pd bolumu ve asin sonrasi sinyalin FFT spektrumu
%   6. Bir iterasyonluk Cross-PSD / DUT periodogrami karsilastirmasi
%   7. Elli iterasyonluk Cross-PSD / DUT periodogrami karsilastirmasi

%% ---------------- PATHS AND OUTPUT DIRECTORY ----------------
script_dir = fileparts(mfilename("fullpath"));
project_dir = fileparts(script_dir);
output_dir = fullfile(script_dir, "output");
addpath(project_dir);

if ~isfolder(output_dir)
    mkdir(output_dir);
end

% Onceki 16:9 taslak setine ait dosyalar yeni teslimle karismasin.
legacy_files = { ...
    "00_islem_akisi_ozet.png", ...
    "01_giris_sinyalleri.png", ...
    "02_mikser_ve_lpf.png", ...
    "03_normalizasyon_ve_faz.png", ...
    "04_cross_psd_dut_periodogram.png"};
for legacy_index = 1:numel(legacy_files)
    legacy_path = fullfile(output_dir, legacy_files{legacy_index});
    if isfile(legacy_path)
        delete(legacy_path);
    end
end

%% ---------------- REQUESTED DEFAULT PARAMETERS ----------------
config = struct();
config.N = 1000000;
config.fs = 1e6;
config.A = 1;
config.f0 = 200e3;
config.settling_samples = 512;
config.lpf_cutoff = 50e3;
config.lpf_order = 4;
config.phase_rms_dut = 0.05;
config.phase_rms_ref1 = 0.05;
config.phase_rms_ref2 = 0.05;
config.number_of_iterations = 50;
config.number_of_log_bins = 100;
config.random_seed = 13082026;

validate_config(config);
rng(config.random_seed, "twister");

%% ---------------- FIXED MODEL QUANTITIES ----------------
N = config.N;
fs = config.fs;
t = (0:N-1)' / fs;
carrier_phase = 2*pi*config.f0*t;
quadrature_phase = carrier_phase + pi/2;
K_pd = config.A^2 / 2;

channel_length = N - config.settling_samples;
nfft_cross = 2^nextpow2(2*channel_length - 1);
number_of_positive_points = floor(nfft_cross/2) + 1;
f_cross = (0:number_of_positive_points-1)' * fs/nfft_cross;

S_cross_sum = complex(zeros(number_of_positive_points, 1));
S_dut_sum = zeros(number_of_positive_points, 1);
first_iteration = struct();
correlation_1 = struct();
correlation_50 = struct();

%% ---------------- TWO-CHANNEL ITERATION FLOW ----------------
fprintf("Sunum grafikleri icin 50 iterasyon hesaplaniyor...\n");
simulation_timer = tic;

for iteration = 1:config.number_of_iterations
    % DUT iki kanalda ortaktir; iki referans birbirinden bagimsizdir.
    phase_noise_dut = presentation_phase_noise(N, config.phase_rms_dut);
    phase_noise_ref1 = presentation_phase_noise(N, config.phase_rms_ref1);
    phase_noise_ref2 = presentation_phase_noise(N, config.phase_rms_ref2);

    x_dut = config.A*cos(carrier_phase + phase_noise_dut);
    x_ref1 = config.A*cos(quadrature_phase + phase_noise_ref1);
    x_ref2 = config.A*cos(quadrature_phase + phase_noise_ref2);

    mixed_signals = mixer(x_dut, [x_ref1, x_ref2]);
    lpf_signals = lowpass_filter( ...
        mixed_signals, fs, config.lpf_cutoff, config.lpf_order);
    normalized_sine = lpf_signals / K_pd;
    clipped_sine = min(max(normalized_sine, -1), 1);
    phase_error = asin(clipped_sine);

    channels = phase_error(config.settling_samples + 1:end, :);
    channels = remove_dc(channels);
    S_cross_sum = S_cross_sum + ...
        compute_cross_psd(channels, fs, nfft_cross);

    dut_noise_for_periodogram = ...
        phase_noise_dut(config.settling_samples + 1:end);
    dut_noise_for_periodogram = remove_dc(dut_noise_for_periodogram);
    [~, S_dut_current] = compute_periodogram( ...
        dut_noise_for_periodogram, fs, nfft_cross);
    S_dut_sum = S_dut_sum + S_dut_current;

    if iteration == 1
        % Ara asama plotlari yalniz ilk, deterministik realizasyondan uretilir.
        first_iteration.phase_noise_dut = phase_noise_dut;
        first_iteration.phase_noise_ref1 = phase_noise_ref1;
        first_iteration.phase_noise_ref2 = phase_noise_ref2;
        first_iteration.x_dut = x_dut;
        first_iteration.x_ref1 = x_ref1;
        first_iteration.x_ref2 = x_ref2;
        first_iteration.mixer_output = mixed_signals(:, 1);
        first_iteration.lpf_output = lpf_signals(:, 1);
        first_iteration.processed_output = remove_dc( ...
            phase_error(config.settling_samples + 1:end, 1));

        correlation_1 = build_correlation_result( ...
            f_cross, S_cross_sum, S_dut_sum, iteration, ...
            config.number_of_log_bins);
    elseif iteration == 50
        correlation_50 = build_correlation_result( ...
            f_cross, S_cross_sum, S_dut_sum, iteration, ...
            config.number_of_log_bins);
    end

    if mod(iteration, 10) == 0
        fprintf("  %d/50 iterasyon tamamlandi.\n", iteration);
    end
end

simulation_seconds = toc(simulation_timer);
fprintf("Hesap tamamlandi: %.2f s\n", simulation_seconds);

if isempty(fieldnames(correlation_1)) || isempty(fieldnames(correlation_50))
    error("1 ve 50 iterasyon kontrol noktalari olusturulamadi.");
end

%% ---------------- FIRST-ITERATION FFT SPECTRA ----------------
[f_dut_fft, dut_fft_db] = one_sided_fft_db(first_iteration.x_dut, fs);
[f_ref_fft, ref_fft_db] = one_sided_fft_db(first_iteration.x_ref1, fs);
[f_mixer_fft, mixer_fft_db] = one_sided_fft_db( ...
    first_iteration.mixer_output, fs);
[f_processed_fft, processed_fft_db] = one_sided_fft_db( ...
    first_iteration.processed_output, fs);

% Ana spektral tepelerin modeldeki beklenen frekanslarda oldugunu dogrula.
[~, dut_peak_index] = max(dut_fft_db);
[~, ref_peak_index] = max(ref_fft_db);
[~, mixer_peak_index] = max(mixer_fft_db);
dut_peak_frequency = f_dut_fft(dut_peak_index);
ref_peak_frequency = f_ref_fft(ref_peak_index);
mixer_peak_frequency = f_mixer_fft(mixer_peak_index);
frequency_tolerance = 2*fs/N;
if abs(dut_peak_frequency - config.f0) > frequency_tolerance
    error("DUT FFT tepesi f0 frekansinda degil: %.3f Hz", ...
        dut_peak_frequency);
end
if abs(ref_peak_frequency - config.f0) > frequency_tolerance
    error("Referans FFT tepesi f0 frekansinda degil: %.3f Hz", ...
        ref_peak_frequency);
end
if abs(mixer_peak_frequency - 2*config.f0) > frequency_tolerance
    error("Mixer FFT tepesi 2f0 frekansinda degil: %.3f Hz", ...
        mixer_peak_frequency);
end

% LPF'nin toplam frekans bilesenini gercekten bastirdigini sayisal kabul
% kontroluyle dogrula. Bu kontrol grafik etiketinden bagimsizdir.
[f_lpf_fft, lpf_fft_db] = one_sided_fft_db(first_iteration.lpf_output, fs);
[~, mixer_2f0_index] = min(abs(f_mixer_fft - 2*config.f0));
[~, lpf_2f0_index] = min(abs(f_lpf_fft - 2*config.f0));
suppression_2f0_db = ...
    mixer_fft_db(mixer_2f0_index) - lpf_fft_db(lpf_2f0_index);
if ~isfinite(suppression_2f0_db) || suppression_2f0_db < 40
    error("LPF 2f0 bastirma kontrolu basarisiz: %.2f dB", ...
        suppression_2f0_db);
end

%% ---------------- PLOT COLORS ----------------
blue = [0.0000, 0.4470, 0.7410];
red = [0.8500, 0.1500, 0.1500];
gold = [0.9290, 0.6940, 0.1250];
purple = [0.4940, 0.1840, 0.5560];
dark_gray = [0.25, 0.25, 0.25];

%% ---------------- 01: DUT FFT SPECTRUM ----------------
plot_fft_spectrum( ...
    f_dut_fft, dut_fft_db, fs, blue, "DUT", ...
    fullfile(output_dir, "01_dut_fft_spektrumu.png"), [], config.f0);

%% ---------------- 02: REFERENCE FFT SPECTRUM ----------------
plot_fft_spectrum( ...
    f_ref_fft, ref_fft_db, fs, gold, "Referans Sinyali", ...
    fullfile(output_dir, "02_referans_fft_spektrumu.png"), [], config.f0);

%% ---------------- 03: DUT AND REFERENCES IN TIME ----------------
time_window_duration = 10e-6;
time_window_count = min(N, round(time_window_duration*fs) + 1);
time_indices = 1:time_window_count;

% fs/f0 = 5 ornek/tur oldugu icin, yalniz gorsel sunumda surekli tasiyiciyi
% gostermek uzere ayni faz realizasyonu daha yogun bir zaman izgarasina tasinir.
display_oversampling = 16;
t_dense = linspace( ...
    t(time_indices(1)), t(time_indices(end)), ...
    display_oversampling*numel(time_indices))';
dut_phase_dense = interp1(t(time_indices), ...
    first_iteration.phase_noise_dut(time_indices), t_dense, "pchip");
ref1_phase_dense = interp1(t(time_indices), ...
    first_iteration.phase_noise_ref1(time_indices), t_dense, "pchip");
ref2_phase_dense = interp1(t(time_indices), ...
    first_iteration.phase_noise_ref2(time_indices), t_dense, "pchip");

x_dut_dense = config.A*cos(2*pi*config.f0*t_dense + dut_phase_dense);
x_ref1_dense = config.A*cos( ...
    2*pi*config.f0*t_dense + pi/2 + ref1_phase_dense);
x_ref2_dense = config.A*cos( ...
    2*pi*config.f0*t_dense + pi/2 + ref2_phase_dense);

fig = standard_figure("DUT ve Referans Sinyalleri");
ax = axes(fig);
plot(ax, 1e6*t_dense, x_dut_dense, ...
    "Color", red, "LineWidth", 1.5, "DisplayName", "DUT");
hold(ax, "on");
plot(ax, 1e6*t_dense, x_ref1_dense, ...
    "Color", gold, "LineWidth", 1.3, "DisplayName", "Referans 1");
plot(ax, 1e6*t_dense, x_ref2_dense, ...
    "Color", purple, "LineWidth", 1.3, "DisplayName", "Referans 2");
xlim(ax, [0, 1e6*time_window_duration]);
xlabel(ax, "Zaman (µs)");
ylabel(ax, "Genlik");
title(ax, "DUT ve Referans Sinyalleri");
legend(ax, "Location", "best");
style_axis(ax);
export_figure(fig, fullfile(output_dir, ...
    "03_dut_ve_referanslar_zaman.png"));

%% ---------------- 04: MIXER OUTPUT FFT SPECTRUM ----------------
plot_fft_spectrum( ...
    f_mixer_fft, mixer_fft_db, fs, blue, "Mixer Çıkışı", ...
    fullfile(output_dir, "04_mixer_cikisi_fft_spektrumu.png"), [], ...
    2*config.f0);

%% ---------------- 05: LPF / KPD / ASIN OUTPUT FFT ----------------
plot_fft_spectrum( ...
    f_processed_fft, processed_fft_db, fs, blue, ...
    "LPF, Kpd ve Asin Sonrası", ...
    fullfile(output_dir, "05_islenmis_sinyal_fft_spektrumu.png"), ...
    struct("frequency", config.lpf_cutoff, ...
           "label", "f_{cutoff}", "color", dark_gray), []);

%% ---------------- 06-07: CORRELATION COMPARISONS ----------------
plot_correlation_comparison( ...
    correlation_1, "Korelasyon Sonucu - 1 İterasyon", ...
    blue, red, fullfile(output_dir, ...
    "06_korelasyon_1_iterasyon.png"));

plot_correlation_comparison( ...
    correlation_50, "Korelasyon Sonucu - 50 İterasyon", ...
    blue, red, fullfile(output_dir, ...
    "07_korelasyon_50_iterasyon.png"));

%% ---------------- RUN SUMMARY ----------------
summary_path = fullfile(output_dir, "run_summary.txt");
summary_file = fopen(summary_path, "w");
if summary_file < 0
    error("Ozet dosyasi acilamadi: %s", summary_path);
end
summary_cleanup = onCleanup(@() fclose(summary_file));
fprintf(summary_file, "Presentation FFT plots\n");
fprintf(summary_file, "seed=%d\n", config.random_seed);
fprintf(summary_file, "N=%d\n", config.N);
fprintf(summary_file, "fs=%.0f Hz\n", config.fs);
fprintf(summary_file, "f0=%.0f Hz\n", config.f0);
fprintf(summary_file, "lpf_cutoff=%.0f Hz\n", config.lpf_cutoff);
fprintf(summary_file, "lpf_order=%d\n", config.lpf_order);
fprintf(summary_file, "DUT_RMS=%.4f rad\n", config.phase_rms_dut);
fprintf(summary_file, "Ref1_RMS=%.4f rad\n", config.phase_rms_ref1);
fprintf(summary_file, "Ref2_RMS=%.4f rad\n", config.phase_rms_ref2);
fprintf(summary_file, "iterations=1,50\n");
fprintf(summary_file, "log_bins=%d\n", config.number_of_log_bins);
fprintf(summary_file, "DUT_FFT_peak=%.3f Hz\n", dut_peak_frequency);
fprintf(summary_file, "Reference_FFT_peak=%.3f Hz\n", ref_peak_frequency);
fprintf(summary_file, "Mixer_FFT_peak=%.3f Hz\n", mixer_peak_frequency);
fprintf(summary_file, "FFT_smoothing_bandwidth=250 Hz\n");
fprintf(summary_file, "FFT_max_plot_points=12000\n");
fprintf(summary_file, "time_domain_window=10 us\n");
fprintf(summary_file, "LPF_suppression_at_2f0=%.6f dB\n", ...
    suppression_2f0_db);
fprintf(summary_file, "runtime=%.3f s\n", simulation_seconds);
clear summary_cleanup;

fprintf("\nYedi grafik hazir: %s\n", output_dir);
fprintf("2f0 bastirma: %.2f dB\n", suppression_2f0_db);

%% ---------------- LOCAL HELPERS ----------------
function phase_noise = presentation_phase_noise(N, phase_rms)
% Ana generate_phase_noise.m ile ayni 1/f^3 sekillendirmeyi uygular.
white = randn(N, 1);
X_white = fft(white);
f_bin = [0:N/2, N/2-1:-1:1]';
f_bin(1) = 1;
phase_noise_filter = 1 ./ sqrt(f_bin.^3);
phase_noise_filter(1) = 0;
unit_phase_noise = real(ifft(X_white .* phase_noise_filter));
unit_phase_noise = unit_phase_noise - mean(unit_phase_noise);
unit_phase_noise = unit_phase_noise / sqrt(mean(unit_phase_noise.^2));
phase_noise = phase_rms * unit_phase_noise;
end

function result = build_correlation_result( ...
    frequency, S_cross_sum, S_dut_sum, iteration_count, number_of_log_bins)
% Ayni birikimli kosunun istenen iterasyon kontrol noktasini log-binler.
valid = frequency > 0;
S_cross_average = S_cross_sum / iteration_count;
S_dut_average = S_dut_sum / iteration_count;
[result.f_cross, result.L_cross] = logbin_phase_noise( ...
    frequency(valid), abs(S_cross_average(valid)), number_of_log_bins);
[result.f_dut, result.L_dut] = logbin_phase_noise( ...
    frequency(valid), S_dut_average(valid), number_of_log_bins);
result.iteration_count = iteration_count;
result.number_of_log_bins = number_of_log_bins;
end

function [frequency, magnitude_db] = one_sided_fft_db(signal, fs)
% FFT genligini tek tarafli spektruma cevirir; referans birim genliktir.
signal = signal(:);
signal_length = length(signal);
X = fft(signal);
positive_count = floor(signal_length/2) + 1;
magnitude = abs(X(1:positive_count)) / signal_length;
if mod(signal_length, 2) == 0
    magnitude(2:end-1) = 2*magnitude(2:end-1);
else
    magnitude(2:end) = 2*magnitude(2:end);
end
frequency = (0:positive_count-1)' * fs/signal_length;
magnitude_db = 20*log10(magnitude + realmin);
end

function plot_fft_spectrum( ...
    frequency, magnitude_db, fs, line_color, plot_title, output_path, ...
    cutoff, preserve_frequencies)
% Tek seri FFT spektrumunu varsayilan/kareye yakin figure boyunda cizer.
[plot_frequency, plot_magnitude_db] = smooth_fft_for_plot( ...
    frequency, magnitude_db, 250, 12000, preserve_frequencies);
fig = standard_figure(plot_title);
ax = axes(fig);
plot(ax, plot_frequency/1e3, plot_magnitude_db, ...
    "Color", line_color, "LineWidth", 1.4);
hold(ax, "on");
if ~isempty(cutoff)
    cutoff_line = xline(ax, cutoff.frequency/1e3, "--", cutoff.label, ...
        "Color", cutoff.color, "LineWidth", 1.4);
    cutoff_line.Interpreter = "tex";
    cutoff_line.LabelVerticalAlignment = "middle";
    cutoff_line.LabelHorizontalAlignment = "left";
end
xlim(ax, [0, fs/2/1e3]);
ylim(ax, spectrum_limits(plot_magnitude_db));
xlabel(ax, "Frekans (kHz)");
ylabel(ax, "FFT Genliği (dB)");
title(ax, plot_title);
style_axis(ax);
export_figure(fig, output_path);
end

function [plot_frequency, plot_magnitude_db] = smooth_fft_for_plot( ...
    frequency, magnitude_db, smoothing_bandwidth_hz, ...
    maximum_plot_points, preserve_frequencies)
% Ham FFT binlerini lineer guc alaninda kayan ortalamayla yumusatir.
% Taşıyıcı/mixer tepeleri, frekans konumlari ve gercek tepe genlikleri
% kaybolmasin diye seyreltilmis gorsel seriye ham degerleriyle geri eklenir.
frequency = frequency(:);
magnitude_db = magnitude_db(:);
if numel(frequency) ~= numel(magnitude_db) || numel(frequency) < 2
    error("FFT yumusatma girdileri ayni uzunlukta olmalidir.");
end

frequency_step = median(diff(frequency));
smoothing_window = max(3, round(smoothing_bandwidth_hz/frequency_step));
if mod(smoothing_window, 2) == 0
    smoothing_window = smoothing_window + 1;
end

linear_power = 10.^(magnitude_db/10);
smoothed_power = movmean( ...
    linear_power, smoothing_window, "Endpoints", "shrink");
smoothed_db = 10*log10(smoothed_power + realmin);

plot_stride = max(1, ceil(numel(frequency)/maximum_plot_points));
plot_indices = (1:plot_stride:numel(frequency))';
if plot_indices(end) ~= numel(frequency)
    plot_indices(end+1) = numel(frequency);
end

preserve_indices = zeros(numel(preserve_frequencies), 1);
for preserve_index = 1:numel(preserve_frequencies)
    [~, preserve_indices(preserve_index)] = min( ...
        abs(frequency - preserve_frequencies(preserve_index)));
end
plot_indices = unique([plot_indices; preserve_indices]);
plot_frequency = frequency(plot_indices);
plot_magnitude_db = smoothed_db(plot_indices);

% Yalniz fiziksel olarak onemli dar tepeleri ham FFT genligiyle koru.
for preserve_index = 1:numel(preserve_indices)
    output_index = find( ...
        plot_indices == preserve_indices(preserve_index), 1, "first");
    plot_magnitude_db(output_index) = ...
        magnitude_db(preserve_indices(preserve_index));
end
end

function plot_correlation_comparison( ...
    result, plot_title, cross_color, dut_color, output_path)
% Cross-PSD ve DUT periodogramini 100 log-bin ile ayni semilogx eksende cizer.
if result.number_of_log_bins ~= 100
    error("Korelasyon grafigi tam olarak 100 log-bin kullanmalidir.");
end
fig = standard_figure(plot_title);
ax = axes(fig);
semilogx(ax, result.f_cross, result.L_cross, ...
    "-", "Color", cross_color, "LineWidth", 2.0, ...
    "DisplayName", "Cross-PSD sonucu");
hold(ax, "on");
semilogx(ax, result.f_dut, result.L_dut, ...
    "--", "Color", dut_color, "LineWidth", 1.7, ...
    "DisplayName", "DUT periodogramı");
xlabel(ax, "Offset Frekansı (Hz)");
ylabel(ax, "Faz Gürültüsü (dBc/Hz)");
title(ax, plot_title);
legend(ax, "Location", "southwest");
style_axis(ax);
export_figure(fig, output_path);
end

function limits = spectrum_limits(levels)
% Tekil FFT tepelerini korurken bos alt bolgeyi sinirlayan saglam y araligi.
finite_levels = levels(isfinite(levels));
if isempty(finite_levels)
    error("FFT spektrumunda sonlu deger bulunamadi.");
end
sorted_levels = sort(finite_levels);
low_index = max(1, round(0.01*numel(sorted_levels)));
lower_limit = max(-220, 10*floor(sorted_levels(low_index)/10) - 10);
upper_limit = min(20, 10*ceil(max(sorted_levels)/10) + 5);
if upper_limit - lower_limit < 60
    lower_limit = upper_limit - 60;
end
limits = [lower_limit, upper_limit];
end

function fig = standard_figure(figure_name)
% Asiri yatay 16:9 yerine MATLAB varsayilanina yakin 7:6 oran kullanilir.
fig = figure("Name", figure_name, "Visible", "off", ...
    "Color", "white", "Units", "inches", ...
    "Position", [1, 1, 7, 6]);
end

function style_axis(ax)
grid(ax, "on");
ax.GridAlpha = 0.20;
ax.MinorGridAlpha = 0.10;
ax.FontName = "Helvetica";
ax.FontSize = 11;
ax.LineWidth = 0.8;
ax.Box = "on";
end

function export_figure(fig, output_path)
% 7 x 6 inch figure'i 150 DPI ile 1050 x 900 PNG olarak kaydeder.
set(fig, "PaperUnits", "inches");
set(fig, "PaperPosition", [0, 0, 7, 6]);
set(fig, "PaperSize", [7, 6]);
print(fig, output_path, "-dpng", "-r150");
close(fig);
end
