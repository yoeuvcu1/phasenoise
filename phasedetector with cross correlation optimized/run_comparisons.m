% Cross-PSD karşılaştırmalarının kullanıcı arayüzü.
%
% Akış:
%   1. default_config tüm testlerde kullanılacak başlangıç ayarlarını tutar.
%   2. test_values içindeki her değer bağımsız bir simülasyon koşusu başlatır.
%   3. run_comparisons_main sonuçları ayrı klasörlere kaydedip karşılaştırır.
%
% Bir testi kapatmak için ilgili test_values alanını [] yapın.

%% Varsayılan simülasyon parametreleri
default_config = struct();
default_config.N = 10000;                % Örnek sayısı
default_config.fs = 1e6;                   % Örnekleme frekansı (Hz)
default_config.A = 1;                      % Taşıyıcı genliği
default_config.f0 = 50e3;                  % Taşıyıcı frekansı (Hz)
default_config.settling_samples = 600;     % LPF geçici rejimi için atılan örnek
default_config.lpf_cutoff = 10e3;          % LPF kesim frekansı (Hz)
default_config.lpf_order = 4;              % LPF derecesi
default_config.phase_rms_dut = 0.2;        % DUT faz gürültüsü RMS (rad)
default_config.phase_rms_ref1 = 0.05;      % Referans 1 RMS (rad)
default_config.phase_rms_ref2 = 0.05;      % Referans 2 RMS (rad)
default_config.number_of_iterations = 100; % Cross-PSD ortalama sayısı
default_config.number_of_log_bins = 100;   % Logaritmik bin sayısı

%% Test değerleri
% Her satır tek bir parametreyi tarar; diğer parametreler default_config
% değerinde kalır. rms_ref testi Ref1 ve Ref2 RMS değerlerini birlikte değiştirir.
test_values = struct();
test_values.lpf_cutoff = [5e3, 10e3, 25e3, 50e3];   % Hz
test_values.rms_dut = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5];   % rad
test_values.rms_ref = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5]; % rad; iki referans birlikte değişir
test_values.iterations = [1, 10, 50, 100, 200, 300];   % adet
test_values.log_bins = [10, 25, 50, 80, 100, 200];      % adet

show_figures = true; % Karşılaştırma figürlerini ekranda göster

% Script başka bir çalışma klasöründen başlatılsa da proje fonksiyonlarını bul.
project_dir = fileparts(mfilename("fullpath"));
addpath(project_dir);

% Testleri çalıştır; ham spektrum, özet ve PNG üretimini ana yöneticide yap.
run_comparisons_main(default_config, test_values, show_figures, project_dir);

fprintf("\nHazir. Sonuclar: %s\n", fullfile(project_dir, "results"));
