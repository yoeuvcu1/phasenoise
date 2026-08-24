# I/Q Demodulasyon Karsilastirmasi

Bu alt klasor aktif proje dosyalarini degistirmeden mevcut tek-quadrature faz
detektoru ile I/Q demodulasyonunu ayni Monte Carlo girdileri uzerinde
karsilastirir. Klasor kendi yardimci fonksiyonlarini icerdigi icin Octave
Editor'de `run_iq_comparison.m` acilip dogrudan **Run** tusuna basilabilir.

## Degismeyen Akis

Iki yontemde su adimlar ortaktir:

```text
Ayni DUT, Ref1 ve Ref2 realizasyonlari
  -> ayni tasiyici ve ornekleme ayarlari
  -> ayni Butterworth LPF
  -> ayni settling ve DC kaldirma
  -> ayni FFT boyu ve kompleks Cross-PSD ortalamasi
  -> ayni log-bin ve SSB dBc/Hz donusumu
  -> ayni filtresiz DUT periodogrami ve MAE hesabi
```

Yalniz faz detektor blogu farklidir.

## Faz Detektorleri

Mevcut yontem quadrature referansla tek mixer kullanir:

```text
Q = LPF{DUT * Ref_quadrature} / K_pd = sin(delta_phi)
phase_current = Q
```

Bu kola aktif `run_simulation.m` ile ayni skaler `sin(phi)` guc duzeltmesi
uygulanir.

I/Q yontemi ayni referans osilatorunun iki dik bilesenini kullanir:

```text
I = LPF{DUT * Ref_in_phase} / K_pd = cos(delta_phi)
Q = LPF{DUT * Ref_quadrature} / K_pd = sin(delta_phi)
phase_iq = unwrap(atan2(Q, I))
```

I/Q fazi dogrudan cikardigi icin bu kola `sin(phi)` guc duzeltmesi uygulanmaz.

## Calistirma

Octave'i repo kokunde acip su betigi calistirin:

```matlab
comparison_dir = fullfile(pwd, ...
    "phasedetector with cross correlation optimized", ...
    "iq_demod_comparison");
run(fullfile(comparison_dir, "run_iq_comparison.m"));
```

Betik kalici sonuc dosyasi yazmaz. Sayisal sonuclar `comparison_results`, grafik
nesnesi `comparison_figure` degiskenine gelir.

Tum ayarlar `comparison_config.m` dosyasindadir. Parametreleri bu dosyada
degistirip `run_iq_comparison.m` dosyasini yeniden calistirin.

Grafikte:

- sol ustte mevcut yontem ile DUT,
- sag ustte I/Q yontemi ile DUT,
- sol altta iki yontemin ust uste karsilastirmasi,
- sag altta DUT'a gore imzali dB hatasi

gosterilir.

Guncel ayarlar `comparison_config.m` icinde gorulur. Nonlineer farki daha
belirgin gormek icin `config.phase_rms_dut` degeri `0.5` rad yapilabilir.

## Dosyalar

- `run_iq_comparison.m`: dogrudan Run ile calistirma ve dort panelli grafik.
- `run_detector_comparison.m`: ortak Monte Carlo akisi ve iki faz detektoru.
- `comparison_config.m`: kullanicinin duzenleyecegi tum simulasyon ayarlari.
- Diger `.m` dosyalari: aktif akisla ayni yerel LPF, PSD ve gurultu yardimcilari.

## Asin Yeri Karsilastirmasi

`run_asin_realization_comparison.m` dosyasini Octave Editor'de acip dogrudan
**Run** tusuna basin. Tek figurde iki satir ve uc sutun olusur:

- Ust satir: DUT `0.2` rad, Ref1/Ref2 `0.5` rad.
- Alt satir: DUT `0.02` rad, Ref1/Ref2 `0.05` rad.
- Her sutun farkli bir realizasyondur.
- Her panelde `asin yok`, `LPF oncesi asin`, `LPF sonrasi asin` ve ayni kaydin
  DUT periodogrami ust uste cizilir.

Her panelde DUT, Ref1 ve Ref2 yalniz bir kez uretilir ve uc detektor kolu ayni
dizileri kullanir. `asin_comparison_config.m` icindeki sabit RNG seed sayesinde
figur yeniden calistirildiginda ayni alti realizasyon uretilir.

Bu test asin yerlesiminin etkisini ayirmak icin global `sin(phi)` guc duzeltmesi
uygulamaz. Her panel tek kayittir; `number_of_iterations` bu scriptte
kullanilmaz. Ornek sayisi, tasiyici, LPF ve log-bin gibi ortak ayarlar
`comparison_config.m`; RMS satirlari ve RNG seed ise
`asin_comparison_config.m` icindedir.
