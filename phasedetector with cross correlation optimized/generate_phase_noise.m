function phase_noise = generate_phase_noise(N, phase_rms)
% İstenen RMS değerine sahip 1/f^3 spektrumlu faz gürültüsü üretir.
% Algoritma beyaz gürültüyü FFT uzayında 1/sqrt(f^3) ile şekillendirir;
% bu genlik filtresi uygulandığında güç spektrumu 1/f^3 olur.

%% ---------------- INPUT CHECK ----------------
% Bu üretim dizisi çift N için tasarlanmıştır.
if mod(N, 2) ~= 0
    error('N cift sayi olmalidir.');
end

%% ---------------- WHITE NOISE SOURCE ----------------
% Projenin istenen davranışı gereği her DUT/Ref üretimi zaman tabanlı yeni seed
% kurar; rng çağrısı bilinçli olarak bu fonksiyonun içindedir.
seed_multiplier = 173;
seed_modulus = 100000;
microseconds_per_second = 1e6;
seed = mod(seed_multiplier*floor(time() * microseconds_per_second), seed_modulus);
rng(seed);
white = randn(N, 1);
X_white = fft(white);

%% ---------------- 1/F^3 SPECTRAL SHAPING ----------------
% FFT'nin pozitif ve negatif taraflarına simetrik bin indeksi kur; DC'deki sıfıra
% bölmeyi geçici olarak önle, ardından DC kazancını açıkça sıfırla.
f_bin = [0:N/2, N/2-1:-1:1]';
f_bin(1) = 1;

% PSD hedefi 1/f^3 olduğundan FFT genliğine bunun karekökü uygulanır.
phase_noise_filter = 1 ./ sqrt(f_bin.^3);
phase_noise_filter(1) = 0;

% Simetrik gerçek giriş nedeniyle IFFT sonucu teorik olarak gerçektir; sayısal
% yuvarlama kaynaklı küçük imajiner kısmı real ile temizle.
X_colored = X_white .* phase_noise_filter;
unit_phase_noise = real(ifft(X_colored));

%% ---------------- RMS NORMALIZATION ----------------
% Her rastgele realizasyonun toplam RMS'ini tam olarak phase_rms değerine getir.
unit_phase_noise = remove_dc(unit_phase_noise);
unit_phase_noise = unit_phase_noise / sqrt(mean(unit_phase_noise.^2));

phase_noise = phase_rms * unit_phase_noise;

end
