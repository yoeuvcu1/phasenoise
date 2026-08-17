function results = benchmark_fft(config)
% Mevcut (asal) nfft ile 2'nin kuvveti nfft'nin FFT hızını karşılaştırır.
% Mevcut kodu değiştirmez; sadece ölçüm yapar.

% Parametre verilmezse varsayılan simülasyon ayarlarını kullan.
if nargin == 0
    config.N = 100000;
    config.fs = 1e6;
    config.settling_samples = 100;
    config.number_of_iterations = 100;
    config.number_of_repeats = 25; % Her ölçümün tekrar sayısı
    config.number_of_warmup = 3;   % Isınma turu (zamanlamaya girmez)
end

N = config.N;
settling_samples = config.settling_samples;
number_of_iterations = config.number_of_iterations;
number_of_repeats = config.number_of_repeats;
number_of_warmup = config.number_of_warmup;

% Settling sonrası kanal uzunluğu.
channel_length = N - settling_samples;

% Karşılaştırılacak iki FFT boyu.
nfft_current = 2*channel_length - 1;   % Şimdiki boy (asal, Bluestein ile yavaş)
nfft_pow2 = 2^nextpow2(nfft_current);  % Üstündeki ilk 2'nin kuvveti (radix-2 hızlı)

fprintf("Kanal uzunlugu : %d\n", channel_length);
fprintf("Mevcut nfft    : %d\n", nfft_current);
fprintf("2'nin kuvveti  : %d\n", nfft_pow2);

% measure_iteration'daki gibi iki kanallı temsili veri üret.
channels = randn(channel_length, 2);

% İki boy için tek FFT sürelerini ölç.
t_current = time_fft(channels, nfft_current, number_of_warmup, number_of_repeats);
t_pow2 = time_fft(channels, nfft_pow2, number_of_warmup, number_of_repeats);

% Her iterasyonda bir cross-FFT var; toplam süreyi iterasyon sayısıyla ölçekle.
total_current = t_current * number_of_iterations;
total_pow2 = t_pow2 * number_of_iterations;
speedup = t_current / t_pow2;

fprintf("\n--- FFT karsilastirma (%d iterasyon) ---\n", number_of_iterations);
fprintf("Mevcut nfft=%d : tek FFT %8.3f ms | toplam %8.3f s\n", ...
    nfft_current, t_current*1e3, total_current);
fprintf("2^k   nfft=%d : tek FFT %8.3f ms | toplam %8.3f s\n", ...
    nfft_pow2, t_pow2*1e3, total_pow2);
fprintf("Hizlanma       : %.2fx\n", speedup);

% Sonuçları yapı olarak döndür.
results.channel_length = channel_length;
results.nfft_current = nfft_current;
results.nfft_pow2 = nfft_pow2;
results.time_current_s = t_current;
results.time_pow2_s = t_pow2;
results.total_current_s = total_current;
results.total_pow2_s = total_pow2;
results.speedup = speedup;
results.number_of_iterations = number_of_iterations;

end

function t_seconds = time_fft(channels, nfft, number_of_warmup, number_of_repeats)
% Verilen nfft boyundaki FFT'yi ısıtıp medyan süresini döndürür.

% Isınma turları: tek seferlik plan kurulum maliyetini dışarıda bırakır.
for warmup_index = 1:number_of_warmup
    fft(channels, nfft, 1);
end

% Ölçüm turları.
t_samples = zeros(number_of_repeats, 1);
for repeat_index = 1:number_of_repeats
    timer = tic;
    fft(channels, nfft, 1);
    t_samples(repeat_index) = toc(timer);
end

% Saçılmayı azaltmak için medyanı al.
t_seconds = median(t_samples);

end
