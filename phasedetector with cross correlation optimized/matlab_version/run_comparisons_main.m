function run_comparisons_main(default_config, test_values, show_figures, project_dir)
% run_comparisons.m içinde tanımlanan testleri çalıştırır ve kaydeder.
%
% Girdiler:
%   default_config : Her sweep değerinden önce kopyalanan temel config.
%   test_values    : Sweep adlarını ve çalıştırılacak değer listelerini tutar.
%   show_figures   : Kaydedilen karşılaştırma figürlerini GUI'de açık bırakır.
%   project_dir    : results klasörünün oluşturulacağı proje yolu.
%
% Her tarama için:
%   - Spektrumlar -> results/<zaman_damgasi>_<tarama>/raw/*.mat
%   - Grafik      -> results/<zaman_damgasi>_<tarama>/plots/*_comparison.png
%   - Özet        -> results/<zaman_damgasi>_<tarama>/summary.mat, summary.csv
%
% Kaydedilen spektrumlar simülasyonu tekrarlamadan çizim yapabilmek için saklanır.
% Kaydedilmiş spektrumlardan grafikleri yeniden çizmek için: replot_results

% Hatalı temel ayarlarla uzun sweep'e başlamadan önce config'i kontrol et.
validate_config(default_config);

% Bütün test klasörleri aynı milisaniyeli zaman damgasını kullanır; test adı
% klasör sonuna eklenerek aynı batch'e ait sonuçlar birlikte görülebilir.
results_dir = fullfile(project_dir, "results");
if ~exist(results_dir, "dir")
    mkdir(results_dir);
end
run_stamp = char(datetime("now", "Format", "yyyyMMdd_HHmmssSSS"));

% Kullanıcı arayüzündeki listeleri ortak bir sweep tanım biçimine dönüştür.
% fields, değer uygulanacak config alanlarını; label_fmt, subplot etiketini tutar.
sweep_specs = {};
if isfield(test_values, "lpf_cutoff") && ~isempty(test_values.lpf_cutoff)
    spec = struct();
    spec.name = "lpf_cutoff";
    spec.fields = {"lpf_cutoff"};
    spec.field_label = "lpf_cutoff";
    spec.values = test_values.lpf_cutoff;
    spec.label_fmt = "f_c = %.0f Hz";
    spec.default = default_config.lpf_cutoff;
    sweep_specs{end+1} = spec;
end
if isfield(test_values, "rms_dut") && ~isempty(test_values.rms_dut)
    spec = struct();
    spec.name = "rms_dut";
    spec.fields = {"phase_rms_dut"};
    spec.field_label = "phase_rms_dut";
    spec.values = test_values.rms_dut;
    spec.label_fmt = "DUT = %.2f rad";
    spec.default = default_config.phase_rms_dut;
    sweep_specs{end+1} = spec;
end
if isfield(test_values, "rms_ref") && ~isempty(test_values.rms_ref)
    % Tek "rms_ref" değeri iki bağımsız referans kanalına birlikte uygulanır.
    if default_config.phase_rms_ref1 ~= default_config.phase_rms_ref2
        error("rms_ref testi icin varsayilan Ref1 ve Ref2 RMS esit olmalidir.");
    end
    spec = struct();
    spec.name = "rms_ref";
    spec.fields = {"phase_rms_ref1", "phase_rms_ref2"};
    spec.field_label = "phase_rms_ref1/phase_rms_ref2";
    spec.values = test_values.rms_ref;
    spec.label_fmt = "Ref1 = Ref2 = %.2f rad";
    spec.default = default_config.phase_rms_ref1;
    sweep_specs{end+1} = spec;
end
if isfield(test_values, "iterations") && ~isempty(test_values.iterations)
    spec = struct();
    spec.name = "iterations";
    spec.fields = {"number_of_iterations"};
    spec.field_label = "number_of_iterations";
    spec.values = test_values.iterations;
    spec.label_fmt = "iter = %d";
    spec.default = default_config.number_of_iterations;
    sweep_specs{end+1} = spec;
end
if isfield(test_values, "log_bins") && ~isempty(test_values.log_bins)
    spec = struct();
    spec.name = "log_bins";
    spec.fields = {"number_of_log_bins"};
    spec.field_label = "number_of_log_bins";
    spec.values = test_values.log_bins;
    spec.label_fmt = "bin = %d";
    spec.default = default_config.number_of_log_bins;
    sweep_specs{end+1} = spec;
end

if isempty(sweep_specs)
    error("En az bir test_values listesi dolu olmalidir.");
end

% Her sweep kendi klasörünü, ham spektrumlarını, grafiğini ve özetini üretir.
summaries = struct();
for spec_index = 1:numel(sweep_specs)
    spec = sweep_specs{spec_index};
    summaries.(spec.name) = run_one_sweep(spec, default_config, ...
        results_dir, run_stamp, show_figures);
end

% Genel özeti sabit genişlikli bir tablo olarak yaz.
fprintf("\n%-14s | %12s | %10s | %10s\n", ...
    "TEST", "DEGER", "MAE (dB)", "SURE (s)");
fprintf("%s\n", repmat("-", 1, 55));
for spec_index = 1:numel(sweep_specs)
    spec = sweep_specs{spec_index};
    summary = summaries.(spec.name);
    for value_index = 1:numel(summary.values)
        fprintf("%-14s | %12g | %10.3f | %10.2f\n", ...
            spec.name, summary.values(value_index), ...
            summary.mean_absolute_error_db(value_index), ...
            summary.elapsed_seconds(value_index));
    end
end

end

% Tek bir parametre taramasını çalıştırıp kaydeder.
function sweep_summary = run_one_sweep(spec, default_config, results_dir, ...
    run_stamp, show_figures)
% Bir parametrenin bütün test değerlerini birbirinden bağımsız çalıştırır.

number_of_values = numel(spec.values);

% Sweep'e ait spektrum ve grafik dosyalarını birbirinden ayıran klasörleri kur.
run_dir = fullfile(results_dir, sprintf("%s_%s", run_stamp, spec.name));
raw_dir = fullfile(run_dir, "raw");
plot_dir = fullfile(run_dir, "plots");
mkdir(run_dir);
mkdir(raw_dir);
mkdir(plot_dir);

% Döngü içinde dizi büyütmemek ve sonunda toplu grafik çizebilmek için ayır.
run_results = cell(1, number_of_values);
run_files = cell(1, number_of_values);
mean_absolute_error_db = zeros(1, number_of_values);
elapsed_seconds = zeros(1, number_of_values);

fprintf("\n=== TARAMA: %s ===\n", spec.name);
for value_index = 1:number_of_values
    value = spec.values(value_index);

    % Her değer temiz default_config kopyasından başlar; önceki run'ın config'i
    % veya spektrum accumulator'ı yeni run'a taşınmaz.
    config = default_config;
    for field_index = 1:numel(spec.fields)
        config.(spec.fields{field_index}) = value;
    end

    % run_simulation tek bir tam DUT/Ref simülasyonu ve Cross-PSD ortalaması yapar.
    run_timer = tic;
    current_results = run_simulation(config);
    elapsed_seconds(value_index) = toc(run_timer);

    % Grafik ve özet için yalnızca gerekli sonuç ve metrikleri bellekte tut.
    run_results{value_index} = current_results;
    mean_absolute_error_db(value_index) = current_results.mean_absolute_error_fft_db;

    % Tam spektrumları büyük dizileri de destekleyen MATLAB v7.3 biçiminde sakla.
    run_file = sprintf("run_%02d_%s_%s.mat", ...
        value_index, spec.name, value_to_suffix(value));
    run_files{value_index} = run_file;
    elapsed_seconds_current = elapsed_seconds(value_index);
    save(fullfile(raw_dir, run_file), ...
        "current_results", "elapsed_seconds_current", "value", "-v7.3");

    fprintf("  %s = %g | MAE: %.3f dB | sure: %.2f s | %s\n", ...
        spec.field_label, value, mean_absolute_error_db(value_index), ...
        elapsed_seconds(value_index), run_file);
end

% Sweep'in bütün bağımsız run'ları tamamlandıktan sonra subplot grafiğini üret.
comparison_png = fullfile(plot_dir, sprintf("%s_comparison.png", spec.name));
plot_sweep_results(spec.name, spec.values, run_results, spec.label_fmt, ...
    spec.default, comparison_png, show_figures);

% Replot işleminin simülasyonu tekrar kurmadan ihtiyaç duyduğu metadata ve
% Command Window tablosunda kullanılan metrikleri tek yapıda topla.
sweep_summary.sweep_name = spec.name;
sweep_summary.value_fields = spec.fields;
sweep_summary.value_field = spec.field_label;
sweep_summary.label_fmt = spec.label_fmt;
sweep_summary.default_value = spec.default;
sweep_summary.values = spec.values;
sweep_summary.run_files = run_files;
sweep_summary.mean_absolute_error_db = mean_absolute_error_db;
sweep_summary.elapsed_seconds = elapsed_seconds;
sweep_summary.config_template = default_config;
sweep_summary.timestamp = run_stamp;

save(fullfile(run_dir, "summary.mat"), "sweep_summary", "-v7.3");
write_summary_csv(fullfile(run_dir, "summary.csv"), sweep_summary);

fprintf("  -> kaydedildi: %s\n", run_dir);

end

function suffix = value_to_suffix(value)
% Sayısal değeri dosya adına uygun kısa bir metne dönüştürür.
% Örnek: 0.05 -> 0p05, -2 -> m2.

suffix = lower(sprintf("%.12g", value));
suffix = strrep(suffix, ".", "p");
suffix = strrep(suffix, "+", "");
suffix = strrep(suffix, "-", "m");

end

% Tarama özetini virgülle ayrılmış CSV dosyasına yazar.
function write_summary_csv(csv_path, sweep_summary)
% MAT özetindeki temel metriklerin elektronik tabloya uygun kopyasını yazar.

file_id = fopen(csv_path, "w");
if file_id < 0
    error("CSV dosyasi acilamadi: %s", csv_path);
end
fprintf(file_id, "run_file,value,mean_abs_error_db,elapsed_s\n");
for value_index = 1:numel(sweep_summary.values)
    fprintf(file_id, "%s,%g,%.6f,%.3f\n", ...
        sweep_summary.run_files{value_index}, ...
        sweep_summary.values(value_index), ...
        sweep_summary.mean_absolute_error_db(value_index), ...
        sweep_summary.elapsed_seconds(value_index));
end
fclose(file_id);

end
