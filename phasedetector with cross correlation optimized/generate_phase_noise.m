function phase_noise = generate_phase_noise(N, phase_rms)
% İstenen RMS değerine sahip 1/f^3 spektrumlu faz gürültüsü üretir.

% Bu üretim dizisi çift N için tasarlanmıştır.
if mod(N, 2) ~= 0
    error('N cift sayi olmalidir.');
end

% Deterministik tohum ile beyaz gürültü üret ve FFT'sini al.
seed_multiplier = 173;
seed_modulus = 100000;
microseconds_per_second = 1e6;
seed = mod(seed_multiplier*floor(time() * microseconds_per_second), seed_modulus);
rng(seed);
white = randn(N, 1);
X_white = fft(white);

% Tek taraflı frekans vektörü kur: [0:N/2, N/2-1:-1:1].
f_bin = [0:N/2, N/2-1:-1:1]';
f_bin(1) = 1;

% 1/f^3 filtre uygula (DC bileşeni filtreden çıkar).
phase_noise_filter = 1 ./ sqrt(f_bin.^3);
phase_noise_filter(1) = 0;

% Filtrelenen spektrumu zaman uzayına çevir ve DC'yi at.
X_colored = X_white .* phase_noise_filter;
unit_phase_noise = real(ifft(X_colored));

% Sinyali birim varyansa normalize et, sonra hedef RMS ile ölçekle.
unit_phase_noise = remove_dc(unit_phase_noise);
unit_phase_noise = unit_phase_noise / std(unit_phase_noise);

phase_noise = phase_rms * unit_phase_noise;

end