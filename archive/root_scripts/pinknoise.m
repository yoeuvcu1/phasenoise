clear; close all; clc;
pkg load signal;
N = 100000;
fs = 100e3;
white = randn(N, 1);
X = fft(white);

f = [0:N/2, N/2-1:-1:1]';
f(1) = 1;

pink_filter = 1 ./ sqrt(f.^3);
pink_filter(1) = 0; % dc bileşenin çıkmasını engellemek


X_pink = X .* pink_filter;
pinknoise_signal = real(ifft(X_pink)); % Back to time domain

pinknoise_signal = pinknoise_signal - mean(pinknoise_signal);
pinknoise_signal = pinknoise_signal / std(pinknoise_signal);


[P, fx] = pwelch(pinknoise_signal, [], [], [], 100000);
figure;
semilogx(fx(2:end), 10*log10(P(2:end) + eps));
grid on;
xlabel("Frekans (Hz)");
ylabel("PSD (dB/Hz)");
title("Pink Noise PSD");
