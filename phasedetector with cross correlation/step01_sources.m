function results = step01_sources(config)
%STEP01_SOURCES Run the cross-PSD phase-noise simulation.

if exist("OCTAVE_VERSION", "builtin")
    pkg load signal;
end

required_fields = { ...
    "N", "fs", "A", "f0", "settling_samples", ...
    "lpf_cutoff", "lpf_order", "phase_rms_dut", ...
    "phase_rms_ref1", "phase_rms_ref2", ...
    "number_of_iterations", "number_of_log_bins"};

for field_index = 1:numel(required_fields)
    field_name = required_fields{field_index};
    if ~isfield(config, field_name)
        error("Eksik parametre: config.%s", field_name);
    end
end

N = config.N;
fs = config.fs;
A = config.A;
f0 = config.f0;
settling_samples = config.settling_samples;
lpf_cutoff = config.lpf_cutoff;
lpf_order = config.lpf_order;
phase_rms_dut = config.phase_rms_dut;
phase_rms_ref1 = config.phase_rms_ref1;
phase_rms_ref2 = config.phase_rms_ref2;
number_of_iterations = config.number_of_iterations;
number_of_log_bins = config.number_of_log_bins;
show_plot = ~isfield(config, "show_plot") || config.show_plot;

if N <= settling_samples
    error("N, settling_samples degerinden buyuk olmalidir.");
end

t = (0:N-1)' / fs;
phase_noise_dut = generate_phase_noise(N, phase_rms_dut);
x_dut = A*cos(2*pi*f0*t + phase_noise_dut);

S_cross_average = [];
for iteration = 1:number_of_iterations
    iteration_timer = tic;

    [S_cross_current, f_cross] = measure_iteration( ...
        x_dut, fs, A, f0, ...
        phase_rms_ref1, phase_rms_ref2, ...
        lpf_cutoff, lpf_order, settling_samples);

    if iteration == 1
        S_cross_average = complex(zeros(size(S_cross_current)));
    end

    S_cross_average = S_cross_average ...
        + (S_cross_current - S_cross_average) / iteration;

    iteration_seconds = toc(iteration_timer);
    fprintf("\rIterasyon %d/%d | Iterasyon suresi: %.3f s", ...
        iteration, number_of_iterations, iteration_seconds);
end
fprintf("\n");

valid_cross = valid_freq_mask(f_cross, lpf_cutoff);
S_cross_final = S_cross_average;

% Correct the PSD level for the phase detector's sin(phi) nonlinearity.
frequency_step = f_cross(2) - f_cross(1);
total_power_sin = sum(abs(S_cross_final(valid_cross))) * frequency_step;
sigma2_est = -0.5 * log(max(1 - 2*total_power_sin, 1e-10));

if total_power_sin > 0 && sigma2_est > 0
    correction_factor = sigma2_est / total_power_sin;
else
    correction_factor = 1;
end

S_cross_corrected = S_cross_final * correction_factor;
[f_cross_binned, L_cross_binned] = bin_and_convert( ...
    f_cross(valid_cross), ...
    abs(S_cross_corrected(valid_cross)), ...
    number_of_log_bins);

% Apply the measurement LPF to the original DUT noise for a fair comparison.
phase_noise_dut_filtered = lowpass_filter( ...
    phase_noise_dut, fs, lpf_cutoff, lpf_order);
phase_noise_dut_compare = phase_noise_dut_filtered(settling_samples + 1:end);
phase_noise_dut_compare = remove_dc(phase_noise_dut_compare);

% Original DUT PSD calculated with a single FFT periodogram.
[f_dut_fft, S_dut_fft] = compute_periodogram(phase_noise_dut_compare, fs);
valid_dut_fft = valid_freq_mask(f_dut_fft, lpf_cutoff);
[f_dut_fft_binned, L_dut_fft_binned] = bin_and_convert( ...
    f_dut_fft(valid_dut_fft), ...
    S_dut_fft(valid_dut_fft), ...
    number_of_log_bins);

% Keep the Welch result available for later use without plotting it now.
nfft_welch = length(phase_noise_dut_compare);
[P_dut_welch, f_dut_welch] = pwelch( ...
    phase_noise_dut_compare, ...
    ones(nfft_welch, 1), ...
    0, ...
    nfft_welch, ...
    fs);
valid_dut_welch = valid_freq_mask(f_dut_welch, lpf_cutoff);
[f_dut_welch_binned, L_dut_welch_binned] = bin_and_convert( ...
    f_dut_welch(valid_dut_welch), ...
    P_dut_welch(valid_dut_welch), ...
    number_of_log_bins);

f_min_common = max(min(f_cross_binned), min(f_dut_fft_binned));
f_max_common = min(max(f_cross_binned), max(f_dut_fft_binned));

if f_min_common >= f_max_common
    error("Cross-PSD ve DUT FFT icin ortak frekans araligi bulunamadi.");
end

f_common = logspace(log10(f_min_common), log10(f_max_common), 200);
L_cross_interp = interp1( ...
    f_cross_binned, L_cross_binned, f_common, "linear");
L_dut_fft_interp = interp1( ...
    f_dut_fft_binned, L_dut_fft_binned, f_common, "linear");
mean_absolute_error_fft_db = mean( ...
    abs(L_cross_interp - L_dut_fft_interp));

fprintf("Ortalama mutlak fark (Cross-PSD - DUT FFT): %.3f dB\n", ...
    mean_absolute_error_fft_db);

if show_plot
    figure;
    semilogx( ...
        f_cross_binned, ...
        L_cross_binned, ...
        "b", ...
        "LineWidth", 2, ...
        "DisplayName", sprintf( ...
            "Cross-PSD (log-binned, %d iter)", number_of_iterations));
    hold on;
    semilogx( ...
        f_dut_fft_binned, ...
        L_dut_fft_binned, ...
        "r--", ...
        "LineWidth", 2, ...
        "DisplayName", "Original DUT Noise - FFT (log-binned)");
    grid on;
    xlabel("Offset Frequency (Hz)");
    ylabel("Phase Noise (dBc/Hz)");
    title("Cross-PSD and Original DUT Noise");
    legend("location", "northeast");
    hold off;
end

results.config = config;
results.correction_factor = correction_factor;
results.mean_absolute_error_fft_db = mean_absolute_error_fft_db;
results.cross.frequency = f_cross;
results.cross.psd = S_cross_corrected;
results.cross.frequency_binned = f_cross_binned;
results.cross.phase_noise_binned = L_cross_binned;
results.dut_fft.frequency = f_dut_fft;
results.dut_fft.psd = S_dut_fft;
results.dut_fft.frequency_binned = f_dut_fft_binned;
results.dut_fft.phase_noise_binned = L_dut_fft_binned;
results.dut_welch.frequency = f_dut_welch;
results.dut_welch.psd = P_dut_welch;
results.dut_welch.frequency_binned = f_dut_welch_binned;
results.dut_welch.phase_noise_binned = L_dut_welch_binned;

end
