# Change Log

Bu dosya projenin güncel kronolojik değişiklik kaydıdır. Ayrıntılı kullanım
için kök `README.md`, oturum handoff'u için `MEMORY_BANK.md` kullanılır.

## 2026-08-21: Son Deney Profili ve Seçilmiş Sonuçlar

- `run_comparisons.m` genel profili `N=1000000`, `f0=200 kHz`,
  `LPF=200 kHz`, DUT/Ref RMS `0.05 rad` olarak güncellendi.
- LPF sweep'i `1 kHz` ile `300 kHz` arasında dokuz noktaya genişletildi.
- Genel iteration sweep listesi `[1,10,100,200,500,1000]` olarak güncellendi.
- `run_iterations.m`, eksik `250` ve `500` iteration noktalarını `N=100000`
  profilinde üretmek üzere ayarlandı.
- `extend_iteration_results.m` ve `extend_iteration_results_main.m` eklendi.
  Tamamlanmış iteration sweep'leri config uyumluluğu doğrulanarak yeniden
  simülasyon yapılmadan yeni bir `_iterations_merged` klasöründe birleştirildi.
- `İki Kanallı Cross.docx` güncellendi; 10 PNG görsel DOCX paketi içine gömülü
  olarak taşındı.

## 2026-08-20: Repo Dokümantasyonu ve Yayınlama

- Kök `README.md` eklendi ve tek aktif çalışma alanı açıkça tanımlandı.
- Optimize klasör README'si config sözleşmesi, runner profilleri, sonuç yapısı,
  sweep/replot akışı ve bilinen sınırlarla yeniden yazıldı.
- `MEMORY_BANK.md` eski makine yolları, ZIP notları ve güncel kodla çelişen
  varsayılanlardan temizlendi.
- Legacy klasör README'si salt tarihsel referans olarak işaretlendi.
- Proje raporu, tarihli ve yerel kanıtlara dayanan tamamlanmamış taslak olarak
  açıkça etiketlendi.
- `results/`, MAT, görsel ve ZIP dosyalarını dışarıda bırakan metin odaklı Git
  politikası eklendi.
- Mevcut Git geçmişi, commit SHA değerleri korunarak GitHub `main` branch'ine
  aktarıldı.

## 2026-08-20: Devre Bloğu Ayrımı

- Mixer işlemi `mixer.m` dosyasına taşındı.
- Butterworth tasarımı ve iki kanal filtrelemesi `lowpass_filter.m` içinde
  toplandı.
- LPF katsayıları config değişmediği sürece persistent cache'den kullanılmaya
  başlandı.
- FFT Cross-PSD hesabı `compute_cross_psd.m` dosyasına ayrıldı.
- `run_simulation.m` ve `measure_iteration.m` orchestration odaklı hale
  getirildi.
- Sayısal formüller ve dış `results` sözleşmesi korunarak okunabilirlik
  artırıldı.
- `run_single.m`, diğer giriş betikleri gibi kendi klasörünü path'e ekleyecek
  şekilde konumdan bağımsız hale getirildi.

## 2026-08-19: Her İterasyonda Yeni DUT

- Önceki tek-DUT yaklaşımı kaldırıldı; her iterasyonda yeni DUT faz gürültüsü
  üretilmeye başlandı.
- Aynı iterasyonun iki ölçüm kanalı ortak DUT kullanmaya devam etti.
- Filtresiz DUT periodogramları lineer PSD alanda ortalanarak Cross-PSD ile
  aynı Monte Carlo popülasyonu karşılaştırıldı.
- Tam çözünürlüklü ortalama `results.dut_fft.psd` alanında saklandı.
- Tek tek DUT zaman dizileri dosya boyutu nedeniyle saklanmadı.
- Yalnız `number_of_iterations` tarayan `run_iterations.m` eklendi.

## 2026-08-18: Aktif Akışın Sadeleştirilmesi

- Optimize uygulama function tabanlı `run_simulation(config)` API'sinde
  toplandı.
- Girişler `run_single.m`, `run_comparisons.m`, `run_iterations.m` ve
  `replot_results.m` olarak ayrıldı.
- Kullanılmayan wrapper, benchmark ve eski test betikleri kaldırıldı.
- Sweep kaydı `raw`, `plots`, `summary.mat` ve `summary.csv` düzeninde
  standartlaştırıldı.
- Kompleks Cross-PSD ve lineer DUT ortalaması sonuç sözleşmesinde netleştirildi.

## 2026-08-17: Optimize Uygulama ve Sweep Altyapısı

- `phasedetector with cross correlation optimized/` ayrı çalışma alanı olarak
  oluşturuldu.
- Zorunlu config doğrulaması `validate_config.m` içine ayrıldı.
- Parametre sweep'leri ve kayıtlı sonucu yeniden çizme akışı eklendi.
- `signal` paketi Octave altında bir kez yüklenen persistent akışa alındı.
- Hata mesajları ve işlev açıklamaları geliştirildi.

## 2026-08-07: Temel Algoritmik Optimizasyonlar

Bu tarih, eski ve optimize akış arasındaki ilk tasarım farklarının tarihsel
başlangıcıdır. O tarihte kullanılan bazı dosyalar daha sonra kaldırılmış veya
yeniden ayrılmıştır; aşağıdaki kararların aktif karşılıkları güncel dosyalarda
devam eder.

### Cross-PSD: `xcorr` Zincirinden Doğrudan FFT'ye

Eski yaklaşım:

```matlab
r = xcorr(channel_1, channel_2, "biased");
r = ifftshift(r);
S = fft(r) / fs;
```

Aktif yaklaşım:

```matlab
X1 = fft(channel_1, nfft);
X2 = fft(channel_2, nfft);
S = X1 .* conj(X2) / (fs * channel_length);
```

- Biased cross-correlation FFT'sinin doğrudan cross-spektrum karşılığı
  kullanıldı.
- `xcorr`, `ifftshift` ve tam korelasyon dizisi kaldırıldı.
- Değişiklik hesaplama maliyetini azaltmak amacıyla yapıldı; güncel repoda
  kontrollü, tekrarlanabilir hız benchmark'ı bulunmadığı için sayısal hız
  çarpanı iddia edilmez.

### FFT Uzunluğu

- `2*M-1` uzunluğunun yavaş asal/Bluestein FFT'ye düşme riski azaltıldı.
- `nfft = 2^nextpow2(2*M-1)` seçilerek radix-2 FFT kullanıldı.
- Zero-padding frekans ızgarasını sıklaştırır; bağımsız çözünürlüğü artırdığı
  şeklinde yorumlanmamalıdır.

### Lineer Ortalama

- Kayan ortalama yerine kompleks spektrum toplamı ve final bölme kullanıldı.
- Büyüklük alma işlemi kompleks Cross-PSD ortalamasından sonraya bırakıldı.
- DUT periodogramı da dB yerine lineer güç alanında ortalandı.

### Log-Bin

- Eski yorumla çelişen `max(P(mask))` davranışı `mean(P(mask))` ile
  değiştirildi.
- Böylece her bin tepe değeri yerine aritmetik ortalama gücü temsil eder.

### Welch Sonuçları

- Çizilmeyen ve aktif karşılaştırmada kullanılmayan `dut_welch` alanları
  kaldırıldı.
- Aktif sonuç sözleşmesi Cross-PSD ile filtresiz DUT periodogramından oluşur.

## 2026-08-04: İlk Uygulama

- Faz gürültüsü kaynak yardımcıları ve ilk cross-correlation modeli eklendi.
- `1/f^3` gürültü şekillendirme, RMS normalizasyonu ve temel faz detektörü
  deneyleri oluşturuldu.

## Aktif Teknik Kararlar

1. Desteklenen runtime GNU Octave'dır.
2. Tek aktif klasör `phasedetector with cross correlation optimized/`dır.
3. Kompleks Cross-PSD büyüklükten önce ortalanır.
4. DUT referansı aynı iterasyonların lineer periodogram ortalamasıdır.
5. Log-bin aritmetik ortalama güç kullanır.
6. Welch aktif sonuç sözleşmesine dahil değildir.
7. Sweep'ler bağımsız tek-parametre taramalarıdır; Cartesian ürün değildir.
8. Büyük sonuç dosyaları Git dışında tutulur.
9. Zaman tabanlı RNG mevcut davranıştır fakat yeniden üretilebilirlik problemi
   olarak ele alınmalı ve gelecekte değiştirilmelidir.
10. Algoritmik performans iddiaları kontrollü benchmark olmadan sayısal değerle
    raporlanmaz.
