# Analitik rapor planı

## Raporlama işi

- Soru: İki kanallı Cross-PSD faz gürültüsü benzetimi MATLAB R2025b altında nasıl kurulmuş, hangi mühendislik adımlarıyla geliştirilmiş ve `N=1.000.000` deneylerinde nasıl davranmıştır?
- Hedef kitle: teknik; faz gürültüsü ölçüm yöntemini, benzetim varsayımlarını ve sonuç kanıtını denetlemek isteyen mühendis/mentor.
- Kapsam: `0799f9f` senkron noktasındaki optimize kaynakların MATLAB uyarlaması; 21 Ağustos 2026 tarihinde tamamlanan karşılaştırma ve uzun yineleme koşuları.
- Karşılaştırma temeli: her taramada yalnız belirtilen parametre değişir; Cross-PSD, aynı Monte Carlo popülasyonundan üretilen filtresiz DUT periodogramıyla karşılaştırılır.
- Başarı ölçütü: her iddianın kaynak kod, CSV/MAT config veya incelenmiş şekille desteklenmesi; `N=100.000` geçici profilinin nihai sonuçlarla karıştırılmaması; model sınırlarının görünür olması.
- Çıktı yüzeyi: kullanıcının açıkça istediği düzenlenebilir DOCX. Analitik rapor skillindeki anlatı ve kanıt standartları uygulanır; istenmeyen ikinci bir HTML/Site raporu üretilmez.

## Cevap-önce rapor omurgası

- Ana cevap: MATLAB uyarlaması iki kanallı ölçüm zincirini çalıştırmakta ve artan kompleks Cross-PSD ortalamasıyla DUT eğrisine yaklaşmaktadır; iyileşme yüksek yineleme sayılarında azalan getiriye girer.
- Metrik: log-binlenmiş Cross-PSD ve filtresiz DUT eğrilerinin 200 ortak log-frekans noktasındaki ortalama mutlak dB farkı. Bu, donanım ölçüm belirsizliği değildir ve LPF üstü ayrışmayı da içerir.
- Deney kapsamı: karşılaştırma profili `N=1M`, LPF 200 kHz, DUT/Ref 0,05 rad ve 100 yineleme; uzun yineleme profili `N=1M`, LPF 100 kHz, DUT 0,02 rad, Ref 0,05 rad ve 1-20.000 yineleme.
- Kanıt: beş karşılaştırma CSV/MAT/PNG grubu ile bir uzun yineleme CSV/MAT/PNG grubu; R&S uygulama notu; güncel MATLAB kaynakları ve Git geçmişi.
- Hassasiyet kontrolleri: CSV-MAT-raw config uyumu, bütün panel/görsel kontrolü, düşük-offset yardımcı MAE, LPF üstü toplam-frekans kalıntısının ayrı yorumlanması.
- Ana sınırlamalar: RNG başlangıç seed'i kaydedilmez; referans bağımsızlığı için ayrı istatistiksel test yoktur; PLL/LNA/ADC/kuantizasyon ve donanım belirsizliği modellenmez; tek-realizasyon taramaları evrensel optimum göstermez.
- Sonraki adım: seed kaydı, tekrarlı ensemble taraması, offset-band metrikleri ve ideal olmayan donanım blokları.

## Teknik rapor yapı eşlemesi

| Teknik rapor rolü | Nihai DOCX bölümü | Uygulama notu |
|---|---|---|
| Başlık | Kapak | Proje başlığı, MATLAB sürümü, kaynak commit ve tarih |
| Teknik özet | Özet | Sonuç, metrik sınırı ve ana kısıt birlikte verilir |
| Görsel kanıtlı temel bulgular | 8. Benzetim sonuçları | Beş karşılaştırma, uzun yineleme ve exact lookup tabloları |
| Kapsam, veri ve metrik tanımları | 7. Deney tasarımı ve değerlendirme ölçütleri | İki config profili ve MAE tanımı |
| Yöntem | 2-6. bölümler | Faz gürültüsü, ölçüm yöntemleri, Cross-PSD, MATLAB modeli ve geliştirme süreci |
| Sınırlamalar ve sağlamlık kontrolleri | 9. Tartışma ve sınırlamalar | Band, sonlu Monte Carlo, RNG ve ideal blok varsayımları |
| Önerilen sonraki adımlar | 10. Sonuç ve gelecek çalışmalar | Yalnız kanıttan türeyen geliştirmeler |
| Açık sorular | 10. Sonuç ve gelecek çalışmalar | Donanım modeli, tekrarlı sweep ve yeniden üretilebilirlik |

Kuramsal bölümlerin sonuçlardan önce gelmesi, kaynak DOCX'ten devam etme ve R&S benzeri öğretici akışı koruma gereğidir. Bu nedenle teknik özet cevap-önce yazılır; ayrıntılı bulgular yöntemden sonra gelir.
