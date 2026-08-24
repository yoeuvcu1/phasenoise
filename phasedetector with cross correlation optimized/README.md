# Optimized Cross-PSD Phase-Noise Simulation

Bu klasör projenin **tek aktif uygulama ve geliştirme alanıdır**. Yeni deney,
algoritma değişikliği ve sonuç üretimi burada yapılır. Kök dizindeki benzer
scriptler ve `phasedetector with cross correlation/` klasörü yalnız tarihsel
referanstır.

## Çalışma Modeli

Her Monte Carlo iterasyonunda yeni bir DUT, Ref1 ve Ref2 faz gürültüsü
realizasyonu üretilir. Aynı DUT iki kanalda ortaktır; referanslar ayrı üretici
çağrılarıyla oluşturulur.

```text
DUT carrier ------------------+--> mixer(DUT, Ref1) --> LPF --> /K_pd --+
                              |                                        |
                              +--> mixer(DUT, Ref2) --> LPF --> /K_pd --+--> Cross-PSD

Her iterasyon:
  kompleks Cross-PSD toplamı + filtresiz DUT periodogram toplamı

Tüm iterasyonlardan sonra:
  lineer ortalama -> sin(phi) düzeltmesi -> log-bin -> dBc/Hz -> MAE
```

Önemli kurallar:

- `K_pd = A^2/2`.
- LPF nedensel Butterworth `filter` çağrısıdır; `filtfilt` kullanılmaz.
- LPF katsayıları ayarlar değişmediği sürece `lowpass_filter.m` içinde cache
  edilir.
- Kompleks cross-spektrumlar önce ortalanır, büyüklük daha sonra alınır.
- DUT karşılaştırması, aynı iterasyonlardaki filtresiz DUT
  periodogramlarının lineer ortalamasıdır.
- FFT uzunluğu `2^nextpow2(2*(N-settling_samples)-1)` olarak seçilir.
- SSB dönüşümü `10*log10(0.5*PSD)` biçimindedir.

## Gereksinimler

- GNU Octave
- Octave `signal` paketi
- PNG üretimi için kullanılabilir graphics toolkit

```matlab
pkg install -forge signal   % yalnız ilk kurulumda
pkg list                    % signal paketini kontrol et
```

`run_simulation.m`, Octave altında paketi ilk çağrıda otomatik yükler. Kod
`time()` ve `save("-mat7-binary", ...)` gibi Octave'a özgü davranışlar
kullandığı için MATLAB desteği doğrulanmış değildir.

## Giriş Noktaları

| Dosya | Amaç | Not |
|---|---|---|
| `run_single.m` | Tek simülasyon ve tek figür | Dosya kaydetmez |
| `run_comparisons.m` | Beş bağımsız tek-parametre sweep'i | Sonuçları diske kaydeder |
| `run_iterations.m` | Yalnız iterasyon sayısı sweep'i | Varsayılan liste uzun sürer |
| `extend_iteration_results.m` | Eski iteration sweep'ine değer ekler | Eski koşuları yeniden çalıştırmaz |
| `replot_results.m` | Kayıtlı sweep'leri yeniden çizer | Simülasyon çalıştırmaz |
| `iq_demod_comparison/run_iq_comparison.m` | Tek-quadrature ve I/Q detektörlerini karşılaştırır | Kalıcı dosya yazmaz |
| `iq_demod_comparison/run_asin_realization_comparison.m` | `asin` yerleşimini aynı realizasyonlarda karşılaştırır | Sabit RNG seed kullanır |
| `run_simulation.m` | Doğrudan programatik API | Tüm config alanları zorunludur |

Betikler başka bir çalışma dizininden başlatılsa da kendi klasörlerini
`addpath` ile ekler.

## Hızlı Smoke Test

Aşağıdaki küçük koşu kalıcı dosya üretmez:

```matlab
project_dir = fullfile(pwd, "phasedetector with cross correlation optimized");
addpath(project_dir);

config = struct( ...
    "N", 10000, ...
    "fs", 1e6, ...
    "A", 1, ...
    "f0", 50e3, ...
    "settling_samples", 100, ...
    "lpf_cutoff", 1e3, ...
    "lpf_order", 4, ...
    "phase_rms_dut", 0.2, ...
    "phase_rms_ref1", 0.05, ...
    "phase_rms_ref2", 0.05, ...
    "number_of_iterations", 5, ...
    "number_of_log_bins", 30);

results = run_simulation(config);
fprintf("MAE: %.3f dB | correction: %.6f\n", ...
    results.mean_absolute_error_fft_db, results.correction_factor);
```

Repo kökü dışında çalışıyorsanız `project_dir` değişkenine bu klasörün tam
yolunu verin.

## Standart Çalıştırmalar

### Tek Koşu

`run_single.m` başındaki parametreleri düzenleyin ve çalıştırın:

```matlab
run(fullfile(project_dir, "run_single.m"));
```

Varsayılan profil:

```text
N=100000, fs=1e6, f0=200e3, settling=100, LPF=50e3
DUT RMS=0.2, Ref RMS=0.5/0.5, iterations=200, log bins=100
```

Sonuç `results`, figür `fig` değişkenine gelir. Batch dizini oluşturulmaz.

### Parametre Sweep'leri

`run_comparisons.m` içindeki `default_config` ve `test_values` alanlarını
düzenleyin:

```matlab
run(fullfile(project_dir, "run_comparisons.m"));
```

Bir sweep'i kapatmak için ilgili listeyi `[]` yapın. Sweep'ler Cartesian ürün
değildir; her liste bağımsız çalışır ve yalnız kendi parametresini değiştirir.
`rms_ref`, Ref1 ve Ref2 RMS değerlerini birlikte değiştirir.

Varsayılan sweep profili:

```text
N=1000000, fs=1e6, f0=200e3, settling=0, LPF=200e3
DUT RMS=0.05, Ref RMS=0.05/0.05, iterations=100, log bins=100
LPF sweep=[1k,5k,10k,25k,50k,75k,100k,200k,300k] Hz
iteration sweep=[1,10,100,200,500,1000]
```

### Büyük İterasyon Sweep'i

```matlab
run(fullfile(project_dir, "run_iterations.m"));
```

Bu betik şu anda `N=100000`, `f0=200e3`, `LPF=50e3`, DUT RMS `0.02`, Ref
RMS `0.1/0.1` profilini ve iteration listesini kullanır:

```matlab
[1, 10, 100, 500, 1000, 2000, 5000, 10000, 20000]
```

### Mevcut Iteration Sweep'ini Genişletme

`extend_iteration_results.m` içindeki temel sonuç klasörünü, içe aktarılacak
tamamlanmış koşuları ve gerekirse yeni değerleri düzenleyin:

```matlab
BASE_RESULTS_SUBFOLDER = "20260821_122201830_iterations";
IMPORT_RESULTS_SUBFOLDERS = {"20260821_145005070_iterations"};
NEW_ITERATION_VALUES = [2500];
```

Ardından betiği çalıştırın:

```matlab
run(fullfile(project_dir, "extend_iteration_results.m"));
```

İçe aktarılan veya temel klasörde zaten bulunan değerler yeniden simüle
edilmez. Yalnız eksik `NEW_ITERATION_VALUES` değerleri çalıştırılır. Kaynak
klasörler korunur; birleşik raw dosyaları, özet ve grafik yeni bir
`<timestamp>_iterations_merged` klasörüne yazılır. İçe aktarılacak bir koşunun
`summary.mat` dosyası oluşmadan, yani koşu tamamlanmadan birleştirme yapılmaz.

## Config Sözleşmesi

`run_simulation(config)` varsayılan değer doldurmaz. Aşağıdaki 12 alanın
tamamı gereklidir:

| Alan | Anlam | Temel doğrulama |
|---|---|---|
| `N` | Örnek sayısı | Pozitif ve çift tamsayı |
| `fs` | Örnekleme frekansı, Hz | Pozitif |
| `A` | Taşıyıcı genliği | Sıfır olamaz |
| `f0` | Taşıyıcı frekansı, Hz | `0 < f0 < fs/2` |
| `settling_samples` | Atılacak LPF geçici rejim örneği | Tamsayı, `0 <= value <= N-2` |
| `lpf_cutoff` | LPF kesim frekansı, Hz | Nyquist altında ve `lpf_cutoff < 2*f0` |
| `lpf_order` | Butterworth derecesi | Pozitif tamsayı |
| `phase_rms_dut` | DUT faz RMS, rad | Negatif olamaz |
| `phase_rms_ref1` | Ref1 faz RMS, rad | Negatif olamaz |
| `phase_rms_ref2` | Ref2 faz RMS, rad | Negatif olamaz |
| `number_of_iterations` | Monte Carlo ortalama sayısı | Pozitif tamsayı |
| `number_of_log_bins` | Logaritmik bin sayısı | En az 2 tamsayı |

LPF kesimi ayrıca sıfır dolgulu FFT ızgarasında en az iki pozitif frekans
noktası bırakmalıdır. Ayrıntılı kurallar `validate_config.m` içindedir.

## Dosya Sorumlulukları

| Dosya | Sorumluluk |
|---|---|
| `run_simulation.m` | Ana akış, iterasyon ortalaması, düzeltme, binleme ve sonuç yapısı |
| `validate_config.m` | Config alan ve sınır kontrolleri |
| `measure_iteration.m` | Tek iterasyondaki iki ölçüm kanalını bağlar |
| `generate_phase_noise.m` | `1/f^3` spektrum şekillendirme ve RMS normalizasyonu |
| `mixer.m` | DUT ve iki referans taşıyıcının çarpımı |
| `lowpass_filter.m` | Butterworth tasarımı, cache ve iki kanalın filtrelenmesi |
| `compute_cross_psd.m` | Kompleks, tek taraflı FFT Cross-PSD |
| `compute_periodogram.m` | Tek taraflı DUT periodogramı |
| `logbin_phase_noise.m` | Pozitif frekans log-bin ve dBc/Hz dönüşümü |
| `remove_dc.m` | Kolon ortalamasını çıkarır |
| `run_comparisons_main.m` | Sweep yürütme, zamanlama ve kayıt yönetimi |
| `plot_sweep_results.m` | Ortak eksenli subplot karşılaştırması ve PNG |
| `replot_results_main.m` | Summary/raw dosyalarını yükleyip yeniden çizme |

## Sonuç Sözleşmesi

`run_simulation` şu ana alanları döndürür:

```text
results.config
results.correction_factor
results.mean_absolute_error_fft_db

results.cross.frequency
results.cross.psd
results.cross.frequency_binned
results.cross.phase_noise_binned

results.dut_fft.frequency
results.dut_fft.psd
results.dut_fft.frequency_binned
results.dut_fft.phase_noise_binned
results.dut_fft.number_of_averages

results.dut_fft_unfiltered   # results.dut_fft alias'ı
```

`cross.psd` kompleks ve düzeltilmiş tam çözünürlüklü Cross-PSD'dir.
`dut_fft.psd`, her iterasyonda üretilen DUT periodogramlarının lineer
ortalamasıdır. Tek tek zaman dizileri saklanmaz.

MAE, iki log-bin eğrisinin ortak frekans aralığında 200 logaritmik noktaya
interpolasyonu sonrası ortalama mutlak dB farkıdır. Ölçüm bandı şu anda LPF
kesimiyle sınırlandırılmaz.

## Sweep Çıktıları

```text
results/
└── <yyyymmdd_HHMMSSFFF>_<sweep>/
    ├── raw/
    │   └── run_<NN>_<sweep>_<value>.mat
    ├── plots/
    │   └── <sweep>_comparison.png
    ├── summary.mat
    └── summary.csv
```

`raw/*.mat` içinde `current_results`, `elapsed_seconds_current` ve sweep
değeri bulunur. `summary.csv` sütunları:

```csv
run_file,value,mean_abs_error_db,correction_factor,elapsed_s
```

`results/` Git tarafından tamamen ignore edilir. Yarım kalan bir sweep raw
dosyalar bırakabilir; summary ve karşılaştırma grafiği ancak sweep tamamlanınca
yazılır.

## Kayıtlı Sonucu Yeniden Çizme

`replot_results.m` içindeki `RESULTS_SUBFOLDER` değerini yerel sonuç klasörüne
ayarlayın:

```matlab
RESULTS_SUBFOLDER = "20260820_081605998_iterations";
```

Sonra:

```matlab
run(fullfile(project_dir, "replot_results.m"));
```

Doğrudan fonksiyon çağrısı da kullanılabilir:

```matlab
replot_results_main("20260820_081605998_iterations", false, project_dir);
```

`RESULTS_SUBFOLDER = ""` tüm yerel alt klasörleri dener. Eksik
`summary.mat` içeren yarım koşular bu modu durdurabileceği için tek klasör
seçmek daha güvenlidir. Temiz clone sonuç klasörü içermez.

## Bilinen Sınırlar

- `generate_phase_noise` global RNG'yi her çağrıda zaman tabanlı ve 100000
  durumlu bir seed ile sıfırlar. Koşular yeniden üretilebilir değildir; yakın
  çağrılarda seed çakışması teorik olarak mümkündür.
- Ref1 ve Ref2 ayrı çağrılarla üretilse de istatistiksel bağımsızlık için
  otomatik korelasyon testi yoktur.
- Gürültü modeli yalnız RMS normalize edilmiş saf `1/f^3` modelidir.
- Periodogramlar dikdörtgen pencere kullanır; Welch ortalaması yoktur.
- Cross-PSD düzeltmesi ve MAE ortak pozitif bandın tamamını kullanır; LPF dışı
  bölge metriği etkiler.
- `run_single` settling değeri `100`, sweep betiklerinde `0` değeridir.
- Sweep'ler seri çalışır ve tüm sonuç yapıları çizime kadar bellekte tutulur.
- Otomatik test, CI ve kontrollü performans benchmark'ı yoktur.

## Güvenli Değişiklik Akışı

1. Önce küçük doğrudan API koşusuyla mevcut davranışı kaydedin.
2. Matematiksel bloğu kendi dosyasında değiştirin; orchestration dosyalarını
   yalnız akış değişiyorsa düzenleyin.
3. Aynı config ve kontrollü RNG sağlanana kadar iki rastgele koşuyu bit düzeyi
   eşdeğerlik testi olarak yorumlamayın.
4. Sonuç yapısı değişirse `plot_sweep_results.m`, `replot_results_main.m`, bu
   README ve kök `MEMORY_BANK.md` dosyasını birlikte güncelleyin.
5. `results/` çıktısını commit etmeyin; rapora girecek seçilmiş kanıtları ayrı,
   izlenen bir doküman alanında saklama kararı verin.

Projenin güncel kararları ve sonraki işler için
[`../MEMORY_BANK.md`](../MEMORY_BANK.md) dosyasına bakın.
