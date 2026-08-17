% run_comparisons.m
% =====================================================================
% Simülasyon karşılaştırma koşu betiği (giriş noktası).
%
% Proje klasörü bir ağ paylaşımında (\\kutu\...) olduğu için Octave
% buradan .m dosyalarını güvenilir şekilde yükleyemez. Bu nedenle
% betik önce tüm .m dosyalarını yerel bir yansıma klasörüne kopyalar,
% simülasyonu oradan koşar ve sonuçları (ham veri + grafik) doğrudan
% projedeki results/ klasörüne yazar.
%
% NASIL ÇALIŞTIRILIR (cwd nerede olursa olsun):
%   Octave komut satırından:
%       run("O:\phasedetector with cross correlation optimized\run_comparisons.m")
%   Veya CLI'den:
%       octave-cli "O:\...\run_comparisons.m"
%
% NOT: PNG grafik üretimi qt altyapısıyla (Octave GUI) çalışır. CLI'den
% koşturulursa ham veriler (.mat/.csv) yine kaydedilir, PNG'ler sonradan
% Octave GUI'den replot_results ile çizilebilir.
%
% AYARLAR:
%   Tüm simülasyon parametreleri ve tarama değerleri
%   run_comparisons_main.m dosyasındaki "DEFAULT PARAMETRELER" ve
%   "KOŞULACAK TARAMALAR" bölümlerinden düzenlenir.
% =====================================================================

SHOW_FIGURES = true;   % karşılaştırma grafiklerini ekranda göster

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

run_comparisons_main(SHOW_FIGURES, project_dir);

fprintf("\nHazir. Sonuclar: %s\n", fullfile(project_dir, "results"));
