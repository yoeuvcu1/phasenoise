function [f, P] = compute_periodogram(x, fs, nfft)
% Dikdörtgen pencereli tek taraflı PSD hesaplar.
x = x(:);
signal_length = length(x);
X = fft(x, nfft);
P_two_sided = abs(X).^2 / (fs*signal_length);
number_of_positive_points = floor(nfft/2) + 1;
P = P_two_sided(1:number_of_positive_points);
P(2:end-1) = 2*P(2:end-1);
f = (0:number_of_positive_points-1)' * fs/nfft;
end
