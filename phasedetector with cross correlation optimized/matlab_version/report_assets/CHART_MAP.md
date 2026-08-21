# Nihai rapor görsel haritası

Bu not, rapor içindeki görsellerin analitik görevini ve son bağlam QA ölçütünü kaydeder. Okuyucuya gösterilen rapor metninin parçası değildir.

## Görsel sözleşmeleri

| Rapor bölümü | Analitik soru / görev | Görsel biçimi | Alanlar ve kapsam | Desteklenen çıkarım | Palet ve renk dışı ayrım | Kaynak / QA yüzeyi |
|---|---|---|---|---|---|---|
| Faz gürültüsü temelleri | İdeal ve gerçek osilatörün zaman/frekans görünümü nasıl ayrılır? | Açıklayıcı dış kaynak şekli | R&S Fig. 2-1 | Faz dalgalanmasının taşıyıcı çevresinde spektral yayılma oluşturduğunu açıklar. | Kaynağın özgün paleti; başlık ve kaynak satırıyla proje sonuçlarından ayrılır. | `figures/rs_fig_2_1.png`; nihai DOCX renderi |
| SSB gösterimi | L(f) hangi offset ve bant genişliğiyle ifade edilir? | Açıklayıcı dış kaynak şekli | R&S Fig. 2-4 | dBc/Hz değerinin taşıyıcıya göre, 1 Hz'e normalize edilmiş tek yan bant oranı olduğunu açıklar. | Kaynağın özgün paleti; kaynak satırı | `figures/rs_fig_2_4.png`; nihai DOCX renderi |
| İki kanallı yöntem | Ortak DUT ve ayrı referans terimleri hangi donanım zincirinden geçer? | Blok şema | R&S Fig. 2-8 | İki bağımsız ölçüm kanalının neden kullanıldığını açıklar; nicel proje sonucu değildir. | Kaynağın özgün paleti; kaynak satırı | `figures/rs_fig_2_8.png`; nihai DOCX renderi |
| LPF kesim frekansı | Kesim frekansı boyunca Cross-PSD ile filtresiz DUT eğrisi nasıl değişir? | 3x3 küçük çoklu, iki çizgili log-x spektrum | 9 kesim noktası; her panel 100 yineleme, N=1M | Kesim üstünde beklenen ayrışmayı ve 400 kHz civarındaki toplam-frekans kalıntısını görünür kılar. | Mavi düz Cross-PSD, kırmızı kesikli DUT; ortak eksenler | `20260821_195439719_lpf_cutoff/...png`; nihai DOCX tam genişlik |
| DUT RMS | DUT seviyesi değişirken kestirim davranışı nasıl değişir? | 2x3 küçük çoklu, iki çizgili log-x spektrum | 0,01-0,50 rad; N=1M, 100 yineleme | Düşük DUT seviyelerinde sonlu ortalamanın etkisini, yüksek seviyelerde düzeltme katsayısının büyümesini gösterir. | Mavi düz / kırmızı kesikli | `20260821_195439719_rms_dut/...png`; nihai DOCX tam genişlik |
| Referans RMS | Referans seviyesi yükselirken artık bağımsız kanal katkısı nasıl görünür? | 2x3 küçük çoklu, iki çizgili log-x spektrum | Ref1=Ref2 0,01-0,50 rad; N=1M, 100 yineleme | 0,1 rad ve üzerindeki referans seviyelerinde tam-bant farkın belirgin biçimde büyüdüğünü gösterir. | Mavi düz / kırmızı kesikli | `20260821_195439719_rms_ref/...png`; nihai DOCX tam genişlik |
| Karşılaştırma profilinde yineleme | Aynı temel profil içinde 1-1000 yineleme arasındaki eğri kararlılığı nasıl gelişir? | 2x3 küçük çoklu, iki çizgili log-x spektrum | DUT/Ref 0,05 rad; LPF 200 kHz; N=1M | Sonlu-gerçekleşim dalgalanmasının genel olarak azaldığını, ancak tek koşuda MAE'nin zorunlu olarak monoton olmadığını gösterir. | Mavi düz / kırmızı kesikli | `20260821_195439719_iterations/...png`; nihai DOCX tam genişlik |
| Log-bin sayısı | Görsel yumuşatma ile yerel değişkenlik arasındaki denge nedir? | 2x3 küçük çoklu, iki çizgili log-x spektrum | 10-200 log-bin; N=1M, 100 yineleme | Çok az binin ayrıntıyı kaybettiğini, çok fazla binin tek-gerçekleşim değişkenliğini görünür kıldığını gösterir; “evrensel optimum” iddiası kurulmaz. | Mavi düz / kırmızı kesikli | `20260821_195439719_log_bins/...png`; nihai DOCX tam genişlik |
| Uzun yineleme profili | DUT referanslardan daha düşük RMS iken 1-20.000 yinelemede yakınsama nasıl ilerler? | 3x3 küçük çoklu, iki çizgili log-x spektrum | LPF 100 kHz; DUT 0,02 rad; Ref 0,05 rad; N=1M | Hızlı ilk iyileşmeyi ve yüksek yinelemelerde azalan getiriyi gösterir; sonuç yalnız tamamlanmış final koşudan alınır. | Mavi düz / kırmızı kesikli; ortak eksenler | en yeni tamamlanmış `*_iterations/...png`; nihai DOCX tam genişlik |

## Seçim ve QA notları

- Spektrumların asıl karşılaştırması sürekli offset ekseninde olduğu için çizgi grafiği ve logaritmik x ekseni uygundur.
- Parametre değerleri farklı eğriler halinde üst üste bindirilmemiş, aynı ölçekli küçük çoklulara ayrılmıştır; bu yaklaşım eğri çakışmasını ve kalabalık lejandı önler.
- Tam-bant MAE ve düzeltme katsayısı exact lookup gerektiği için raporda ayrıca tablo halinde verilir; bu değerler için ikinci bir dekoratif grafik üretilmez.
- Her proje grafiğinin hemen öncesinde veya sonrasında çıkarım, okuma biçimi ve sınırlama açıklayan bir paragraf bulunmalıdır.
- MATLAB PNG'leri 1.995-2.002 piksel genişliğinde ve 150 DPI olarak görsel kontrolden geçmiştir; başlık, lejant ve eksen etiketleri okunaklıdır.
- Nihai iterasyon görseli yalnız `LATEST_PIPELINE_COMPLETE.txt`, CSV, MAT yapılandırmaları ve bütün panel sayısı doğrulandıktan sonra rapora alınacaktır.
