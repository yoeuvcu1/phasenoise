# MATLAB Version

Bu klasor, ust dizindeki aktif Cross-PSD simulasyonunun MATLAB uyumlu
kopyasidir. Eski MATLAB deneyleri, rapor araclari ve iteration yardimcilari bu
surume dahil edilmemistir.

## Gereksinimler

- MATLAB R2021a veya daha yeni bir surum
- Signal Processing Toolbox (`butter` fonksiyonu icin)

## Calistirma

Tek kosu:

```matlab
run_single
```

Parametre taramalari:

```matlab
run_comparisons
```

Yalniz iteration taramasi:

```matlab
run_iterations
```

Bir taramayi kapatmak icin `run_comparisons.m` icindeki ilgili alani bos dizi
yapin. Satiri yorumlayarak kaldirmayin:

```matlab
test_values.iterations = [];
```

Tarama sonuclari bu klasorde olusan `results/` altina yazilir. Ust dizindeki
Octave `results/` klasoru ayri kalir ve MATLAB calismalarindan etkilenmez.

## MATLAB Uyarlamalari

- Octave `pkg load signal` blogu yoktur; Signal Processing Toolbox kullanilir.
- Octave `time()` yerine global MATLAB RNG ilk kullanimda `rng("shuffle")` ile
  baslatilir ve sonraki uretimler ayni stream'den devam eder.
- Ham spektrumlar ve ozetler buyuk dizileri desteklemek icin `-v7.3` olarak
  kaydedilir.
- Zaman damgasi `datetime` ile, PNG ciktilari `exportgraphics` ile uretilir.

Simulasyon matematigi, config degerleri ve sonuc yapisi ust dizindeki aktif
surumle aynidir. `correction_factor` uygulanmaz.
