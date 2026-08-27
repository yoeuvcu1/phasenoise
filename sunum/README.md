# Sunum — İki Kanallı Cross-PSD Yöntemiyle Faz Gürültüsü Ölçümünün Simülasyonu

`yeni_50kHz.docx` raporunun Manim ile hazırlanmış, 32 sahnelik vektörel animasyonlu
sunumu. Sahne sırası ve anlatım raporun bölüm sıralamasına birebir uyar.

## Nasıl sunulur

**Klavyeyle gezilen sunum (önerilen)**

```bash
cd "/Users/omer/Desktop/phasenoise/sunum/cikti" && python3 -m http.server 8777
```

Sonra tarayıcıda `http://localhost:8777/sunum.html` açın ve `F` ile tam ekran yapın.
(`sunum.html` dosyasına çift tıklayarak da açılır; yerel sunucu en güvenilir yol.)

| Tuş | İşlev |
|---|---|
| `→` / `Space` | sonraki sahne |
| `←` | önceki sahne |
| `R` | sahneyi baştan oynat |
| `P` | duraklat / devam |
| `A` | otomatik ilerleme aç/kapa |
| `O` | içindekiler (sahneye atla) |
| `N` | notları ve kontrolleri gizle |
| `F` | tam ekran |
| `?` | tuş yardımı |

Fare 3 saniye hareketsiz kalınca kontroller kendiliğinden gizlenir.
Alt şeritte her sahne için rapora dayalı konuşmacı notu görünür.

**Tek parça film**

`cikti/sunum_tamvideo.mp4` — 32 sahne arka arkaya, 7 dk 7 sn, 1080p60.
Projeksiyon/paylaşım için tarayıcı gerektirmez.

**Tek tek sahneler**

`cikti/video/01_Baslik.mp4` … `32_Kapanis.mp4` — PowerPoint/Keynote'a tek tek
gömmek isterseniz bu dosyaları kullanın.

## İçerik akışı

| # | Sahne | Rapor bölümü |
|---|---|---|
| 1 | Başlık | — |
| 2 | Faz gürültüsü neyi sınırlar? | 1 Giriş |
| 3 | Fazör animasyonu: ideal ve gerçek osilatör | 2 |
| 4 | Zaman ve frekans bölgesi | 2.1 |
| 5 | Tek yan bant (SSB), dBc/Hz | 2.2 |
| 6 | Spectral regrowth | 3.1 |
| 7 | Reciprocal mixing | 3.2 |
| 8 | 16-QAM constellation | 3.3 |
| 9 | Güç yasası, spektral eğimler | 4.1 |
| 10 | Absolute / additive faz gürültüsü | 4.2 |
| 11 | Doğrudan spektral analiz | 5.1 |
| 12 | Faz detektörü yöntemi | 5.2 |
| 13 | Cross-correlation yöntemi | 5.3 |
| 14 | **Yöntemin özü — kompleks düzlemde vektör ortalaması** | 5.3 |
| 15 | Modelin işlem zinciri | 6 |
| 16 | Gürültü ve taşıyıcı üretimi | 6.1 |
| 17 | Mikser, LPF ve K_pd | 6.2 |
| 18 | Kompleks Cross-PSD ve doğrusal ortalama | 6.3 |
| 19 | Log binleme ve MAE | 6.4 |
| 20 | Modelin kapsamı | 6.5 |
| 21 | Modelin fonksiyon akışı | 7.1 |
| 22 | asin() optimizasyonu | 7.2 |
| 23 | Optimizasyon tablosu | 7.2 |
| 24 | Temel parametreler | 8.1 |
| 25 | LPF kesim frekansı taraması | 8.2 |
| 26 | DUT ve referans RMS taramaları | 8.3–8.4 |
| 27 | Logaritmik bin sayısı | 8.5 |
| 28 | **İterasyon sayısı — yakınsama** | 8.6 |
| 29 | Dekad bantlarında MAE | 8.6 |
| 30 | Tek kanal PD ve çapraz korelasyon | 9 |
| 31 | Sonuç | 9 |
| 32 | Kapanış | — |

## Eğrilerin kaynağı — önemli not

Slaytlarda yazan **MAE değerleri raporun kendi tam ölçekli koşularından** alınmıştır
(N = 1.000.000, 100–20.000 iterasyon).

Ekranda oynayan **eğriler** ise aynı Octave modelinin `simulasyon.py` içindeki
numpy portuyla, sunum için küçültülmüş parametrelerle (N = 65.536) yeniden
üretilmiştir; animasyon için gereken hızı sağlamak amacıyla. Algoritma adımları
birebir aynıdır: 1/√(f³) genlik şekillendirme → mikser → 4. derece Butterworth →
/K_pd → `asin()` → DC silme → `X₁X₂*/(fs·Nc)` → kompleks ortalama → log binleme.

Port, raporun bulgularını yakından tekrar üretir; örneğin tek kanal PD ve çapraz
korelasyon karşılaştırmasında referans RMS 0,10 rad için port 7,11 / 0,58 dB,
rapor 6,94 / 0,89 dB vermektedir. Bu nedenle taramalı slaytların sağ alt köşesinde
bunu belirten bir dipnot vardır.

## Yeniden üretme

```bash
cd "/Users/omer/Desktop/phasenoise/sunum" && .venv/bin/python veri_uret.py
```

```bash
cd "/Users/omer/Desktop/phasenoise/sunum" && .venv/bin/python derle.py -qh 6
```

```bash
cd "/Users/omer/Desktop/phasenoise/sunum" && .venv/bin/python deck_uret.py
```

Tek bir sahneyi hızlıca önizlemek için:

```bash
cd "/Users/omer/Desktop/phasenoise/sunum" && .venv/bin/manim -ql --disable_caching sahneler/s12_vektor_ortalama.py CrossVektorOrtalama
```

## Dosya düzeni

```
sunum/
  tema.py             renk paleti, tipografi, kutu/ok/tablo/eksen yardımcıları
  simulasyon.py       Octave modelinin numpy portu (eğri üretimi)
  veri_uret.py        bütün taramaları hesaplar -> veri/sweep.pkl
  sahne_listesi.py    sunum sırası
  notlar.py           sahne başına konuşmacı notu
  derle.py            bütün sahneleri paralel render eder
  deck_uret.py        cikti/sunum.html üretir
  sahneler/           s01…s20, 32 sahne sınıfı
  veri/sweep.pkl      önceden hesaplanmış tarama sonuçları
  cikti/
    sunum.html        klavyeyle gezilen sunum
    sunum_tamvideo.mp4  tek parça film (7 dk 7 sn)
    video/*.mp4       sahne sahne 1080p60
    manifest.json     sahne listesi ve süreler
  _kaynak/            rapordan çıkarılan metin ve şekiller
```

## Gereksinimler

Python sanal ortamı `sunum/.venv` içinde hazır (manim 0.21, numpy, scipy).
Sistem tarafında `ffmpeg`, `cairo`, `pango`, BasicTeX ve `dvisvgm` gerekir —
hepsi kurulu.
