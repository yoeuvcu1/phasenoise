% replot_results.m
% =====================================================================
% Kaydedilmiş ham verilerden (.mat) grafikleri yeniden çizer.
% Simülasyonu yeniden koşturmaz; ham veriler results/ klasöründen okunur.
%
% Çalıştırma biçimi ve ağ sürücüsü notu run_comparisons.m ile aynıdır:
%   run("O:\phasedetector with cross correlation optimized\replot_results.m")
%   veya CLI'den: octave-cli "O:\...\replot_results.m"
%
% Not: PNG üretimi qt altyapısı (Octave GUI) gerektirir; CLI'den
% koşturulursa grafikler atlanır ve uyarı verilir.
%
% AYARLAR:
%   RESULTS_SUBFOLDER boş ise results/ altındaki TÜM koşu klasörleri
%   çizilir (her test için ayrı plot). Belirli bir koşuyu çizmek için
%   zaman damgalı klasör adını yazın, örnek:
%       RESULTS_SUBFOLDER = "20260807_123456_lpf_cutoff";
% =====================================================================

RESULTS_SUBFOLDER = "";
SHOW_FIGURES = true;   % karşılaştırma grafiğini ekranda göster

project_dir = fileparts(mfilename("fullpath"));
mirror_dir = fullfile(tempdir(), "octave_pd_mirror");

% .m dosyalarını yerel yansımaya kopyala (ağ yolundan yüklenemezler).
% Eski dosyaları unlink ile sessizce temizle (GUI onay penceresi açmaz).
if ~exist(mirror_dir, "dir")
    mkdir(mirror_dir);
end
mirror_entries = dir(mirror_dir);
for mirror_index = 1:numel(mirror_entries)
    if ~mirror_entries(mirror_index).isdir
        unlink(fullfile(mirror_dir, mirror_entries(mirror_index).name));
    end
end
project_entries = dir(project_dir);
for entry_index = 1:numel(project_entries)
    entry = project_entries(entry_index);
    if entry.isdir || length(entry.name) < 3
        continue;
    end
    if ~strcmp(entry.name(end-1:end), ".m")
        continue;
    end
    launcher_source_id = fopen(fullfile(project_dir, entry.name), "rb");
    launcher_target_id = fopen(fullfile(mirror_dir, entry.name), "wb");
    if launcher_source_id < 0 || launcher_target_id < 0
        error("Yansima kopyalanamadi: %s", entry.name);
    end
    while ~feof(launcher_source_id)
        launcher_chunk = fread(launcher_source_id, 65536, "uint8");
        if isempty(launcher_chunk)
            break;
        end
        fwrite(launcher_target_id, launcher_chunk, "uint8");
    end
    fclose(launcher_source_id);
    fclose(launcher_target_id);
end
cd(mirror_dir);
addpath(mirror_dir);

% Boş bırakılırsa tüm koşu klasörlerini, doluysa yalnızca belirtileni çiz.
results_root = fullfile(project_dir, "results");
if isempty(RESULTS_SUBFOLDER)
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
    for subfolder_index = 1:numel(subfolders)
        fprintf("\n=== COZULUYOR: %s ===\n", subfolders{subfolder_index});
        replot_results_main(subfolders{subfolder_index}, SHOW_FIGURES, project_dir);
    end
else
    replot_results_main(RESULTS_SUBFOLDER, SHOW_FIGURES, project_dir);
end

fprintf("\nHazir. Grafikler: %s\n", results_root);
