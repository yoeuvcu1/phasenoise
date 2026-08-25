# Phase Noise Cross-Correlation Simulation

GNU Octave ile iki kanallı cross-correlation/Cross-PSD faz gürültüsü ölçümünü
simüle eden araştırma projesi.

> **Aktif geliştirme alanı:**
> [`phasedetector with cross correlation optimized/`](phasedetector%20with%20cross%20correlation%20optimized/)
>
> Yeni kod, deney ve dokümantasyon çalışmaları yalnız bu klasörde yapılır.
> `phasedetector with cross correlation/` geçmiş karşılaştırmaları için tutulan
> legacy koddur.

## Amaç

Model, aynı DUT sinyalini kullanan iki ölçüm kanalını bağımsız referanslarla
karıştırır. Kanalların kompleks cross-spektrumları çok sayıda Monte Carlo
iterasyonu boyunca lineer alanda ortalanır. Amaç, ortak DUT faz gürültüsünü
korurken kanallara özgü referans gürültüsünü ortalamayla bastırmaktır.

Aktif akış şu işlemleri uygular:

```text
DUT + Ref1/Ref2 üretimi
  -> iki mixer kanalı
  -> Butterworth LPF
  -> faz detektörü kazanç normalizasyonu
  -> settling ve DC kaldırma
  -> kompleks Cross-PSD
  -> iterasyon ortalaması
  -> sin(phi) güç düzeltmesi
  -> log-bin ve DUT periodogramı karşılaştırması
```

## Gereksinimler

- GNU Octave
- Octave `signal` paketi (`butter` ve filtreleme için)
- Grafik üretilecekse kullanılabilir bir Octave graphics toolkit

Paket kurulumu yalnız ilk kez gerekir:

```matlab
pkg install -forge signal
```

`run_simulation.m`, Octave altında `signal` paketini ilk çağrıda otomatik
yükler. Aktif kod Octave'a özgü `time()` ve MAT kayıt seçenekleri kullandığı
için MATLAB desteği şu anda doğrulanmış değildir.

## Hızlı Başlangıç

Octave'ı repo kökünde açın ve tek koşu betiğini çalıştırın:

```matlab
active_dir = fullfile(pwd, "phasedetector with cross correlation optimized");
run(fullfile(active_dir, "run_single.m"));
```

Varsayılan tek koşu `N=100000` ve `200` iterasyon kullanır. Daha kısa bir
kontrol için `run_single.m` içindeki değerleri geçici olarak küçültün veya
aktif klasör README'sindeki küçük doğrudan API örneğini kullanın.

## Giriş Noktaları

| Dosya | Kullanım | Kalıcı çıktı |
|---|---|---|
| `run_single.m` | Tek config çalıştırır ve iki spektrumu çizer | Yok; `results` workspace'te kalır |
| `run_comparisons.m` | LPF, RMS, iterasyon ve log-bin taramaları | `results/` altında MAT, CSV ve PNG |
| `run_iterations.m` | Büyük iterasyon sayısı taraması | `results/` altında MAT, CSV ve PNG |
| `replot_results.m` | Kayıtlı bir sweep'i simülasyonsuz yeniden çizer | Karşılaştırma PNG'si |
| `run_simulation.m` | Programatik API: `results = run_simulation(config)` | Yok |

Parametre şeması, üç giriş betiğinin farklı varsayılan profilleri, çıktı
alanları ve yeniden çizim kullanımı için
[aktif uygulama kılavuzuna](phasedetector%20with%20cross%20correlation%20optimized/README.md)
bakın.

## Repo Yapısı

```text
.
├── README.md
├── MEMORY_BANK.md
├── CHANGES.md
├── phasedetector with cross correlation optimized/   # aktif uygulama
├── phasedetector with cross correlation/             # legacy referans
├── *.m                                               # eski/bağımsız deney araçları
└── .opencode/                                        # opsiyonel geliştirme desteği
```

- `MEMORY_BANK.md`: sonraki çalışma oturumu için güncel durum, kararlar,
  riskler ve öncelikli işler.
- `CHANGES.md`: projenin kronolojik değişiklik kaydı.
- Kök `*.m` dosyaları aktif optimize akışın runtime bağımlılığı değildir.
- `.opencode/` opsiyonel araç dokümanıdır; simülasyonu çalıştırmak için gerekli
  değildir.

## Sonuç Politikası

Sweep çıktıları aktif klasördeki `results/` dizinine yazılır. Bu dizin,
`.mat`, görsel ve arşiv dosyaları Git'e gönderilmez. Kaynak kod, Markdown
dokümanları ve metin tabanlı yapılandırmalar izlenir.

Bu nedenle temiz bir clone:

- geçmiş yerel deneylerin ham MAT/PNG dosyalarını içermez;
- `replot_results.m` kullanmadan önce yerel bir sweep sonucu gerektirir;
- rapordaki tarihli sonuçları koddan yeniden üretebilir, ancak mevcut zaman
  tabanlı RNG nedeniyle aynı bit düzeyinde sonucu garanti etmez.

## Mevcut Sınırlar

- RNG her faz gürültüsü çağrısında zaman tabanlı yeniden seed edilir; koşular
  birebir tekrarlanamaz ve seed bilgisi sonuç dosyasına kaydedilmez.
- Otomatik test ve kontrollü performans benchmark'ı yoktur.
- MAE şu anda LPF geçiş bandıyla sınırlandırılmadan ortak pozitif frekans
  aralığının tamamında hesaplanır.
- Sweep'ler seri çalışır; büyük iterasyon listeleri uzun sürebilir.
- `run_single.m`, `run_comparisons.m` ve `run_iterations.m` farklı parametre
  profilleri kullanır.

## Devam Etme

Yeni bir çalışma oturumunda sırasıyla:

1. `README.md` ve `MEMORY_BANK.md` dosyalarını okuyun.
2. `git status` ile çalışma ağacını kontrol edin.
3. Yalnız `phasedetector with cross correlation optimized/` altında çalışın.
4. Önce küçük bir `run_simulation` smoke testi yapın.
5. Algoritmik değişikliklerde `MEMORY_BANK.md` ve `CHANGES.md` dosyalarını aynı
   commit içinde güncelleyin.

## Lisans

Bu repoda henüz açık bir lisans tanımlanmamıştır. Lisans eklenene kadar kodun
yeniden dağıtım ve kullanım hakları ayrıca değerlendirilmelidir.
