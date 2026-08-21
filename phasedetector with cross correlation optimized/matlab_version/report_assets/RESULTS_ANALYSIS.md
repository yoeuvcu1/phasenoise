# MATLAB Simülasyon Sonuçları Analizi — Final Güncel Koşu

## 1. Kapsam ve tamamlanma kaydı

Bu not yalnızca 21 Ağustos 2026 tarihli final MATLAB R2025b pipeline çıktılarından hazırlanmıştır. Daha eski batch sonuçları bu analize dahil edilmemiştir.

Yetkili sonuç klasörleri:

- Karşılaştırma taramaları:
  - `results/20260821_195439719_lpf_cutoff`
  - `results/20260821_195439719_rms_dut`
  - `results/20260821_195439719_rms_ref`
  - `results/20260821_195439719_iterations`
  - `results/20260821_195439719_log_bins`
- Ana iterasyon taraması:
  - `results/20260821_200352497_iterations`

`LATEST_PIPELINE_COMPLETE.txt` ve pipeline logu birlikte kontrol edilmiştir:

| Kayıt | Değer |
|---|---|
| Kaynak commit | `0799f9f` |
| MATLAB | 25.2.0.3042426 — R2025b Update 1 |
| Örnek sayısı | 1,000,000 |
| Pipeline başlangıcı | 21-Aug-2026 19:54:39 |
| Pipeline tamamlanması | 21-Aug-2026 21:10:06 |
| Log kapanışı | `=== RUN_ITERATIONS COMPLETE ===` |

## 2. İki sonuç grubunun konfigürasyonları

Karşılaştırma ve ana iterasyon taramaları aynı fiziksel ayarlarla çalıştırılmamıştır. Bu nedenle iki iterasyon tablosu bağımsız deneyler olarak yorumlanmalı, aynı deneyin tekrarı gibi doğrudan karşılaştırılmamalıdır.

### 2.1 Karşılaştırma taramalarının temel konfigürasyonu

| Parametre | Temel değer |
|---|---:|
| `N` | 1,000,000 |
| `fs` | 1 MHz |
| Taşıyıcı genliği `A` | 1 |
| Taşıyıcı frekansı `f0` | 200 kHz |
| Yerleşme örneği | 0 |
| LPF | 4. derece Butterworth |
| LPF kesimi | 200 kHz |
| DUT RMS | 0.05 rad |
| Ref1 / Ref2 RMS | 0.05 / 0.05 rad |
| İterasyon | 100 |
| Logaritmik bin sayısı | 100 |

Her taramada yalnız adı geçen parametrenin değiştiği; diğer sabit alanların hem ham MAT dosyalarında hem konfigürasyon kaydında yukarıdaki değerlerle uyuştuğu doğrulanmıştır.

### 2.2 Ana iterasyon taramasının temel konfigürasyonu

| Parametre | Değer |
|---|---:|
| `N` | 1,000,000 |
| `fs` | 1 MHz |
| Taşıyıcı genliği `A` | 1 |
| Taşıyıcı frekansı `f0` | 200 kHz |
| Yerleşme örneği | 0 |
| LPF | 4. derece Butterworth |
| LPF kesimi | 100 kHz |
| DUT RMS | 0.02 rad |
| Ref1 / Ref2 RMS | 0.05 / 0.05 rad |
| Grafikte `(orig)` değeri | 100 iterasyon |
| Logaritmik bin sayısı | 100 |
| Taranan iterasyonlar | 1, 10, 100, 250, 500, 1000, 5000, 10000, 20000 |

Dokuz ham MAT dosyasında yalnız `number_of_iterations` alanının değiştiği doğrulanmıştır.

## 3. Veri bütünlüğü ve görsel kalite kontrolü

Altı final klasörü salt okunur biçimde çapraz doğrulanmıştır.

| Kontrol | Sonuç |
|---|---|
| CSV veri satırı | 42 |
| Ham MAT sonucu | 42 |
| CSV ↔ ham MAT: test değeri | 42/42 uyumlu |
| CSV ↔ ham MAT: MAE | 42/42, CSV yuvarlaması içinde uyumlu |
| CSV ↔ ham MAT: correction factor | 42/42, CSV yuvarlaması içinde uyumlu |
| CSV ↔ ham MAT: süre | 42/42, CSV yuvarlaması içinde uyumlu |
| `summary.mat` ↔ CSV temel dizileri | Altı klasörün tamamında uyumlu |
| Konfigürasyon alanları | Beklenen sweep dışında sapma yok |
| Binned frekans/seviye dizileri | Uzunluklar eş; frekanslar pozitif ve sonlu, seviyeler sonlu |
| Karşılaştırma PNG'si | Her klasörde bir adet, boş olmayan ve okunabilir |
| Toplam doğrulama sorunu | **0** |

Beş karşılaştırma PNG'si 1995–2002 piksel genişlikte ve 1032–1488 piksel yüksekliktedir. Ana iterasyon PNG'si 2008 × 1489 pikseldir; dokuz panelin tamamı, ortak eksenler, başlıklar, lejantlar ve 100 iterasyondaki `(orig)` işareti görsel olarak kontrol edilmiştir.

Karşılaştırma koşularının kayıtlı simülasyon süreleri toplamı 513.766 saniye, yani yaklaşık 8 dakika 33.8 saniyedir. Ana iterasyon taramasındaki dokuz bağımsız noktanın kayıtlı süreleri toplamı 3964.305 saniye, yani 1 saat 6 dakika 4.3 saniyedir. Bu toplamlar grafik üretimi ve dosya yazımı gibi ek pipeline sürelerini içermez.

## 4. Metriklerin doğru yorumu

### 4.1 Resmî tam-bant MAE

`mean_absolute_error_fft_db`, düzeltilmiş Cross-PSD ile aynı iterasyon sayısında lineer güç alanında ortalanmış **filtresiz DUT periodogramı** arasındaki mutlak dB farkının, 200 ortak logaritmik frekans noktası üzerindeki ortalamasıdır. Varsayılan 100 log-bin konfigürasyonunda bu aralık yaklaşık 0.477 Hz–467.264 kHz'dir.

Bu nedenle resmî MAE yalnız bağımsız referans gürültüsü kalıntısını ölçmez; ayrıca:

- LPF geçiş ve durdurma bandında filtreli ölçüm kanalı ile filtresiz DUT referansı arasındaki beklenen farkı,
- yaklaşık 400 kHz'deki `2f0` mixer toplam-ürün kalıntısını,
- her test noktası için yeniden üretilen rastgele realizasyonun etkisini

de içerir. Rapor için güvenli karşılık **“verilen konfigürasyondaki uçtan uca spektral uyum”**dur. Metrik, donanım analizörünün mutlak doğruluğu veya saf korelasyon kestirim hatası olarak adlandırılmamalıdır.

### 4.2 Yardımcı ≤10 kHz MAE

Ana iterasyon sonuçlarında ayrıca, kayıtlı binned Cross-PSD ve DUT dizilerinin aynı ortak log-frekans ızgarasında yalnız `f ≤ 10 kHz` noktaları alınarak yardımcı MAE hesaplanmıştır. Bu değer resmî CSV metriği değildir; 100 kHz LPF kesiminin bir dekad altında, geçiş bandından uzak ölçüm bölgesindeki yakınsamayı görmek için yapılan ham MAT tabanlı tanısal incelemedir.

### 4.3 Correction factor

`correction_factor`, sinüzoidal faz dedektörünün küçük-sinyal dışındaki güç sıkışmasını geri almak için Cross-PSD gücüne uygulanan düzeltmedir. Değerin 1'e yakın olması düzeltmenin küçük kaldığını, belirgin biçimde büyümesi ise doğrusal olmayan dedektör etkisinin önem kazandığını gösterir.

## 5. Ana iterasyon taraması: 1–20000

| İterasyon | Tam-bant MAE (dB) | ≤10 kHz yardımcı MAE (dB) | Correction factor | Süre (s) | Süre / iterasyon (s) |
|---:|---:|---:|---:|---:|---:|
| 1 | 6.958415 | 7.355101 | 1.002878 | 0.226 | 0.226442 |
| 10 | 5.334866 | 4.765523 | 1.000959 | 1.215 | 0.121512 |
| 100 | 2.940180 | 2.213308 | 1.000372 | 12.213 | 0.122126 |
| 250 | 2.112152 | 1.120814 | 1.000279 | 30.910 | 0.123640 |
| 500 | 1.661024 | 0.453248 | 1.000493 | 59.319 | 0.118638 |
| 1000 | 1.554048 | 0.322986 | 1.000409 | 118.988 | 0.118988 |
| 5000 | 1.426552 | 0.163581 | 1.000385 | 590.691 | 0.118138 |
| 10000 | **1.366247** | **0.093889** | 1.000392 | 1051.084 | 0.105108 |
| 20000 | 1.437095 | 0.171457 | 1.000411 | 2099.659 | 0.104983 |

### 5.1 Güvenle söylenebilecek yakınsama ve süre bulguları

- 1'den 20000 iterasyona geçildiğinde tam-bant MAE 6.958415 dB'den 1.437095 dB'ye düşmüş; mutlak azalma **5.521320 dB** olmuştur.
- 1'den 20000'e yardımcı ≤10 kHz MAE 7.355101 dB'den 0.171457 dB'ye düşmüştür. Bu, ana ölçüm bandındaki yakınsamanın tam-bant ortalamadan daha güçlü olduğunu gösterir.
- 5000→10000 geçişinde tam-bant MAE yalnız 0.060305 dB iyileşirken kayıtlı süre 1.779 katına çıkmıştır. Bu aralıkta azalan getiri açıktır.
- 10000→20000 geçişinde süre 1.9976 katına çıkmış, tam-bant MAE ise 0.070848 dB artmıştır. Yardımcı ≤10 kHz MAE de 0.077568 dB artmıştır. Bu küçük ters yönlü değişimler bağımsız tek realizasyonlar arasındaki Monte Carlo oynaklığı olarak yorumlanmalı; “20000 iterasyon sonucu bozdu” denmemelidir.
- 5000, 10000 ve 20000 noktaları tam-bant metrikte yaklaşık 1.37–1.44 dB aralığında bir plato oluşturur. Platonun önemli bir kısmı LPF üstü sistematik fark ve mixer ürünüyle ilişkilidir.
- 10–20000 arasında correction factor 1.000279–1.000959 aralığındadır. Yakınsama eğilimi correction factor değişiminden kaynaklanmamaktadır.
- Sürenin iterasyon sayısına doğrusal regresyonu yaklaşık 0.104911 saniye/iterasyon eğimi ve `R² = 0.999129` vermiştir. Hesap maliyeti bu batch içinde çok güçlü biçimde yaklaşık doğrusaldır.
- 20000 iterasyon tek başına 2099.659 saniye, yani yaklaşık 35 dakika sürmüştür.

### 5.2 Frekans bölgelerine göre yardımcı tanı

Aşağıdaki değerler resmî CSV metrikleri değil, ham MAT eğrilerinden türetilen tanısal sonuçlardır.

| İterasyon | ≤10 kHz (dB) | 10–100 kHz (dB) | >100 kHz (dB) | 406.8 kHz civarı Cross−DUT farkı (dB) |
|---:|---:|---:|---:|---:|
| 100 | 2.213308 | 3.798530 | 6.259490 | 24.701 |
| 500 | 0.453248 | 4.574991 | 5.041841 | 25.128 |
| 1000 | 0.322986 | 4.340858 | 5.263102 | 25.156 |
| 5000 | 0.163581 | 4.327960 | 5.170958 | 25.058 |
| 10000 | 0.093889 | 4.315992 | 5.100072 | 24.941 |
| 20000 | 0.171457 | 4.478171 | 4.997806 | 24.967 |

Yüksek iterasyonda ≤10 kHz hatası 0.1 dB mertebesine inerken 10–100 kHz ve LPF üstü bölgelerde hata birkaç dB seviyesinde kalır. Yaklaşık 406.777 kHz'deki dar farkın yüksek iterasyonda yaklaşık 25 dB olarak değişmeden kalması, bunun korelasyonsuz rastgele tabandan çok `2f0 ≈ 400 kHz` mixer toplam-ürün kalıntısıyla uyumlu deterministik bir bileşen olduğunu destekler.

## 6. LPF kesim frekansı taraması

| LPF kesimi (kHz) | MAE (dB) | Correction factor | Süre (s) |
|---:|---:|---:|---:|
| 1 | 1.359519 | 1.003147 | 11.443 |
| 5 | 1.045953 | 1.002447 | 11.294 |
| 10 | 1.065387 | 1.002685 | 11.240 |
| 25 | 1.013057 | 1.002644 | 11.141 |
| 50 | **0.664432** | 1.002441 | 11.571 |
| 75 | 1.358531 | 1.002254 | 11.311 |
| 100 | 0.770257 | 1.002885 | 11.468 |
| 200 `(orig)` | 1.526132 | 1.002810 | 11.006 |
| 300 | 2.475921 | 1.003272 | 11.083 |

- Bu tek taramada en düşük MAE 50 kHz'de 0.664432 dB'dir; 100 kHz sonucu yalnız 0.105825 dB daha yüksektir.
- 300 kHz sonucu 50 kHz sonucundan 1.811489 dB yüksek ve sayısal olarak 3.726 kattır. PNG'de 200–300 kHz ayarlarında yüksek frekans ayrışmasının büyüdüğü görülür.
- Sonuçlar tüm aralıkta monoton değildir ve her nokta yeni rastgele realizasyon kullanır. Bu nedenle 50 kHz “evrensel optimum” değil, yalnız bu örneklenmiş taramanın en düşük MAE noktasıdır.
- Kesimin taşıyıcıya ve `2f0` toplam ürününe yaklaşmasıyla bozulmanın artması devre modeliyle uyumludur; kesin filtre bastırması ayrıca ölçülmeden verilmemelidir.

## 7. DUT faz gürültüsü RMS taraması

| DUT RMS (rad) | MAE (dB) | Correction factor | Düzeltme artışı | Süre (s) |
|---:|---:|---:|---:|---:|
| 0.01 | 5.221920 | 1.000115 | +0.012% | 11.517 |
| 0.02 | 3.373746 | 1.000272 | +0.027% | 11.343 |
| 0.05 `(orig)` | 1.559933 | 1.002657 | +0.266% | 11.171 |
| 0.10 | 0.841158 | 1.009741 | +0.974% | 10.967 |
| 0.20 | **0.535676** | 1.040998 | +4.100% | 10.949 |
| 0.50 | 0.803766 | 1.301961 | +30.196% | 10.862 |

- 0.01→0.20 rad aralığında tam-bant MAE 4.686244 dB azalmıştır. Ortak DUT bileşeninin referans gürültüsüne göre güçlenmesi Cross-PSD uyumunu iyileştirmiştir.
- Bu taramadaki en düşük MAE 0.20 rad'dadır; 0.50 rad'da MAE yeniden 0.803766 dB'ye yükselir.
- Correction factor 0.20 rad'da +4.100%, 0.50 rad'da +30.196% olmuştur. Yüksek DUT RMS düzeylerinde küçük-sinyal yaklaşımından uzaklaşma belirgindir.
- 0.20 rad yalnız bu taramanın en iyi örneklenmiş noktasıdır; genel optimum veya donanım çalışma sınırı olarak sunulmamalıdır.

## 8. Referans faz gürültüsü RMS taraması

| Ref1 = Ref2 RMS (rad) | MAE (dB) | Correction factor | Süre (s) |
|---:|---:|---:|---:|
| 0.01 | **1.462986** | 1.002503 | 11.109 |
| 0.02 | 1.497891 | 1.002343 | 11.024 |
| 0.05 `(orig)` | 1.603076 | 1.002248 | 10.977 |
| 0.10 | 3.788310 | 1.003926 | 10.776 |
| 0.20 | 4.862625 | 1.004530 | 10.805 |
| 0.50 | 9.517614 | 1.034367 | 11.499 |

- 0.01–0.05 rad sonuçları yalnız yaklaşık 0.14 dB aralığındadır; tek realizasyonlu taramadan bu üç düşük seviye arasında güçlü bir sıralama çıkarılmamalıdır.
- 0.10 rad ve üzerinde bozulma belirgindir. 0.50 rad MAE'si varsayılan 0.05 rad sonucundan 7.914538 dB yüksek ve sayısal olarak 5.937 kattır.
- 0.50 rad'da correction factor yalnız 1.034367 olduğundan büyük MAE artışı esas olarak sonlu ortalamada kalan bağımsız referans gürültüsüyle uyumludur.
- Güvenli sonuç, yüksek referans gürültüsünün aynı spektral uyum için daha fazla korelasyon ortalaması gerektirdiğidir.

## 9. Karşılaştırma batch'i iterasyon taraması

Bu tablo 200 kHz LPF, 0.05 rad DUT ve 0.05/0.05 rad referans temel konfigürasyonuna aittir; Bölüm 5'teki 100 kHz LPF ve 0.02 rad DUT kullanılan ana taramayla doğrudan sayısal tekrar karşılaştırması yapılmamalıdır.

| İterasyon | MAE (dB) | Correction factor | Süre (s) |
|---:|---:|---:|---:|
| 1 | 5.119062 | 1.001983 | 0.211 |
| 10 | 2.805762 | 1.002136 | 1.160 |
| 100 `(orig)` | 2.055674 | 1.002610 | 11.721 |
| 200 | **1.471845** | 1.002403 | 22.925 |
| 500 | 1.532481 | 1.002420 | 57.765 |
| 1000 | 1.386740 | 1.002530 | 113.496 |

- 1→1000 arasında MAE 3.732322 dB azalmıştır.
- Yakınsama monoton değildir: 200→500 geçişinde MAE 0.060636 dB artmıştır.
- 200→1000 arasındaki toplam iyileşme yalnız 0.085105 dB'dir; bu konfigürasyonda da yüksek iterasyonlarda azalan getiri görülür.

## 10. Logaritmik bin sayısı taraması

| Bin sayısı | MAE (dB) | Correction factor | Süre (s) |
|---:|---:|---:|---:|
| 10 | 2.481905 | 1.002540 | 11.734 |
| 25 | 2.063567 | 1.002202 | 11.591 |
| 50 | 1.615065 | 1.002068 | 11.472 |
| 80 | 1.534158 | 1.002349 | 12.888 |
| 100 `(orig)` | **1.395794** | 1.002459 | 12.532 |
| 200 | 1.708257 | 1.002456 | 11.715 |

- En düşük gözlenen MAE 100 log-bin değerinde 1.395794 dB'dir; 200 log-bin'e çıkıldığında MAE 0.312463 dB artmıştır.
- PNG'de 10 log-bin spektrumu belirgin biçimde yumuşatırken 200 log-bin daha fazla yerel ayrıntı ve pürüz göstermektedir. 100 log-bin bu koşuda okunabilirlik ve çözünürlük arasında iyi bir pratik dengedir.
- Her bin değeri yeni bir rastgele realizasyon kullanır ve MAE binned eğrilerden hesaplanır. Bu nedenle 100 log-bin istatistiksel optimum olarak sunulmamalıdır; kesin binleme karşılaştırması için aynı tam çözünürlüklü spektrum yeniden binlenmelidir.

## 11. PNG'lerin görsel değerlendirmesi

- Tüm grafiklerde Cross-PSD ile DUT periodogramı renk ve çizgi stiliyle açık biçimde ayrılmıştır; başlıklar, MAE, correction factor ve değiştirilen parametre okunabilmektedir.
- Her sweep içindeki ortak eksen sınırları panel karşılaştırmasını güvenilir kılmaktadır.
- Ana iterasyon grafiğinde düşük iterasyon panelleri belirgin rastgele sapma gösterirken 5000, 10000 ve 20000 panelleri ana ölçüm bandında görsel olarak büyük ölçüde üst üste gelmektedir.
- LPF grafiğinde 200 ve 300 kHz kesimlerde yüksek frekans ayrışması büyümektedir.
- DUT RMS grafiğinde 0.50 rad panelindeki düzeltme katsayısı artışı doğrusal olmayan rejimi görsel sonuçla birlikte işaretlemektedir.
- Referans RMS grafiğinde 0.10 rad ve üzerindeki artık sapma belirgindir.
- Yaklaşık 406.8 kHz'deki dar Cross-PSD tepesi yüksek iterasyonda da kaldığından faz gürültüsü tabanı gibi yorumlanmamalı; mixer toplam-frekans kalıntısı olarak açıklanmalıdır.

## 12. Rapora doğrudan aktarılabilecek güvenli sonuç cümleleri

1. İki kanallı çapraz korelasyon ortalamasında iterasyon sayısının artırılması, kanallara özgü bağımsız referans gürültüsü bileşenlerini bastırarak Cross-PSD tahminini ortak DUT spektrumuna yaklaştırmıştır.
2. Final 1–20000 iterasyon taramasında uçtan uca tam-bant MAE 6.958 dB'den 1.437 dB'ye düşmüş, toplam iyileşme 5.521 dB olmuştur.
3. LPF geçiş bandından uzak `≤10 kHz` yardımcı analizinde MAE 10000 iterasyonda 0.094 dB, 20000 iterasyonda 0.171 dB bulunmuştur; iki yüksek-iterasyon sonucu da ana ölçüm bandında güçlü uyum göstermektedir.
4. 10000→20000 geçişinde süre yaklaşık iki katına çıkmasına karşın tam-bant MAE 0.071 dB artmıştır. Bu sonuç, tek realizasyonlu Monte Carlo oynaklığıyla birlikte yüksek iterasyondaki azalan getiriyi göstermekte; 20000 iterasyonun fiziksel olarak daha kötü olduğu anlamına gelmemektedir.
5. Yüksek iterasyonda tam-bant MAE'nin yaklaşık 1.4 dB düzeyinde kalmasının önemli bölümü LPF geçiş/durdurma bandı ve yaklaşık 400 kHz'deki mixer toplam-ürün kalıntısıyla ilişkilidir.
6. Referans faz gürültüsü 0.10 rad ve üzerine çıktığında aynı 100 iterasyonda spektral uyum belirgin biçimde bozulmuş; bu durum daha gürültülü referansların daha fazla korelasyon ortalaması gerektirdiğini göstermiştir.
7. DUT RMS taramasında 0.20 rad en düşük örneklenmiş MAE'yi vermiş; 0.50 rad'da correction factor'ın 1.302'ye çıkması küçük-sinyal doğrusal yaklaşımından uzaklaşmanın belirginleştiğini göstermiştir.
8. LPF kesim taramasında 50 kHz en düşük örneklenmiş MAE'yi vermiş, 200–300 kHz bölgesinde yüksek frekanslı mixer ürünlerinin bastırılması zayıfladıkça uyum kötüleşmiştir.
9. 100 log-bin bu tek taramada en düşük MAE'yi ve okunabilir bir spektral gösterimi sağlamıştır; ancak istatistiksel optimum olduğu iddia edilmemelidir.
10. Ana iterasyon batch'inde süre-iterasyon ilişkisi `R² = 0.9991` ile yaklaşık doğrusaldır; 20000 iterasyon koşusu 2099.659 saniye sürmüştür.

## 13. Yorum sınırları

- Sweep noktaları `rng("shuffle")` ile başlatılan bağımsız rastgele realizasyonlardır; RNG seed/state sonuç dosyalarına kaydedilmemiştir. Tek eğriler bit düzeyinde yeniden üretilemez.
- Her parametre değeri yalnız bir realizasyonla ölçülmüştür. Özellikle yaklaşık 0.1 dB mertebesindeki küçük farklara istatistiksel anlam yüklenmemelidir.
- İterasyon arttıkça MAE'nin her tek noktada zorunlu olarak monoton azalacağı iddia edilmemelidir.
- 50 kHz LPF, 0.20 rad DUT RMS veya 100 log-bin değerleri yalnız bu taramaların en düşük örneklenmiş MAE noktalarıdır; genel optimum değildir.
- Resmî tam-bant MAE saf referans bastırması, donanım ölçüm belirsizliği veya mutlak cihaz doğruluğu olarak sunulmamalıdır.
- Yardımcı ≤10 kHz MAE raporda kullanılırsa “ham sonuçlardan türetilmiş tanısal bant metriği” olarak açıkça etiketlenmelidir.
- Simülasyon; gerçek LNA/ADC gürültüsü, kuantizasyon, saat jitter'ı, mixer kaçakları, sıcaklık ve kalibrasyon belirsizliklerinin tamamını temsil etmez.
- Correction factor'ın 1'e yakın olması tek başına mutlak genlik kalibrasyonunu doğrulamaz.
- Karşılaştırma batch'i ile ana iterasyon batch'i farklı LPF ve DUT RMS konfigürasyonlarına sahiptir; ortak iterasyon değerlerinin MAE'leri aynı deneyin tekrarı gibi kıyaslanmamalıdır.

## 14. Final doğrulama özeti

- Yetkili sonuç kapsamı: beş `20260821_195439719_*` karşılaştırma klasörü ve `20260821_200352497_iterations`.
- 42/42 ham MAT sonucu CSV satırlarıyla, altı `summary.mat` dosyası da CSV dizileriyle uyuşmaktadır.
- Ana taramanın 20000 iterasyon sonucu: **MAE 1.437095 dB**, **correction factor 1.000411**, **süre 2099.659 s**, **≤10 kHz yardımcı MAE 0.171457 dB**.
- 10000→20000: süre oranı **1.9976**, tam-bant MAE değişimi **+0.070848 dB**, yardımcı ≤10 kHz MAE değişimi **+0.077568 dB**.
- 1→20000: tam-bant MAE değişimi **−5.521320 dB**.
- Altı PNG görsel olarak açılmış; eksik panel, bozuk çıktı veya MAT/CSV/özet tutarsızlığı saptanmamıştır.
