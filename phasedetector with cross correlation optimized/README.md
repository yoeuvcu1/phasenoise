# Cross-PSD phase-noise comparison

## Kullanım

Octave GUI'de `run_comparisons.m` dosyasını çalıştırın. Varsayılan
simülasyon parametreleri ve tüm test listeleri bu dosyanın başındadır.
Bir testi kapatmak için ilgili `test_values` listesini `[]` yapın.

Sonuçlar `results/<timestamp>_<test>/` altında saklanır:

- `raw/`: yeniden çizim için spektrum dosyaları
- `plots/`: subplot'lu karşılaştırma grafiği
- `summary.mat` ve `summary.csv`: koşu özeti

Kayıtlı sonuçları yeniden çizmek için `replot_results.m` dosyasını
çalıştırın. Simülasyon `signal` paketini kullanır.

Faz gürültüsü üreticisinin çağrı başına zaman tabanlı seed davranışı
bilinçli olarak korunmuştur.

Tek bir config çalıştırıp grafiğini görmek için `run_single.m` içindeki
ayarları düzenleyip dosyayı Octave GUI'den çalıştırın.

```matlab
run_single
```
