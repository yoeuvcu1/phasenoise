%% LOW PASS COLORED NOISE

clear; close all; clc;
pkg load signal;

fs=100e3;
N=100000;
fc=5e3; % alcak geciren cutoff
filter_order=4; % butter filtre derecesi


whiteNoise = wgn(N,1,-20);

normalized_fc = fc/(fs/2);

% butter() fonksiyonunda frekanslar doğrudan Hz olarak değil,
% Nyquist frekansına normalize edilmiş olarak verilir. fs/2
% normalize değer de 0 ile 1 arsı olması gerek

[b,a] = butter(filter_order, normalized_fc, "low");

coloredNoise = filter(b,a,whiteNoise);
coloredNoise = coloredNoise - mean(coloredNoise); % dc değerini kaldırmak icin
coloredNoise = coloredNoise/std(coloredNoise); % gürültünün standart sapmasını 1 yapmak için. karşılaştırma kolay olmasu için.


%% PLOTS
figure;

subplot(2,1,1);
plot(whiteNoise(1:2000));
grid on;
xlabel("sample n");
ylabel("amp");
title("wgn");

subplot(2,1,2);
plot(coloredNoise(1:2000));
grid on;
xlabel("sample n");
ylabel("amp");
title("LP colored noise");




%% spectral plots

figure;

% pwelch sinyalin güç spektral yoğunluğunu tahmin eder.
[P_white, f_white] = pwelch(whiteNoise, [], [], [], fs);

[P_colored, f_colored] = pwelch(coloredNoise, [], [], [], fs);

plot(f_white, 10*log10(P_white));
hold on;
plot(f_colored, 10*log10(P_colored));
grid on;

xlabel("Frekans (Hz)");
ylabel("PSD (dB/Hz)");
title("Beyaz ve alçak geçiren colored noise karşılaştırması");
legend("White noise", "Low-pass colored noise");

