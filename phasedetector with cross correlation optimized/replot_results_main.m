function replot_results_main(results_subfolder, show_figures, project_dir)
% Tek bir sonuç klasöründeki kayıtlı spektrumlardan grafiği yeniden çizer.
%
% Girdiler:
%   results_subfolder : results/ altındaki tam klasör adı.
%   show_figures      : true ise kaydedilen figürü GUI'de açık bırakır.
%   project_dir       : results klasörünün bağlı olduğu proje yolu.
%
% Bu fonksiyon run_simulation çağırmaz; summary.mat dosyasını indeks olarak
% kullanıp daha önce kaydedilmiş current_results yapılarını belleğe yükler.

% Önce ana results klasörünün ve kullanıcının seçtiği run klasörünün varlığını doğrula.
results_root = fullfile(project_dir, "results");
if ~exist(results_root, "dir")
    error("results klasoru bulunamadi: %s (once run_comparisons calistirin)", results_root);
end

run_dir = fullfile(results_root, results_subfolder);
if ~exist(run_dir, "dir")
    error("Kosu klasoru bulunamadi: %s", run_dir);
end

% summary.mat; sweep adı, değer sırası, raw dosya adları ve plot etiketi gibi
% yeniden çizim için gerekli metadata'yı içerir.
summary_file = fullfile(run_dir, "summary.mat");
if ~exist(summary_file, "file")
    error("Ozet dosyasi bulunamadi: %s", summary_file);
end
loaded_summary = load(summary_file);
sweep_summary = loaded_summary.sweep_summary;

% PNG aynı run klasörünün plots/ dizisine yazılır; klasör silinmişse yeniden kurulur.
raw_dir = fullfile(run_dir, "raw");
plot_dir = fullfile(run_dir, "plots");
if ~exist(plot_dir, "dir")
    mkdir(plot_dir);
end

% summary içindeki sıra, subplot sırası ve legend/başlık değerleriyle aynıdır.
number_of_values = numel(sweep_summary.values);
run_results = cell(1, number_of_values);

% Her raw MAT dosyasından yalnızca simülasyonun döndürdüğü current_results
% yapısını al; yeniden FFT, filtreleme veya gürültü üretimi yapılmaz.
for value_index = 1:number_of_values
    raw_file = fullfile(raw_dir, sweep_summary.run_files{value_index});
    if ~exist(raw_file, "file")
        error("Spektrum dosyasi bulunamadi: %s", raw_file);
    end
    loaded_run = load(raw_file);
    run_results{value_index} = loaded_run.current_results;
end

% İlk çalıştırmada kullanılan aynı çiziciye metadata ve spektrumları gönder.
% Böylece run_comparisons ve replot ile üretilen grafik formatları aynı kalır.
comparison_png = fullfile(plot_dir, ...
    sprintf("%s_comparison.png", sweep_summary.sweep_name));
plot_sweep_results(sweep_summary.sweep_name, sweep_summary.values, ...
    run_results, sweep_summary.label_fmt, sweep_summary.default_value, ...
    comparison_png, show_figures);

fprintf("Grafikler yeniden cizildi: %s\n", plot_dir);

end
