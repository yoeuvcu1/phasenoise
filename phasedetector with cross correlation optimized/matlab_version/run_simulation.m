function results = run_simulation(config)
% Cross-PSD faz gürültüsü simülasyonunu çalıştıran ana işlev.
%
% Her iterasyonda yeni DUT ve Ref1/Ref2 realizasyonları üretilir. Dönen results
% yapısında ortalama Cross-PSD, ortalama DUT periodogramı, log-binlenmiş eğriler
% ve iki ortalama eğrinin MAE değeri bulunur.

%% ---------------- CONFIG VALIDATION ----------------
% Boyut, frekans ve sayım hatalarını büyük diziler oluşturulmadan yakala.
validate_config(config);

%% ---------------- SIMULATION PARAMETERS ----------------
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
% Faz dedektorundeki DUT--referans merkez faz farki. Alan verilmezse eski
% davranisi korumak icin quadrature (90 derece) kullanilir.
if isfield(config, "phase_offset_deg")
    phase_offset_deg = config.phase_offset_deg;
else
    phase_offset_deg = 90;
end

%% ---------------- CARRIER TIME BASE ----------------
% Taşıyıcı zaman tabanı ve referansların merkez faz farkı bütün iterasyonlarda
% aynıdır; rastgele DUT/Ref faz realizasyonları döngüde yenilenir.
t = (0:N-1)' / fs;
carrier_phase = 2*pi*f0*t;
reference_phase = carrier_phase + deg2rad(phase_offset_deg);

%% ---------------- PHASE DETECTOR GAIN ----------------
% Çarpım faz detektörünün LPF çıkışını sin(faz hatası) ölçeğine getiren kazanç.
% LPF tasarımı ve uygulaması lowpass_filter.m içinde tek devre bloğundadır.
K_pd = A^2 / 2;

%% ---------------- FFT AND ACCUMULATORS ----------------
% Zero-padding için 2*N-1'i kapsayan en yakın radix-2 FFT boyu seçilir; bu
% frekans ızgarasını sıklaştırır ve FFT hesabını uygun bir radix-2 boya taşır.
channel_length = N - settling_samples;
% Hızlı radix-2 FFT için nfft'yi üstteki ilk 2'nin kuvvetine yuvarla.
nfft_cross = 2^nextpow2(2*channel_length - 1);
% Tek taraflı spektrumun nokta sayısını belirle.
number_of_positive_points = floor(nfft_cross/2) + 1;
f_cross = (0:number_of_positive_points-1)' * fs / nfft_cross;
S_cross_sum = complex(zeros(number_of_positive_points, 1));
S_dut_sum = zeros(number_of_positive_points, 1);

%% ---------------- MONTE CARLO ITERATIONS ----------------
% Kompleks cross spektrumlar önce toplanır, magnitude işlemi ortalamadan sonra
% yapılır; böylece korelasyonsuz referans bileşenlerinin iptali korunur.
simulation_timer = tic;
fprintf("%d iterasyon paralel hesaplaniyor...\n", number_of_iterations);
parfor iteration = 1:number_of_iterations

    % Aynı fiziksel DUT modelinin yeni zaman realizasyonunu oluştur. Bu kayıt iki
    % ölçüm kanalında ortak, Ref1/Ref2 ise birbirinden bağımsız bileşenlerdir.
    phase_noise_dut = generate_phase_noise(N, phase_rms_dut);
    x_dut = A*cos(carrier_phase + phase_noise_dut);

    S_cross_current = measure_iteration( ...
        x_dut, A, reference_phase, ...
        phase_rms_ref1, phase_rms_ref2, ...
        fs, lpf_cutoff, lpf_order, K_pd, settling_samples, nfft_cross);

    S_cross_sum = S_cross_sum + S_cross_current;

    % Cross-PSD ile aynı kayıt bölümüne ait filtresiz DUT periodogramını lineer
    % güç alanında topla. dB eğrilerini değil PSD'leri ortalamak gerekir.
    phase_noise_dut_compare = phase_noise_dut(settling_samples + 1:end);
    phase_noise_dut_compare = remove_dc(phase_noise_dut_compare);
    [~, S_dut_current] = compute_periodogram( ...
        phase_noise_dut_compare, fs, nfft_cross);
    S_dut_sum = S_dut_sum + S_dut_current;
end
simulation_seconds = toc(simulation_timer);
fprintf("Iterasyonlar tamamlandi | toplam sure: %.2f s | hiz: %.2f iter/s\n", ...
    simulation_seconds, number_of_iterations / simulation_seconds);

%% ---------------- CROSS-PSD AVERAGE ----------------
% DC karşılaştırmaya dahil edilmez. LPF etkisi ayrıca frekans maskesiyle
% gizlenmez; Cross-PSD'nin bütün pozitif frekansları korunur.
S_cross_average = S_cross_sum / number_of_iterations;
valid_cross = f_cross > 0;

%% ---------------- CROSS-PSD LOG BINNING ----------------
[f_cross_binned, L_cross_binned] = logbin_phase_noise( ...
    f_cross(valid_cross), ...
    abs(S_cross_average(valid_cross)), ...
    number_of_log_bins);

%% ---------------- DUT REFERENCE PERIODOGRAM ----------------
% Her iterasyondaki filtresiz DUT periodogramının lineer ortalamasını kullan.
% Tam çözünürlüklü bu ortalama results ile birlikte raw MAT dosyasına kaydedilir.
f_dut_fft = f_cross;
S_dut_fft = S_dut_sum / number_of_iterations;
valid_dut_fft = f_dut_fft > 0;
[f_dut_fft_binned, L_dut_fft_binned] = logbin_phase_noise( ...
    f_dut_fft(valid_dut_fft), ...
    S_dut_fft(valid_dut_fft), ...
    number_of_log_bins);

%% ---------------- ERROR METRIC ----------------
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
fprintf("Ortalama mutlak fark (Cross-PSD - unfiltered DUT): %.3f dB\n", ...
    mean_absolute_error_fft_db);

%% ---------------- RESULTS STRUCTURE ----------------
% Tam çözünürlüklü spektrumlar replot/inceleme için, binned alanlar doğrudan
% grafik çizmek için saklanır.
results.config = config;
results.config.phase_offset_deg = phase_offset_deg;
results.mean_absolute_error_fft_db = mean_absolute_error_fft_db;
results.cross.frequency = f_cross;
results.cross.psd = S_cross_average;
results.cross.frequency_binned = f_cross_binned;
results.cross.phase_noise_binned = L_cross_binned;
results.dut_fft.frequency = f_dut_fft;
results.dut_fft.psd = S_dut_fft;
results.dut_fft.frequency_binned = f_dut_fft_binned;
results.dut_fft.phase_noise_binned = L_dut_fft_binned;
results.dut_fft.number_of_averages = number_of_iterations;
results.dut_fft_unfiltered = results.dut_fft;

end
