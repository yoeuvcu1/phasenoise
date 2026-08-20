# Cross-PSD phase-noise comparison

## Devre blokları ve aranan ayarlar

Ana akış `run_simulation.m` dosyasındadır. Fiziksel/sayısal bloklar ayrı
fonksiyonlara bölünmüştür:

| Aranan bölüm | Dosya | İçerik |
|---|---|---|
| LPF / Butter ayarları | `lowpass_filter.m` | Butterworth katsayıları, katsayı önbelleği ve filtre uygulaması |
| Mixer | `mixer.m` | DUT ile Ref1/Ref2 taşıyıcılarının çarpımı |
| Korelasyon / Cross-PSD | `compute_cross_psd.m` | FFT tabanlı kompleks korelasyon ve tek taraflı PSD |
| Tek ölçüm iterasyonu | `measure_iteration.m` | Ref üretimi ile devre bloklarının bağlantı sırası |
| Faz gürültüsü kaynağı | `generate_phase_noise.m` | 1/f^3 şekillendirme ve RMS normalizasyonu |
| Ana simülasyon | `run_simulation.m` | İterasyon, ortalama, düzeltme, binleme ve sonuç yapısı |

Kod içindeki `%% ---------------- ... ----------------` section başlıkları,
Octave/MATLAB editöründe ilgili aşamaya hızlı geçmek için kullanılır.

## Kullanım

Octave GUI'de `run_comparisons.m` dosyasını çalıştırın. Varsayılan
simülasyon parametreleri ve tüm test listeleri bu dosyanın başındadır.
Bir testi kapatmak için ilgili `test_values` listesini `[]` yapın.

Sonuçlar `results/<timestamp>_<test>/` altında saklanır:

- `raw/`: yeniden çizim için spektrum dosyaları
- `plots/`: subplot'lu karşılaştırma grafiği
- `summary.mat` ve `summary.csv`: koşu özeti

Kayıtlı sonuçları yeniden çizmek için `replot_results.m` dosyasını
çalıştırın. Simülasyon `signal` paketini kullanır.

Faz gürültüsü üreticisinin çağrı başına zaman tabanlı seed davranışı
bilinçli olarak korunmuştur.

Tek bir config çalıştırıp grafiğini görmek için `run_single.m` içindeki
ayarları düzenleyip dosyayı Octave GUI'den çalıştırın.

```matlab
run_single
```

Yalnız iterasyon sayısını taramak için `run_iterations.m` içindeki sabit
parametreleri ve `iteration_values` listesini düzenleyip çalıştırın:

```matlab
run_iterations
```

Her iterasyonda yeni DUT, Ref1 ve Ref2 faz gürültüsü realizasyonları üretilir.
Grafikteki DUT referansı bu realizasyonların lineer periodogram ortalamasıdır;
tam çözünürlüklü ortalama `raw/*.mat` içindeki
`current_results.dut_fft.psd` alanında saklanır.
