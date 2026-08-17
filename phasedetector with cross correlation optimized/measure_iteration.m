function S_cross_iteration = measure_iteration( ...
    x_dut, A, quadrature_phase, ...
    phase_rms_ref1, phase_rms_ref2, ...
    b_lpf, a_lpf, K_pd, settling_samples, fs, nfft_cross)
% Tek bir iterasyonda iki referansla cross-PSD ölçümünü döndürür.

N = length(x_dut);

% İki bağımsız (korelasyonsuz) referans kanalını üret.
phase_noise_ref1 = generate_phase_noise(N, phase_rms_ref1);
phase_noise_ref2 = generate_phase_noise(N, phase_rms_ref2);

x_ref1 = A*cos(quadrature_phase + phase_noise_ref1);
x_ref2 = A*cos(quadrature_phase + phase_noise_ref2);

% DUT ve referansların korelasyonunu al, LPF ile filtrele (faz hatası).
pd_raw = [x_dut .* x_ref1, x_dut .* x_ref2];
phase_error = filter(b_lpf, a_lpf, pd_raw) / K_pd;
channels = phase_error(settling_samples + 1:end, :);

% DC bileşenini at ve kanal uzunluğunu belirle.
channels = remove_dc(channels);
channel_length = size(channels, 1);

% İki kanalın kesit (cross) spektrumunu FFT ile hesapla.
channel_spectra = fft(channels, nfft_cross, 1);
S_cross_two_sided = channel_spectra(:, 1) ...
    .* conj(channel_spectra(:, 2)) / (fs*channel_length);

% Tek taraflı spektruma geçir, DC hariç çöpleri 2 ile ölçekle.
number_of_positive_points = floor(nfft_cross/2) + 1;
S_cross_iteration = S_cross_two_sided(1:number_of_positive_points);
S_cross_iteration(2:end) = 2*S_cross_iteration(2:end);

end