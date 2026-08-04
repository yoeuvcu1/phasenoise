%% Pink phase noise

clear; close all; clc;

pkg load signal;

N = 100000;
fs = 1e6;
t = (0:N-1)' / fs;

% sinyal
A = 1;
f0 = 10e3;

x_clean = A*cos(2*pi*f0*t);


% noise
white = randn(N,1);
X_white = fft(white);

f_bin = [0:N/2 , N/2-1:-1:1]';
f_bin(1) = 1;

% pink filtre

pink_filter = 1 ./ sqrt(f_bin.^3);
pink_filter(1) = 0;

X_pink = X_white .* pink_filter;

% zaman domaini ve normalize etme
pinknoise_signal = real(ifft(X_pink));
pinknoise_signal = pinknoise_signal - mean(pinknoise_signal);
pinknoise_signal = pinknoise_signal/std(pinknoise_signal);



% İstenen rms faz gürültüsü

phase_rms = 0.05;

phase_noise = phase_rms*pinknoise_signal;

x_phase_noisy = A * cos(2*pi*f0*t + phase_noise);


measured_phase_rms = std(phase_noise);

fprintf("Hedef RMS faz hatası:   %.5f rad\n", phase_rms);
fprintf("Ölçülen RMS faz hatası: %.5f rad\n", measured_phase_rms);

fprintf("Ölçülen RMS faz hatası: %.3f derece\n", measured_phase_rms * 180/pi);

%% ZAMAN BÖLGESİ GRAFİKLERİ

figure;


subplot(3,1,1);

plot(t*1e3, x_clean);

grid on;

xlabel("Zaman (ms)");
ylabel("Genlik");

title("Temiz Taşıyıcı");

% 10 kHz sinyalin periyodu 0.1 ms'dir.
% İlk 0.5 ms içinde 5 periyot görürüz.
xlim([0 0.5]);


subplot(3,1,2);

plot(t*1e3, phase_noise);

grid on;

xlabel("Zaman (ms)");
ylabel("Faz hatası (rad)");

title("Pink Karakterli Phase Noise");

% Phase noise düşük frekans ağırlıklı olduğu için
% daha uzun bir zaman aralığında görmek daha anlamlıdır.
xlim([0 0.5]);


subplot(3,1,3);

plot(t*1e3, x_phase_noisy);

grid on;

xlabel("Zaman (ms)");
ylabel("Genlik");

title("Pink Phase Noise Eklenmiş Taşıyıcı");

xlim([0 0.5]);

%% TEMİZ VE GÜRÜLTÜLÜ SİNYALİ KARŞILAŞTIR

figure;

plot(t*1e3, x_clean, ...
     "LineWidth", 1.2);

hold on;

plot(t*1e3, x_phase_noisy);

grid on;

xlabel("Zaman (ms)");
ylabel("Genlik");

title("Temiz ve Phase Noise'lu Taşıyıcı");

legend("Temiz taşıyıcı", ...
       "Phase noise'lu taşıyıcı");

xlim([0 0.5]);


%% TEMİZ VE PHASE NOISE'LU TAŞIYICI SPEKTRUMU

##[P_clean, f_carrier] = pwelch(x_clean, [], [], [], 100e3);
##
##[P_noisy, ~] = pwelch(x_phase_noisy, [], [], [], 100e3);

[P_clean, f_carrier] = pwelch(x_clean, kaiser(2048,12), .5, 2048, 100e3);

[P_noisy, ~] = pwelch(x_phase_noisy, kaiser(2048,12), .5, 2048, 100e3);

% İki spektrumu da temiz taşıyıcının maksimum gücüne göre
% normalize ediyoruz.
reference_power = max(P_clean);

P_clean_dB = 10*log10(P_clean/reference_power + eps);

P_noisy_dB = 10*log10(P_noisy/reference_power + eps);


figure;

plot(f_carrier/1e3, P_clean_dB, "LineWidth", 1.2);

hold on;

plot(f_carrier/1e3, P_noisy_dB);

grid on;

xlabel("Frekans (kHz)");
ylabel("Normalize PSD (dB)");
title("Taşıyıcı Spektrumu");
legend("Temiz taşıyıcı", "Phase noise'lu taşıyıcı");
% 10 kHz taşıyıcının çevresine yakınlaş.
xlim([0 16]);
##ylim([-100 5]);


%% flicker noisy signal spectrum logarithmic
figure;
semilogx(f_carrier(2:end), 10*log10(P_noisy(2:end) + eps));
grid on;
xlabel("Frekans (Hz)");
ylabel("PSD (dB/Hz)");
title("Pink Noise PSD");
