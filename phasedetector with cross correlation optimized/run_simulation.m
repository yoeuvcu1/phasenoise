function results = run_simulation(config)
% Cross-PSD faz gürültüsü simülasyonunu çalıştıran ana işlev.
%
% Aynı DUT sinyali, number_of_iterations boyunca yeni Ref1/Ref2 çiftleriyle
% ölçülür. Dönen results yapısında düzeltilmiş Cross-PSD, DUT periodogramı,
% log-binlenmiş eğriler, correction factor ve iki eğrinin MAE değeri bulunur.

% Octave'de signal paketini yalnızca bir kez yükle.
persistent signal_package_loaded;
if exist("OCTAVE_VERSION", "builtin") && isempty(signal_package_loaded)
    pkg load signal;
    signal_package_loaded = true;
end

% Boyut, frekans ve sayım hatalarını büyük diziler oluşturulmadan yakala.
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

% DUT faz gürültüsü bu run boyunca sabittir; yalnızca referanslar iterasyondan
% iterasyona yenilenir. Böylece kanalların ortak bileşeni DUT olur.
t = (0:N-1)' / fs;
quadrature_phase = 2*pi*f0*t + pi/2;
phase_noise_dut = generate_phase_noise(N, phase_rms_dut);
x_dut = A*cos(2*pi*f0*t + phase_noise_dut);

% Taşıyıcı çarpımından gelen yüksek frekanslı bileşeni bastıracak LPF'yi ve
% faz detektörü çıkışını rad cinsine ölçekleyen K_pd = A^2/2 kazancını hazırla.
normalized_cutoff = lpf_cutoff / (fs/2);
[b_lpf, a_lpf] = butter(lpf_order, normalized_cutoff, "low");
K_pd = A^2 / 2;

% Zero-padding için 2*N-1'i kapsayan en yakın radix-2 FFT boyu seçilir; bu
% frekans çözünürlüğünü sıklaştırır ve FFT hesabını hızlandırır.
channel_length = N - settling_samples;
% Hızlı radix-2 FFT için nfft'yi üstteki ilk 2'nin kuvvetine yuvarla.
nfft_cross = 2^nextpow2(2*channel_length - 1);
% Tek taraflı spektrumun nokta sayısını belirle.
number_of_positive_points = floor(nfft_cross/2) + 1;
f_cross = (0:number_of_positive_points-1)' * fs / nfft_cross;
S_cross_sum = complex(zeros(number_of_positive_points, 1));

% Kompleks cross spektrumlar önce toplanır, magnitude işlemi ortalamadan sonra
% yapılır; böylece korelasyonsuz referans bileşenlerinin iptali korunur.
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

% DC karşılaştırmaya dahil edilmez; LPF cutoff üzerindeki frekanslar da ölçüm
% modelinin geçerli bandının dışında olduğu için atılır.
S_cross_average = S_cross_sum / number_of_iterations;
valid_cross = f_cross > 0 & f_cross <= lpf_cutoff;

% Sinüzoidal faz detektörünün yüksek RMS'te oluşturduğu güç sıkışmasını yaklaşık
% olarak geri almak için bant içi güçten eşdeğer faz varyansı tahmin edilir:
%   sigma^2 = -0.5*ln(1 - 2*P), correction = sigma^2/P.
min_log_argument = 1e-10;
frequency_step = f_cross(2) - f_cross(1);
total_power_sin = sum(abs(S_cross_average(valid_cross))) * frequency_step;
sigma2_est = -0.5 * log(max(1 - 2*total_power_sin, min_log_argument));

% Güç veya tahmin sıfırsa spektrumu değiştirmemek için correction=1 kullan.
if total_power_sin > 0 && sigma2_est > 0
    correction_factor = sigma2_est / total_power_sin;
else
    correction_factor = 1;
end

S_cross_corrected = S_cross_average * correction_factor;
[f_cross_binned, L_cross_binned] = logbin_phase_noise( ...
    f_cross(valid_cross), ...
    abs(S_cross_corrected(valid_cross)), ...
    number_of_log_bins);

% Referans eğriyi adil karşılaştırmak için gerçek DUT fazı da ölçüm kanallarıyla
% aynı LPF ve settling işleminden geçirilir.
phase_noise_dut_filtered = filter(b_lpf, a_lpf, phase_noise_dut);
phase_noise_dut_compare = phase_noise_dut_filtered(settling_samples + 1:end);
phase_noise_dut_compare = remove_dc(phase_noise_dut_compare);

% DUT faz gürültüsünün periodogramını (FFT) hesapla.
[f_dut_fft, S_dut_fft] = compute_periodogram( ...
    phase_noise_dut_compare, fs, nfft_cross);
valid_dut_fft = f_dut_fft > 0 & f_dut_fft <= lpf_cutoff;
[f_dut_fft_binned, L_dut_fft_binned] = logbin_phase_noise( ...
    f_dut_fft(valid_dut_fft), ...
    S_dut_fft(valid_dut_fft), ...
    number_of_log_bins);

% MAE yalnızca iki eğrinin de veri içerdiği ortak frekans aralığında hesaplanır.
f_min_common = max(min(f_cross_binned), min(f_dut_fft_binned));
f_max_common = min(max(f_cross_binned), max(f_dut_fft_binned));

% Aralık boşsa simülasyon anlamsızdır, hata ver.
if f_min_common >= f_max_common
    error("Cross-PSD ve DUT periodogram icin ortak frekans araligi bulunamadi.");
end

% Bin merkezleri birebir aynı olmak zorunda olmadığından iki eğriyi 200 ortak
% log-frekans noktasına taşı ve mutlak dB farkının ortalamasını al.
interp_point_count = 200;
f_common = logspace(log10(f_min_common), log10(f_max_common), interp_point_count);
% Uç noktadaki kayar nokta taşmasını önlemek için aralığa kıstır.
f_common = min(max(f_common, f_min_common), f_max_common);
L_cross_interp = interp1( ...
    log10(f_cross_binned), L_cross_binned, log10(f_common), "linear");
L_dut_fft_interp = interp1( ...
    log10(f_dut_fft_binned), L_dut_fft_binned, log10(f_common), "linear");
% Aralık dışı kalmış NaN noktaları ortalamaya katma.
valid_common = ~isnan(L_cross_interp) & ~isnan(L_dut_fft_interp);
if ~any(valid_common)
    error("Hata hesabi icin ortak frekans noktasi bulunamadi.");
end
mean_absolute_error_fft_db = mean( ...
    abs(L_cross_interp(valid_common) - L_dut_fft_interp(valid_common)));

% Ölçüm hata metnini ekrana yaz.
fprintf("Ortalama mutlak fark (Cross-PSD - DUT periodogram): %.3f dB\n", ...
    mean_absolute_error_fft_db);

% Tam çözünürlüklü spektrumlar replot/inceleme için, binned alanlar doğrudan
% grafik çizmek için saklanır.
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
