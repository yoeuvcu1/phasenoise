# MATLAB R2025b sürümü

Bu klasör, üst dizindeki optimized kaynakların MATLAB R2025b uyumlu kopyasıdır.
Üst dizindeki özgün dosyalar değiştirilmemiştir.

Kaynak senkron noktası: `0799f9f` (`Add iteration merge workflow and update report`).

MATLAB'a özgü uyarlamalar:

- Octave `pkg load signal` bloğu kaldırıldı; Signal Processing Toolbox kullanılır.
- Octave `time()` tabanlı her-çağrıda seed yerine MATLAB random stream'i bir kez
  `rng("shuffle")` ile başlatılır.
- Ham sonuçlar ve özetler `-v7.3` MAT biçiminde kaydedilir.
- PNG grafikleri `exportgraphics` ile 150 DPI kaydedilir.
- Uzun otomatik koşularda pencereler açık kalmasın diye `show_figures=false` olur;
  bütün grafikler yine `results/.../plots/` altına yazılır.
- Uzun iterasyon profilinde örnek sayısı, geçici hızlı testte kullanılan
  `100000` yerine nihai rapor koşusu için `1000000` olarak ayarlanmıştır.
- Nihai iterasyon listesi, güncel rapor akışıyla uyumlu olarak
  `[1, 10, 100, 250, 500, 1000, 5000, 10000, 20000]` değerlerini kullanır.

Çalıştırma sırası:

1. `run_comparisons`
2. İlk betik tamamen bittikten sonra `run_iterations`

Her iki betik de sonuçlarını bu klasördeki `results/` dizisine yazar.

`run_comparisons.m` güncel repo profilini korur: `N=1000000`, `f0=200 kHz`,
varsayılan LPF `200 kHz`, DUT/Ref RMS `0.05/0.05 rad` ve 100 iterasyon.
`run_iterations.m` ise `N=1000000`, LPF `100 kHz`, DUT RMS `0.02 rad` ve
Ref RMS `0.05/0.05 rad` kullanır.

## Güncel pipeline

İki koşuyu aynı MATLAB oturumunda sırasıyla çalıştırmak için:

```matlab
run_latest_matlab_pipeline
```

Başarılı tamamlanma sonunda `LATEST_PIPELINE_COMPLETE.txt` üretilir. Ham MAT
dosyaları çok büyük olduğu için `results/` Git dışında tutulur; raporda
kullanılan özet CSV'ler ayrıca `report_assets/final_results/` altına alınır.

## Teknik rapor

Repo kökündeki `İki Kanallı Cross.docx` değiştirilmeden, doğrulanmış sonuçlarla
geliştirilmiş rapor şu komutla oluşturulur:

```bash
python3 report_assets/build_report.py
```

Oluşturucu, beş karşılaştırma taramasındaki CSV/MAT/config/PNG zincirini ve en
yeni dokuz noktalı `N=1000000` uzun yineleme koşusunu doğrulamadan çıktı yazmaz.
Nihai dosya `Iki_Kanalli_Cross_PSD_Faz_Gurultusu_Raporu.docx` adını taşır.
Gerekli Python paketleri `python-docx`, `Pillow` ve `h5py` paketleridir.
