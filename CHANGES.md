# Değişiklik Raporu: "phasedetector with cross correlation" → "phasedetector with cross correlation optimized"

Tarih: 2026-08-07
Amaç: Aynı simülasyonun hız/okunabilirlik için optimize edilmiş kopyasındaki algoritmik ve yapısal farkları belgelemek. Orijinal klasör değiştirilmedi.

> Güncel not (2026-08-19): Bu rapor 2026-08-07 durumunu belgeler. Aktif kodda
> DUT artık her iterasyonda yeniden üretilir ve DUT periodogramları ortalanır;
> güncel davranış için `MEMORY_BANK.md` dosyasına bakın.
>
> Güncel not (2026-08-20): Aktif kodun okunabilirlik refactor'unda mixer,
> Butterworth LPF ve FFT tabanlı Cross-PSD ayrı fonksiyonlara taşındı. Aşağıdaki
> "LPF run_simulation içindedir" ifadeleri yalnız 2026-08-07 durumunu anlatır.

## 1. Dosya Yapısı Farkları

| Dosya | Durum | Açıklama |
|---|---|---|
| `main.m` | Değişti | `step01_sources` yerine `run_simulation` çağırıyor, açıklamalar eklendi |
| `step01_sources.m` | Silindi | İçeriği `run_simulation.m` + `validate_config.m`'e ayrıldı |
| `lowpass_filter.m` | Silindi | Butter tasarımı `run_simulation` içine alındı, her iterasyonda tekrar tasarlama kaldırıldı |
| `run_simulation.m` | Yeni | Ana simülasyon (eski `step01_sources`'un karşılığı) |
| `validate_config.m` | Yeni | Zorunlu config alanı kontrolü |
| `benchmark_fft.m` | Yeni | Asal nfft vs 2'nin kuvveti nfft FFT hız karşılaştırması (yalnız ölçüm, kodu değiştirmez) |
| `measure_iteration.m` | Büyük değişiklik | Aşağıya bakın |
| `generate_phase_noise.m` | Küçük değişiklik | Sabitler adlandırıldı, seed modulus 10000 → 100000 |
| `logbin_psd.m` | Algoritmik değişiklik | `max(P)` → `mean(P)` |
| `test_rms_runs.m` | Parametre değişti | N: 10000 → 1000000, iterasyon: 500 → 100 |
| `compute_periodogram.m` | Aynı (yalnız yorum) | — |
| `bin_and_convert.m` | Aynı (yalnız yorum) | — |
| `psd_to_ssb.m` | Aynı (yalnız yorum) | — |
| `remove_dc.m` | Aynı (yalnız yorum) | — |
| `valid_freq_mask.m` | Aynı (yalnız yorum) | — |
| `README.md` | Geliştirildi | Boş başlık → proje tanımı |

## 2. Algoritmik Değişiklikler (Sıralı Etki)

### 2.1 Cross-PSD hesabı: `xcorr` → doğrudan FFT cross-spektrumu  ⭐ en önemli değişiklik

**Orijinal** (`measure_iteration.m`):
```
r = xcorr(channel_1, channel_2, "biased");   % 2M-1 uzunluğunda
r = ifftshift(r);
S = fft(r) / fs;                              % 2M-1 nokta
```

**Optimized**:
```
X1 = fft(channel_1, nfft);  X2 = fft(channel_2, nfft);
S = X1 .* conj(X2) / (fs * channel_length);
```

- Matematiksel olarak eşdeğer: biased xcorr'in FFT'si `X1·conj(X2)/(fs·M)` verir; ikinci form tek adımda hesaplanır.
- `xcorr` + `ifftshift` + tam uzunluk FFT zinciri kaldırıldı → büyük hız kazancı.

### 2.2 FFT boyu: asal `2M-1` → 2'nin kuvveti `2^nextpow2(2M-1)` ⭐

- Orijinal nfft = 2M-1 (çoğunlukla asal → Octave Bluestein algoritması kullanır, yavaş).
- Optimized: üstteki ilk 2'nin kuvveti → radix-2 hızlı FFT.
- Sonuç: frekans ızgarası sıkılaştı (df = fs/nfft), toplam güç değişmez (yalnızca frekans enterpolasyonu/zero-padding).
- Hız farkı `benchmark_fft.m` ile ölçülebilir.

### 2.3 LPF katsayıları döngü dışında bir kez hesaplanıyor ⭐

- Orijinal: her iterasyonda her kanal için `lowpass_filter` → 2 kez `butter` tasarımı + 2 ayrı `filter` çağrısı.
- Optimized: `b_lpf, a_lpf` ve `K_pd = A²/2` `run_simulation`'da bir kez hazırlanıp `measure_iteration`'a parametre olarak geçilir.
- Ayrıca iki kanal `[x_dut .* x_ref1, x_dut .* x_ref2]` matrisinde birleştirildi → tek `filter` çağrısı (kolon bazında vektörize).

### 2.4 İterasyon ortalaması: kayan ortalama → toplam/böl

- Orijinal: `S_avg += (S_i - S_avg) / i` (her iterasyonda bölme).
- Optimized: `S_sum += S_i`, sonunda `S_sum / number_of_iterations`. Sonuç aynı, maliyet daha düşük.
- Frekans ekseni ve toplam vektörü de döngü dışında bir kez ayrılıyor.

### 2.5 `logbin_psd`: bin gücü `max` → `mean`

- Orijinal yorum "aritmetik ortalama" dese de kod `P_binned(i) = max(P(mask))` kullanıyordu.
- Optimized: `P_binned(i) = mean(P(mask))` (yorumla tutarlı gerçek ortalama).
- dB hata metriğini etkiler (tepe değil ortalama seviye ölçülür).

### 2.6 Welch karşılaştırma bloğu kaldırıldı

- Orijinal `step01_sources` sonuçlara `results.dut_welch.*` alanlarını da ekliyordu (çizdirilmiyordu).
- Optimized'ta bu blok ve `dut_welch` çıktıları yok; çıktı yalnızca cross-PSD ve DUT FFT.

### 2.7 İnterpolasyon sağlamlaştırma

- `f_common` uç noktalarda kayan nokta taşmasına karşı `[f_min, f_max]` aralığına kıstırılıyor (`min(max(...))`).
- NaN noktalar maske ile ortalamadan çıkarılıyor; hepsi NaN ise açık hata veriliyor.

### 2.8 Diğer küçük farklar

- `generate_phase_noise`: sabitler isimlendirildi; seed modulus 10000 → 100000 (rastgelelik dönemi 10× büyüdü). Per-call seed davranışı korundu.
- `test_rms_runs`: N = 1.000.000, iterasyon = 100 (daha uzun kanal + daha az iterasyon; kaynak başına maliyet düştüğü için toplam süre dengelendi).
- `pkg load signal`: yalnızca Octave'de ve `persistent` bayrakla bir kez yükleniyor.
- Hata mesajları Türkçeleştirildi ve işlev açıklama satırları eklendi.

## 3. Değişmeyen / Korunan Davranış

- DUT faz gürültüsü döngü dışında **bir kez** üretilir; referanslar her iterasyonda yeniden üretilir (cross-correlation'ın amacı).
- sin(φ) doğrusalsızlık düzeltmesi (`sigma2 = -0.5·ln(1-2P)`, `correction_factor`) aynı.
- `psd_to_ssb` (L = 10·log10(P/2)), `valid_freq_mask` ve `remove_dc` davranışları birebir aynı.
- `main`'in varsayılan config değerleri aynı (N=100000, fs=1e6, f0=50e3, ...).
