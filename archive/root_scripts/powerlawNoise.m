% POWERLAW

function noise = powerlawNoise(N, alpha, fs)
  % powerlaw_noise:
  % 1/f^alpha karakterinde gerçek değerli colored noise üretir.
  %
  % Girişler:
  %
  % N:
  % Üretilecek örnek sayısı.
  %
  % alpha:
  % Spektral eğim katsayısı.
  %
  % alpha = 0  -> white noise
  % alpha = 1  -> pink noise
  % alpha = 2  -> brown/red noise
  %
  % fs:
  % Örnekleme frekansı.
  %
  % Çıkış:
  %
  % noise:
  % Ortalaması 0, standart sapması 1 olacak şekilde
  % normalize edilmiş colored noise.


  %% başlangıçta beyaz Gauss gürültüsü üret
  pkg load signal
  white = wgn(N,1,-30);
  X = fft(white);

  f = (0:N-1)' * fs/N; % FFT indekslerini Hz cinsinden frekansa dönüştürür.


  f_distance = min(f, fs-f);


  %% DC'de sıfıra bölünmeyi engelle, en küçük fft bini fs/N
  f_distance(1) = fs/N;


  %% spektral şekilledirme katsayısı
  shaping = 1 ./ (f_distance .^ (alpha/2));


  %% dc bileşenleri kaldır

  shaping(1) = 0;


  X_colored = X.*shaping;

  noise = real(ifft(X_colored));

  noise = noise - mean(noise);
  noise = noise/std(noise);

 endfunction
