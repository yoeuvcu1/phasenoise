%% pink and brown noise

% white noise psd 1, pink 1/f, brown 1/(f^2)

clear;
close all;
clc;

pkg load signal

fs = 100e3;
N = 100000;

whiteNoise = powerlawNoise(N,0,fs);

pinkNoise = powerlawNoise(N,1,fs);
brownNoise = powerlawNoise(N,2,fs);

[P_white, f] = pwelch(whiteNoise, [], [], [], fs);
[P_pink, f] = pwelch(pinkNoise, [], [], [], fs);
[P_brown, f] = pwelch(brownNoise, [], [], [], fs);


figure;

plot(f, 10*log10(P_white));
hold on;
plot(f, 10*log10(P_pink));
plot(f, 10*log10(P_brown));
plot(f, 10*log10(P2));
grid on;
xlabel("Frekans Hz");
ylabel("PSD dB/Hz");
title("White,pink,brown noise PSD");
legend("white", "pink", "brown");
