function plot_single_run(results, out_png, show_figure)
% Tek bir simülasyon koşusunun Cross-PSD ve DUT FFT eğrilerini çizer ve
% PNG olarak kaydeder. Legend'de koşunun tüm ana parametreleri yazılır.

cfg = results.config;

try
    fig = figure("visible", "off");
catch
    fig = figure;
end
ax = axes(fig);

semilogx(ax, results.cross.frequency_binned, ...
    results.cross.phase_noise_binned, ...
    "b", "LineWidth", 2, ...
    "DisplayName", sprintf( ...
        "Cross-PSD (DUT=%.2f rad, Ref=%.2f rad, %d iter, %d bin)", ...
        cfg.phase_rms_dut, cfg.phase_rms_ref1, ...
        cfg.number_of_iterations, cfg.number_of_log_bins));
hold(ax, "on");
semilogx(ax, results.dut_fft.frequency_binned, ...
    results.dut_fft.phase_noise_binned, ...
    "r--", "LineWidth", 2, ...
    "DisplayName", "Original DUT Noise (FFT)");
grid(ax, "on");
xlabel(ax, "Offset Frequency (Hz)");
ylabel(ax, "Phase Noise (dBc/Hz)");
title(ax, sprintf("Cross-PSD vs Original DUT (N=%d, f_c=%.0f Hz)", ...
    cfg.N, cfg.lpf_cutoff));
legend(ax, "location", "northeast", "FontSize", 9);

save_figure_to_png(fig, out_png, show_figure);

end
