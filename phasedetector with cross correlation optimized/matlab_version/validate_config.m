function validate_config(config)
% Simülasyon config alanlarının varlığını ve temel sınırlarını doğrular.
% Geçersiz bir alan bulduğunda açıklayıcı error üretir; değerleri değiştirmez.

%% ---------------- REQUIRED CONFIG FIELDS ----------------
required_fields = { ...
    "N", "fs", "A", "f0", "settling_samples", ...
    "lpf_cutoff", "lpf_order", "phase_rms_dut", ...
    "phase_rms_ref1", "phase_rms_ref2", ...
    "number_of_iterations", "number_of_log_bins"};

% Önce alan varlığını kontrol et; böylece sonraki kontroller güvenle erişebilir.
for field_index = 1:numel(required_fields)
    field_name = required_fields{field_index};
    if ~isfield(config, field_name)
        error("Eksik parametre: config.%s", field_name);
    end
end

%% ---------------- NUMERIC VALUE CHECKS ----------------
% Vektör, kompleks, NaN ve Inf değerler filtre/FFT boyutlarını bozacağı için reddedilir.
for field_index = 1:numel(required_fields)
    field_name = required_fields{field_index};
    field_value = config.(field_name);
    if ~isnumeric(field_value) || ~isscalar(field_value) || ...
            ~isreal(field_value) || ~isfinite(field_value)
        error("config.%s sonlu, gercek ve skaler olmalidir.", field_name);
    end
end

%% ---------------- SIGNAL AND FILTER LIMITS ----------------
% Örnek ve frekans parametrelerinin fiziksel/sayısal sınırlarını kontrol et.
if config.N <= 0 || config.N ~= fix(config.N) || mod(config.N, 2) ~= 0
    error("config.N pozitif ve cift bir tamsayi olmalidir.");
end
if config.fs <= 0
    error("config.fs pozitif olmalidir.");
end
if config.A == 0
    error("config.A sifir olamaz.");
end
if config.f0 <= 0 || config.f0 >= config.fs/2
    error("config.f0, (0, fs/2) araliginda olmalidir.");
end
% Settling sonrasında FFT için en az iki örnek kalmalıdır.
if config.settling_samples < 0 || ...
        config.settling_samples ~= fix(config.settling_samples) || ...
        config.settling_samples > config.N - 2
    error("config.settling_samples, [0, N-2] araliginda bir tamsayi olmalidir.");
end
if config.lpf_cutoff <= 0 || config.lpf_cutoff >= config.fs/2
    error("config.lpf_cutoff, (0, fs/2) araliginda olmalidir.");
end
if 2*config.f0 <= config.lpf_cutoff
    error(['2*config.f0, lpf_cutoff degerinden buyuk olmalidir; ', ...
        'tasiyici toplam-frekans bileseni LPF bandina giremez.']);
end
if config.lpf_order <= 0 || config.lpf_order ~= fix(config.lpf_order)
    error("config.lpf_order pozitif bir tamsayi olmalidir.");
end

%% ---------------- NOISE AND AVERAGING LIMITS ----------------
% RMS sıfır olabilir (gürültüsüz kanal), ancak negatif olamaz.
if config.phase_rms_dut < 0 || config.phase_rms_ref1 < 0 || ...
        config.phase_rms_ref2 < 0
    error("Faz gurultusu RMS degerleri negatif olamaz.");
end
% Döngü sayısı pozitif, log-bin sayısı ise en az iki olmalıdır.
if config.number_of_iterations <= 0 || ...
        config.number_of_iterations ~= fix(config.number_of_iterations)
    error("config.number_of_iterations pozitif bir tamsayi olmalidir.");
end
if config.number_of_log_bins < 2 || ...
        config.number_of_log_bins ~= fix(config.number_of_log_bins)
    error("config.number_of_log_bins en az 2 olan bir tamsayi olmalidir.");
end

%% ---------------- FFT FREQUENCY RESOLUTION ----------------
% Seçilen cutoff altında en az iki pozitif FFT örneği yoksa log-bin ve MAE
% hesapları anlamlı bir frekans aralığı oluşturamaz.
channel_length = config.N - config.settling_samples;
nfft = 2^nextpow2(2*channel_length - 1);
if config.lpf_cutoff < 2*config.fs/nfft
    error("LPF bandinda en az iki pozitif FFT noktasi bulunmalidir.");
end

end
