% Self-contained runner for conventional single-channel PD versus Cross-PSD.
% Run this script directly from the Octave editor. The 2x2 figure is left
% open and is also saved next to this file as pd_vs_cross_comparison.png.

clear;
close all;
clc;

%% ---------------- PATHS ----------------
runner_dir = fileparts(mfilename("fullpath"));
addpath(runner_dir);

%% ---------------- RUN_COMPARISONS PROFILE ----------------
% N and iteration count follow the requested reduced run size. All other
% values come from run_comparisons.m, with a fixed 50 kHz cutoff.
config = struct();
config.N = 100000;
config.fs = 1e6;
config.A = 1;
config.f0 = 200e3;
config.settling_samples = 0;
config.lpf_cutoff = 50e3;
config.lpf_order = 4;
config.phase_rms_dut = 0.05;
config.phase_rms_ref1 = 0.01;
config.phase_rms_ref2 = 0.01;
config.number_of_iterations = 200;
config.number_of_log_bins = 100;

reference_rms_values = [0.01, 0.1];
comparison_results = cell(size(reference_rms_values));

%% ---------------- SIMULATIONS ----------------
% Conventional PD instruments commonly average repeated auto-PSDs. The same
% 200 records are therefore averaged for PD and Cross-PSD. Auto-PSD averaging
% reduces estimator variance, but cannot remove the reference-noise PSD.
for row_index = 1:numel(reference_rms_values)
    current_config = config;
    current_config.phase_rms_ref1 = reference_rms_values(row_index);
    current_config.phase_rms_ref2 = reference_rms_values(row_index);

    fprintf("\n=== DUT RMS %.2f rad | Reference RMS %.2f rad ===\n", ...
        current_config.phase_rms_dut, reference_rms_values(row_index));
    comparison_results{row_index} = simulate_pd_vs_cross(current_config);
end

%% ---------------- COMMON PLOT LIMITS ----------------
frequency_min = Inf;
level_min = Inf;
level_max = -Inf;

for row_index = 1:numel(comparison_results)
    current_results = comparison_results{row_index};
    method_names = {"pd", "cross"};
    for method_index = 1:numel(method_names)
        estimate = current_results.(method_names{method_index});
        estimate_in_band = estimate.frequency_binned > 0 & ...
            estimate.frequency_binned <= config.lpf_cutoff;
        dut_in_band = current_results.dut.frequency_binned > 0 & ...
            current_results.dut.frequency_binned <= config.lpf_cutoff;

        frequencies = [estimate.frequency_binned(estimate_in_band); ...
            current_results.dut.frequency_binned(dut_in_band)];
        levels = [estimate.phase_noise_binned(estimate_in_band); ...
            current_results.dut.phase_noise_binned(dut_in_band)];
        frequencies = frequencies(isfinite(frequencies) & frequencies > 0);
        levels = levels(isfinite(levels));

        frequency_min = min(frequency_min, min(frequencies));
        level_min = min(level_min, min(levels));
        level_max = max(level_max, max(levels));
    end
end

if ~isfinite(frequency_min) || ~isfinite(level_min) || ~isfinite(level_max)
    error("No finite in-band data were produced for the comparison plot.");
end
level_padding = max(2, 0.04*(level_max - level_min));

%% ---------------- 2x2 COMPARISON FIGURE ----------------
fig = figure("name", "Conventional PD versus Cross-PSD", ...
    "color", "w", "position", [50, 50, 1280, 820]);

for row_index = 1:numel(comparison_results)
    current_results = comparison_results{row_index};
    ref_rms = reference_rms_values(row_index);

    ax_pd = subplot(2, 2, 2*row_index - 1, "Parent", fig);
    semilogx(ax_pd, current_results.pd.frequency_binned, ...
        current_results.pd.phase_noise_binned, ...
        "b-", "LineWidth", 1.8, "DisplayName", ...
        sprintf("Single-channel PD (%d PSD averages)", ...
        config.number_of_iterations));
    hold(ax_pd, "on");
    semilogx(ax_pd, current_results.dut.frequency_binned, ...
        current_results.dut.phase_noise_binned, ...
        "r--", "LineWidth", 1.5, "DisplayName", ...
        "Averaged unfiltered DUT periodogram");
    grid(ax_pd, "on");
    xlim(ax_pd, [frequency_min, config.lpf_cutoff]);
    ylim(ax_pd, [level_min - level_padding, level_max + level_padding]);
    xlabel(ax_pd, "Offset Frequency (Hz)");
    ylabel(ax_pd, "Phase Noise (dBc/Hz)");
    title(ax_pd, {sprintf("Conventional PD | Ref RMS %.2f rad", ref_rms), ...
        sprintf("DUT RMS %.2f rad | In-band MAE %.2f dB", ...
        config.phase_rms_dut, current_results.mean_absolute_error_pd_db)}, ...
        "Interpreter", "none");
    legend(ax_pd, "location", "southwest", "FontSize", 8);
    hold(ax_pd, "off");

    ax_cross = subplot(2, 2, 2*row_index, "Parent", fig);
    semilogx(ax_cross, current_results.cross.frequency_binned, ...
        current_results.cross.phase_noise_binned, ...
        "b-", "LineWidth", 1.8, "DisplayName", ...
        sprintf("Cross-PSD (%d complex averages)", ...
        config.number_of_iterations));
    hold(ax_cross, "on");
    semilogx(ax_cross, current_results.dut.frequency_binned, ...
        current_results.dut.phase_noise_binned, ...
        "r--", "LineWidth", 1.5, "DisplayName", ...
        "Averaged unfiltered DUT periodogram");
    grid(ax_cross, "on");
    xlim(ax_cross, [frequency_min, config.lpf_cutoff]);
    ylim(ax_cross, [level_min - level_padding, level_max + level_padding]);
    xlabel(ax_cross, "Offset Frequency (Hz)");
    ylabel(ax_cross, "Phase Noise (dBc/Hz)");
    title(ax_cross, {sprintf("Cross-correlation | Ref RMS %.2f rad", ref_rms), ...
        sprintf("DUT RMS %.2f rad | In-band MAE %.2f dB", ...
        config.phase_rms_dut, current_results.mean_absolute_error_cross_db)}, ...
        "Interpreter", "none");
    legend(ax_cross, "location", "southwest", "FontSize", 8);
    hold(ax_cross, "off");
end

output_png = fullfile(runner_dir, "pd_vs_cross_comparison.png");
try
    set(fig, "paperpositionmode", "auto");
    print(fig, output_png, "-dpng", "-r180");
    fprintf("\nFigure saved: %s\n", output_png);
catch err
    warning("Figure could not be saved: %s", err.message);
end

fprintf("Results remain in workspace variable: comparison_results\n");
