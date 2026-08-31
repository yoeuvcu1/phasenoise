function [S_cross_iteration, f_cross] = measure_iteration( ...
    x_dut, fs, A, f0, ...
    phase_rms_ref1, phase_rms_ref2, ...
    lpf_cutoff, lpf_order, settling_samples)

    %% ZAMAN DİZİSİ

    x_dut = x_dut(:);
    N = length(x_dut);
    t = (0:N-1)' / fs;

    if settling_samples >= N
        error("settling_samples, sinyal uzunluğundan küçük olmalıdır.");
    end


    %% BAĞIMSIZ REFERANS PHASE NOISE'LARI

    phase_noise_ref1 = generate_phase_noise(N, phase_rms_ref1);
    phase_noise_ref2 = generate_phase_noise(N, phase_rms_ref2);
   %% phase_noise_ref2 = phase_noise_ref1 + phase_rms_ref1/100*randn(N, 1);

    %% REFERANS SİNYALLERİ

    x_ref1 = A*cos(2*pi*f0*t + pi/2 + phase_noise_ref1);
    x_ref2 = A*cos(2*pi*f0*t + pi/2 + phase_noise_ref2);


    %% FAZ DEDEKTÖRLERİ

    pd_ref1_raw = x_dut .* x_ref1;
    pd_ref2_raw = x_dut .* x_ref2;


    %% LOW-PASS FİLTRELER

    pd_ref1_lpf = lowpass_filter( pd_ref1_raw, fs, lpf_cutoff, lpf_order);

    pd_ref2_lpf = lowpass_filter( pd_ref2_raw, fs, lpf_cutoff, lpf_order);


    %% PHASE ERROR ELDE ET

    K_pd = A^2 / 2;

    phase_error_ref1 = pd_ref1_lpf / K_pd;
    phase_error_ref2 = pd_ref2_lpf / K_pd;


    %% FİLTRE GEÇİŞ BÖLGESİNİ ÇIKAR

    correlation_start = settling_samples + 1;

    channel_1 = phase_error_ref1(correlation_start:end);
    channel_2 = phase_error_ref2(correlation_start:end);

    channel_1 = remove_dc(channel_1);
    channel_2 = remove_dc(channel_2);


    %% CROSS-CORRELATION

    r_cross = xcorr(channel_1, channel_2, "biased");

    % Sıfır lag'i dizinin başına taşı
    r_cross_ordered = ifftshift(r_cross);


    %% CROSS-CORRELATION'DAN CROSS-PSD

    S_cross_two_sided = fft(r_cross_ordered) / fs;

    number_of_points = length(S_cross_two_sided);

    number_of_positive_points = floor(number_of_points/2) + 1;

    S_cross_iteration = S_cross_two_sided(1:number_of_positive_points);

    % Tek taraflı PSD
    S_cross_iteration(2:end) = 2*S_cross_iteration(2:end);

    f_cross = (0:number_of_positive_points-1)' * fs / number_of_points;

end
