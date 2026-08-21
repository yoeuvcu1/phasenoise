# Rapor için doğrulanmış özet sonuçlar

Bu klasör, 21 Ağustos 2026 tarihinde MATLAB R2025b ile üretilen final rapor
koşularının küçük ve sürüm kontrolüne uygun CSV özetlerini içerir. Çok büyük ham
MAT dosyaları `matlab_version/results/` altında yerel olarak korunur ve repo
politikasına göre Git'e eklenmez.

## Parametrik karşılaştırma batch'i

Kaynak klasör öneki: `results/20260821_195439719_*`

- `comparison_lpf_cutoff.csv`
- `comparison_rms_dut.csv`
- `comparison_rms_ref.csv`
- `comparison_iterations.csv`
- `comparison_log_bins.csv`

Sabit profil: `N=1.000.000`, `fs=1 MHz`, `f0=200 kHz`, varsayılan
`LPF=200 kHz`, `DUT/Ref=0,05/0,05 rad`, temel `100` yineleme ve `100` log-bin.

## Uzun yineleme koşusu

Kaynak klasör: `results/20260821_200352497_iterations`

- `final_iterations_n1m.csv`

Sabit profil: `N=1.000.000`, `LPF=100 kHz`, `DUT=0,02 rad`,
`Ref1=Ref2=0,05 rad`, `100` log-bin ve
`[1, 10, 100, 250, 500, 1000, 5000, 10000, 20000]` yineleme.

Her CSV satırı nihai rapor oluşturulmadan önce ilgili raw MATLAB v7.3 dosyası,
config alanları ve karşılaştırma PNG'siyle doğrulanmıştır.
