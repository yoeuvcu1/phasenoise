function replot_results_main(results_subfolder, show_figures, project_dir)
% Kaydedilmiş ham verilerden (.mat) grafikleri yeniden çizer
% (replot_results.m tarafından yerel yansıma klasöründen çağrılır).
% results_subfolder boş ise results/ altındaki en son koşu klasörü seçilir.

results_root = fullfile(project_dir, "results");
if ~exist(results_root, "dir")
    error("results klasoru bulunamadi: %s (once run_comparisons calistirin)", results_root);
end

if isempty(results_subfolder)
    results_subfolder = latest_results_subfolder(results_root);
end

run_dir = fullfile(results_root, results_subfolder);
if ~exist(run_dir, "dir")
    error("Kosu klasoru bulunamadi: %s", run_dir);
end

summary_file = fullfile(run_dir, "summary.mat");
if ~exist(summary_file, "file")
    error("Ozet dosyasi bulunamadi: %s", summary_file);
end
loaded_summary = load(summary_file);
sweep_summary = loaded_summary.sweep_summary;

raw_dir = fullfile(run_dir, "raw");
plot_dir = fullfile(run_dir, "plots");
if ~exist(plot_dir, "dir")
    mkdir(plot_dir);
end

number_of_values = numel(sweep_summary.values);
run_results = cell(1, number_of_values);

for value_index = 1:number_of_values
    raw_file = fullfile(raw_dir, sweep_summary.run_files{value_index});
    if ~exist(raw_file, "file")
        error("Ham veri dosyasi bulunamadi: %s", raw_file);
    end
    loaded_run = load(raw_file);
    run_results{value_index} = loaded_run.current_results;

    single_png = fullfile(plot_dir, sprintf("run_%02d_%s_%s.png", ...
        value_index, sweep_summary.sweep_name, ...
        make_file_suffix(sweep_summary.values(value_index))));
    plot_single_run(loaded_run.current_results, single_png, false);
end

comparison_png = fullfile(plot_dir, ...
    sprintf("%s_comparison.png", sweep_summary.sweep_name));
plot_sweep_results(sweep_summary.sweep_name, sweep_summary.values, ...
    run_results, sweep_summary.label_fmt, sweep_summary.default_value, ...
    comparison_png, show_figures);

fprintf("Grafikler yeniden cizildi: %s\n", plot_dir);

end

% ======================================================================
% results klasöründeki en son koşu klasörünü bulur (isimler zaman
% damgalı olduğu için alfabetik sıralama zaman sıralamasıdır).
% ======================================================================
function latest_name = latest_results_subfolder(results_root)

dir_entries = dir(results_root);
name_list = {};
for entry_index = 1:numel(dir_entries)
    if dir_entries(entry_index).isdir && ...
            ~strcmp(dir_entries(entry_index).name, ".") && ...
            ~strcmp(dir_entries(entry_index).name, "..")
        name_list{end+1} = dir_entries(entry_index).name;
    end
end
if isempty(name_list)
    error("results klasorunde sonuc bulunamadi.");
end

name_list = sort(name_list);
latest_name = name_list{end};

end
