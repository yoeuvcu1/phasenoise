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
% MATLAB'in global random stream'ini ilk çağrıda başlat. Her DUT, Ref1 ve Ref2
% çağrısı aynı stream'den ardışık yeni örnekler alır.
% parfor altında persistent değişken her worker'da ayrıdır ve worker'lar aynı
% anda başladığı için tek başına saat tabanlı seed çakışabilir. Thread tabanlı
% havuzda worker kimliği (getCurrentTask) okunamadığından seed üç bağımsız
% kaynağın XOR'u olarak kurulur: saat tabanlı shuffle seed'i, yüksek
% çözünürlüklü dahili sayaç ve worker'ın varsayılan stream'inden alınan bir
% çekim. threefry sayaç tabanlı olduğundan farklı seed'ler istatistiksel olarak
% bağımsız diziler üretir. Bağımsızlık ayrıca otomatik bir kabul testiyle
% doğrulanmamaktadır.
persistent rng_initialized;
if isempty(rng_initialized)
    shuffled_stream = RandStream("threefry", "Seed", "shuffle");
    clock_seed = uint64(shuffled_stream.Seed);
    counter_seed = uint64(tic);
    worker_seed = uint64(randi(intmax("uint32")));
    combined_seed = bitxor(bitxor(clock_seed, counter_seed), worker_seed);
    combined_seed = double(mod(combined_seed, uint64(intmax("uint32"))));
    RandStream.setGlobalStream(RandStream("threefry", "Seed", combined_seed));
    rng_initialized = true;
end
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
