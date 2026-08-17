function results = main(config)
% Simülasyonu başlatan giriş noktası.

% Parametre verilmezse varsayılan test ayarları.
if nargin == 0
    config.N = 100000;                 % Toplam örnek sayısı
    config.fs = 1e6;                   % Örnekleme frekansı (Hz)
    config.A = 1;                      % Taşıyıcı genliği
    config.f0 = 50e3;                  % Taşıyıcı frekansı (Hz)
    config.settling_samples = 100;     % LPF geçici bölgesi atılacak örnek sayısı
    config.lpf_cutoff = 25e3;          % Faz detektörü LPF kesim frekansı (Hz)
    config.lpf_order = 4;              % Faz detektörü LPF derecesi
    config.phase_rms_dut = 0.2;        % DUT faz gürültüsünün RMS değeri (rad)
    config.phase_rms_ref1 = 0.05;      % Referans 1 faz gürültüsü RMS (rad)
    config.phase_rms_ref2 = 0.05;      % Referans 2 faz gürültüsü RMS (rad)
    config.number_of_iterations = 100; % Cross-PSD ortalaması için iterasyon
    config.number_of_log_bins = 50;    % Logaritmik bin sayısı
    config.show_plot = true;           % Sonuç grafiğini çiz
end

% Ana simülasyonu çalıştır ve sonuç yapısını döndür.
results = run_simulation(config);

end
