% replot_results.m
% =====================================================================
% Kaydedilmiş spektrumlardan grafikleri yeniden çizer.
% Simülasyonu yeniden koşturmaz; veriler results/ klasöründen okunur.
%
% Akış:
%   1. Çizilecek sonuç klasörü veya klasörleri seçilir.
%   2. Her klasörün summary.mat dosyasından koşu listesi okunur.
%   3. raw/*.mat spektrumları yüklenir ve aynı subplot çizicisine gönderilir.
%   4. Mevcut karşılaştırma PNG'si yeni grafikle güncellenir.
%
% Çalıştırma biçimi run_comparisons.m ile aynıdır. Örnek:
%   project_dir = "/path/to/phasedetector with cross correlation optimized";
%   run(fullfile(project_dir, "replot_results.m"));
%
% Grafikler Octave GUI'de gösterilebilir ve PNG olarak kaydedilir.
%
% AYARLAR:
%   RESULTS_SUBFOLDER = "" ise results/ altındaki TÜM koşu klasörleri çizilir.
%   Yalnızca bir koşuyu çizmek için klasör adını tam olarak yazın, örnek:
%       RESULTS_SUBFOLDER = "20260807_123456_lpf_cutoff";
% =====================================================================

RESULTS_SUBFOLDER = "20260819_162451251_iterations"; % Yerel klasör adıyla değiştirin.
SHOW_FIGURES = true;   % karşılaştırma grafiğini ekranda göster

% Proje ve results yollarını script'in bulunduğu konumdan türet.
project_dir = fileparts(mfilename("fullpath"));
addpath(project_dir);

% Boş bırakılırsa tüm koşu klasörlerini, doluysa yalnızca belirtileni çiz.
results_root = fullfile(project_dir, "results");
if isempty(RESULTS_SUBFOLDER)
    % results/ altındaki gerçek klasörleri topla; "." ve ".." girdilerini atla.
    subfolders = {};
    root_entries = dir(results_root);
    for entry_index = 1:numel(root_entries)
        if root_entries(entry_index).isdir && ...
                ~strcmp(root_entries(entry_index).name, ".") && ...
                ~strcmp(root_entries(entry_index).name, "..")
            subfolders{end+1} = root_entries(entry_index).name;
        end
    end
    if isempty(subfolders)
        error("results klasorunde kosu bulunamadi: %s", results_root);
    end
    % Her sonuç klasörü kendi summary.mat ve raw dosyalarıyla bağımsız çizilir.
    for subfolder_index = 1:numel(subfolders)
        fprintf("\n=== COZULUYOR: %s ===\n", subfolders{subfolder_index});
        replot_results_main(subfolders{subfolder_index}, SHOW_FIGURES, project_dir);
    end
else
    % Tam klasör adı verildiyse yalnızca o sonuç setini yeniden çiz.
    replot_results_main(RESULTS_SUBFOLDER, SHOW_FIGURES, project_dir);
end

fprintf("\nHazir. Grafikler: %s\n", results_root);
