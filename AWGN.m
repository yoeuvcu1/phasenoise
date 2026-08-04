%%AWGN
clear; close all; clc;
pkg load communications
pkg load signal

fs = 100e3; % 100kHz sampling
duration = 0.005; % 0.01 saniye sinyal üretilecek
t = (0  : 1/fs  :  duration-1/fs)'; % 0'dan duration'a kadar zaman aralığı, 1/fs kadar parçalarla, sonda 1/fs cıkarıyoruz tam adet tutsun diye

A = 1; % genlik
f0 = 10e3; % frekans
x = A*cos(2*pi*f0*t);

SNR_dB = 20;

y = awgn(x, SNR_dB, "measured");
% "measured": Octave'ın x sinyalinin gerçek ortalama gücünü ölçmesini sağlar.
% Gürültü gücü bu ölçülen sinyal gücüne göre ayarlanır.

noise = y - x;

figure;
subplot(3,1,1);
plot(t, x);
grid on;
xlabel("zaman");
ylabel("genlik");
title("Temiz Sinüs Sinyali");

subplot(3,1,2);
plot(t, noise);
grid on;
xlabel("Zaman");
ylabel("Genlik");
title("Eklenen AWGN");

subplot(3,1,3);
plot(t, y);
grid on;
xlabel("Zaman");
ylabel("Genlik");
title("Gürültülü Sinyal");



% complex noise
clear;
clc;

N = 100e3;

noise_power_dBW = -30;
noise_complex = wgn(N, 1, noise_power_dBW, 1, "complex");
noise_real = real(noise_complex);
noise_imaginer = imag(noise_complex);

measured_power_W = mean(abs(noise_complex).^2);
% Gerçek veya kompleks bir sinyalin ortalama gücü: P = mean(|x|^2)
% abs reelde onemli degil sinyal gercek cunku ama aklimda kalsin.

measured_power_dBW = 10 * log10(measured_power_W);

fprintf("%.2f", measured_power_dBW);
% gucu terminale yazdirdik

figure;
subplot(2,1,1);
plot(noise_real(1:1000));
grid on;
xlabel("Örnek numarası");
ylabel("Genlik");
title("Real WGN");

subplot(2,1,2);
plot(noise_imaginer(1:1000));
grid on;
xlabel("Örnek numarası");
ylabel("Genlik");
title("Complex WGN");







