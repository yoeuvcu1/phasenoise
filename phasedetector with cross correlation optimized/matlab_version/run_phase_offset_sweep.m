% Faz dedektorundeki merkez faz farkini tarar ve her noktada Cross-PSD ile
% elde edilen faz gurultusunu cizer. 90 derece, maksimum kucuk-isaret kazanci
% olan klasik quadrature calisma noktasidir.

%% ---------------- SWEEP PARAMETERS ----------------
config = struct();
config.N = 1000000;
config.fs = 1e6;
config.A = 1;
config.f0 = 200e3;
config.settling_samples = 100;
config.lpf_cutoff = 50e3;
config.lpf_order = 4;
config.phase_rms_dut = 0.05;
config.phase_rms_ref1 = 0.05;
config.phase_rms_ref2 = 0.05;
config.number_of_iterations = 1000; % run_single.m ile ayni ortalama sayisi.
config.number_of_log_bins = 100;

% Dedektor cevabi 90 derece etrafinda yaklasik simetrik oldugu icin yalnizca
% 0--90 derece araligini tara; 90 derece orijinal quadrature noktasi olarak kalir.
phase_offsets_deg = 0:15:90;

%% ---------------- PROJECT SETUP ----------------
project_dir = fileparts(mfilename("fullpath"));
addpath(project_dir);

number_of_offsets = numel(phase_offsets_deg);
sweep_results = cell(number_of_offsets, 1);
mae_db = nan(number_of_offsets, 1);

%% ---------------- CROSS-PSD SWEEP ----------------
for offset_index = 1:number_of_offsets
    config.phase_offset_deg = phase_offsets_deg(offset_index);
    fprintf("\n--- Faz farki: %.0f derece ---\n", config.phase_offset_deg);
    sweep_results{offset_index} = run_simulation(config);
    current = sweep_results{offset_index};
    mae_db(offset_index) = current.mean_absolute_error_fft_db;
end

%% ---------------- SINGLE-RUN STYLE COMPARISON PLOTS ----------------
% Her panel run_single.m ile ayni karsilastirmayi yapar: mavi Cross-PSD
% tahmini ve kirmizi kesikli filtrelenmemis DUT periodogrami. Butun paneller
% ortak eksen limitlerini kullandigi icin faz farklarinin etkisi dogrudan
% karsilastirilabilir. 90 derece paneli "(orig)" olarak isaretlenir.
output_dir = fullfile(project_dir, "phase_offset_sweep_output");
if ~exist(output_dir, "dir")
    mkdir(output_dir);
end
comparison_png = fullfile(output_dir, "phase_offset_cross_psd_vs_dut.png");
plot_sweep_results("Phase offset", phase_offsets_deg, sweep_results, ...
    "%.0f deg", 90, comparison_png, true);

%% ---------------- MAE VERSUS PHASE OFFSET ----------------
% Spektrum panellerindeki uyumu tek sayiyla da ozetle. En dusuk MAE, Cross-PSD
% tahmininin ortalama DUT spektrumuna en cok yaklastigi faz farkini gosterir.
mae_figure = figure("Name", "Cross-PSD convergence versus phase offset");
plot(phase_offsets_deg, mae_db, "o-", "LineWidth", 1.6, ...
    "MarkerFaceColor", [0.1 0.45 0.8]);
hold on;
xline(90, "k--", "90 deg (orig)", "LabelVerticalAlignment", "bottom");
grid on;
xlim([min(phase_offsets_deg), max(phase_offsets_deg)]);
xlabel("DUT-reference phase difference (deg)");
ylabel("Cross-PSD - averaged DUT MAE (dB)");
title("Cross-PSD'nin orijinal DUT faz gurultusuna yakinligi");
hold off;
mae_png = fullfile(output_dir, "phase_offset_mae.png");
exportgraphics(mae_figure, mae_png, "Resolution", 150);

%% ---------------- RESULTS TABLE ----------------
sweep_table = table(phase_offsets_deg(:), mae_db(:), ...
    VariableNames=["phase_offset_deg", "mae_db"]);
disp(sweep_table);
fprintf("\nKarsilastirma grafigi: %s\n", comparison_png);
fprintf("MAE grafigi: %s\n", mae_png);

% Kucuk-isaret faz detektoru kazanci sin(delta) ile orantilidir. Bu nedenle
% 90 derecede maksimumdur; 0 derecede birinci-derece faz hassasiyeti sifira
% iner. Bu script mevcut 90 derece kalibrasyonunu korur; dolayisiyla
% quadrature disindaki egriler hem kazanc kaybini hem de asin kaynakli
% dogrusal-olmayanligi gorunur kilar.
