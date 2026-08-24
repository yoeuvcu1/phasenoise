% Compare no-asin, asin-before-LPF and asin-after-LPF detector branches.
% Open this file in Octave Editor and press Run. All six records are generated
% from a fixed seed, so rerunning the script reproduces the same figure.

%% ---------------- PATH AND SETTINGS ----------------
comparison_dir = fileparts(mfilename("fullpath"));
addpath(comparison_dir, "-begin");
rehash;

settings = asin_comparison_config();
config = settings.base_config;
validate_config(config);

if settings.realization_count ~= 3
    error("Bu grafik duzeni icin realization_count tam olarak 3 olmalidir.");
end
if numel(settings.dut_rms_by_row) ~= 2 || ...
        numel(settings.ref_rms_by_row) ~= 2
    error("DUT ve Ref RMS listeleri tam olarak iki satir degeri icermelidir.");
end

% Unlike the active time-seeded generator, this comparison is reproducible.
rng(settings.random_seed, "twister");
asin_comparison_results = cell(2, settings.realization_count);

%% ---------------- SIX SHARED-INPUT RECORDS ----------------
for row_index = 1:2
    for realization_index = 1:settings.realization_count
        case_config = config;
        case_config.phase_rms_dut = settings.dut_rms_by_row(row_index);
        case_config.phase_rms_ref1 = settings.ref_rms_by_row(row_index);
        case_config.phase_rms_ref2 = settings.ref_rms_by_row(row_index);

        fprintf("RMS grubu %d/2 | Realizasyon %d/%d | DUT %.3f rad, Ref %.3f rad\n", ...
            row_index, realization_index, settings.realization_count, ...
            case_config.phase_rms_dut, case_config.phase_rms_ref1);

        asin_comparison_results{row_index, realization_index} = ...
            run_asin_realization_case(case_config);
    end
end

%% ---------------- SHARED AXIS LIMITS ----------------
all_levels = [];
for row_index = 1:2
    for realization_index = 1:settings.realization_count
        current_result = asin_comparison_results{row_index, realization_index};
        all_levels = [all_levels; ...
            current_result.no_asin.phase_noise(:); ...
            current_result.asin_before_lpf.phase_noise(:); ...
            current_result.asin_after_lpf.phase_noise(:); ...
            current_result.dut.phase_noise(:)];
    end
end
all_levels = all_levels(isfinite(all_levels));
y_limits = [floor(min(all_levels)/10)*10 - 5, ...
    ceil(max(all_levels)/10)*10 + 5];
first_result = asin_comparison_results{1, 1};
x_limits = [min(first_result.dut.frequency), max(first_result.dut.frequency)];

%% ---------------- TWO-BY-THREE FIGURE ----------------
asin_comparison_figure = figure( ...
    "name", "Asin placement comparison", ...
    "position", [40, 40, 1500, 820]);

for row_index = 1:2
    for realization_index = 1:settings.realization_count
        plot_index = (row_index - 1)*settings.realization_count ...
            + realization_index;
        current_result = asin_comparison_results{row_index, realization_index};

        subplot(2, 3, plot_index);
        semilogx(current_result.no_asin.frequency, ...
            current_result.no_asin.phase_noise, ...
            "b-", "LineWidth", 1.35, "DisplayName", "Asin yok");
        hold on;
        semilogx(current_result.asin_before_lpf.frequency, ...
            current_result.asin_before_lpf.phase_noise, ...
            "Color", [0.90, 0.45, 0.10], "LineWidth", 1.25, ...
            "DisplayName", "LPF oncesi asin");
        semilogx(current_result.asin_after_lpf.frequency, ...
            current_result.asin_after_lpf.phase_noise, ...
            "Color", [0.10, 0.55, 0.25], "LineWidth", 1.25, ...
            "DisplayName", "LPF sonrasi asin");
        semilogx(current_result.dut.frequency, ...
            current_result.dut.phase_noise, ...
            "k--", "LineWidth", 1.35, "DisplayName", "Gercek DUT");

        grid on;
        xlim(x_limits);
        ylim(y_limits);
        xlabel("Offset Frequency (Hz)");
        ylabel("Phase Noise (dBc/Hz)");
        title({sprintf("DUT %.2f | Ref %.2f rad | Realizasyon %d", ...
            settings.dut_rms_by_row(row_index), ...
            settings.ref_rms_by_row(row_index), realization_index), ...
            sprintf("MAE: yok %.2f | once %.2f | sonra %.2f dB", ...
            current_result.no_asin.mae_db, ...
            current_result.asin_before_lpf.mae_db, ...
            current_result.asin_after_lpf.mae_db)});
        legend("location", "southwest");
        hold off;
    end
end

fprintf("\nAsin karsilastirmasi tamamlandi. RNG seed: %d\n", ...
    settings.random_seed);
