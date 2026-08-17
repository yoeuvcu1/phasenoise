function run_comparisons_main(show_figures, project_dir)
% Cross-PSD faz gürültüsü simülasyonunu farklı parametre değerleriyle
% koşturup karşılaştıran koşu işlevi (run_comparisons.m tarafından
% yerel yansıma klasöründen çağrılır).
%
% Her tarama için:
%   - Ham veriler -> results/<zaman_damgasi>_<tarama>/raw/*.mat
%   - Grafikler   -> results/<zaman_damgasi>_<tarama>/plots/*.png
%   - Özet        -> results/<zaman_damgasi>_<tarama>/summary.mat, summary.csv
%
% Ham veriler tekrar hesaplama ve tekrar çizim için saklanır.
% Kaydedilmiş ham verilerden grafikleri yeniden çizmek için: replot_results

%% ======================= DEFAULT PARAMETRELER =======================
% Bu bölümdeki değerleri düzenleyerek koşuyu değiştirebilirsiniz.

% Sabit parametreler (tüm taramalarda ortak)
defaults.N = 100000;                 % Toplam örnek sayısı (test: 100000, gerçek sim: 1M)
defaults.fs = 1e6;                   % Örnekleme frekansı (Hz)
defaults.A = 1;                      % Taşıyıcı genliği
defaults.f0 = 50e3;                  % Taşıyıcı frekansı (Hz)
defaults.settling_samples = 100;     % LPF geçici bölgesi atılan örnek sayısı
defaults.lpf_order = 4;              % Faz detektörü LPF derecesi

% Değişken parametrelerin orijinal değerleri
defaults.lpf_cutoff = 25e3;          % Faz detektörü LPF kesim frekansı (Hz)
defaults.phase_rms_dut = 0.2;        % DUT faz gürültüsü RMS (rad)
defaults.phase_rms_ref = 0.05;       % Referans 1 = Referans 2 faz gürültüsü RMS (rad)
defaults.number_of_iterations = 100; % Cross-PSD ortalaması iterasyon sayısı
defaults.number_of_log_bins = 50;    % Logaritmik bin sayısı

%% ======================= KOŞULACAK TARAMALAR =======================
% Hangi taramaların yapılacağı ve her taramada denenecek değerler.
% Orijinal değer her listenin içinde bulunmalıdır (grafikte "(orig)" ile
% işaretlenir).

sweep_enabled.lpf_cutoff = true;     % Kesim frekansı taraması
sweep_enabled.rms_dut = true;        % DUT RMS taraması (ref1 = ref2 sabit)
sweep_enabled.rms_ref = true;        % Referans RMS taraması (ref1 = ref2, DUT sabit)
sweep_enabled.iterations = true;     % İterasyon sayısı taraması
sweep_enabled.log_bins = true;       % Log bin sayısı taraması

sweep_values.lpf_cutoff = [5e3, 10e3, 25e3, 50e3];   % Hz
sweep_values.rms_dut = [0.05, 0.1, 0.2, 0.5, 1.0];   % rad
sweep_values.rms_ref = [0.01, 0.02, 0.05, 0.1, 0.2]; % rad
sweep_values.iterations = [1, 5, 10, 25, 50, 100];   % adet
sweep_values.log_bins = [10, 25, 50, 100, 200];      % adet

%% ============================ HAZIRLIK ============================
results_dir = fullfile(project_dir, "results");
if ~exist(results_dir, "dir")
    mkdir(results_dir);
end
run_stamp = datestr(now(), "yyyymmdd_HHMMSS");

config_template.N = defaults.N;
config_template.fs = defaults.fs;
config_template.A = defaults.A;
config_template.f0 = defaults.f0;
config_template.settling_samples = defaults.settling_samples;
config_template.lpf_cutoff = defaults.lpf_cutoff;
config_template.lpf_order = defaults.lpf_order;
config_template.phase_rms_dut = defaults.phase_rms_dut;
config_template.phase_rms_ref1 = defaults.phase_rms_ref;
config_template.phase_rms_ref2 = defaults.phase_rms_ref;
config_template.number_of_iterations = defaults.number_of_iterations;
config_template.number_of_log_bins = defaults.number_of_log_bins;
config_template.show_plot = false;

% Tarama tanımlarını hazırla.
sweep_specs = {};
if sweep_enabled.lpf_cutoff
    sweep_specs{end+1} = struct("name", "lpf_cutoff", "field", "lpf_cutoff", ...
        "values", sweep_values.lpf_cutoff, "label_fmt", "f_c = %.0f Hz", ...
        "default", defaults.lpf_cutoff);
end
if sweep_enabled.rms_dut
    sweep_specs{end+1} = struct("name", "rms_dut", "field", "phase_rms_dut", ...
        "values", sweep_values.rms_dut, "label_fmt", "DUT = %.2f rad", ...
        "default", defaults.phase_rms_dut);
end
if sweep_enabled.rms_ref
    sweep_specs{end+1} = struct("name", "rms_ref", "field", "phase_rms_ref1", ...
        "values", sweep_values.rms_ref, "label_fmt", "Ref = %.2f rad", ...
        "default", defaults.phase_rms_ref);
end
if sweep_enabled.iterations
    sweep_specs{end+1} = struct("name", "iterations", "field", "number_of_iterations", ...
        "values", sweep_values.iterations, "label_fmt", "iter = %d", ...
        "default", defaults.number_of_iterations);
end
if sweep_enabled.log_bins
    sweep_specs{end+1} = struct("name", "log_bins", "field", "number_of_log_bins", ...
        "values", sweep_values.log_bins, "label_fmt", "bin = %d", ...
        "default", defaults.number_of_log_bins);
end

%% =========================== TARAMALARI KOŞ ===========================
summaries = struct();
for spec_index = 1:numel(sweep_specs)
    spec = sweep_specs{spec_index};
    summaries.(spec.name) = run_one_sweep( ...
        spec.name, spec.values, spec.field, spec.label_fmt, spec.default, ...
        config_template, results_dir, run_stamp, show_figures);
end

% Genel özeti ekrana yaz.
fprintf("\n==================== GENEL OZET ====================\n");
for spec_index = 1:numel(sweep_specs)
    spec = sweep_specs{spec_index};
    summary = summaries.(spec.name);
    fprintf("%-12s |", spec.name);
    for value_index = 1:numel(summary.values)
        fprintf(" %s = %-6g -> %.3f dB |", ...
            spec.field, summary.values(value_index), ...
            summary.mean_absolute_error_db(value_index));
    end
    fprintf("\n");
end

end

% ======================================================================
% Tek bir taramayı (bir parametrenin farklı değerlerini) koşturup
% kaydeder; ham veri dosyaları, tek koşu grafikleri, karşılaştırma
% grafiği ve özet çıktılarını üretir.
% ======================================================================
function sweep_summary = run_one_sweep(sweep_name, values, value_field, ...
    label_fmt, default_value, config_template, results_dir, run_stamp, show_figures)

number_of_values = numel(values);

run_dir = fullfile(results_dir, sprintf("%s_%s", run_stamp, sweep_name));
raw_dir = fullfile(run_dir, "raw");
plot_dir = fullfile(run_dir, "plots");
mkdir(run_dir);
mkdir(raw_dir);
mkdir(plot_dir);

run_results = cell(1, number_of_values);
run_files = cell(1, number_of_values);
mean_absolute_error_db = zeros(1, number_of_values);
correction_factors = zeros(1, number_of_values);
elapsed_seconds = zeros(1, number_of_values);

% Bu tarama için tek bir DUT taban gürültüsü üret (varsayılan RMS ile).
% Tüm koşullar bu SINYALİ paylaşır; sadece LPF kesim frekansı değişirse
% DUT FFT grafiği filtrelenerek değişir (farklı LPF grafiği olur ama
% aynı taban gürültüsünden gelir). Bu sayede karşılaştırma grafikleri
% temiz ve karşılaştırılabilir olur.
sweep_dut_noise = config_template.phase_rms_dut * ...
    generate_phase_noise(config_template.N, 1);

fprintf("\n=== TARAMA: %s ===\n", sweep_name);
for value_index = 1:number_of_values
    value = values(value_index);

    config = config_template;
    config.(value_field) = value;
    % Tüm koşullara AYNI DUT gürültüsünü geçir (tek taban sinyal).
    config.phase_noise_dut = sweep_dut_noise;

    run_timer = tic;
    current_results = main(config);
    elapsed_seconds(value_index) = toc(run_timer);

    run_results{value_index} = current_results;
    mean_absolute_error_db(value_index) = current_results.mean_absolute_error_fft_db;
    correction_factors(value_index) = current_results.correction_factor;

    run_file = sprintf("run_%02d_%s_%s.mat", ...
        value_index, sweep_name, make_file_suffix(value));
    run_files{value_index} = run_file;
    save(fullfile(raw_dir, run_file), "current_results", "elapsed_seconds", "value");

    single_png = fullfile(plot_dir, sprintf("run_%02d_%s_%s.png", ...
        value_index, sweep_name, make_file_suffix(value)));
    plot_single_run(current_results, single_png, false);

    fprintf("  %s = %g | MAE: %.3f dB | corr: %.4f | sure: %.2f s | %s\n", ...
        value_field, value, mean_absolute_error_db(value_index), ...
        correction_factors(value_index), elapsed_seconds(value_index), run_file);
end

comparison_png = fullfile(plot_dir, sprintf("%s_comparison.png", sweep_name));
plot_sweep_results(sweep_name, values, run_results, label_fmt, ...
    default_value, comparison_png, show_figures);

sweep_summary.sweep_name = sweep_name;
sweep_summary.value_field = value_field;
sweep_summary.label_fmt = label_fmt;
sweep_summary.default_value = default_value;
sweep_summary.values = values;
sweep_summary.run_files = run_files;
sweep_summary.mean_absolute_error_db = mean_absolute_error_db;
sweep_summary.correction_factors = correction_factors;
sweep_summary.elapsed_seconds = elapsed_seconds;
sweep_summary.config_template = config_template;
sweep_summary.timestamp = run_stamp;

save(fullfile(run_dir, "summary.mat"), "sweep_summary");
write_summary_csv(fullfile(run_dir, "summary.csv"), sweep_summary);

fprintf("  -> kaydedildi: %s\n", run_dir);

end

% ======================================================================
% Tarama özetini sekmeyle ayrılmış CSV dosyasına yazar.
% ======================================================================
function write_summary_csv(csv_path, sweep_summary)

file_id = fopen(csv_path, "w");
if file_id < 0
    error("CSV dosyasi acilamadi: %s", csv_path);
end
fprintf(file_id, "run_file\tvalue\tmean_abs_error_db\tcorrection_factor\telapsed_s\n");
for value_index = 1:numel(sweep_summary.values)
    fprintf(file_id, "%s\t%g\t%.6f\t%.6f\t%.3f\n", ...
        sweep_summary.run_files{value_index}, ...
        sweep_summary.values(value_index), ...
        sweep_summary.mean_absolute_error_db(value_index), ...
        sweep_summary.correction_factors(value_index), ...
        sweep_summary.elapsed_seconds(value_index));
end
fclose(file_id);

end
