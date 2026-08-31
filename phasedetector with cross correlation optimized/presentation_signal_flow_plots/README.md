# Sunum için FFT ve korelasyon grafikleri (GNU Octave)

Bu klasördeki Octave scripti, `matlab_version/presentation_signal_flow_plots`
içeriğinin GNU Octave uyumlu kopyasıdır. Analizör zincirinin istenen
aşamalarını bağımsız grafikler halinde üretir. Ara aşamaların tamamı frekans
domenindedir; yalnız DUT ile iki referansın birlikte gösterildiği grafik zaman
domenindedir.

## Çalıştırma

Octave'da proje kökünden:

```octave
plot_dir = fullfile(pwd, ...
    "phasedetector with cross correlation optimized", ...
    "presentation_signal_flow_plots");
addpath(plot_dir);
generate_signal_flow_plots();
```

Script, ana klasördeki mixer, LPF, periodogram ve Cross-PSD fonksiyonlarını
kullanır ve `signal` paketini otomatik yükler. FFT eğrileri, dar taşıyıcı
tepeleri korunarak 250 Hz kayan güç ortalamasıyla yumuşatılır ve PNG'de kalın
bir bant oluşmaması için en fazla 12.000 çizim noktasına seyreltilir.

## MATLAB sürümünden farklar

- `03_dut_ve_referanslar_zaman.png`, diğer grafiklerin 7:6 kareye yakın oranı
  yerine 10:6 yatay oranda (1500×900 px) çizdirilir.
- 03 grafiğinde `legend` konum isteği (`"Location", "best"`) kaldırıldı;
  varsayılan konum kullanılır.
- Octave'de `xline` olmadığı için `f_cutoff` dikey çizgisi `line` + `text`
  ile çizilir.
- Dosya, adıyla eşleşen `generate_signal_flow_plots()` ana fonksiyonu ve aynı
  dosyadaki yardımcı alt fonksiyonlardan oluşur.
- Kullanılan ortak fonksiyonların gövdeleri ana dosyada alt fonksiyon olarak da
  yer alır; çalışma sırasında başka bir `.m` dosyasının bulunmasına gerek yoktur.

## Çıktılar

- `01_dut_fft_spektrumu.png`: DUT FFT spektrumu (1050×900 px)
- `02_referans_fft_spektrumu.png`: birinci referansın FFT spektrumu (1050×900 px)
- `03_dut_ve_referanslar_zaman.png`: DUT, Ref1 ve Ref2, 10 µs zaman
  penceresinde (1500×900 px, yatay)
- `04_mixer_cikisi_fft_spektrumu.png`: birinci mixer çıkışının FFT spektrumu
- `05_islenmis_sinyal_fft_spektrumu.png`: LPF, `/K_pd`, clip ve `asin` sonrası
  FFT spektrumu; `f_cutoff` dikey çizgiyle işaretlidir
- `06_korelasyon_1_iterasyon.png`: 1 iterasyonda Cross-PSD ve DUT periodogramı
- `07_korelasyon_N_iterasyon.png`: seçilen `number_of_iterations` değerindeki
  Cross-PSD ve DUT periodogramı
- `run_summary.txt`: koşu ayarları ve doğrulama özeti

İki korelasyon grafiği aynı deterministik, birikimli koşunun 1. ve seçilen son
iterasyon kontrol noktalarından üretilir ve tam olarak 100 log-bin kullanır.
