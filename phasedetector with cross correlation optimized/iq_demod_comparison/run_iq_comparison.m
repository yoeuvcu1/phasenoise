% Run the current phase detector and I/Q demodulator on identical signals.
% No project source file is modified. The comparison folder is self-contained.

%% ---------------- PATHS ----------------
comparison_dir = fileparts(mfilename("fullpath"));
addpath(comparison_dir, "-begin");
rehash;

%% ---------------- COMPARISON PARAMETERS ----------------
% Edit comparison_config.m to change the simulation settings.
config = comparison_config();

%% ---------------- SIMULATION ----------------
comparison_results = run_detector_comparison(config);

current = comparison_results.current.cross;
iq = comparison_results.iq.cross;
dut = comparison_results.dut_fft;

%% ---------------- COMMON PLOT LIMITS ----------------
all_levels = [current.phase_noise_binned(:); ...
    iq.phase_noise_binned(:); dut.phase_noise_binned(:)];
all_levels = all_levels(isfinite(all_levels));
y_limits = [floor(min(all_levels)/10)*10 - 5, ...
    ceil(max(all_levels)/10)*10 + 5];
x_limits = [max([min(current.frequency_binned), ...
    min(iq.frequency_binned), min(dut.frequency_binned)]), ...
    min([max(current.frequency_binned), ...
    max(iq.frequency_binned), max(dut.frequency_binned)])];

%% ---------------- SIDE-BY-SIDE FIGURE ----------------
comparison_figure = figure("name", "Current detector versus I/Q demodulation");

subplot(2, 2, 1);
semilogx(current.frequency_binned, current.phase_noise_binned, ...
    "b-", "LineWidth", 1.8, "DisplayName", "Current detector");
hold on;
semilogx(dut.frequency_binned, dut.phase_noise_binned, ...
    "r--", "LineWidth", 1.4, "DisplayName", "Unfiltered DUT");
grid on;
xlim(x_limits);
ylim(y_limits);
xlabel("Offset Frequency (Hz)");
ylabel("Phase Noise (dBc/Hz)");
title(sprintf("Current: sin(delta), MAE %.3f dB", ...
    comparison_results.current.mean_absolute_error_fft_db));
legend("location", "southwest");
hold off;

subplot(2, 2, 2);
semilogx(iq.frequency_binned, iq.phase_noise_binned, ...
    "Color", [0.10, 0.55, 0.25], "LineWidth", 1.8, ...
    "DisplayName", "I/Q atan2 detector");
hold on;
semilogx(dut.frequency_binned, dut.phase_noise_binned, ...
    "r--", "LineWidth", 1.4, "DisplayName", "Unfiltered DUT");
grid on;
xlim(x_limits);
ylim(y_limits);
xlabel("Offset Frequency (Hz)");
ylabel("Phase Noise (dBc/Hz)");
title(sprintf("I/Q: atan2(Q,I), MAE %.3f dB", ...
    comparison_results.iq.mean_absolute_error_fft_db));
legend("location", "southwest");
hold off;

subplot(2, 2, 3);
semilogx(current.frequency_raw_binned, ...
    current.phase_noise_raw_binned, "Color", [0.45, 0.65, 1.0], ...
    "LineStyle", ":", "LineWidth", 1.2, ...
    "DisplayName", "Current raw");
hold on;
semilogx(current.frequency_binned, current.phase_noise_binned, ...
    "b-", "LineWidth", 1.6, "DisplayName", "Current corrected");
semilogx(iq.frequency_binned, iq.phase_noise_binned, ...
    "Color", [0.10, 0.55, 0.25], "LineWidth", 1.6, ...
    "DisplayName", "I/Q atan2");
semilogx(dut.frequency_binned, dut.phase_noise_binned, ...
    "r--", "LineWidth", 1.3, "DisplayName", "Unfiltered DUT");
grid on;
xlim(x_limits);
ylim(y_limits);
xlabel("Offset Frequency (Hz)");
ylabel("Phase Noise (dBc/Hz)");
title(sprintf("Overlay, current correction %.4f", ...
    comparison_results.current.correction_factor));
legend("location", "southwest");
hold off;

subplot(2, 2, 4);
L_dut_at_current = interp1(log10(dut.frequency_binned), ...
    dut.phase_noise_binned, log10(current.frequency_binned), "linear");
L_dut_at_iq = interp1(log10(dut.frequency_binned), ...
    dut.phase_noise_binned, log10(iq.frequency_binned), "linear");
semilogx(current.frequency_binned, ...
    current.phase_noise_binned - L_dut_at_current, ...
    "b-", "LineWidth", 1.5, "DisplayName", "Current - DUT");
hold on;
semilogx(iq.frequency_binned, iq.phase_noise_binned - L_dut_at_iq, ...
    "Color", [0.10, 0.55, 0.25], "LineWidth", 1.5, ...
    "DisplayName", "I/Q - DUT");
plot(x_limits, [0, 0], "k--", "LineWidth", 1.0, ...
    "DisplayName", "Zero error");
grid on;
xlim(x_limits);
xlabel("Offset Frequency (Hz)");
ylabel("Signed Error (dB)");
title("Binned spectrum error");
legend("location", "southwest");
hold off;

fprintf("\nKarsilastirma tamamlandi. Sonuclar comparison_results icinde.\n");
