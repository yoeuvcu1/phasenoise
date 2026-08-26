function results = simulate_pd_vs_cross(config)
%SIMULATE_PD_VS_CROSS Average conventional PD and Cross-PSD on shared data.
% Each iteration uses one common DUT, one Ref1 for the conventional PD, and
% Ref1/Ref2 for Cross-PSD. This keeps the method comparison statistically fair.

if exist("OCTAVE_VERSION", "builtin")
    pkg load signal;
end
validate_comparison_config(config);

N = config.N;
fs = config.fs;
A = config.A;
settling_samples = config.settling_samples;
number_of_iterations = config.number_of_iterations;

t = (0:N-1)' / fs;
carrier_phase = 2*pi*config.f0*t;
quadrature_phase = carrier_phase + pi/2;
K_pd = A^2 / 2;

channel_length = N - settling_samples;
nfft = 2^nextpow2(2*channel_length - 1);
number_of_positive_points = floor(nfft/2) + 1;
frequency = (0:number_of_positive_points-1)' * fs/nfft;

S_pd_sum = zeros(number_of_positive_points, 1);
S_cross_sum = complex(zeros(number_of_positive_points, 1));
S_dut_sum = zeros(number_of_positive_points, 1);

for iteration = 1:number_of_iterations
    phase_noise_dut = generate_phase_noise_local(N, config.phase_rms_dut);
    phase_noise_ref1 = generate_phase_noise_local(N, config.phase_rms_ref1);
    phase_noise_ref2 = generate_phase_noise_local(N, config.phase_rms_ref2);

    x_dut = A*cos(carrier_phase + phase_noise_dut);
    reference_signals = [ ...
        A*cos(quadrature_phase + phase_noise_ref1), ...
        A*cos(quadrature_phase + phase_noise_ref2)];

    mixed_signals = bsxfun(@times, x_dut, reference_signals);
    phase_sine = lowpass_filter_local(mixed_signals, fs, ...
        config.lpf_cutoff, config.lpf_order) / K_pd;
    phase_sine = min(max(phase_sine, -1), 1);
    phase_error = asin(phase_sine);
    channels = phase_error(settling_samples + 1:end, :);
    channels = remove_dc_local(channels);

    % The conventional PD uses channel 1 auto-PSD. Cross-PSD uses both
    % channels and remains complex until all iterations have been averaged.
    [~, S_pd_current] = compute_periodogram_local( ...
        channels(:, 1), fs, nfft);
    S_cross_current = compute_cross_psd_local(channels, fs, nfft);

    phase_noise_dut_compare = phase_noise_dut(settling_samples + 1:end);
    phase_noise_dut_compare = remove_dc_local(phase_noise_dut_compare);
    [~, S_dut_current] = compute_periodogram_local( ...
        phase_noise_dut_compare, fs, nfft);

    S_pd_sum = S_pd_sum + S_pd_current;
    S_cross_sum = S_cross_sum + S_cross_current;
    S_dut_sum = S_dut_sum + S_dut_current;

    fprintf("\rRecord %d/%d", iteration, number_of_iterations);
end
fprintf("\n");

S_pd_average = S_pd_sum / number_of_iterations;
S_cross_average = S_cross_sum / number_of_iterations;
S_dut_average = S_dut_sum / number_of_iterations;
valid = frequency > 0;

[f_pd_binned, L_pd_binned] = logbin_phase_noise_local( ...
    frequency(valid), S_pd_average(valid), config.number_of_log_bins);
[f_cross_binned, L_cross_binned] = logbin_phase_noise_local( ...
    frequency(valid), abs(S_cross_average(valid)), ...
    config.number_of_log_bins);
[f_dut_binned, L_dut_binned] = logbin_phase_noise_local( ...
    frequency(valid), S_dut_average(valid), config.number_of_log_bins);

mean_absolute_error_pd_db = in_band_mae( ...
    f_pd_binned, L_pd_binned, f_dut_binned, L_dut_binned, ...
    config.lpf_cutoff);
mean_absolute_error_cross_db = in_band_mae( ...
    f_cross_binned, L_cross_binned, f_dut_binned, L_dut_binned, ...
    config.lpf_cutoff);

fprintf("In-band MAE | PD: %.3f dB | Cross-PSD: %.3f dB\n", ...
    mean_absolute_error_pd_db, mean_absolute_error_cross_db);

results.config = config;
results.mean_absolute_error_pd_db = mean_absolute_error_pd_db;
results.mean_absolute_error_cross_db = mean_absolute_error_cross_db;

results.pd.frequency = frequency;
results.pd.psd = S_pd_average;
results.pd.frequency_binned = f_pd_binned;
results.pd.phase_noise_binned = L_pd_binned;

results.cross.frequency = frequency;
results.cross.psd = S_cross_average;
results.cross.frequency_binned = f_cross_binned;
results.cross.phase_noise_binned = L_cross_binned;

results.dut.frequency = frequency;
results.dut.psd = S_dut_average;
results.dut.frequency_binned = f_dut_binned;
results.dut.phase_noise_binned = L_dut_binned;

end

function mae_db = in_band_mae(f_estimate, L_estimate, f_dut, L_dut, cutoff)
% Compare log-binned curves only inside the plotted measurement bandwidth.

valid_estimate = isfinite(f_estimate) & isfinite(L_estimate) & ...
    f_estimate > 0 & f_estimate <= cutoff;
valid_dut = isfinite(f_dut) & isfinite(L_dut) & ...
    f_dut > 0 & f_dut <= cutoff;

f_estimate = f_estimate(valid_estimate);
L_estimate = L_estimate(valid_estimate);
f_dut = f_dut(valid_dut);
L_dut = L_dut(valid_dut);

f_min = max(min(f_estimate), min(f_dut));
f_max = min(max(f_estimate), max(f_dut));
if f_min >= f_max
    error("No common in-band frequencies were found for the MAE calculation.");
end

f_common = logspace(log10(f_min), log10(f_max), 200);
L_estimate_common = interp1(log10(f_estimate), L_estimate, ...
    log10(f_common), "linear");
L_dut_common = interp1(log10(f_dut), L_dut, ...
    log10(f_common), "linear");
valid_common = isfinite(L_estimate_common) & isfinite(L_dut_common);
mae_db = mean(abs(L_estimate_common(valid_common) ...
    - L_dut_common(valid_common)));

end

function validate_comparison_config(config)
% Keep this experiment independent from the parent project's helper files.

required_fields = { ...
    "N", "fs", "A", "f0", "settling_samples", ...
    "lpf_cutoff", "lpf_order", "phase_rms_dut", ...
    "phase_rms_ref1", "phase_rms_ref2", ...
    "number_of_iterations", "number_of_log_bins"};

for field_index = 1:numel(required_fields)
    field_name = required_fields{field_index};
    if ~isfield(config, field_name)
        error("Missing parameter: config.%s", field_name);
    end
    field_value = config.(field_name);
    if ~isnumeric(field_value) || ~isscalar(field_value) || ...
            ~isreal(field_value) || ~isfinite(field_value)
        error("config.%s must be a finite real scalar.", field_name);
    end
end

if config.N <= 0 || config.N ~= fix(config.N) || mod(config.N, 2) ~= 0
    error("config.N must be a positive even integer.");
end
if config.fs <= 0 || config.A == 0
    error("config.fs must be positive and config.A cannot be zero.");
end
if config.f0 <= 0 || config.f0 >= config.fs/2
    error("config.f0 must be between zero and Nyquist.");
end
if config.settling_samples < 0 || ...
        config.settling_samples ~= fix(config.settling_samples) || ...
        config.settling_samples > config.N - 2
    error("config.settling_samples must be an integer in [0, N-2].");
end
if config.lpf_cutoff <= 0 || config.lpf_cutoff >= config.fs/2 || ...
        config.lpf_cutoff >= 2*config.f0
    error("config.lpf_cutoff is outside the valid mixer baseband range.");
end
if config.lpf_order <= 0 || config.lpf_order ~= fix(config.lpf_order)
    error("config.lpf_order must be a positive integer.");
end
if config.phase_rms_dut < 0 || config.phase_rms_ref1 < 0 || ...
        config.phase_rms_ref2 < 0
    error("Phase-noise RMS values cannot be negative.");
end
if config.number_of_iterations <= 0 || ...
        config.number_of_iterations ~= fix(config.number_of_iterations)
    error("config.number_of_iterations must be a positive integer.");
end
if config.number_of_log_bins < 2 || ...
        config.number_of_log_bins ~= fix(config.number_of_log_bins)
    error("config.number_of_log_bins must be an integer of at least two.");
end

end

function phase_noise = generate_phase_noise_local(N, phase_rms)
% Generate an RMS-normalized 1/f^3 phase-noise realization.

seed = mod(173*floor(time()*1e6), 100000);
rng(seed);
white_spectrum = fft(randn(N, 1));

frequency_bin = [0:N/2, N/2-1:-1:1]';
frequency_bin(1) = 1;
shaping = 1 ./ sqrt(frequency_bin.^3);
shaping(1) = 0;

unit_noise = real(ifft(white_spectrum .* shaping));
unit_noise = remove_dc_local(unit_noise);
unit_noise = unit_noise / sqrt(mean(unit_noise.^2));
phase_noise = phase_rms * unit_noise;

end

function filtered_signal = lowpass_filter_local( ...
        input_signal, fs, cutoff_frequency, filter_order)
% Apply the same causal Butterworth LPF used by the main simulation.

persistent cached_fs cached_cutoff cached_order cached_b cached_a;
settings_changed = isempty(cached_b) || cached_fs ~= fs || ...
    cached_cutoff ~= cutoff_frequency || cached_order ~= filter_order;
if settings_changed
    [cached_b, cached_a] = butter( ...
        filter_order, cutoff_frequency/(fs/2), "low");
    cached_fs = fs;
    cached_cutoff = cutoff_frequency;
    cached_order = filter_order;
end
filtered_signal = filter(cached_b, cached_a, input_signal);

end

function x = remove_dc_local(x)
% Remove each channel's mean independently.

x = x - mean(x);

end

function [frequency, P] = compute_periodogram_local(x, fs, nfft)
% Compute a rectangular-window, one-sided periodogram.

x = x(:);
signal_length = length(x);
X = fft(x, nfft);
P_two_sided = abs(X).^2 / (fs*signal_length);
number_of_positive_points = floor(nfft/2) + 1;
P = P_two_sided(1:number_of_positive_points);
P(2:end-1) = 2*P(2:end-1);
frequency = (0:number_of_positive_points-1)' * fs/nfft;

end

function S_cross = compute_cross_psd_local(channels, fs, nfft)
% Compute a complex, one-sided cross spectrum for the two PD channels.

channel_length = size(channels, 1);
channel_spectra = fft(channels, nfft, 1);
S_two_sided = channel_spectra(:, 1) ...
    .* conj(channel_spectra(:, 2)) / (fs*channel_length);
number_of_positive_points = floor(nfft/2) + 1;
S_cross = S_two_sided(1:number_of_positive_points);
S_cross(2:end-1) = 2*S_cross(2:end-1);

end

function [f_binned, L_binned] = logbin_phase_noise_local( ...
        frequency, P, number_of_bins)
% Log-bin a one-sided phase PSD and convert it to SSB dBc/Hz.

frequency = frequency(:);
P = P(:);
valid = isfinite(frequency) & isfinite(P) & frequency > 0 & P >= 0;
frequency = frequency(valid);
P = P(valid);

bin_edges = logspace( ...
    log10(min(frequency)), log10(max(frequency)), number_of_bins + 1);
f_binned = NaN(number_of_bins, 1);
P_binned = NaN(number_of_bins, 1);

for bin_index = 1:number_of_bins
    in_bin = frequency >= bin_edges(bin_index) ...
        & frequency < bin_edges(bin_index + 1);
    if bin_index == number_of_bins
        in_bin = frequency >= bin_edges(bin_index) ...
            & frequency <= bin_edges(bin_index + 1);
    end
    if any(in_bin)
        f_binned(bin_index) = exp(mean(log(frequency(in_bin))));
        P_binned(bin_index) = mean(P(in_bin));
    end
end

nonempty_bins = isfinite(f_binned);
f_binned = f_binned(nonempty_bins);
P_binned = P_binned(nonempty_bins);
L_binned = 10*log10(0.5*P_binned + realmin);

end
