function decade_table = export_decade_errors(results_subfolder, project_dir)
% Kayitli bir taramanin her kosusu için dekad bazli MAE tablosunu üretir.
%
% Simülasyonu yeniden çalistirmaz; replot_results_main ile ayni sekilde
% summary.mat indeksini ve raw/*.mat spektrumlarini okur. Sonuç hem ekrana
% yazilir hem de kosu klasoründeki decade_mae.csv dosyasina kaydedilir.
%
% Kullanim:
%   project_dir = fileparts(which("run_iterations"));
%   export_decade_errors("20260826_171636081_iterations", project_dir);

if nargin < 2 || isempty(project_dir)
    project_dir = fileparts(mfilename("fullpath"));
end
addpath(project_dir);

run_dir = fullfile(project_dir, "results", results_subfolder);
summary_file = fullfile(run_dir, "summary.mat");
if ~exist(summary_file, "file")
    error("Ozet dosyasi bulunamadi: %s", summary_file);
end
loaded_summary = load(summary_file);
sweep_summary = loaded_summary.sweep_summary;

number_of_values = numel(sweep_summary.values);
decade_table = struct("value", {}, "labels", {}, "mae_db", {}, ...
    "full_band_mae_db", {});

for value_index = 1:number_of_values
    raw_file = fullfile(run_dir, "raw", sweep_summary.run_files{value_index});
    loaded_run = load(raw_file, "current_results");
    current_results = loaded_run.current_results;
    if isfield(current_results, "dut_fft_unfiltered")
        dut_plot = current_results.dut_fft_unfiltered;
    else
        dut_plot = current_results.dut_fft;
    end

    bands = decade_band_errors( ...
        current_results.cross.frequency_binned, ...
        current_results.cross.phase_noise_binned, ...
        dut_plot.frequency_binned, ...
        dut_plot.phase_noise_binned, []);

    decade_table(value_index).value = sweep_summary.values(value_index);
    decade_table(value_index).labels = {bands.label};
    decade_table(value_index).mae_db = [bands.mean_absolute_error_db];
    decade_table(value_index).full_band_mae_db = ...
        current_results.mean_absolute_error_fft_db;
end

%% ---------------- CSV OUTPUT ----------------
% Bant etiketleri bütün kosularda ayni oldugu için ilk kosunun basligi kullanilir.
band_labels = decade_table(1).labels;
csv_path = fullfile(run_dir, "decade_mae.csv");
file_id = fopen(csv_path, "w");
if file_id < 0
    error("CSV yazilamadi: %s", csv_path);
end
fprintf(file_id, "value");
for band_index = 1:numel(band_labels)
    fprintf(file_id, ",%s", band_labels{band_index});
end
fprintf(file_id, ",full_band\n");
for value_index = 1:numel(decade_table)
    fprintf(file_id, "%g", decade_table(value_index).value);
    fprintf(file_id, ",%.3f", decade_table(value_index).mae_db);
    fprintf(file_id, ",%.3f\n", decade_table(value_index).full_band_mae_db);
end
fclose(file_id);

%% ---------------- CONSOLE OUTPUT ----------------
fprintf("%-10s", "value");
for band_index = 1:numel(band_labels)
    fprintf("%14s", band_labels{band_index});
end
fprintf("%14s\n", "full_band");
for value_index = 1:numel(decade_table)
    fprintf("%-10g", decade_table(value_index).value);
    fprintf("%14.3f", decade_table(value_index).mae_db);
    fprintf("%14.3f\n", decade_table(value_index).full_band_mae_db);
end
fprintf("Dekad MAE tablosu yazildi: %s\n", csv_path);

end
