function result = run_asin_realization_case(config)
%RUN_ASIN_REALIZATION_CASE Compare three detector transforms on one record.
%   The DUT, Ref1 and Ref2 arrays are generated once and shared by all three
%   branches. The caller controls the random stream and therefore reproducibility.

%% ---------------- OCTAVE SIGNAL PACKAGE ----------------
persistent signal_package_loaded;
if exist("OCTAVE_VERSION", "builtin") && isempty(signal_package_loaded)
    pkg load signal;
    signal_package_loaded = true;
end

validate_config(config);

%% ---------------- COMMON SIGNALS ----------------
N = config.N;
fs = config.fs;
A = config.A;
t = (0:N-1)' / fs;
carrier_phase = 2*pi*config.f0*t;
quadrature_phase = carrier_phase + pi/2;
K_pd = A^2 / 2;

% This generator uses the caller's RNG stream instead of reseeding itself.
phase_noise_dut = generate_phase_noise_from_stream(N, config.phase_rms_dut);
phase_noise_ref1 = generate_phase_noise_from_stream(N, config.phase_rms_ref1);
phase_noise_ref2 = generate_phase_noise_from_stream(N, config.phase_rms_ref2);

x_dut = A*cos(carrier_phase + phase_noise_dut);
x_ref1 = A*cos(quadrature_phase + phase_noise_ref1);
x_ref2 = A*cos(quadrature_phase + phase_noise_ref2);
mixed_signals = mixer(x_dut, [x_ref1, x_ref2]);

%% ---------------- THREE DETECTOR BRANCHES ----------------
% Branch 1 is the unmodified detector output.
% Branch 2 reproduces asin(mixed_signals) before the LPF.
[mixed_before_asin, clipped_before_count] = bounded_asin(mixed_signals);

% Filter both input variants in one call to keep the LPF operation identical.
filtered = lowpass_filter( ...
    [mixed_signals, mixed_before_asin], ...
    fs, config.lpf_cutoff, config.lpf_order) / K_pd;
phase_no_asin = filtered(:, 1:2);
phase_asin_before_lpf = filtered(:, 3:4);

% Branch 3 reproduces asin(phase_error) after LPF and K_pd normalization.
[phase_asin_after_lpf, clipped_after_count] = bounded_asin(phase_no_asin);

first_sample = config.settling_samples + 1;
channels_no_asin = remove_dc(phase_no_asin(first_sample:end, :));
channels_asin_before = remove_dc(phase_asin_before_lpf(first_sample:end, :));
channels_asin_after = remove_dc(phase_asin_after_lpf(first_sample:end, :));

%% ---------------- IDENTICAL SPECTRAL PROCESSING ----------------
channel_length = N - config.settling_samples;
nfft = 2^nextpow2(2*channel_length - 1);
number_of_positive_points = floor(nfft/2) + 1;
f = (0:number_of_positive_points-1)' * fs/nfft;
valid = f > 0;

S_no_asin = compute_cross_psd(channels_no_asin, fs, nfft);
S_asin_before = compute_cross_psd(channels_asin_before, fs, nfft);
S_asin_after = compute_cross_psd(channels_asin_after, fs, nfft);

phase_noise_dut_compare = phase_noise_dut(first_sample:end);
phase_noise_dut_compare = remove_dc(phase_noise_dut_compare);
[~, S_dut] = compute_periodogram(phase_noise_dut_compare, fs, nfft);

[f_no_asin, L_no_asin] = logbin_phase_noise( ...
    f(valid), abs(S_no_asin(valid)), config.number_of_log_bins);
[f_asin_before, L_asin_before] = logbin_phase_noise( ...
    f(valid), abs(S_asin_before(valid)), config.number_of_log_bins);
[f_asin_after, L_asin_after] = logbin_phase_noise( ...
    f(valid), abs(S_asin_after(valid)), config.number_of_log_bins);
[f_dut, L_dut] = logbin_phase_noise( ...
    f(valid), S_dut(valid), config.number_of_log_bins);

mae_no_asin = calculate_mae_db(f_no_asin, L_no_asin, f_dut, L_dut);
mae_asin_before = calculate_mae_db( ...
    f_asin_before, L_asin_before, f_dut, L_dut);
mae_asin_after = calculate_mae_db( ...
    f_asin_after, L_asin_after, f_dut, L_dut);

%% ---------------- RESULTS ----------------
result.config = config;
result.no_asin.frequency = f_no_asin;
result.no_asin.phase_noise = L_no_asin;
result.no_asin.mae_db = mae_no_asin;
result.asin_before_lpf.frequency = f_asin_before;
result.asin_before_lpf.phase_noise = L_asin_before;
result.asin_before_lpf.mae_db = mae_asin_before;
result.asin_before_lpf.clipped_sample_count = clipped_before_count;
result.asin_after_lpf.frequency = f_asin_after;
result.asin_after_lpf.phase_noise = L_asin_after;
result.asin_after_lpf.mae_db = mae_asin_after;
result.asin_after_lpf.clipped_sample_count = clipped_after_count;
result.dut.frequency = f_dut;
result.dut.phase_noise = L_dut;

end

function phase_noise = generate_phase_noise_from_stream(N, phase_rms)
% Match generate_phase_noise.m without changing the caller's RNG seed.

white = randn(N, 1);
X_white = fft(white);
f_bin = [0:N/2, N/2-1:-1:1]';
f_bin(1) = 1;
phase_noise_filter = 1 ./ sqrt(f_bin.^3);
phase_noise_filter(1) = 0;
unit_phase_noise = real(ifft(X_white .* phase_noise_filter));
unit_phase_noise = remove_dc(unit_phase_noise);
unit_phase_noise = unit_phase_noise / sqrt(mean(unit_phase_noise.^2));
phase_noise = phase_rms * unit_phase_noise;

end

function [y, clipped_sample_count] = bounded_asin(x)
% Keep asin real if filtering produces a small numerical range overshoot.

clipped_sample_count = sum(abs(x(:)) > 1);
x = min(max(x, -1), 1);
y = asin(x);

end

function mae_db = calculate_mae_db(f_estimate, L_estimate, f_dut, L_dut)
% Use the active project's 200-point common log-frequency MAE definition.

f_min_common = max(min(f_estimate), min(f_dut));
f_max_common = min(max(f_estimate), max(f_dut));
f_common = logspace(log10(f_min_common), log10(f_max_common), 200);
L_estimate_interp = interp1( ...
    log10(f_estimate), L_estimate, log10(f_common), "linear");
L_dut_interp = interp1(log10(f_dut), L_dut, log10(f_common), "linear");
valid = ~isnan(L_estimate_interp) & ~isnan(L_dut_interp);
mae_db = mean(abs(L_estimate_interp(valid) - L_dut_interp(valid)));

end
