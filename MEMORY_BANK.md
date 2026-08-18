# MEMORY BANK — Phase Noise Cross-Correlation Projesi

Bu dosya, "phasedetector with cross correlation optimized" projesindeki çalışma oturumları arasında bağlam korumak içindir. Yeni bir oturumda önce burayı oku.

## Proje Özeti

Faz gürültüsü ölçümünün (phase noise) **cross-correlation / cross-PSD** yöntemiyle simülasyonu (GNU Octave). İki bağımsız referans kanalıyla DUT faz gürültüsü ölçülür; referansların kendi gürültüleri iterasyon ortalamasında söner, DUT'unki birikir.

## Klasör Yapısı

```
Octave/  (workspace kökü)
├── CHANGES.md                       ← orijinal vs optimized fark raporu
├── MEMORY_BANK.md                   ← bu dosya
├── phasedetector with cross correlation/          (ORİJİNAL - değiştirme)
└── phasedetector with cross correlation optimized/ (AKTİF - üzerinde çalışılan)
    ├── run_single.m                 ← tek simülasyon giriş betiği ve grafiği
    ├── run_comparisons.m            ← parametre taraması giriş betiği
    ├── run_simulation.m             ← ana simülasyon akışı
    ├── measure_iteration.m          ← tek iterasyonluk cross-PSD ölçümü (FFT tabanlı)
    ├── generate_phase_noise.m       ← 1/f³ spektrumlu faz gürültüsü üretici
    ├── compute_periodogram.m        ← DUT referans PSD (tek taraflı)
    ├── logbin_phase_noise.m         ← log-bin + SSB dBc/Hz dönüşümü
    ├── remove_dc.m                  ← kolon ortalamasını çıkar
    ├── validate_config.m            ← config alan doğrulama
    ├── plot_sweep_results.m         ← sweep sonuçlarının subplot grafiği
    ├── replot_results.m             ← kaydedilmiş sweep sonuçları giriş betiği
    └── replot_results_main.m        ← kayıtlı spektrumları yükleyip yeniden çizer
```

## Çalıştırma

```matlab
run_single;                % tek simülasyon (ayarlar betiğin başındadır)
run_comparisons;           % tanımlı parametre taramalarını çalıştırır
replot_results;            % kaydedilmiş taramaların grafiklerini yeniden çizer
```

Gereksinim: Octave `signal` paketi (`pkg load signal`, otomatik yüklenir).

## Önemli Algoritma Notları

- **Cross-PSD (optimized):** `S_cross = fft(c1, nfft) .* conj(fft(c2, nfft)) / (fs·M)`, tek taraflıya çevrilip DC hariç ×2. nfft = `2^nextpow2(2·(N - settling) - 1)` (radix-2). Eski xcorr+ifftshift+fft zincirine eşdeğer, çok daha hızlı.
- **İterasyon döngüsü:** DUT faz gürültüsü bir kez üretilir (`x_dut` sabit); referanslar her iterasyonda yeniden üretilir → korelasyonsuz gürültü söner.
- **Faz detektörü:** `x_dut · x_ref` → LPF (butter, `lpf_cutoff/lpf_order`, katsayılar döngü dışında) → `/K_pd` (`K_pd = A²/2`) → settling atılır → DC atılır.
- **sin(φ) düzeltmesi:** `P = Σ|S_cross|·df`; `σ² = -0.5·ln(1-2P)`; `correction_factor = σ²/P`; `S_corrected = S·correction_factor`.
- **Hata metriği:** cross-PSD ile DUT FFT periodogramı ortak log-frekans ekseninde (200 nokta, interp) karşılaştırılır; `mean_absolute_error_fft_db` = ortalama |Δ| dB. NaN'lar maskelenir.
- **DUT RMS ayarı:** `generate_phase_noise` normalize edip `phase_rms` ile ölçekler; N **çift** olmalı.

## Alınan Kararlar (Karar Günlüğü)

1. **xcorr → doğrudan FFT cross-spektrumu** (2026-08-07): Eşdeğer sonuç, büyük hız kazancı.
2. **nfft → 2'nin kuvveti**: Asal FFT (Bluestein) yavaş; zero-padding yalnız frekansı sıkılaştırır, gücü değiştirmez.
3. **LPF katsayıları döngü dışında**: Butter tasarımı iterasyon başına tekrarlanmaz.
4. **Log-bin: max → mean**: Yorumla tutarlı gerçek ortalama güç.
5. **Welch bloğu kaldırıldı**: Kullanılmıyordu, sonuç yapısını şişiriyordu.
6. **generate_phase_noise seed davranışı korundu** (per-call seed) — README'de de not edildi; kırılmasına izin verilmedi.
7. Aktif klasörde otomatik test veya ayrı benchmark betiği yoktur.

## Dikkat / Bilinen Noktalar

- `generate_phase_noise` zaman bazlı seed kullandığı için aynı config ile aynı run'ı birebir tekrarlamaz (istatistiksel test için istenen davranış).
- `lowpass_filter.m` optimize klasörde **yok**; butter+filter artık `run_simulation` içinde.
- Orijinal klasördeki `results.dut_welch.*` çıktıları optimized'ta mevcut değil.
- `N <= settling_samples` ve tek N durumlarında hata verilir (dokümante edildi).
- Çalışma dizini, her iki klasörü ve kökteki yardımcı `*.m` dosyalarını içeren `Octave/` köküdür (AWGN, pinknoise vb. bağımsız araçlar).

## Yapılacaklar / Açık Sorular

- [ ] FFT hız kazancını tekrarlanabilir bir benchmark betiğiyle sayısal olarak kaydet.
- [ ] Cross-PSD ile DUT FFT hata metriğinin düşük RMS'lerde (ör. 0.05 rad) davranışı doğrulandı mı?
- [ ] İstenirse `run_simulation`'a Welch karşılaştırması geri eklenebilir (kaldırıldı).

## Karşılaştırma Koşu Çerçevesi (2026-08-07)

Farklı parametre verileriyle simülasyonu koşturup karşılaştıran ve **ham veriyi kalıcı kaydeden** çerçeve. Optimized klasörüne eklenen dosyalar:

```
run_comparisons.m        → giriş betiği (proje yolunu ekler, koşuyu başlatır)
run_comparisons_main.m   → DEFAULT PARAMETRELER + tarama listeleri + koşu mantığı
replot_results.m         → ham veriden grafikleri yeniden çizen giriş betiği
replot_results_main.m    → raw .mat dosyalarını yükleyip yeniden çizer
plot_sweep_results.m     → tarama değerlerini üst üste çizen karşılaştırma grafiği
run_single.m             → tek koşu grafiği (cross-PSD + DUT FFT)
```

Çalıştırma: `run("O:\phasedetector with cross correlation optimized\run_comparisons.m")`. Grafikleri sonradan çizmek için aynı şekilde `replot_results.m`.

Çıktı düzeni: `results/<yyyymmdd_HHMMSS>_<tarama>/` altında `raw/run_NN_<tarama>_<deger>.mat` (tam sonuç yapısı), `plots/*.png`, `summary.mat`, `summary.csv`. Ham veri hem tekrar hesaplama hem tekrar çizim için yeterlidir (config dahil saklanır).

### Taramalar (run_comparisons_main.m "KOŞULACAK TARAMALAR" bölümü)

- Sabitler: `N=1000000`, `fs=1e6`, `A=1`, `f0=50e3`, `settling_samples=600`, `lpf_order=4`.
- `lpf_cutoff` = [5k, 10k, 25k, 50k] Hz; `rms_dut` ve `rms_ref` = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5]; `iterations` = [1, 10, 50, 100, 200, 300]; `log_bins` = [10, 25, 50, 80, 100, 200]. Orijinal değer her listede grafikte "(orig)" işaretlenir.

### Ağ sürücüsü notu

- Güncel giriş betiklerinde yerel yansıma (mirror) uygulanmaz; `run_comparisons.m` ve `replot_results.m` doğrudan proje yolunu `addpath` ile ekler.
- PNG üretiminde kullanılabilir grafik backend'ine ihtiyaç vardır; `plot_sweep_results` kaydetme hatasını uyarı olarak bildirir.
- Proje klasörü `O:` sürücüsü olarak da haritalanmıştır (`net use O: \\kutu\users\staj\92010866\Desktop\Octave /persistent:yes`).

### Karar günlüğü ekleri

8. Güncel aktif kaynakta yerel yansıma mimarisi bulunmaz; bu konu gelecekte ortam sorunu olarak yeniden değerlendirilmelidir.
9. PNG üretimi grafik backend'ine bağlıdır; kaydetme hatası simülasyon sonucunu durdurmaz.
