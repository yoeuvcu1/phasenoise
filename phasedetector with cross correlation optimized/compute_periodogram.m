function [f, P] = compute_periodogram(x, fs, nfft)
% Dikdörtgen pencere ile tek taraflı (single-sided) PSD hesaplar.

x = x(:);
signal_length = length(x);

% FFT boyutu verilmezse 2*N - 1 kullan.
if nargin < 3
    nfft = 2*signal_length - 1;
end

% İki taraflı PSD = |X|^2 / (fs * N) formülüyle hesapla.
X = fft(x, nfft);
P_two_sided = abs(X).^2 / (fs*signal_length);

% Tek taraflı spektruma geçir, DC hariç tüm çöpleri 2 ile ölçekle.
number_of_positive_points = floor(nfft/2) + 1;
P = P_two_sided(1:number_of_positive_points);
P(2:end) = 2*P(2:end);

f = (0:number_of_positive_points-1)' * fs/nfft;

end