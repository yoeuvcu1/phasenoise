function results = run_simulation(config)
% Cross-PSD faz gürültüsü simülasyonunu çalıştıran ana işlev.

% Octave'de signal paketini yalnızca bir kez yükle.
persistent signal_package_loaded;
if exist("OCTAVE_VERSION", "builtin") && isempty(signal_package_loaded)
    pkg load signal;
    signal_package_loaded = true;
end

% Simülasyon için gerekli tüm alanların verildiğini kontrol et.
validate_config(config);

% Config alanlarını yerel değişkenlere aktar.
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

% Settling bölgesi için en az 1 örnek şartını zorunlu tut.
if N <= settling_samples
    error("N, settling_samples degerinden buyuk olmalidir.");
end

% Zaman ekseni ve faz gürültülü DUT taşıyıcı sinyalini üret.
t = (0:N-1)' / fs;
quadrature_phase = 2*pi*f0*t + pi/2;
if isfield(config, "phase_noise_dut") && ~isempty(config.phase_noise_dut)
    % Paylaşılmış DUT gürültüsü: taramalar arasında temiz karşılaştırma
    % için aynı taban sinyal kullanılır (run_comparisons_main üretir).
    phase_noise_dut = config.phase_noise_dut(:);
else
    phase_noise_dut = generate_phase_noise(N, phase_rms_dut);
end
x_dut = A*cos(2*pi*f0*t + phase_noise_dut);

% Faz detektörü LPF katsayılarını ve detektör kazancı K_pd = A^2/2'yi hazırla.
normalized_cutoff = lpf_cutoff / (fs/2);
[b_lpf, a_lpf] = butter(lpf_order, normalized_cutoff, "low");
K_pd = A^2 / 2;

% Settling sonrası uzunluğunu, cross-PSD FFT boyunu ve frekans eksenini kur.
channel_length = N - settling_samples;
% Hızlı radix-2 FFT için nfft'yi üstteki ilk 2'nin kuvvetine yuvarla.
nfft_cross = 2^nextpow2(2*channel_length - 1);
% Tek taraflı spektrumun nokta sayısını belirle.
number_of_positive_points = floor(nfft_cross/2) + 1;
f_cross = (0:number_of_positive_points-1)' * fs / nfft_cross;
S_cross_sum = complex(zeros(number_of_positive_points, 1));

% Her iterasyonda yeni referanslar üretilir; cross spektrum toplanır.
for iteration = 1:number_of_iterations
    iteration_timer = tic;

    S_cross_current = measure_iteration( ...
        x_dut, A, quadrature_phase, ...
        phase_rms_ref1, phase_rms_ref2, ...
        b_lpf, a_lpf, K_pd, settling_samples, fs, nfft_cross);

    S_cross_sum = S_cross_sum + S_cross_current;

    iteration_seconds = toc(iteration_timer);
    fprintf("\rIterasyon %d/%d | Iterasyon suresi: %.3f s", ...
        iteration, number_of_iterations, iteration_seconds);
end
fprintf("\n");

% İterasyon ortalamasını al ve LPF bant aralığındaki geçerli frekansları seç.
S_cross_average = S_cross_sum / number_of_iterations;
valid_cross = valid_freq_mask(f_cross, lpf_cutoff);

% Toplam güç integrali P = sum|S|*df ile sigma2 = -0.5*ln(1 - 2*P) tahmini.
min_log_argument = 1e-10;
frequency_step = f_cross(2) - f_cross(1);
total_power_sin = sum(abs(S_cross_average(valid_cross))) * frequency_step;
sigma2_est = -0.5 * log(max(1 - 2*total_power_sin, min_log_argument));

% Tahmin ile güç kaybını telafi eden düzeltme faktörünü uygula.
if total_power_sin > 0 && sigma2_est > 0
    correction_factor = sigma2_est / total_power_sin;
else
    correction_factor = 1;
end

S_cross_corrected = S_cross_average * correction_factor;
[f_cross_binned, L_cross_binned] = bin_and_convert( ...
    f_cross(valid_cross), ...
    abs(S_cross_corrected(valid_cross)), ...
    number_of_log_bins);

% DUT faz gürültüsünü filtreleyip aynı uzunlukta karşılaştırma sinyali oluştur.
phase_noise_dut_filtered = filter(b_lpf, a_lpf, phase_noise_dut);
phase_noise_dut_compare = phase_noise_dut_filtered(settling_samples + 1:end);
phase_noise_dut_compare = remove_dc(phase_noise_dut_compare);

% DUT faz gürültüsünün periodogramını (FFT) hesapla.
[f_dut_fft, S_dut_fft] = compute_periodogram( ...
    phase_noise_dut_compare, fs, nfft_cross);
valid_dut_fft = valid_freq_mask(f_dut_fft, lpf_cutoff);
[f_dut_fft_binned, L_dut_fft_binned] = bin_and_convert( ...
    f_dut_fft(valid_dut_fft), ...
    S_dut_fft(valid_dut_fft), ...
    number_of_log_bins);

% İki eğri için ortak logaritmik frekans aralığını belirle.
f_min_common = max(min(f_cross_binned), min(f_dut_fft_binned));
f_max_common = min(max(f_cross_binned), max(f_dut_fft_binned));

% Aralık boşsa simülasyon anlamsızdır, hata ver.
if f_min_common >= f_max_common
    error("Cross-PSD ve DUT FFT icin ortak frekans araligi bulunamadi.");
end

% Eğrileri ortak eksende doğrusallıkla interpole et ve farkı dB cinsinden ölç.
interp_point_count = 200;
f_common = logspace(log10(f_min_common), log10(f_max_common), interp_point_count);
% Uç noktadaki kayar nokta taşmasını önlemek için aralığa kıstır.
f_common = min(max(f_common, f_min_common), f_max_common);
L_cross_interp = interp1( ...
    f_cross_binned, L_cross_binned, f_common, "linear");
L_dut_fft_interp = interp1( ...
    f_dut_fft_binned, L_dut_fft_binned, f_common, "linear");
% Aralık dışı kalmış NaN noktaları ortalamaya katma.
valid_common = ~isnan(L_cross_interp) & ~isnan(L_dut_fft_interp);
if ~any(valid_common)
    error("Hata hesabi icin ortak frekans noktasi bulunamadi.");
end
mean_absolute_error_fft_db = mean( ...
    abs(L_cross_interp(valid_common) - L_dut_fft_interp(valid_common)));

% Ölçüm hata metnini ekrana yaz.
fprintf("Ortalama mutlak fark (Cross-PSD - DUT FFT): %.3f dB\n", ...
    mean_absolute_error_fft_db);

% Cross-PSD ile DUT FFT eğrilerini log-frekans ekseninde çiz.
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

% Tüm sonuçları bir yapı olarak topla ve döndür.
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

end
