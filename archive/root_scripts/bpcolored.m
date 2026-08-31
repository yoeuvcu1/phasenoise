%% BANDPASS COLORED NOISE

clear; close all; clc;
pkg load signal;

fs=100e3;
N=100000;
f1=5e3; % bp alt
f2=15e3; % bp üst
filter_order=4; % butter filtre derecesi


whiteNoise = wgn(N,1,-20);

normalizedBand = [f1 f2]/(fs/2);

% butter() fonksiyonunda frekanslar doğrudan Hz olarak değil,
% Nyquist frekansına normalize edilmiş olarak verilir. fs/2
% normalize değer de 0 ile 1 arsı olması gerek

[b,a] = butter(filter_order, normalizedBand, "bandpass");

coloredNoise = filter(b,a,whiteNoise);
coloredNoise = coloredNoise - mean(coloredNoise); % dc değerini kaldırmak icin
coloredNoise = coloredNoise/std(coloredNoise); % gürültünün standart sapmasını 1 yapmak için. karşılaştırma kolay olmasu için.

[Pxxw, fw] = pwelch(whiteNoise, [], [], [], fs);
[Pxx, f] = pwelch(coloredNoise, [], [], [], fs);

figure;
plot(f/1e3, 10*log10(Pxx));
hold on;
plot(fw/1e3, 10*log10(Pxxw));
grid on;
xlabel("Frekans kHz");
ylabel("PSD dB/Hz");
legend("bp","white")
title("5-15 kHz Bandpass Colored Noise")
