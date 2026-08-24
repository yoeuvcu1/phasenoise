function results = run_detector_comparison(config)
%RUN_DETECTOR_COMPARISON Compare the current and I/Q phase detectors.
%   Both detector branches receive the same DUT and reference realizations.
%   The simulation flow outside the detector is kept equal to the active
%   project flow.

%% ---------------- OCTAVE SIGNAL PACKAGE ----------------
persistent signal_package_loaded;
if exist("OCTAVE_VERSION", "builtin") && isempty(signal_package_loaded)
    pkg load signal;
    signal_package_loaded = true;
end

validate_config(config);

%% ---------------- SIMULATION PARAMETERS ----------------
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

t = (0:N-1)' / fs;
carrier_phase = 2*pi*f0*t;
K_pd = A^2 / 2;

channel_length = N - settling_samples;
nfft_cross = 2^nextpow2(2*channel_length - 1);
number_of_positive_points = floor(nfft_cross/2) + 1;
f_cross = (0:number_of_positive_points-1)' * fs / nfft_cross;

S_current_sum = complex(zeros(number_of_positive_points, 1));
S_iq_sum = complex(zeros(number_of_positive_points, 1));
S_dut_sum = zeros(number_of_positive_points, 1);

%% ---------------- MONTE CARLO ITERATIONS ----------------
for iteration = 1:number_of_iterations
    iteration_timer = tic;

    % Generate each realization once so both detectors see identical inputs.
    phase_noise_dut = generate_phase_noise(N, phase_rms_dut);
    phase_noise_ref1 = generate_phase_noise(N, phase_rms_ref1);
    phase_noise_ref2 = generate_phase_noise(N, phase_rms_ref2);
    x_dut = A*cos(carrier_phase + phase_noise_dut);

    [current_channels, iq_channels] = compare_detector_outputs( ...
        x_dut, A, carrier_phase, phase_noise_ref1, phase_noise_ref2, ...
        fs, lpf_cutoff, lpf_order, K_pd, settling_samples);

    S_current_sum = S_current_sum ...
        + compute_cross_psd(current_channels, fs, nfft_cross);
    S_iq_sum = S_iq_sum ...
        + compute_cross_psd(iq_channels, fs, nfft_cross);

    phase_noise_dut_compare = phase_noise_dut(settling_samples + 1:end);
    phase_noise_dut_compare = remove_dc(phase_noise_dut_compare);
    [~, S_dut_current] = compute_periodogram( ...
        phase_noise_dut_compare, fs, nfft_cross);
    S_dut_sum = S_dut_sum + S_dut_current;

    iteration_seconds = toc(iteration_timer);
    fprintf("\rKarsilastirma iterasyonu %d/%d | Iterasyon suresi: %.3f s", ...
        iteration, number_of_iterations, iteration_seconds);
end
fprintf("\n");

%% ---------------- AVERAGE AND CURRENT-METHOD CORRECTION ----------------
S_current_average = S_current_sum / number_of_iterations;
S_iq_average = S_iq_sum / number_of_iterations;
S_dut_average = S_dut_sum / number_of_iterations;
valid = f_cross > 0;

% This is the same scalar sin(phi) power correction used by run_simulation.
frequency_step = f_cross(2) - f_cross(1);
total_power_sin = sum(abs(S_current_average(valid))) * frequency_step;
sigma2_est = -0.5 * log(max(1 - 2*total_power_sin, 1e-10));
if total_power_sin > 0 && sigma2_est > 0
    correction_factor = sigma2_est / total_power_sin;
else
    correction_factor = 1;
end
S_current_corrected = S_current_average * correction_factor;

%% ---------------- LOG BINNING AND SSB CONVERSION ----------------
[f_current_binned, L_current_binned] = logbin_phase_noise( ...
    f_cross(valid), abs(S_current_corrected(valid)), number_of_log_bins);
[f_current_raw_binned, L_current_raw_binned] = logbin_phase_noise( ...
    f_cross(valid), abs(S_current_average(valid)), number_of_log_bins);
[f_iq_binned, L_iq_binned] = logbin_phase_noise( ...
    f_cross(valid), abs(S_iq_average(valid)), number_of_log_bins);
[f_dut_binned, L_dut_binned] = logbin_phase_noise( ...
    f_cross(valid), S_dut_average(valid), number_of_log_bins);

mae_current_db = calculate_mae_db( ...
    f_current_binned, L_current_binned, f_dut_binned, L_dut_binned);
mae_iq_db = calculate_mae_db( ...
    f_iq_binned, L_iq_binned, f_dut_binned, L_dut_binned);

fprintf("Mevcut detector MAE : %.3f dB (correction %.6f)\n", ...
    mae_current_db, correction_factor);
fprintf("I/Q detector MAE    : %.3f dB\n", mae_iq_db);

%% ---------------- RESULTS ----------------
results.config = config;

results.current.correction_factor = correction_factor;
results.current.mean_absolute_error_fft_db = mae_current_db;
results.current.cross.frequency = f_cross;
results.current.cross.psd_raw = S_current_average;
results.current.cross.psd = S_current_corrected;
results.current.cross.frequency_binned = f_current_binned;
results.current.cross.phase_noise_binned = L_current_binned;
results.current.cross.frequency_raw_binned = f_current_raw_binned;
results.current.cross.phase_noise_raw_binned = L_current_raw_binned;

results.iq.correction_factor = 1;
results.iq.mean_absolute_error_fft_db = mae_iq_db;
results.iq.cross.frequency = f_cross;
results.iq.cross.psd = S_iq_average;
results.iq.cross.frequency_binned = f_iq_binned;
results.iq.cross.phase_noise_binned = L_iq_binned;

results.dut_fft.frequency = f_cross;
results.dut_fft.psd = S_dut_average;
results.dut_fft.frequency_binned = f_dut_binned;
results.dut_fft.phase_noise_binned = L_dut_binned;
results.dut_fft.number_of_averages = number_of_iterations;

end

function [current_channels, iq_channels] = compare_detector_outputs( ...
        x_dut, A, carrier_phase, phase_noise_ref1, phase_noise_ref2, ...
        fs, lpf_cutoff, lpf_order, K_pd, settling_samples)
% Keep all processing shared and change only phase extraction at the detector.

reference_phase_noise = [phase_noise_ref1, phase_noise_ref2];

% The current branch uses only the quadrature reference and obtains sin(delta).
reference_q = A*cos(bsxfun(@plus, ...
    carrier_phase + pi/2, reference_phase_noise));

% The I/Q branch adds the matching in-phase reference and obtains cos(delta).
reference_i = A*cos(bsxfun(@plus, ...
    carrier_phase, reference_phase_noise));

mixed_q = mixer(x_dut, reference_q);
mixed_i = mixer(x_dut, reference_i);

% Filter all products in one call so both methods use identical LPF settings.
filtered_products = lowpass_filter( ...
    [mixed_q, mixed_i], fs, lpf_cutoff, lpf_order) / K_pd;
q_outputs = filtered_products(:, 1:2);
i_outputs = filtered_products(:, 3:4);

current_phase = q_outputs;
iq_phase = atan2(q_outputs, i_outputs);
for channel_index = 1:2
    iq_phase(:, channel_index) = unwrap(iq_phase(:, channel_index));
end

current_channels = current_phase(settling_samples + 1:end, :);
iq_channels = iq_phase(settling_samples + 1:end, :);
current_channels = remove_dc(current_channels);
iq_channels = remove_dc(iq_channels);

end

function mae_db = calculate_mae_db(f_estimate, L_estimate, f_dut, L_dut)
% Use the same 200-point common log-frequency MAE as the active simulation.

f_min_common = max(min(f_estimate), min(f_dut));
f_max_common = min(max(f_estimate), max(f_dut));
if f_min_common >= f_max_common
    error("Karsilastirma icin ortak frekans araligi bulunamadi.");
end

f_common = logspace(log10(f_min_common), log10(f_max_common), 200);
f_common = min(max(f_common, f_min_common), f_max_common);
L_estimate_interp = interp1( ...
    log10(f_estimate), L_estimate, log10(f_common), "linear");
L_dut_interp = interp1(log10(f_dut), L_dut, log10(f_common), "linear");
valid_common = ~isnan(L_estimate_interp) & ~isnan(L_dut_interp);
if ~any(valid_common)
    error("MAE hesabi icin ortak frekans noktasi bulunamadi.");
end

mae_db = mean(abs( ...
    L_estimate_interp(valid_common) - L_dut_interp(valid_common)));

end
