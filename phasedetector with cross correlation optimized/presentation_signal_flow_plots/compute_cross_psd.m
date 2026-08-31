function S_cross = compute_cross_psd(channels, fs, nfft)
% İki ölçüm kanalının tek taraflı Cross-PSD'sini hesaplar.
if size(channels, 2) ~= 2
    error("Cross-PSD hesabi icin channels tam olarak iki kolonlu olmalidir.");
end
channel_length = size(channels, 1);
channel_spectra = fft(channels, nfft, 1);
S_cross_two_sided = channel_spectra(:, 1) ...
    .* conj(channel_spectra(:, 2)) / (fs*channel_length);
number_of_positive_points = floor(nfft/2) + 1;
S_cross = S_cross_two_sided(1:number_of_positive_points);
S_cross(2:end-1) = 2*S_cross(2:end-1);
end
