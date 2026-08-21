# Rapor şablonu kanıtı ve tasarım kararı

## Kaynak belge

- Kaynak: `/Users/omer/Desktop/phasenoise/İki Kanallı Cross.docx`
- SHA-256: `cf4cee318a5ce5055558d0dfc5843145ad9cacd1609db9fe98a3ad09bde8ce2f`
- İnceleme tarihi: 21 Ağustos 2026
- Görsel inceleme: belgenin 10 sayfası `report_assets/qa/source_docx_latest/` altında render edilerek denetlenmiştir.
- Paket yapısı: tek bölüm, 137 paragraf, 3 tablo, 10 gömülü görsel; 7 adet Başlık 1 ve 15 adet Başlık 2 paragrafı.

## Kaynak belgenin düzen sistemi

- Sayfa: A4 dikey, yaklaşık 2,5 cm kenar boşlukları.
- Üstbilgi/altbilgi: iki bölgede de `TASNİF DIŞI` sınıflandırması.
- Gövde: Arial, iki yana yaslı.
- Başlık: yaklaşık 26 punto; Başlık 1 yaklaşık 16 punto; Başlık 2 yaklaşık 13 punto.
- Şekil açıklamaları: ortalı, italik, yaklaşık 9 punto.
- Bileşenler: kuramsal denklemler, R&S şemaları, proje akış şemaları, gürültü/optimizasyon/parametre tabloları ve MATLAB/Octave grafiklerinden oluşan teknik rapor akışı.
- İçerik sırası: giriş, faz gürültüsü temelleri, ölçüm yöntemleri, iki kanallı yöntem, model, optimizasyonlar ve 7. bölümde kısmen tamamlanmış parametrik sonuçlar.

## Korunacak öğeler

- A4 sayfa geometrisi ve `TASNİF DIŞI` işareti.
- Faz gürültüsü temellerinden iki kanallı yönteme ilerleyen kavramsal sıra.
- Geçerli denklemler, mevcut proje mimarisi ve optimizasyon kararlarının teknik özü.
- Dış kaynaklı şekillerde R&S kaynağının açıkça belirtilmesi.
- Kaynak belgenin gömülü içeriği başlangıç noktası olarak kullanılacak; kök DOCX değiştirilmeden ayrı bir nihai dosya üretilecektir.

## Kullanıcı isteğiyle uygulanacak bilinçli sapmalar

Kullanıcı mevcut raporu “biraz basit” bulduğu ve geliştirilmesini istediği için kaynak belgenin sade siyah-beyaz biçimi birebir korunmayacaktır. Aşağıdaki sapmalar kasıtlıdır:

- Kurumsal lacivert/turkuaz vurgu sistemi, tutarlı başlık hiyerarşisi ve daha okunabilir tablo/şekil yerleşimleri kullanılacaktır.
- Kapak, belge bilgileri, özet, anahtar kelimeler ve içindekiler eklenecektir.
- Eski `N=100.000` sonuçları ve yarım 7.5 bölümü kaldırılacak; tamamlanan MATLAB R2025b `N=1.000.000` koşularının doğrulanmış sonuçlarıyla yeniden kurulacaktır.
- Octave ifadeleri, güncel MATLAB uyarlaması ile commit geçmişini birbirinden ayıran teknik bir geliştirme anlatısına dönüştürülecektir.
- Çapraz korelasyon ilkesi ile kodda kullanılan kompleks Cross-PSD kestiricisi terminolojik olarak ayrılacaktır.
- MAE metriğinin tam ortak pozitif bantta, filtreli Cross-PSD ile filtresiz DUT referansı arasında hesaplandığı ve bu nedenle donanım doğruluk değeri olmadığı açıkça yazılacaktır.
- Tartışma, model sınırlamaları, sonuç, gelecek çalışmalar, kaynakça ve yapılandırma/provenance ekleri eklenecektir.
- Sayfa numarası ve rapor adı üstbilgi/altbilgi sistemine eklenecek; sınıflandırma metni korunacaktır.

## Hedef çıktı

`/Users/omer/Desktop/phasenoise/phasedetector with cross correlation optimized/matlab_version/Iki_Kanalli_Cross_PSD_Faz_Gurultusu_Raporu.docx`
