# Memory Bank: Phase Noise Cross-Correlation

Son güncelleme: 2026-08-24

Bu dosya oturumlar arası teknik handoff kaydıdır. Yeni bir oturumda önce kök
`README.md`, sonra bu dosya okunmalıdır. Ayrıntılı kullanım ve config sözleşmesi
aktif klasörün `README.md` dosyasındadır.

## Iletisim Tercihi

- Matematiksel formuller kullaniciya aciklanirken KaTeX uyumlu blok biciminde
  `$$ ... $$` ile yazilmalidir; `\[ ... \]` bicimi kullanilmamalidir.

## Aktif Kapsam

Tek aktif çalışma alanı:

```text
phasedetector with cross correlation optimized/
```

Kurallar:

- Yeni kod ve deney yalnız aktif klasörde yapılır.
- `phasedetector with cross correlation/` legacy referanstır; açık istek
  olmadan değiştirilmez.
- Kök `AWGN.m`, `phasenoise.m`, `pinknoise.m` ve benzeri dosyalar aktif akışın
  runtime bağımlılığı değildir.
- `results/`, `.mat`, görseller ve ZIP yedekleri Git'e gönderilmez.
- `.opencode/` opsiyonel geliştirme aracıdır; simülasyon bağımlılığı değildir.

## Projenin Amacı

GNU Octave üzerinde iki bağımsız referans kanallı faz detektörü modellemek ve
kompleks Cross-PSD ortalamasıyla ortak DUT faz gürültüsünü tahmin etmek.
Kanallara özgü referans gürültüsünün iterasyon sayısıyla bastırılması, tahminin
filtresiz DUT periodogram ortalamasıyla karşılaştırılması ve parametre
sweep'lerinin kalıcı olarak incelenmesi hedeflenir.

## Güncel Mimari

```text
run_single / run_comparisons / run_iterations
  -> run_simulation
     -> validate_config
     -> generate_phase_noise (DUT)
     -> measure_iteration
        -> generate_phase_noise (Ref1, Ref2)
        -> mixer
        -> lowpass_filter
        -> remove_dc
        -> compute_cross_psd
     -> compute_periodogram (DUT)
     -> kompleks/lineer iterasyon ortalamaları
     -> sin(phi) güç düzeltmesi
     -> logbin_phase_noise
     -> MAE hesabı
```

Sweep ve tekrar çizim:

```text
run_comparisons / run_iterations
  -> run_comparisons_main
     -> run_simulation
     -> raw MAT + summary MAT/CSV + comparison PNG

extend_iteration_results
  -> extend_iteration_results_main
     -> tamamlanmış iteration sweep'lerini doğrula ve birleştir
     -> yalnız eksik iteration değerlerini çalıştır

replot_results
  -> replot_results_main
     -> summary/raw yükle
     -> plot_sweep_results
```

## Aktif Dosya Sorumlulukları

| Dosya | Sorumluluk |
|---|---|
| `run_simulation.m` | Ana simülasyon ve sonuç sözleşmesi |
| `measure_iteration.m` | Tek iterasyondaki iki kanalın işlem sırası |
| `generate_phase_noise.m` | Zaman seed'li `1/f^3` faz gürültüsü |
| `mixer.m` | DUT ile referansların çarpımı |
| `lowpass_filter.m` | Cache'li Butterworth LPF |
| `compute_cross_psd.m` | FFT tabanlı kompleks tek taraflı Cross-PSD |
| `compute_periodogram.m` | Filtresiz DUT PSD referansı |
| `logbin_phase_noise.m` | Log-bin ve SSB dBc/Hz |
| `validate_config.m` | 12 zorunlu config alanının doğrulanması |
| `run_comparisons_main.m` | Sweep, zamanlama ve kayıt yönetimi |
| `extend_iteration_results_main.m` | Tamamlanmış iteration sweep'lerini birleştirme |
| `plot_sweep_results.m` | Ortak ölçekli karşılaştırma figürü |
| `replot_results_main.m` | Kayıtlı sweep'in yeniden çizimi |

## Değişmemesi Gereken Algoritmik Kurallar

1. Her iterasyonda yeni DUT, Ref1 ve Ref2 realizasyonları üretilir.
2. Aynı iterasyonda iki kanal aynı DUT'u kullanır.
3. Cross-spektrum `X1 .* conj(X2) / (fs*M)` olarak hesaplanır.
4. Cross-spektrumlar kompleks alanda toplanır; büyüklük ortalamadan sonra
   alınır.
5. DUT periodogramları lineer PSD alanda toplanır ve aynı iterasyon sayısına
   bölünür.
6. FFT uzunluğu radix-2 olacak şekilde
   `2^nextpow2(2*(N-settling_samples)-1)` seçilir.
7. Faz detektörü kazancı `K_pd=A^2/2` ile normalize edilir.
8. Log-bin içinde tepe değil aritmetik ortalama kullanılır.
9. Welch sonucu aktif sözleşmenin parçası değildir.
10. `results.dut_fft_unfiltered`, `results.dut_fft` ile aynı verinin alias'ıdır.

Bu kurallardan biri değişirse sonuç karşılaştırmaları artık doğrudan eski
koşularla eşdeğer kabul edilmemeli ve `CHANGES.md` güncellenmelidir.

## Güncel Runner Profilleri

Tek bir ortak varsayılan profil yoktur.

### `run_single.m`

```text
N=100000, fs=1e6, A=1, f0=200e3
settling=100, LPF=50e3/order 4
DUT RMS=0.2, Ref RMS=0.5/0.5
iterations=200, log bins=100
```

### `run_comparisons.m`

```text
N=1000000, fs=1e6, A=1, f0=200e3
settling=0, LPF=200e3/order 4
DUT RMS=0.05, Ref RMS=0.05/0.05
iterations=100, log bins=100
```

Sweep listeleri:

```text
lpf_cutoff: [1k, 5k, 10k, 25k, 50k, 75k, 100k, 200k, 300k] Hz
rms_dut:    [0.01, 0.02, 0.05, 0.1, 0.2, 0.5] rad
rms_ref:    [0.01, 0.02, 0.05, 0.1, 0.2, 0.5] rad
iterations: [1, 10, 100, 200, 500, 1000]
log_bins:   [10, 25, 50, 80, 100, 200]
```

Her liste bağımsız tek-parametre sweep'idir; Cartesian ürün değildir.

### `run_iterations.m`

```text
N=100000, fs=1e6, A=1, f0=200e3
settling=0, LPF=50e3/order 4
DUT RMS=0.02, Ref RMS=0.1/0.1
iterations marker=100, log bins=100
sweep=[1,10,100,500,1000,2000,5000,10000,20000]
```

## Sonuç ve Metrik Sözleşmesi

- `results.cross.psd`: kompleks, ortalanmış ve düzeltme uygulanmış tam
  çözünürlüklü Cross-PSD.
- `results.dut_fft.psd`: aynı koşulardaki filtresiz DUT periodogramlarının
  lineer ortalaması.
- `correction_factor`: ortalama Cross-PSD büyüklüğünden hesaplanan `sin(phi)`
  güç düzeltmesi.
- `mean_absolute_error_fft_db`: iki log-bin eğrinin ortak frekans aralığında
  200 logaritmik noktadaki ortalama mutlak dB farkı.
- MAE ve düzeltme hesabı şu anda LPF kesimiyle maskelenmez.

Sweep çıktısı:

```text
results/<timestamp>_<sweep>/
├── raw/run_<NN>_<sweep>_<value>.mat
├── plots/<sweep>_comparison.png
├── summary.mat
└── summary.csv
```

Ham MAT dosyası config ve tam spektrumu içerir, fakat Git commit'i, Octave
sürümü, signal paket sürümü veya RNG seed dizisini içermez.

## Karar Günlüğü

### 2026-08-07

- `xcorr -> ifftshift -> fft` zinciri doğrudan FFT cross-spektrumuna çevrildi.
- `nfft`, yavaş asal uzunluk yerine bir sonraki 2 kuvvetine yükseltildi.
- Log-bin içindeki `max` kullanımı `mean` ile değiştirildi.
- Kullanılmayan Welch sonuçları kaldırıldı.

### 2026-08-18

- Aktif akış function tabanlı hale getirildi.
- Sweep ve replot altyapısı sadeleştirildi.
- Ayrı benchmark ve eski wrapper scriptleri kaldırıldı.

### 2026-08-19

- DUT yalnız bir kez üretilmek yerine her iterasyonda yeniden üretilmeye
  başlandı.
- DUT periodogramları lineer ortalanarak Cross-PSD ile aynı Monte Carlo
  popülasyonu karşılaştırıldı.
- Büyük iterasyon sweep'i eklendi.

### 2026-08-20

- Mixer, LPF ve Cross-PSD ayrı blok fonksiyonlarına taşındı.
- LPF katsayı cache'i `lowpass_filter.m` içinde toplandı.
- Kök README, aktif kullanım kılavuzu ve handoff dokümanları güncel kodla
  eşitlendi.
- Repo `main` branch'i GitHub'a aktarıldı; sonuç dosyaları hariç tutuldu.

### 2026-08-21

- Genel sweep profili `N=1e6`, `f0=200 kHz`, `LPF=200 kHz` ve daha geniş LPF
  kesim listesine güncellendi.
- Eksik iteration noktaları için `run_iterations.m` profili `N=100000` ve
  `[250,500]` listesine ayarlandı.
- Tamamlanmış iteration sweep'lerini yeniden çalıştırmadan birleştiren
  `extend_iteration_results.m` ve `extend_iteration_results_main.m` eklendi.
- Güncel DOCX raporundaki 10 görsel belge içine gömülü olarak yayınlandı.

### 2026-08-24

- Tek-quadrature, I/Q ve `asin` yerleşimlerini aynı Monte Carlo girdilerinde
  karşılaştıran `iq_demod_comparison/` çalışma alanı eklendi.
- `run_single.m` profili `f0=200 kHz`, `LPF=50 kHz`, Ref RMS `0.5 rad` olarak
  güncellendi.
- `run_iterations.m` profili `LPF=50 kHz`, Ref RMS `0.1 rad` ve dokuz noktalı
  iteration listesine güncellendi.

## Bilinen Riskler

1. **RNG yeniden üretilebilir değil.** `generate_phase_noise` her çağrıda
   global RNG'yi zaman tabanlı seed ile sıfırlar. Seed alanı yalnız 100000
   değerdir ve kaydedilmez.
2. **Bağımsızlık doğrulanmadı.** Ref1 ve Ref2 ayrı çağrılardır ancak seed
   çakışmasına karşı otomatik korelasyon testi yoktur.
3. **Metrik bandı geniş.** MAE, LPF dışındaki bastırılmış bölgeyi de kapsar.
4. **Settling profilleri farklı.** Tek koşu 100 örnek atarken sweep'ler sıfır
   örnek atar.
5. **İstatistiksel kanıt sınırlı.** Sweep noktaları bağımsız tek koşulardır;
   güven aralığı veya tekrarlar raporlanmaz.
6. **Otomasyon yok.** Unit test, CI, paket sürüm kilidi ve kontrollü benchmark
   bulunmaz.
7. **Kısmi sonuç mümkün.** Sweep yarıda kesilirse raw dosyalar kalır fakat
   summary/plot oluşmayabilir.
8. **MATLAB uyumluluğu yok.** Aktif çalışma ortamı GNU Octave'dır.

## Öncelikli Sonraki İşler

1. Config'e üst seviye kontrollü RNG seed'i ekle; DUT/Ref alt akışlarını ayrı
   substream/seed'lerle üret ve provenance bilgisini raw/summary dosyalarına
   kaydet.
2. Ref1/Ref2 ve DUT/ref korelasyonlarını ölçen otomatik bağımsızlık testi ekle.
3. Tek taraflı PSD normalizasyonu, kompleks-before-magnitude ortalama ve RMS
   normalizasyonu için küçük deterministik testler ekle.
4. MAE için fiziksel olarak anlamlı bir ölçüm bandı tanımla; LPF geçiş ve
   stop-band etkisini metrikten ayır.
5. `settling_samples` varsayılanını tüm runner'larda tutarlı ve filtre derecesi
   ile gerekçeli hale getir.
6. Aynı ham spektrum üzerinde log-bin sayılarını karşılaştır; her bin değeri
   için yeni rastgele veri üretme etkisini ayır.
7. Rapor için seçilmiş CSV/PNG kanıtlarını Git tarafından izlenen ayrı bir
   dizine taşı ve commit/config/Octave sürümü manifesti ekle.
8. Eski ve yeni Cross-PSD yollarını aynı deterministik dizilerle karşılaştıran
   benchmark/eşdeğerlik testi oluştur.

## Yeni Oturum Handoff Kontrolü

```text
[ ] git status ve son commit kontrol edildi
[ ] kök README ve bu dosya okundu
[ ] yalnız optimized klasör aktif kabul edildi
[ ] değiştirilecek runner profilinin değerleri doğrulandı
[ ] küçük smoke test config'i hazırlandı
[ ] sonuç yapısı değişecekse plot/replot etkisi değerlendirildi
[ ] üretilen results dosyalarının Git'e girmediği kontrol edildi
[ ] algoritma kararı değiştiyse CHANGES ve README güncellendi
```

## Ortam Notu

Repo bir ağ paylaşımında olabilir; dokümanlarda sürücü harfi veya kullanıcıya
özel mutlak yol kullanılmamalıdır. Giriş betikleri yollarını kendi
`mfilename("fullpath")` değerlerinden türetir ve aktif klasörü path'e ekler.
PNG kaydı grafik backend'ine bağlıdır ve hata halinde simülasyon sonuçları yine
üretilebilir.
