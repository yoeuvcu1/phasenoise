# Sunum için FFT ve korelasyon grafikleri

Bu klasördeki MATLAB scripti, analizör zincirinin istenen aşamalarını bağımsız
grafikler halinde üretir. Ara aşamaların tamamı frekans domenindedir; yalnız
DUT ile iki referansın birlikte gösterildiği grafik zaman domenindedir.

## Çalıştırma

MATLAB'da proje kökünden:

```matlab
plot_dir = fullfile(pwd, ...
    "phasedetector with cross correlation optimized", ...
    "matlab_version", "presentation_signal_flow_plots");
run(fullfile(plot_dir, "generate_signal_flow_plots.m"));
```

Script, ana `matlab_version` klasöründeki mixer, LPF, periodogram ve Cross-PSD
fonksiyonlarını kullanır. FFT eğrileri, dar taşıyıcı tepeleri korunarak 250 Hz
kayan güç ortalamasıyla yumuşatılır ve PNG'de kalın bir bant oluşmaması için en
fazla 12.000 çizim noktasına seyreltilir. Grafikler `output/` altına 1050×900
PNG olarak kaydedilir.

## Çıktılar

- `01_dut_fft_spektrumu.png`: DUT FFT spektrumu
- `02_referans_fft_spektrumu.png`: birinci referansın FFT spektrumu
- `03_dut_ve_referanslar_zaman.png`: DUT, Ref1 ve Ref2, 10 µs zaman penceresinde
- `04_mixer_cikisi_fft_spektrumu.png`: birinci mixer çıkışının FFT spektrumu
- `05_islenmis_sinyal_fft_spektrumu.png`: LPF, `/K_pd`, clip ve `asin` sonrası
  FFT spektrumu; `f_cutoff` dikey çizgiyle işaretlidir
- `06_korelasyon_1_iterasyon.png`: 1 iterasyonda Cross-PSD ve DUT periodogramı
- `07_korelasyon_50_iterasyon.png`: 50 iterasyonda Cross-PSD ve DUT periodogramı
- `run_summary.txt`: koşu ayarları ve doğrulama özeti

İki korelasyon grafiği aynı deterministik, birikimli koşunun 1. ve 50.
iterasyon kontrol noktalarından üretilir ve tam olarak 100 log-bin kullanır.
