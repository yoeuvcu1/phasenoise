function merged_results_subfolder = extend_iteration_results_main( ...
    base_results_subfolder, import_results_subfolders, ...
    new_iteration_values, show_figures, project_dir)
% Eski iteration sweep'ini tamamlanmis kosular ve yeni degerlerle genisletir.
%
% Kaynak klasorler degistirilmez. Birlesik raw dosyalari, summary ve grafik
% yeni bir <timestamp>_iterations_merged klasorune yazilir.

if nargin ~= 5
    error(["Bes girdi gereklidir: base klasoru, import klasorleri, yeni ", ...
        "iteration degerleri, show_figures ve project_dir."]);
end

if ischar(import_results_subfolders)
    import_results_subfolders = {import_results_subfolders};
elseif ~iscell(import_results_subfolders)
    error("import_results_subfolders bir metin veya metin hucre dizisi olmalidir.");
end
if ~isscalar(show_figures) || ...
        ~(islogical(show_figures) || isnumeric(show_figures))
    error("show_figures skaler logical veya sayisal bir deger olmalidir.");
end
if isempty(import_results_subfolders) && isempty(new_iteration_values)
    error("Ice aktarilacak bir klasor veya yeni iteration degeri verilmelidir.");
end

new_iteration_values = validate_iteration_values(new_iteration_values);
results_root = fullfile(project_dir, "results");
if ~exist(results_root, "dir")
    error("results klasoru bulunamadi: %s", results_root);
end

%% ---------------- LOAD EXISTING RUNS ----------------
base_sweep = load_iteration_sweep(results_root, base_results_subfolder);
reference_config = base_sweep.summary.config_template;
records = base_sweep.records;

for record_index = 1:numel(records)
    assert_matching_config(reference_config, ...
        records(record_index).current_results.config, ...
        sprintf("%s / %g", base_results_subfolder, records(record_index).value));
end

for folder_index = 1:numel(import_results_subfolders)
    source_subfolder = import_results_subfolders{folder_index};
    if ~ischar(source_subfolder) || isempty(source_subfolder)
        error("Her import klasoru bos olmayan bir metin olmalidir.");
    end

    source_sweep = load_iteration_sweep(results_root, source_subfolder);
    assert_matching_config(reference_config, source_sweep.summary.config_template, ...
        source_subfolder);

    for source_index = 1:numel(source_sweep.records)
        source_record = source_sweep.records(source_index);
        assert_matching_config(reference_config, ...
            source_record.current_results.config, ...
            sprintf("%s / %g", source_subfolder, source_record.value));

        if any(record_values(records) == source_record.value)
            fprintf("Mevcut deger korunuyor, import atlandi: %g iter\n", ...
                source_record.value);
        else
            records(end+1) = source_record;
            fprintf("Import edildi: %g iter <- %s\n", ...
                source_record.value, source_subfolder);
        end
    end
end

%% ---------------- DETERMINE OUTPUT VALUES ----------------
all_values = unique([record_values(records), new_iteration_values]);
if isempty(all_values)
    error("Birlesik sonuc icin iteration degeri bulunamadi.");
end

run_stamp = datestr(now(), "yyyymmdd_HHMMSSFFF");
merged_results_subfolder = sprintf("%s_iterations_merged", run_stamp);
run_dir = fullfile(results_root, merged_results_subfolder);
suffix_index = 1;
while exist(run_dir, "dir")
    merged_results_subfolder = sprintf("%s_iterations_merged_%d", ...
        run_stamp, suffix_index);
    run_dir = fullfile(results_root, merged_results_subfolder);
    suffix_index = suffix_index + 1;
end

raw_dir = fullfile(run_dir, "raw");
plot_dir = fullfile(run_dir, "plots");
mkdir(run_dir);
mkdir(raw_dir);
mkdir(plot_dir);

number_of_values = numel(all_values);
run_results = cell(1, number_of_values);
run_files = cell(1, number_of_values);
mean_absolute_error_db = zeros(1, number_of_values);
correction_factors = zeros(1, number_of_values);
elapsed_seconds = zeros(1, number_of_values);

%% ---------------- REUSE OR RUN EACH VALUE ----------------
for value_index = 1:number_of_values
    value = all_values(value_index);
    existing_index = find(record_values(records) == value, 1);

    if isempty(existing_index)
        config = reference_config;
        config.number_of_iterations = value;
        validate_config(config);

        fprintf("\nEksik deger calistiriliyor: %g iter\n", value);
        run_timer = tic;
        current_results = run_simulation(config);
        elapsed_seconds_current = toc(run_timer);
    else
        current_results = records(existing_index).current_results;
        elapsed_seconds_current = records(existing_index).elapsed_seconds;
        fprintf("Kayitli sonuc kullaniliyor: %g iter\n", value);
    end

    run_file = sprintf("run_%02d_iterations_%s.mat", ...
        value_index, value_to_suffix(value));
    run_files{value_index} = run_file;
    run_results{value_index} = current_results;
    mean_absolute_error_db(value_index) = ...
        current_results.mean_absolute_error_fft_db;
    correction_factors(value_index) = current_results.correction_factor;
    elapsed_seconds(value_index) = elapsed_seconds_current;

    save("-mat7-binary", fullfile(raw_dir, run_file), ...
        "current_results", "elapsed_seconds_current", "value");
end

%% ---------------- SUMMARY AND PLOT ----------------
sweep_summary.sweep_name = "iterations";
sweep_summary.value_fields = {"number_of_iterations"};
sweep_summary.value_field = "number_of_iterations";
sweep_summary.label_fmt = "iter = %d";
sweep_summary.default_value = base_sweep.summary.default_value;
sweep_summary.values = all_values;
sweep_summary.run_files = run_files;
sweep_summary.mean_absolute_error_db = mean_absolute_error_db;
sweep_summary.correction_factors = correction_factors;
sweep_summary.elapsed_seconds = elapsed_seconds;
sweep_summary.config_template = reference_config;
sweep_summary.timestamp = run_stamp;
sweep_summary.base_results_subfolder = base_results_subfolder;
sweep_summary.import_results_subfolders = import_results_subfolders;

save("-mat7-binary", fullfile(run_dir, "summary.mat"), "sweep_summary");
write_summary_csv(fullfile(run_dir, "summary.csv"), sweep_summary);

comparison_png = fullfile(plot_dir, "iterations_comparison.png");
plot_sweep_results("iterations", all_values, run_results, ...
    sweep_summary.label_fmt, sweep_summary.default_value, ...
    comparison_png, show_figures);

fprintf("Birlesik iteration sweep'i kaydedildi: %s\n", run_dir);

end


function sweep = load_iteration_sweep(results_root, results_subfolder)
% Tamamlanmis bir iteration sweep'inin summary ve raw dosyalarini yukler.

run_dir = fullfile(results_root, results_subfolder);
summary_file = fullfile(run_dir, "summary.mat");
if ~exist(summary_file, "file")
    error(["Tamamlanmis summary.mat bulunamadi: %s. Kosu devam ediyorsa ", ...
        "bitmesini bekleyin."], summary_file);
end

loaded_summary = load(summary_file);
if ~isfield(loaded_summary, "sweep_summary")
    error("sweep_summary bulunamadi: %s", summary_file);
end
sweep.summary = loaded_summary.sweep_summary;
if ~isfield(sweep.summary, "sweep_name") || ...
        ~strcmp(sweep.summary.sweep_name, "iterations")
    error("Klasor bir iterations sweep'i degil: %s", results_subfolder);
end
if ~isfield(sweep.summary, "config_template")
    error("config_template summary icinde bulunamadi: %s", summary_file);
end
if numel(sweep.summary.values) ~= numel(sweep.summary.run_files)
    error("summary values/run_files uzunluklari uyusmuyor: %s", summary_file);
end

record_template = struct( ...
    "value", [], "current_results", [], "elapsed_seconds", [], ...
    "source_subfolder", "");
sweep.records = repmat(record_template, 1, numel(sweep.summary.values));
raw_dir = fullfile(run_dir, "raw");

for value_index = 1:numel(sweep.summary.values)
    raw_file = fullfile(raw_dir, sweep.summary.run_files{value_index});
    if ~exist(raw_file, "file")
        error("Summary'de listelenen raw dosyasi bulunamadi: %s", raw_file);
    end

    loaded_run = load(raw_file);
    if ~isfield(loaded_run, "current_results")
        error("current_results raw dosyasinda bulunamadi: %s", raw_file);
    end

    sweep.records(value_index).value = sweep.summary.values(value_index);
    sweep.records(value_index).current_results = loaded_run.current_results;
    sweep.records(value_index).source_subfolder = results_subfolder;
    if isfield(loaded_run, "elapsed_seconds_current")
        sweep.records(value_index).elapsed_seconds = ...
            loaded_run.elapsed_seconds_current;
    else
        sweep.records(value_index).elapsed_seconds = ...
            sweep.summary.elapsed_seconds(value_index);
    end
end

end


function values = validate_iteration_values(values)
% Yeni sweep degerlerini run_simulation sozlesmesine gore dogrular.

if isempty(values)
    values = [];
    return;
end
if ~isnumeric(values) || ~isreal(values) || any(~isfinite(values(:))) || ...
        any(values(:) <= 0) || any(values(:) ~= fix(values(:)))
    error("Yeni iteration degerleri pozitif, sonlu tamsayilar olmalidir.");
end
values = unique(values(:).');

end


function values = record_values(records)
% Bos struct dizisini de guvenli bicimde sayisal deger listesine cevirir.

if isempty(records)
    values = [];
else
    values = [records.value];
end

end


function assert_matching_config(reference_config, candidate_config, context)
% Iteration sayisi disindaki tum ayarlarin ayni oldugunu dogrular.

fields = fieldnames(reference_config);
for field_index = 1:numel(fields)
    field_name = fields{field_index};
    if strcmp(field_name, "number_of_iterations")
        continue;
    end
    if ~isfield(candidate_config, field_name) || ...
            ~isequal(reference_config.(field_name), candidate_config.(field_name))
        error("Config uyusmazligi (%s): %s", context, field_name);
    end
end

end


function suffix = value_to_suffix(value)
% Sayisal degeri mevcut raw dosya adlandirmasina donusturur.

suffix = lower(sprintf("%.12g", value));
suffix = strrep(suffix, ".", "p");
suffix = strrep(suffix, "+", "");
suffix = strrep(suffix, "-", "m");

end


function write_summary_csv(csv_path, sweep_summary)
% Birlesik summary'nin elektronik tablo kopyasini yazar.

file_id = fopen(csv_path, "w");
if file_id < 0
    error("CSV dosyasi acilamadi: %s", csv_path);
end
fprintf(file_id, "run_file,value,mean_abs_error_db,correction_factor,elapsed_s\n");
for value_index = 1:numel(sweep_summary.values)
    fprintf(file_id, "%s,%g,%.6f,%.6f,%.3f\n", ...
        sweep_summary.run_files{value_index}, ...
        sweep_summary.values(value_index), ...
        sweep_summary.mean_absolute_error_db(value_index), ...
        sweep_summary.correction_factors(value_index), ...
        sweep_summary.elapsed_seconds(value_index));
end
fclose(file_id);

end
