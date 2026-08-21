# İki Kanallı Faz Gürültüsü Raporu - Anlatı ve Bölüm Taslağı

Bu dosya, son raporun yazımında kullanılacak içerik omurgasıdır. Sayısal sonuçlar
bilinçli olarak burada kesinleştirilmemiştir. Sonuç tabloları ve performans
yorumları yalnız tamamlanmış MATLAB koşularının `summary.csv`, `summary.mat`, ham
MAT dosyaları ve karşılaştırma PNG'leri birlikte doğrulandıktan sonra rapora
eklenmelidir.

İnceleme dayanakları:

- `İki Kanallı Cross.docx` (10 sayfalık, 21 Ağustos 2026 tarihli güncel belge)
- `PROJE_RAPORU_TASLAGI.md`
- kök `README.md`, `MEMORY_BANK.md` ve `CHANGES.md`
- optimize klasörün `README.md` dosyası
- `matlab_version/` altındaki güncel MATLAB kaynakları
- Git geçmişi ve çalışma ağacı farkları
- Rohde & Schwarz, *Mastering Phase Noise Measurements* (Parts 1-3), yerel
  birleşik PDF

## 1. Mevcut DOCX'in değerlendirilmesi

### 1.1. Korunması gereken güçlü içerik

Güncel belge artık yalnız bir giriş metni değildir. Yaklaşık 1.270 sözcük, üç
tablo ve belge paketine gömülü 10 görselle kuramsal çerçeveden parametrik
karşılaştırmalara kadar ilerleyen kullanılabilir bir rapor omurgası vardır.
Aşağıdaki içerik korunmalı, yeniden yazılacaksa özü değiştirilmemelidir:

- Başlık, iki kanallı Cross-PSD yaklaşımını ve faz gürültüsü ölçüm hedefini
  doğrudan tanımlamaktadır.
- Giriş; faz gürültüsünü haberleşme, radar ve sayısal sistem performansıyla
  ilişkilendiren yeterli bir motivasyon sunmaktadır.
- İdeal ve gerçek osilatör ifadeleri, SSB gösterimi ve güç yasası eğimleri
  okuyucuyu ölçüm yöntemlerine hazırlayan doğru konu sırasındadır.
- Doğrudan spektral analiz, tek kanallı faz dedektörü ve iki kanallı yöntem
  ayrı alt başlıklarda verilmiş; R&S kaynağındaki ölçüm-yöntemi sıralamasına
  yaklaşılmıştır.
- R&S'ye ait ideal/gerçek işaret, spektrum analizörü, faz dedektörü ve çapraz
  korelasyon blok şemaları kuramsal bölümü görsel olarak desteklemektedir.
- Projeye ait genel model ve fonksiyon akış şemaları, dış kaynaklı donanım
  şemalarıyla uygulanan sayısal modeli ayırmak için iyi bir başlangıçtır.
- Optimizasyon tablosunda açık korelasyon zincirinin kaldırılması, radix-2 FFT,
  LPF katsayı önbelleği, iki kanalın birlikte filtrelenmesi, doğrusal/kompleks
  ortalama ve log-bin ortalaması gibi gerçek geliştirme kararları toplanmıştır.
- Temel `N=1.000.000` karşılaştırma profili ayrı bir tabloda verilmiş; LPF,
  DUT RMS ve referans RMS taramaları kendi şekilleriyle başlamıştır.
- A4 sayfa düzeni, yaklaşık 2,5 cm kenar boşlukları, denklem yerleşimleri ve
  belge boyunca yinelenen `TASNİF DIŞI` üstbilgi/altbilgisi tutarlıdır.

### 1.2. Güncel belgede düzeltilmesi gereken noktalar

Belge 10 sayfaya ulaşmış olsa da sonuç anlatısı tamamlanmamıştır. Sayfa 10,
`7.5. İterasyon sayılarının karşılaştırılması` bölümündeki "Referansların PSD
seviyesi DUT'ye göre yaklaşık:" cümlesinden sonra kesilmekte; bunun altında
geniş bir boş alan kalmaktadır. Sonraki düzenlemede aşağıdaki maddeler birlikte
ele alınmalıdır.

| Mevcut durum | Önerilen düzeltme |
|---|---|
| Giriş, `5.2 Modelin Octave ortamına uygulanması` ve `6. Octave Modelinin Yapısı ve Optimizasyonlar` ifadeleri çalışma ortamını Octave olarak vermektedir. | Nihai rapor sonuçları `matlab_version/` altında MATLAB R2025b ile üretildiği için uygulama ve sonuç bölümleri MATLAB R2025b olarak yazılmalıdır. Üst dizindeki commitli optimize kaynakların GNU Octave uygulaması olduğu, MATLAB klasörünün ise `0799f9f` senkron noktasından türetilmiş uyarlama olduğu geliştirme tarihçesinde bir kez açıklanmalıdır. |
| `Phase Noise Nedir?` başlığı iki dili karıştırmaktadır. | `Faz Gürültüsü Nedir?` kullanılmalı; İngilizce terim ilk geçtiği yerde parantez içinde verilmelidir. |
| İlk iki kuramsal şeklin ikisi de `Şekil 2.1` olarak numaralanmıştır. | Bütün şekiller bölüm bazlı ve benzersiz numaralandırılmalı; Word çapraz başvuru alanlarıyla metindeki şekil atıfları da güncellenmelidir. |
| R&S'den alınan görsellerin altında kaynak satırı bulunmamaktadır. | Her dış kaynaklı şeklin başlığında `Kaynak: Rohde & Schwarz, Part ..., Fig. ..., s. ...` yazılmalı; proje grafikleri `Kaynak: Bu çalışma` olarak ayrılmalıdır. |
| Faz terimi içeren sadeleştirilmiş işaret denklemi `x_ideal(t)` olarak adlandırılmıştır. | Faz hatası içerdiği için `x(t)` veya `x_real(t)` kullanılmalıdır. |
| `için için`, `iteraston`, `db/decade` ve `Single Side Band` gibi yazım/terim sorunları vardır. | Dil denetimi uygulanmalı; `dB/dekad`, `yineleme`, `tek yan bant` ve `Single Sideband` yazımları tutarlılaştırılmalıdır. |
| Cross-correlation ve Cross-PSD aynı kavrammış gibi dönüşümlü kullanılmaktadır. | Fiziksel/istatistiksel ilke `çapraz korelasyon`, kodda kullanılan frekans bölgesi kestiricisi ise `kompleks çapraz güç spektral yoğunluğu (Cross-PSD)` olarak ayrıştırılmalıdır. |
| Optimizasyon tablosunda `nfft=nextpow2(2*Nc-1)` yazılmıştır. | Kodla uyumlu ifade `nfft = 2^nextpow2(2*Nc-1)` olmalıdır; `nextpow2` tek başına FFT uzunluğunu değil üs değerini döndürür. |
| Doğrudan FFT yolu için "matematiksel olarak eşdeğer" ve "daha hızlı" ifadeleri kesin hüküm olarak verilmiştir. | Açık korelasyon dizisinin korelasyon teoremine dayalı spektral çarpımla değiştirildiği yazılmalı; deterministik eşdeğerlik testi ve kontrollü benchmark olmadığı için kesin eşdeğerlik ya da sayısal hızlanma iddiası verilmemelidir. |
| `ortalama genlik hatası` terimi kullanılmıştır. | Güncel metrik, log-binlenmiş iki eğri arasındaki ortalama mutlak **dB farkıdır**; fiziksel genlik hatası veya donanım doğruluğu olarak adlandırılmamalıdır. |
| 7.2'deki LPF listesi ve sekiz panelli eski şekil 75 kHz noktasını içermemektedir. | Güncel `run_comparisons.m` listesindeki dokuz değer (`1, 5, 10, 25, 50, 75, 100, 200, 300 kHz`) yeni `N=1.000.000` sonucu ve dokuz panelli final şekille eşleştirilmelidir. |
| 7.2, MAE yorumunda LPF geçiş bandının dikkate alınmasını önerirken kod MAE'yi bütün ortak pozitif frekans bandında hesaplamaktadır. | Resmî MAE'nin LPF üstü beklenen ayrışmayı da içerdiği açıkça yazılmalı; ayrıca passband/offset-band metriği hesaplanırsa `ek tanısal metrik` diye etiketlenmelidir. |
| 7.4'te referans RMS taramasının denklem/listesi `sigma_DUT` simgesiyle gösterilmiştir. | `sigma_R1 = sigma_R2 = sigma_ref` kullanılmalıdır. "Tamamen bağımsız" yerine "ayrı rastgele diziler olarak üretilmiş ve modelde korelasyonsuz kabul edilmiştir" denmelidir. |
| 7.5'te `N=100.000` yazılı eski özel profil bulunmaktadır. | MATLAB `run_iterations.m` final profili `N=1.000.000`, `f_c=100 kHz`, DUT RMS `0,02 rad`, Ref RMS `0,05/0,05 rad`, 100 log-bin ve `[1, 10, 100, 250, 500, 1000, 5000, 10000, 20000]` yineleme değerleridir. Nihai değerler tamamlanan `summary.mat`/raw config ile son kez doğrulanmalıdır. |
| 7.5 yarım kalmış, `log_bins` taraması için 7.6 bulunmamaktadır. | 7.5 sonuç grafiği ve nicel yorumla tamamlanmalı; ardından `7.6 Logaritmik bin sayısının etkisi` eklenmelidir. |
| Özet, içindekiler, birleşik sonuç tablosu, tartışma, sınırlamalar, sonuç, kaynakça ve ekler bulunmamaktadır. | Aşağıdaki bölüm akışı uygulanmalı; sonuç bölümü yeni koşuların kanıtları geldikten sonra doldurulmalıdır. |

### 1.3. Yapısal tamamlama haritası

Mevcut 1-7.4 içeriği silinmemeli; dil ve teknik düzeltmelerle korunmalıdır.
`7.5`ten sonra rapor şu sırayla tamamlanmalıdır:

1. `7.5 İterasyon sayısının etkisi`: final MATLAB grafiği, değer tablosu ve
   monotonluk/azalan getiri yorumu.
2. `7.6 Logaritmik bin sayısının etkisi`: son `run_comparisons` çıktısı ve
   binleme-realizasyon etkisinin ayrımı.
3. `8. Toplu bulgular`: beş taramanın seçilmiş, doğrulanmış sonuçlarını tek
   tabloda özetleyen bölüm.
4. `9. Tartışma ve sınırlamalar`: teori, ölçüm bandı, LPF, sonlu Monte Carlo,
   RNG ve ideal donanım varsayımları.
5. `10. Sonuç ve gelecek çalışmalar`: yeni sayı üretmeden bulguların sentezi.
6. `Kaynakça` ve `Ekler`: R&S künyesi, kullanılan MATLAB belgeleri, config ve
   sonuç provenance tablosu.

SSB bağıntısı kullanılırken PSD tanımı sabit tutulmalıdır. Raporda

\[
L(f)=10\log_{10}\left(\frac{S_\varphi(f)}{2}\right)\quad[\mathrm{dBc/Hz}]
\]

ifadesi kullanılacaksa `S_\varphi(f)` tek taraflı faz dalgalanması PSD'si olarak
tanımlanmalı ve bağıntının küçük faz yaklaşımında kullanıldığı belirtilmelidir.

## 2. R&S benzeri, projeye uyarlanmış bölüm akışı

Rohde & Schwarz uygulama notu önce kavramı ve önemini açıklar, ardından ölçüm
yöntemlerini karşılaştırır, çapraz korelasyonu ayrı bir yöntem olarak sunar ve
sonunda ileri ölçümlere geçer. Proje raporunda aynı okuma mantığı korunmalı;
ancak ürün tanıtımı yerine MATLAB modeli, geliştirme süreci ve deneysel kanıt
merkeze alınmalıdır.

| Bölüm | Amaç | Ana kanıt / görsel |
|---|---|---|
| Kapak, belge bilgileri ve içindekiler | Kurum, hazırlayan, danışman, tarih ve sınıflandırma bilgilerini vermek | Sade kapak; otomatik içindekiler |
| Özet | Problem, yöntem, MATLAB modeli, başlıca doğrulanmış bulgu ve sınırlamayı tek sayfadan kısa vermek | Son koşudan doğrulanmış en fazla iki sayı |
| 1. Giriş ve motivasyon | Faz gürültüsünün haberleşme, radar ve sayısal saat sistemleri için önemini açıklamak | R&S ideal/gerçek işaret görseli |
| 2. Faz gürültüsü temelleri | Zaman ve frekans bölgesi tanımı, SSB, dBc/Hz, güç yasası eğimleri ve `1/f^3` modelini kurmak | R&S faz gürültüsü nicelendirme görseli; eğim tablosu |
| 3. Ölçüm yöntemleri | Doğrudan spektrum, faz dedektörü, gecikme hattı ve iki kanallı yöntemi kısa karşılaştırmak | Yöntem karşılaştırma tablosu |
| 4. İki kanallı çapraz korelasyon ilkesi | Ortak DUT teriminin korunmasını ve bağımsız kanal terimlerinin ortalamada azalmasını matematiksel olarak göstermek | R&S Fig. 2-8; yanında projeye ait sadeleştirilmiş blok şema |
| 5. MATLAB benzetim modeli | Gürültü üretimi, taşıyıcılar, karıştırıcı, LPF, kazanç normalizasyonu, Cross-PSD, periodogram ve log-bin akışını açıklamak | Özgün MATLAB işlem zinciri diyagramı |
| 6. Projenin gelişimi ve optimizasyonlar | İlk gürültü deneylerinden modüler ve taranabilir MATLAB sürümüne geçişi anlatmak | Eski-yeni algoritma tablosu; commit zaman çizelgesi |
| 7. Deney tasarımı | Sabit parametreleri, tek-parametre taramalarını, sonuç kaydını ve değerlendirme ölçütlerini tanımlamak | Config tabloları ve sonuç provenance tablosu |
| 8. Benzetim sonuçları | Tamamlanan karşılaştırma ve yineleme koşularını yalnız kanıta dayalı yorumlamak | MATLAB PNG'leri; CSV'den üretilmiş özet tablolar |
| 9. Tartışma | Sonuçların teoriyle uyumunu, sapmaları ve model sınırlarını değerlendirmek | Teorik `5 log10(K)` eğilimi ile gözlenen davranışın nitel karşılaştırması |
| 10. Sonuç ve gelecek çalışmalar | Proje çıktısını, öğrenilen temel teknik dersi ve sonraki doğrulama adımlarını özetlemek | Yeni sayı eklenmez; önceki bulgular sentezlenir |
| Kaynakça ve ekler | Kaynakları, config manifestini, dosya sorumluluklarını ve gerekirse sözde kodu vermek | Kaynak listesi, commit/config manifesti |

Ana anlatı çizgisi şu sırayı izlemelidir:

> Ölçüm problemi -> fiziksel ilke -> iki kanallı çözüm -> MATLAB modeli ->
> hesaplama optimizasyonu -> deney tasarımı -> gözlenen sonuç -> sınırlamalar.

Bu sıra, staj günlüğündeki gerçek gelişimi yansıtır; ancak günlük cümlelerini
rapora taşımaz.

## 3. Projenin gelişim ve optimizasyon anlatısı

Projenin gelişimi tarihlere bölünmüş bir staj günlüğü gibi değil, birbirini
izleyen mühendislik kararları olarak anlatılmalıdır.

### 3.1. Kuramsal çerçevenin kurulması

Çalışma, yerel osilatör faz gürültüsünün sistem performansına etkisini ve bu
gürültünün doğrudan ölçümündeki duyarlılık sınırını anlamaya yönelik kaynak
taramasıyla başlamıştır. R&S ve benzeri ölçüm notları üzerinden faz gürültüsü,
flicker mekanizmaları, tek yan bant gösterimi ve faz dedektörü tabanlı ölçüm
yöntemleri incelenmiştir. Bu aşamanın sonunda proje hedefi, çok düşük seviyeli
ortak DUT gürültüsünü iki bağımsız ölçüm kanalından kestiren sayısal bir model
olarak belirlenmiştir.

### 3.2. Gürültü üretiminden `1/f^3` modele geçiş

İlk sayısal çalışmalar beyaz Gauss gürültüsünün `randn` ile üretilmesi ve bir
taşıyıcının fazına eklenmesi üzerinde yürütülmüştür. Ardından farklı renkli
gürültülerin spektral şekillendirme mantığı incelenmiş ve proje için hedeflenen
flicker frekans gürültüsünü temsil etmek üzere `1/f^3` faz PSD modeli
seçilmiştir. Güncel üretici, beyaz gürültünün FFT genliğini
`1/sqrt(k^3)` ile şekillendirir, DC bileşenini kaldırır ve zaman dizisini hedef
RMS değerine ölçekler. Bu model, gerçek bir osilatörün bütün gürültü bölgelerini
değil, kontrollü bir güç yasası spektrumunu temsil etmektedir.

### 3.3. İlk iki kanallı ölçüm modelinin kurulması

DUT ve iki referans için aynı spektral karaktere sahip fakat ayrı rastgele
örnekler üreten fonksiyonlar hazırlanmıştır. Aynı DUT taşıyıcısı iki kanalda
ortak tutulmuş; referans taşıyıcıları DUT'a göre 90 derece merkez fazında
oluşturulmuştur. Her kanalda DUT ile referans çarpılmış, toplam frekans bileşeni
Butterworth LPF ile bastırılmış ve taban bant çıkışı faz dedektörü kazancına
bölünmüştür. Bu yapı, R&S donanım şemasındaki faz dedektörü ve LPF bloklarının
sayısal karşılığıdır; LNA, ADC ve PLL davranışları güncel modele dahil değildir.

### 3.4. Tek koşudan Monte Carlo ortalamasına geçiş

Sonlu bir kayıtta bağımsız referans terimleri tam olarak sıfırlanmadığı için
ölçüm yinelenebilir hale getirilmiştir. Her yinelemede yeni DUT ve referans
gerçekleşimleri üretilir. Aynı yinelemenin iki kanalında DUT ortaktır. Kompleks
Cross-PSD değerleri önce toplanır; büyüklük işlemi kompleks ortalama
tamamlandıktan sonra uygulanır. DUT karşılaştırma eğrisi de aynı yinelemelerdeki
filtresiz DUT periodogramlarının doğrusal güç alanındaki ortalamasıdır. Böylece
ölçüm kestiricisi ve referans eğri aynı Monte Carlo popülasyonuna dayanır.

### 3.5. Hesaplama zincirinin sadeleştirilmesi

İlk yaklaşım zaman bölgesinde `xcorr` üretip diziyi `ifftshift` ile düzenliyor ve
yeniden FFT alıyordu. Güncel yaklaşım korelasyon teoreminden yararlanarak iki
kanal FFT'sinin `X1 .* conj(X2)` çarpımını doğrudan hesaplamaktadır. FFT boyu,
`2M-1` uzunluğunu kapsayan ilk ikinin kuvveti olarak seçilmiştir. Bu sıfır
doldurma frekans ızgarasını sıklaştırır; bağımsız fiziksel çözünürlüğü artırdığı
şeklinde yorumlanmamalıdır.

Performans geliştirmeleri yalnız Cross-PSD formülüyle sınırlı değildir. LPF
katsayıları ayarlar değişmediği sürece önbellekte tutulmakta, iki kanal tek
matris halinde filtrelenmekte, sabit zaman/frekans eksenleri döngü dışında
hazırlanmakta ve spektrum toplam dizileri önceden ayrılmaktadır. Kullanılmayan
Welch çıktıları kaldırılmış, logaritmik bin içindeki tepe değerinin yerine
doğrusal PSD aritmetik ortalaması kullanılmaya başlanmıştır.

### 3.6. Deney altyapısının kurulması

Kod daha sonra `run_simulation(config)` işlevi etrafında modülerleştirilmiş;
tek koşu, parametre karşılaştırmaları, büyük yineleme taraması ve kayıtlı
sonucu yeniden çizme görevleri ayrı giriş betiklerine ayrılmıştır. Her tarama
noktası temiz bir temel config kopyasından başlar. Ham spektrum, süre ve config
bilgileri MAT dosyasına; temel metrikler CSV ve özet MAT dosyasına; eğriler ise
PNG çıktısına kaydedilir. Bu ayrım, uzun simülasyonların sonradan yeniden
çalıştırılmadan incelenmesini sağlar.

### 3.7. MATLAB R2025b uyarlaması

Optimize Octave kaynakları eski dosyalar korunarak `matlab_version/` altına
kopyalanmıştır. MATLAB sürümünde Octave'a özgü `pkg load signal`, `time()` ve
`-mat7-binary` kullanımları kaldırılmıştır. Random stream MATLAB oturumu başında
bir kez `rng("shuffle")` ile başlatılır ve sonraki DUT/Ref örnekleri aynı akıştan
sıralı olarak alınır. Büyük sonuçlar `-v7.3` biçiminde, grafikler
`exportgraphics` ile 150 DPI PNG olarak kaydedilir. Uzun batch koşularında
pencereler gizli tutulur ve isteğe bağlı `progress_interval` alanı Command
Window yazdırma yükünü azaltır.

Bu uyarlama hızlı ardışık çağrılarda aynı zaman seed'ine dönme riskini azaltır;
ancak başlangıç seed'i sonuçlara kaydedilmediği için koşular hâlâ bit düzeyinde
yeniden üretilebilir değildir. Referansların istatistiksel bağımsızlığı da ayrı
bir otomatik testle henüz kanıtlanmış değildir.

### 3.8. Uzun koşuların sürdürülmesi ve sonuç birleştirme

Yineleme sayısı büyüdükçe tek bir tarama noktası uzun sürdüğü için, tamamlanan
sonuçların yeniden hesaplanmadan korunması ayrı bir mühendislik gereksinimi
haline gelmiştir. `0799f9f` commitinde eklenen `extend_iteration_results.m` ve
`extend_iteration_results_main.m`, temel bir yineleme taramasını ve istenirse
başka tamamlanmış taramaları yükler. Birleştirme öncesinde tarama türü,
`summary.mat`/raw dosya bütünlüğü ve `number_of_iterations` dışındaki config
alanları kontrol edilir. Yinelenen yineleme değerlerinde temel kaydın sonucu
korunur; yalnız eksik ve açıkça istenen değerler çalıştırılır. Değerler
sıralanıp yeni bir `_iterations_merged` klasörüne raw MAT, özet ve grafik olarak
yazılır; kaynak sonuç klasörleri değiştirilmez.

MATLAB uyarlamasındaki final yürütme profili bu genel iş akışından türetilmiş,
fakat rapor için `N=1.000.000` ve
`[1, 10, 100, 250, 500, 1000, 5000, 10000, 20000]` noktalarına ayarlanmıştır.
Rapor, birleştirilmiş ya da sürdürülmüş bir koşuyu tek kesintisiz çalışma gibi
sunmamalıdır. Hangi noktaların hangi oturumda üretildiği provenance ekinde
belirtilmeli; süreler farklı oturum/makine yükleri içeriyorsa yalnız gözlenen
süre olarak yorumlanmalıdır.

## 4. Commitlere dayalı değişiklik özeti

| Commit | Tarih | Doğrulanmış değişiklik | Rapordaki karşılığı |
|---|---|---|---|
| `0fa4d8f` | 2026-08-04 | AWGN ve renkli gürültü deneyleri, ilk faz detektörü/cross-correlation modeli ve ilk `generate_phase_noise` yapısı eklendi. | Gürültü üretiminden ilk prototipe geçiş |
| `045fee4` | 2026-08-17 | Ayrı optimize çalışma alanı, config doğrulaması, tarama, yeniden çizim ve benchmark altyapısı eklendi. | Optimize sürüm ve deney otomasyonu |
| `b979435` | 2026-08-18 | Akış `run_simulation(config)` çevresinde sadeleştirildi; giriş betikleri ayrıldı; eski wrapper, kullanılmayan benchmark/test araçları ve eski binleme yardımcıları kaldırıldı; çıktı düzeni standartlaştırıldı. | Modüler API ve bakım kolaylığı |
| `c8c5260` | 2026-08-20 | Her yinelemede yeni DUT üretimi, doğrusal DUT periodogram ortalaması, `run_iterations`, ayrı `mixer`, `lowpass_filter` ve `compute_cross_psd` blokları ile geniş rapor taslağı eklendi. | Adil Monte Carlo karşılaştırması ve devre bloğu ayrımı |
| `9b14de0` | 2026-08-20 | Kök README, handoff notları, config/sonuç sözleşmesi ve raporun kanıt sınırları güncellendi. | Yeniden üretilebilir raporlama disiplini |
| `ed60dc6` | 2026-08-20 | `İki Kanallı Cross.docx` repoya eklendi. | Mevcut rapor başlangıcı |
| `0799f9f` | 2026-08-21 | `run_comparisons` profili `N=1.000.000` ve dokuz LPF noktasına güncellendi; eksik yineleme noktaları için ayrı koşu ve config kontrollü sonuç birleştirme akışı eklendi; DOCX 10 gömülü görselle genişletildi. | Nihai deney profili, kesinti sonrası yeniden kullanma ve güncel 10 sayfalık rapor omurgası |

Not: `CHANGES.md`, doğrudan FFT, radix-2 FFT ve log-bin ortalaması gibi temel
kararların 7 Ağustos'taki geliştirme evresinde başladığını kaydetmektedir. Git
geçmişinde 7 Ağustos tarihli ayrı bir commit yoktur; bu kararların repodaki ilk
toplu izi 17 Ağustos tarihli optimize sürüm commitidir. Raporda bu ayrım
korunmalı, commit tarihi staj günüymüş gibi sunulmamalıdır.

`matlab_version/` uyarlaması mevcut inceleme anında henüz commitlenmemiş çalışma
ağacı içeriğidir; `README_MATLAB.md` kaynak senkron noktası olarak `0799f9f`
değerini kaydetmektedir. Bu SHA, MATLAB portunun kendisinin commitlendiği
anlamına gelmez. Son raporun provenance ekinde MATLAB uyarlamasını ve nihai
sonuç dosyalarını taşıyan gerçek commit SHA değeri, commit tamamlandıktan sonra
eklenmelidir.

## 5. Teknik olarak doğrulanmış ifade bankası

Aşağıdaki cümleler güncel MATLAB kaynaklarıyla doğrulanmıştır ve raporda
kullanılabilir:

1. Güncel model, beyaz Gauss gürültüsünü frekans bölgesinde
   `1/sqrt(k^3)` ile şekillendirerek sentetik `1/f^3` faz gürültüsü üretir ve
   her gerçekleşimi hedef RMS değerine normalize eder.
2. Aynı yinelemede iki ölçüm kanalı aynı DUT taşıyıcısını kullanır; Ref1 ve Ref2
   ayrı `randn` örnek dizilerinden oluşturulur.
3. Referans taşıyıcılarının merkez fazı DUT'a göre `pi/2` kaydırılır. Böylece
   çarpım faz dedektörü küçük faz farklarına duyarlı bölgede çalışır.
4. Karıştırıcı çıkışları nedensel dördüncü derece Butterworth `filter` çağrısıyla
   alçak geçiren filtreden geçirilir; `filtfilt` kullanılmaz.
5. Küçük işaret faz dedektörü kazancı `K_pd=A^2/2` olarak alınır ve filtre
   çıkışları bu değere bölünür.
6. Kompleks Cross-PSD, `X1 .* conj(X2) / (fs*M)` ile hesaplanır. Tek taraflı
   dönüşümde DC ve Nyquist kutuları ikiyle çarpılmaz.
7. Cross-PSD büyüklüğü her yinelemede alınmaz; kompleks spektrumlar önce
   ortalanır, büyüklük daha sonra uygulanır.
8. DUT referansı, aynı yinelemelerde üretilen filtresiz DUT faz dizilerinin
   dikdörtgen pencereli periodogramlarının doğrusal PSD ortalamasıdır.
9. Logaritmik bin merkezleri geometrik ortalamayla, bin güçleri doğrusal
   aritmetik ortalamayla hesaplanır; dBc/Hz dönüşümü binlemeden sonra yapılır.
10. MAE, iki log-bin eğrinin ortak frekans aralığında 200 logaritmik frekans
    noktasına enterpolasyonundan sonra hesaplanan ortalama mutlak dB farkıdır.
11. MATLAB tarama yöneticisi her koşu için ham `-v7.3` MAT, özet MAT/CSV ve 150
    DPI PNG üretir.
12. R&S uygulama notuna göre bağımsız kanal gürültüsünün ortalamayla azalması
    ideal durumda yaklaşık `5 log10(K)` dB düzeyindedir; örneğin kaynak 100
    korelasyon için 10 dB, 10.000 korelasyon için 20 dB iyileşme örneği verir.

### Mutlaka koşullu yazılması gereken ifadeler

- `Ref1 ve Ref2 bağımsızdır` yerine `modelde bağımsız kabul edilmiş ve ayrı
  rastgele örnek dizilerinden üretilmiştir` denmelidir; bağımsızlık için
  otomatik korelasyon testi yoktur.
- `Yeni yöntem eski yöntemle tamamen eşdeğerdir` yerine `açık korelasyon dizisi
  korelasyon teoremine dayalı doğrudan spektral çarpımla değiştirilmiştir`
  denmelidir. Aynı deterministik veriyle eşdeğerlik testi henüz yoktur.
- Kontrollü benchmark tamamlanmadan `x kat hızlanma` yazılmamalıdır. Kod yapısı
  işlem zincirini kısaltır; sayısal hız iddiası yalnız ölçümle verilmelidir.
- Sıfır doldurma için `frekans çözünürlüğünü artırdı` denmemeli; `frekans
  ızgarasını sıklaştırdı ve FFT'yi uygun uzunluğa taşıdı` denmelidir.
- R&S donanım şeması raporda gösterilse bile MATLAB modelinin PLL, LNA, ADC,
  kuantalama, saat jitteri, kanal kazanç/faz uyumsuzluğu ve donanım gürültü
  tabanını modellemediği yazılmalıdır.
- Kodun doğrusal olmayan faz dedektörü için kullandığı düzeltme, bütün pozitif
  frekans bandından elde edilen tek bir global katsayıdır. `Tam fiziksel
  kalibrasyon` olarak sunulmamalıdır.
- Güncel MAE LPF geçiş bandıyla sınırlandırılmamıştır. Bu nedenle LPF kesim
  taramasındaki farkların bir bölümü, filtrelenmiş Cross-PSD ile filtresiz DUT
  referansının tüm ortak bantta karşılaştırılmasından kaynaklanabilir.
- `settling_samples=0` kullanılan koşularda IIR başlangıç geçicisinin otomatik
  olarak elendiği iddia edilmemelidir.
- Sonuç eğrileri doğrulanmadan `monoton iyileşme`, `en iyi ayar` veya `başarıyla
  doğrulandı` ifadeleri kullanılmamalıdır. Monte Carlo koşuları dalgalanabilir.

## 6. R&S ve proje görsellerinin kullanım planı

Güncel DOCX 10 gömülü görsel taşımaktadır. R&S uygulama notundan alınan
kavramsal görseller korunabilir; ancak MATLAB grafiklerinden elde edilen proje
sonuçlarıyla karıştırılmamalıdır. Her doğrudan alıntı görselinin altında
`Kaynak:` satırı bulunmalı, mevcut şekil numaraları benzersiz hale
getirilmelidir.

1. **Faz gürültüsü kavramı:** R&S Part 1, Fig. 2-1, birleşik PDF s. 4. İdeal ve
   gerçek işaretin zaman/frekans alanındaki farkını girişte göstermek için
   uygundur.
2. **Faz gürültüsünün nicelendirilmesi:** R&S Part 1, Fig. 2-4, birleşik PDF
   s. 8. Offset frekansı ve dBc/Hz eksenlerini tanımlamak için kullanılabilir.
3. **İki kanallı donanım mimarisi:** R&S Part 2, Fig. 2-8, birleşik PDF s. 20.
   Çapraz korelasyon bölümünde kullanılmalı; altında MATLAB modelinin hangi
   blokları kapsadığı açıklanmalıdır.
4. **Özgün proje blok şeması:** Belgedeki mevcut genel sistem ve fonksiyon akış
   şemaları korunmalı; DUT/Ref üretimi -> iki mixer -> LPF ->
   `K_pd` normalizasyonu -> DC/settling -> kompleks Cross-PSD -> yineleme
   ortalaması -> log-bin -> dBc/Hz sırası eksikse diyagrama eklenmelidir.
5. **MATLAB karşılaştırma grafikleri:** Belgedeki mevcut LPF, DUT RMS ve Ref RMS
   grafikleri eski değer listeleriyle üretildiyse korunmamalıdır. Tamamlanan
   güncel `run_comparisons` koşusundan
   LPF, DUT RMS, Ref RMS, yineleme ve log-bin PNG'leri kullanılmalıdır. Her
   şekil başlığında değiştirilen parametre ve sabit tutulan temel config kısa
   biçimde yazılmalıdır.
6. **Büyük yineleme grafiği:** Kesintiden sonra tamamlanan/birleştirilen
   `run_iterations` klasöründeki son karşılaştırma PNG'si kullanılmalıdır.
   Grafik, ilgili bütün ham MAT dosyaları ve özetle aynı config'e ait olduğu
   doğrulanmadan rapora alınmamalıdır.

R&S Fig. 2-9'daki ticari analizör ekran görüntüsü, projenin ölçüm sonucu gibi
algılanabileceği için sonuç bölümünde kullanılmamalıdır. Kavramsal örnek olarak
kullanılacaksa bunun dış kaynağa ait olduğu başlıkta açıkça belirtilmelidir.

Kaynakçada kullanılabilecek temel künye:

> Rohde & Schwarz, *Mastering Phase Noise Measurements* (Parts 1-3),
> Application Note, 2016,
> <https://cdn.rohde-schwarz.com/am/us/campaigns_2/embedded/Rohde_Schwarz_Phase_Noise_App_Note_Allparts.pdf>.

İncelenen yerel kopya:
`matlab_version/report_assets/rohde_schwarz/Rohde_Schwarz_Phase_Noise_App_Note_Allparts.pdf`.

Önerilen şekil başlığı örnekleri:

> **Şekil 1.** İdeal ve faz gürültülü işaretin zaman ve frekans alanındaki
> gösterimi. Kaynak: Rohde & Schwarz, *Mastering Phase Noise Measurements*,
> Part 1, Fig. 2-1, birleşik PDF s. 4.

> **Şekil 3.** Faz dedektörü tabanlı iki kanallı çapraz korelasyon ölçüm
> mimarisi. Kaynak: Rohde & Schwarz, *Mastering Phase Noise Measurements*,
> Part 2, Fig. 2-8, birleşik PDF s. 20.

> **Şekil X.** MATLAB modelinde [değiştirilen parametre] taraması için
> Cross-PSD kestirimi ve aynı yinelemelerin ortalama filtresiz DUT
> periodogramı. Kaynak: Bu çalışma.

## 7. Rapor için hazır Türkçe bölüm taslağı

Aşağıdaki metin sonuç sayıları dışında doğrudan son rapora uyarlanabilir.
Köşeli parantezli alanlar, yalnız nihai dosyalar doğrulandıktan sonra
doldurulmalıdır.

### Önerilen başlık

**İki Kanallı Cross-PSD Yöntemiyle Faz Gürültüsü Ölçümü: MATLAB Benzetimi,
Algoritmik Optimizasyon ve Parametre İncelemesi**

### Özet

Bu çalışmada, bir test edilen cihazın (Device Under Test, DUT) faz gürültüsünü
iki bağımsız referans kanalı üzerinden kestiren çapraz korelasyon yöntemi MATLAB
R2025b ortamında modellenmiştir. Yöntemin temel amacı, iki kanalda ortak olan
DUT faz gürültüsünü korurken kanallara özgü referans gürültüsü bileşenlerini
kompleks çapraz güç spektral yoğunluğu (Cross-PSD) ortalamasıyla bastırmaktır.

Benzetimde DUT ve iki referans için kontrollü RMS değerine sahip sentetik
`1/f^3` faz gürültüsü üretilmiştir. DUT taşıyıcısı, 90 derece merkez faz
farkındaki iki referansla ayrı kanallarda karıştırılmış; karıştırıcı çıkışları
Butterworth alçak geçiren filtreden geçirilmiş ve faz dedektörü kazancıyla
normalize edilmiştir. İki taban bant kanalının kompleks Cross-PSD'si doğrudan
FFT çarpımıyla hesaplanmış, aynı yinelemelerdeki DUT periodogramları doğrusal
güç alanında ortalanmış ve sonuçlar dBc/Hz cinsine dönüştürülmüştür.

İlk uygulamadaki açık `xcorr -> ifftshift -> fft` zinciri, korelasyon teoremine
dayalı doğrudan `FFT(x1) * conj(FFT(x2))` hesabıyla değiştirilmiştir. FFT
uzunluğunun ikinin kuvvetine taşınması, LPF katsayılarının önbelleğe alınması,
iki kanalın birlikte filtrelenmesi, sabit hesapların döngü dışına çıkarılması
ve sonuç üretiminin modüler tarama betiklerinde toplanması diğer temel
iyileştirmelerdir.

Tamamlanan testlerde [ANA BULGU, SAYI VE KOŞUL] gözlenmiştir. Büyük yineleme
çalışmasında [İLK VE SON NOKTA KARŞILAŞTIRMASI] elde edilmiştir. Bulgular,
[TEORİYLE UYUMLU NİTEL SONUÇ] göstermekle birlikte, mevcut MAE tanımının geniş
frekans bandı, kaydedilmeyen RNG seed'i ve ideal donanım varsayımları sonuçların
yorumunda sınır oluşturmaktadır.

**Anahtar kelimeler:** Faz gürültüsü, çapraz korelasyon, Cross-PSD, FFT, faz
dedektörü, MATLAB, dBc/Hz.

### 1. Giriş

İdeal bir osilatör, frekans bölgesinde yalnız taşıyıcı frekansında bulunan dar
bir spektral çizgi üretir. Gerçek osilatörlerde termal etkiler, aktif eleman
gürültüsü, rezonatör kayıpları, besleme değişimleri ve çevresel koşullar sinyalin
anlık fazında rastgele sapmalara neden olur. Bu sapmalar taşıyıcının çevresinde
gürültü yan bantları meydana getirir ve faz gürültüsü olarak adlandırılır.

Faz gürültüsü haberleşme sistemlerinde modülasyon kalitesini ve komşu kanal
performansını, radar sistemlerinde zayıf hedeflerin güçlü yansımalar yakınında
ayırt edilmesini, sayısal sistemlerde ise saat jitteri ve örnekleme doğruluğunu
sınırlar. Bu nedenle düşük faz gürültülü bir osilatörün yalnız tasarlanması
değil, ölçüm sisteminin kendi gürültü tabanının altında güvenilir biçimde
karakterize edilmesi de önemlidir.

Tek kanallı faz dedektörü ölçümünde DUT ve referans gürültüsü aynı çıkışta
toplanır. Referansın veya analiz kanalının gürültüsü DUT gürültüsünden yüksekse
ölçüm tabanı DUT'u örtebilir. İki kanallı çapraz korelasyon yaklaşımı aynı DUT'u
iki ayrı referansla ölçerek bu sınırlamayı azaltır. DUT bileşeni iki kanalda
ortaktır; referanslara özgü bileşenler ise korelasyonsuz kabul edilir ve çoklu
ölçüm ortalamasında azalır.

Bu projenin amacı söz konusu ölçüm ilkesini MATLAB ortamında kurmak, modelin
fiziksel ve sayısal bloklarını birbirinden ayırmak, uzun Monte Carlo
çalışmalarına uygun hale getirmek ve temel parametrelerin Cross-PSD kestirimine
etkisini incelemektir.

### 2. Faz gürültüsü ve spektral gösterim

Faz gürültüsü içeren bir taşıyıcı

\[
x(t)=A\cos\left(2\pi f_0t+\varphi(t)\right)
\]

ifadesiyle modellenebilir. Burada `A` nominal genliği, `f0` taşıyıcı
frekansını ve `varphi(t)` zamana bağlı faz sapmasını göstermektedir. Bu
çalışmada genlik gürültüsü ayrıca modellenmemiş, yalnız faz sapması ele
alınmıştır.

Faz gürültüsü çoğunlukla taşıyıcıdan belirli bir offset frekansındaki 1 Hz
bant genişliğine normalize edilmiş tek yan bant güç oranı olarak verilir.
Küçük faz yaklaşımında tek taraflı faz PSD'si `S_varphi(f)` ile SSB faz
gürültüsü arasındaki ilişki

\[
L(f)=10\log_{10}\left(\frac{S_\varphi(f)}{2}\right)
\]

şeklindedir ve sonuç dBc/Hz birimiyle ifade edilir.

Gerçek osilatör spektrumlarında farklı fiziksel mekanizmalar farklı eğimler
oluşturabilir. Beyaz PM, flicker PM, beyaz FM, flicker FM ve rastgele yürüyüş
FM bileşenleri sırasıyla yaklaşık `f^0`, `1/f`, `1/f^2`, `1/f^3` ve `1/f^4`
PSD davranışlarıyla temsil edilir. Bu çalışmadaki sentetik kaynak yalnız
`1/f^3` davranışını üretmektedir. Dolayısıyla model, bütün bir osilatör
spektrumundan ziyade yakın offsetteki flicker FM karakterini kontrollü biçimde
inceleyen sınırlı bir benzetimdir.

### 3. Faz gürültüsü ölçüm yöntemleri ve yöntem seçimi

Faz gürültüsü doğrudan spektrum analizi, tek kanallı faz dedektörü, gecikme
hattı ayırıcısı ve sayısal demodülasyon gibi farklı yöntemlerle ölçülebilir.
Doğrudan spektrum analizi basit ve hızlıdır; ancak ölçülebilecek en düşük seviye
analizörün yerel osilatörü ve iç gürültü tabanı tarafından sınırlandırılır. Faz
dedektörü yöntemi daha yüksek hassasiyet sağlayabilir, fakat referans
osilatörün gürültüsü de ölçüm çıkışına eklenir.

İki kanallı yaklaşım, faz dedektörü zincirini farklı referans kullanan ikinci
bir kanalla çoğaltır. Bu yöntemde daha düşük ölçüm tabanı, donanım gürültüsünün
doğrudan yok edilmesiyle değil, kanallara özgü terimlerin istatistiksel
ortalamasıyla elde edilir. Bu nedenle referans kanallarının ortak sızıntı,
ortak saat veya benzer sistematik etkiler taşımaması kritik önemdedir.

### 4. İki kanallı Cross-PSD yönteminin matematiksel temeli

Küçük faz farkı bölgesinde iki faz dedektörü çıkışı, seçilen quadrature yönüne
bağlı ortak bir işaret katsayısıyla yaklaşık olarak

\[
y_1(t)=s\,[\varphi_D(t)-\varphi_{R1}(t)],\qquad
y_2(t)=s\,[\varphi_D(t)-\varphi_{R2}(t)],\qquad s\in\{-1,+1\}
\]

biçiminde düşünülebilir. DUT fazı iki kanalda ortak, referans fazları ise
kanala özgüdür. Ortak işaret katsayısı PSD sonucunu değiştirmez. Frekans
bölgesinde iki çıkışın çapraz spektrumu

\[
S_{12}(f)=\mathrm{E}\{Y_1(f)Y_2^*(f)\}
\]

olarak tanımlanır. DUT ile referanslar ve iki referans kendi aralarında
korelasyonsuz kabul edildiğinde çapraz terimlerin beklenen değeri sıfıra
yaklaşır ve

\[
S_{12}(f)\approx S_D(f)
\]

elde edilir. Sonlu kayıt ve sonlu yineleme sayısında kanala özgü terimler tam
olarak yok olmaz. Bu nedenle kompleks çapraz spektrumlar çok sayıda bağımsız
gerçekleşim üzerinden ortalanır. İdeal bağımsız gürültü durumunda kalan
belirsizliğin standart sapması yaklaşık `1/sqrt(K)` ile azalır; dB cinsinden
ölçüm tabanı iyileşmesi yaklaşık `5 log10(K)` mertebesindedir.

### 5. MATLAB benzetim modelinin gerçekleştirilmesi

Her Monte Carlo yinelemesinde yeni bir DUT faz dizisi ve iki ayrı referans faz
dizisi oluşturulur. Aynı DUT taşıyıcısı iki kanala uygulanırken referanslar ayrı
rastgele örneklerden üretilir. Referansların merkez fazına `pi/2` eklenir ve
DUT her referansla örnek örnek çarpılır. Çarpım, faz farkını taşıyan taban bant
bileşeni ile yaklaşık `2f0` çevresindeki toplam frekans bileşenini birlikte
içerir. Dördüncü derece Butterworth LPF yüksek frekanslı bileşeni bastırır.

Filtre çıkışları küçük işaret faz dedektörü kazancı

\[
K_{pd}=\frac{A^2}{2}
\]

ile normalize edilir. Seçilen başlangıç örnekleri atıldıktan sonra her kanalın
DC bileşeni kaldırılır. İki kanalın FFT'si alınır ve kompleks tek taraflı
Cross-PSD

\[
\hat S_{12}[k]=\frac{X_1[k]X_2^*[k]}{f_sM}
\]

ile hesaplanır. DC ve Nyquist kutuları tek taraflı dönüşümde ikiyle
çarpılmaz. Kompleks spektrumlar bütün yinelemeler boyunca toplandıktan sonra
ortalama alınır; kanala özgü kompleks terimlerin birbirini götürebilmesi için
büyüklük işlemi bu aşamadan sonra uygulanır.

Aynı yinelemelerde üretilen DUT faz dizilerinin filtresiz periodogramları da
doğrusal güç alanında ortalanır. Böylece Cross-PSD kestirimi farklı bir DUT
örneğiyle değil, aynı Monte Carlo popülasyonunun ortalama DUT spektrumuyla
karşılaştırılır. Spektrumlar logaritmik frekans kutularında doğrusal güç
ortalamasıyla birleştirildikten sonra SSB dBc/Hz'e dönüştürülür.

R&S donanım mimarisinde bulunan PLL, LNA ve ADC blokları güncel MATLAB modelinde
ayrıca gerçekleştirilmemiştir. Taşıyıcıların tam frekans eşitliği ve quadrature
durumu doğrudan sayısal ifadelerle sağlanır; yükselteç gürültüsü, kuantalama,
örnekleme saati jitteri ve kanal uyumsuzlukları ideal kabul edilir.

### 6. Algoritmik optimizasyon ve yazılım mimarisi

İlk prototipte iki kanalın zaman bölgesi çapraz korelasyonu `xcorr` ile
üretiliyor, gecikme dizisi `ifftshift` ile düzenleniyor ve spektruma dönmek için
yeniden FFT uygulanıyordu. Güncel uygulama aynı korelasyon ilkesini doğrudan
frekans bölgesinde değerlendirir. İki kanal FFT'sinin eşlenik çarpımı, açık
korelasyon dizisini ve ek dönüşümü ortadan kaldırır.

FFT boyu `2M-1` değerini kapsayan ilk ikinin kuvveti olarak belirlenmiştir.
Bu seçim FFT uygulaması için elverişli bir radix-2 uzunluk sağlar. Sıfır
doldurma frekans örneklerini sıklaştırır; kayıt süresinin belirlediği bağımsız
çözünürlüğü değiştirmez.

Butterworth katsayıları `fs`, kesim frekansı veya filtre derecesi değişene kadar
`persistent` önbellekte tutulur. İki kanal aynı filtre çağrısının kolonları
olarak işlenir. Taşıyıcı fazı, quadrature fazı, `K_pd`, FFT boyu ve spektrum
toplam dizileri yineleme döngüsünden önce hazırlanır. Cross-PSD ve DUT
periodogramları dB alanında değil doğrusal/kompleks alanda toplanır. Bu
değişiklikler, kodun hem hesaplama yükünü hem de işlev sorumluluklarını daha
kontrollü hale getirmiştir.

### 7. Deney tasarımı ve sonuç üretimi

MATLAB sürümünde `run_comparisons.m`, LPF kesim frekansı, DUT RMS, iki
referansın ortak RMS değeri, yineleme sayısı ve logaritmik bin sayısını ayrı
tek-parametre taramaları olarak çalıştırır. Tarama noktaları Kartezyen çarpım
değildir; her koşul temiz bir temel config kopyasından başlar ve yalnız ilgili
parametre değiştirilir.

#### 7.1. Güncel `run_comparisons` profili

`0799f9f` ile senkronize MATLAB portundaki temel karşılaştırma profili şöyledir:

| Parametre | Değer |
|---|---:|
| Örnek sayısı `N` | 1.000.000 |
| Örnekleme frekansı `fs` | 1 MHz |
| Taşıyıcı frekansı `f0` | 200 kHz |
| Taşıyıcı genliği `A` | 1 |
| Atılan geçici rejim örneği | 0 |
| LPF kesim frekansı / derece | 200 kHz / 4 |
| DUT RMS | 0,05 rad |
| Ref1 / Ref2 RMS | 0,05 / 0,05 rad |
| Temel yineleme sayısı | 100 |
| Logaritmik bin sayısı | 100 |

Bağımsız tarama listeleri:

| Tarama | Değerler |
|---|---|
| LPF kesimi | 1, 5, 10, 25, 50, 75, 100, 200, 300 kHz |
| DUT RMS | 0,01; 0,02; 0,05; 0,10; 0,20; 0,50 rad |
| Ref1 = Ref2 RMS | 0,01; 0,02; 0,05; 0,10; 0,20; 0,50 rad |
| Yineleme | 1, 10, 100, 200, 500, 1000 |
| Log-bin | 10, 25, 50, 80, 100, 200 |

#### 7.2. Güncel `run_iterations` profili

Uzun yineleme taraması, karşılaştırma profilinden farklı bir duyarlılık
senaryosudur ve sonuçları aynı tabloya config farkı belirtilmeden
birleştirilmemelidir:

| Parametre | Değer |
|---|---:|
| Örnek sayısı `N` | 1.000.000 |
| Örnekleme frekansı / taşıyıcı | 1 MHz / 200 kHz |
| LPF kesimi / derece | 100 kHz / 4 |
| DUT RMS | 0,02 rad |
| Ref1 / Ref2 RMS | 0,05 / 0,05 rad |
| Log-bin | 100 |
| Yineleme listesi | 1, 10, 100, 250, 500, 1000, 5000, 10000, 20000 |

Referanslar ve DUT aynı `1/f^3` spektral biçimine göre üretildiği için, bu
profilde bir referansın teorik PSD seviyesi DUT seviyesinden yaklaşık

\[
\Delta L=10\log_{10}\!\left(\frac{\sigma_{ref}^{2}}
{\sigma_{DUT}^{2}}\right)
=20\log_{10}\!\left(\frac{0{,}05}{0{,}02}\right)
\approx 7{,}96\ \mathrm{dB}
\]

daha yüksektir. Bu hesap, yarım kalan 7.5 bölümündeki cümleyi tamamlar; bir
simülasyon bulgusu değil, eş spektral şekil ve RMS ölçeklemesinden gelen teorik
başlangıç farkıdır.

#### 7.3. Sonuç kanıt zinciri

Her tarama noktası için tam spektrum ve gerçek config `raw/*.mat` dosyasına;
MAE, düzeltme katsayısı ve gözlenen süre `summary.csv` dosyasına; tarama
manifesti `summary.mat` dosyasına; karşılaştırma eğrileri ise `plots/*.png`
dosyasına kaydedilir. Yeni sonuçlar geldiğinde aşağıdaki kontrol tamamlanmadan
rapor metni doldurulmamalıdır:

1. `summary.csv` satır sayısı ve `value` dizisi beklenen tarama listesiyle
   eşleşmelidir.
2. Her CSV satırındaki raw MAT dosyası açılmalı; `current_results.config.N`
   değerinin 1.000.000 olduğu ve taranan alan dışında config'in değişmediği
   doğrulanmalıdır.
3. `summary.mat` içindeki `values`, `run_files`, MAE, düzeltme ve süre dizileri
   CSV ile eşleşmelidir.
4. PNG açılmalı; panel sayısı, legend, eksenler, `(orig)` işareti ve görünür
   anomali/tepe noktaları kontrol edilmelidir.
5. `run_comparisons` ve `run_iterations` klasörleri farklı config'e sahip
   oldukları için aynı seri gibi çizilmemeli; her şekil başlığında kendi sabit
   profili verilmelidir.
6. Süre yalnız aynı MATLAB sürümü, makine ve koşu bağlamında karşılaştırılmalı;
   kesinti sonrası sürdürülen nokta ayrıca işaretlenmelidir.

### 8. Yeni `N=1.000.000` sonuçları için hazır bölüm metni

Aşağıdaki paragraflardaki köşeli alanlar yalnız final CSV/MAT/PNG çapraz
doğrulamasından sonra doldurulmalıdır. `En iyi`, `optimum`, `monoton` ve
`doğrulandı` sözcükleri ancak bütün tarama değerleri bu iddiayı gerçekten
destekliyorsa kullanılmalıdır.

#### 8.1. LPF kesim frekansının etkisi

> Şekil [7.1], `1-300 kHz` aralığındaki dokuz LPF kesim frekansı için
> Cross-PSD kestirimiyle aynı yinelemelerde üretilen filtresiz DUT
> periodogramını karşılaştırmaktadır. Bütün koşullarda `N=1.000.000`,
> `f0=200 kHz`, DUT/Ref RMS `0,05 rad` ve 100 yineleme sabit tutulmuştur.
> [GÖZLENEN LPF EĞİLİMİ]. Bu taramada en düşük resmî MAE [FC] kHz için [MAE]
> dB, en yüksek değer ise [FC] kHz için [MAE] dB olarak bulunmuştur.

> Cross-PSD kanalları LPF'den geçtiği halde karşılaştırma eğrisi filtresiz DUT
> periodogramı olduğundan resmî MAE, geçiş ve durdurma bandındaki beklenen
> farkı da içermektedir. Bu nedenle [SEÇİLEN FC] değerinin "mutlak optimum"
> olduğu değil, yalnız bu config ve bu geniş bant metrik altında [GÜVENLİ
> SONUÇ] verdiği söylenebilir. Grafikte `2f0=400 kHz` yakınında kalıcı bir tepe
> görülürse bunun mixer toplam-frekans ürünüyle uyumlu bir kalıntı olduğu,
> ayrı filtre-cevap analizi yapılmadan kesin neden/bastırma değeri
> verilemeyeceği belirtilmelidir.

#### 8.2. DUT RMS değerinin etkisi

> Şekil [7.2], DUT RMS değeri `0,01-0,50 rad` arasında değiştirilirken
> referansların `0,05 rad` ve diğer parametrelerin temel değerlerde tutulduğu
> sonuçları göstermektedir. DUT RMS arttıkça ideal PSD seviye farkı
> `20 log10(sigma_2/sigma_1)` bağıntısıyla değişmektedir. [DOĞRULANMIŞ DUT RMS
> EĞİLİMİ]. En düşük gözlenen MAE [RMS] rad noktasında [MAE] dB'dir; bu nokta
> tek taramadan genel çalışma optimumu olarak yorumlanmamıştır.

> Düzeltme katsayısı [ARALIK] arasında değişmiştir. Katsayının yüksek RMS
> noktalarında [DAVRANIŞ] göstermesi, küçük-açı yaklaşımından uzaklaşmanın
> [NİTEL YORUM] olduğunu göstermektedir. Bu katsayı sayısal modelde kullanılan
> global bir güç düzeltmesidir; donanım kalibrasyonu değildir.

#### 8.3. Referans RMS değerinin etkisi

> Şekil [7.3]'te Ref1 ve Ref2 RMS değerleri birlikte `0,01-0,50 rad` arasında
> değiştirilmiş, DUT RMS `0,05 rad` ve yineleme sayısı 100 olarak sabit
> tutulmuştur. Referans dizileri ayrı rastgele örneklerden üretilmiş ve modelde
> korelasyonsuz kabul edilmiştir. [DOĞRULANMIŞ REFERANS RMS EĞİLİMİ]. Özellikle
> [ARALIK] bölgesinde [GÖZLEM], sonlu yineleme sayısında daha yüksek referans
> gürültüsünün daha fazla ortalama gerektirdiği yorumuyla uyumludur.

> Tarama [MONOTON / MONOTON DEĞİL] bir davranış göstermiştir. Ara noktalardaki
> [SAPMA], her değer için yeni rastgele gerçekleşim üreten tek koşulu Monte
> Carlo taramasının değişkenliği nedeniyle kesin bir sıralama olarak
> yorumlanmamıştır.

#### 8.4. Genel karşılaştırma profilinde yineleme sayısı

> Şekil [7.4a], temel `run_comparisons` profilinde 1, 10, 100, 200, 500 ve
> 1000 yinelemeyi karşılaştırmaktadır. MAE, [İLK DEĞER] dB'den [SON DEĞER]
> dB'ye [AZALMIŞ/DEĞİŞMİŞ], ancak [MONOTONLUK GÖZLEMİ]. Bu sonuç, yineleme
> sayısının artmasının rastgele kanal terimlerini genel olarak bastırdığına
> [DESTEK DÜZEYİ] sağlamaktadır; tek başına istatistiksel güven aralığı
> oluşturmaz.

#### 8.5. Logaritmik bin sayısının etkisi

> Şekil [7.4b], 10, 25, 50, 80, 100 ve 200 logaritmik bin için elde edilen
> eğrileri göstermektedir. [DÜŞÜK BİN GÖZLEMİ]; [YÜKSEK BİN GÖZLEMİ]. Bu
> taramada [BİN] değeri [MAE] dB ile en düşük gözlenen MAE'yi vermiştir. Bununla
> birlikte her bin değeri için yeni rastgele gerçekleşimler üretildiğinden
> fark yalnız binleme çözünürlüğüne bağlanmamış ve "istatistiksel optimum"
> iddiası yapılmamıştır. Binleme etkisini izole etmek için aynı tam çözünürlüklü
> PSD'nin farklı bin sayılarıyla yeniden işlenmesi önerilmektedir.

#### 8.6. Uzun yineleme taraması

> Şekil [7.5], DUT RMS'in `0,02 rad`, referans RMS değerlerinin `0,05 rad`, LPF
> kesiminin `100 kHz` ve örnek sayısının `N=1.000.000` olduğu özel profilde
> yineleme sayısının etkisini göstermektedir. Bir referansın teorik PSD seviyesi
> DUT seviyesinden yaklaşık 7,96 dB yüksektir. 1 yinelemede [MAE_1] dB olan
> resmî MAE, 20.000 yinelemede [MAE_20000] dB olmuştur; mutlak değişim
> [DELTA_MAE] dB'dir. [ARA NOKTALARDAKİ MONOTONLUK/PLATO GÖZLEMİ].

> [K1] ile [K2] arasında süre [SÜRE ORANI] katına çıkarken MAE yalnız [MAE
> DEĞİŞİMİ] dB değişmiştir. Bu bulgu [AZALAN GETİRİ / HENÜZ YAKINSAMAMA]
> biçiminde yorumlanmıştır. Farklı bir oturumda tamamlanan bir nokta varsa süre
> oranı kontrollü benchmark değil, yalnız gözlenen çalışma süresidir.

R&S uygulama notundaki ideal bağımsız kanal yaklaşımı, korelasyon sayısı `K`
arttıkça kanal gürültü tabanında yaklaşık `5 log10(K)` dB iyileşme bekler.
Kodun resmî MAE'si ise filtrelenmiş Cross-PSD ile filtresiz DUT eğrisinin geniş
bant dB farkıdır; gürültü tabanı iyileşmesiyle aynı büyüklük değildir. Bu
nedenle hazır tartışma cümlesi şu olmalıdır:

> Yineleme sayısı arttıkça gözlenen [NİTEL EĞİLİM], bağımsız kanal terimlerinin
> ortalamayla azalması yönündeki kuramsal beklentiyle uyumludur. Bununla
> birlikte `5 log10(K)` bağıntısı resmî MAE değerine doğrudan uygulanmamış;
> sonlu kayıt, LPF transferi, filtresiz karşılaştırma eğrisi ve diğer sistematik
> etkiler nedeniyle karşılaştırma nitel düzeyde tutulmuştur.

### 9. Tartışma ve sınırlamalar

Sonuçlar doğrulandıktan sonra tartışmanın açılışı aşağıdaki yapıdan
oluşturulabilir:

> Beş parametrik tarama ve özel uzun-yineleme çalışması birlikte
> değerlendirildiğinde, [GENEL ANA BULGU] görülmüştür. Yineleme sayısındaki
> artış [YAKINSAMA BULGUSU] sağlarken, LPF taraması [FİLTRE BULGUSU], DUT ve
> referans RMS taramaları ise [SİNYAL/REFERANS DENGESİ BULGUSU] göstermiştir.
> Böylece sonuç yalnız daha fazla ortalamanın etkisini değil, ölçüm zincirinin
> bant sınırlaması ve faz dedektörü çalışma bölgesiyle birlikte
> değerlendirilmesi gerektiğini ortaya koymuştur.

> Uzun taramada [K_ARALIĞI] için gözlenen [MAE/SPEKTRAL UYUM EĞİLİMİ], ortak
> DUT bileşeninin korunması ve korelasyonsuz kabul edilen referans terimlerinin
> ortalamada azalmasıyla uyumludur. Bununla birlikte [MONOTON OLMAYAN
> NOKTALAR/PLATO], her tarama noktasının tek rastgele koşudan oluşması ve resmî
> metriğin LPF dışı bölgeyi de içermesi nedeniyle teorik `5 log10(K)`
> bağıntısıyla birebir eşleştirilmemiştir.

Aşağıdaki sınırlama metni sayı beklemeden kullanılabilir:

Model, iki kanallı çapraz korelasyon ölçümünün temel istatistiksel davranışını
incelemek için tasarlanmıştır; ticari bir faz gürültüsü analizörünün bütün
donanım davranışlarını temsil etmez. Özellikle PLL dinamiği, LNA gürültüsü, ADC
kuantalaması, örnekleme saati jitteri, kanal sızıntısı ve kazanç/faz uyumsuzluğu
ideal kabul edilmiştir. Bu nedenle benzetimde ulaşılan gürültü tabanı gerçek
donanımın mutlak duyarlılık değeri olarak yorumlanamaz.

Gürültü üreticisi tek bir `1/f^3` eğimi oluşturur ve her gerçekleşimi toplam
RMS'e göre normalize eder. Gerçek bir osilatörde farklı offset bölgelerinde
birden fazla güç yasası bileşeni ve ayrık spur'lar bulunabilir. Ayrıca MATLAB
random stream'inin başlangıç durumu kaydedilmediğinden koşular birebir yeniden
üretilemez. Ref1 ve Ref2 ayrı rastgele dizilerden alınsa da aralarındaki
korelasyon için otomatik kabul testi henüz yoktur.

MAE, log-binlenmiş Cross-PSD ile filtresiz DUT periodogramını bütün ortak
pozitif frekans aralığında karşılaştırır. Bu tanım özellikle LPF kesim taraması
için fiziksel ölçüm bandıyla tam örtüşmeyebilir. `settling_samples=0` kullanılan
final profillerde IIR filtrenin başlangıç geçicisi ayrıca atılmamıştır. Tarama
noktaları farklı rastgele gerçekleşimlerden oluştuğu ve her config yalnız bir
kez çalıştırıldığı için küçük metrik farkları istatistiksel üstünlük kanıtı
değildir.

Gelecek sürümde üst düzey RNG seed/state kaydı, DUT/Ref alt akışları için
kontrollü substream'ler, otomatik bağımsızlık testi, kullanıcı tanımlı geçiş
bandı MAE'si, aynı config için çoklu tekrar ve güven aralıkları eklenmelidir.
PLL, LNA, ADC, kuantalama, saat jitteri ve kanal uyumsuzluğu gibi donanım
etkilerinin eklenmesi model ile gerçek analizör arasındaki boşluğu azaltacaktır.

### 10. Sonuç

Bu projede iki referans kanallı faz dedektörü mimarisi MATLAB ortamında
gerçekleştirilmiş ve DUT faz gürültüsünün kompleks Cross-PSD ortalamasıyla
kestirilmesi amaçlanmıştır. Ortak DUT bileşeni iki kanalda korunurken kanala
özgü referans terimleri ayrı rastgele dizilerle modellenmiş ve kompleks
ortalama yoluyla bastırılmıştır.

İşlem zincirinin doğrudan FFT çarpımına taşınması, uygun FFT boyunun seçilmesi,
filtre katsayılarının önbelleğe alınması ve simülasyonun modüler giriş
betiklerine ayrılması uzun karşılaştırmaların otomatik yürütülmesini ve
sonuçların ham/özet/görsel kanıtlarla saklanmasını sağlamıştır. Bu değişiklikler
için kontrollü bir hız benchmark'ı yapılmadığından sonuç bölümünde sayısal bir
hızlanma çarpanı verilmemelidir.

Yeni sonuçlar geldikten sonra kullanılacak sonuç paragrafı:

> `N=1.000.000` örnekli final koşularda [EN ÖNEMLİ PARAMETRE BULGUSU] elde
> edilmiştir. Referans PSD seviyesinin DUT'tan teorik olarak yaklaşık 7,96 dB
> yüksek olduğu özel profilde, yineleme sayısının 1'den 20.000'e çıkarılmasıyla
> resmî MAE [MAE_1] dB'den [MAE_20000] dB'ye [DEĞİŞİM] göstermiştir.
> [PLATO/MONOTONLUK CÜMLESİ]. LPF, DUT RMS, referans RMS ve log-bin taramaları
> ise sırasıyla [DÖRT KISA DOĞRULANMIŞ BULGU] ortaya koymuştur.

Çalışmanın temel katkısı yalnız belirli bir sonuç eğrisi değil, faz gürültüsü
ölçüm zincirinin gürültü üretiminden Cross-PSD ortalamasına kadar şeffaf bir
sayısal model halinde kurulmasıdır. Kontrollü RNG kaydı, bağımsızlık testleri,
ölçüm bandı tanımı ve donanım kusurlarının eklenmesi modelin sonraki geliştirme
adımlarını oluşturmaktadır.

## 8. Son rapor öncesi içerik kontrol listesi

- [ ] Başlık, özet ve yöntem boyunca çalışma ortamı MATLAB R2025b olarak
  güncellendi.
- [ ] Commitli optimized klasörün GNU Octave kaynağı, `matlab_version/`
  klasörünün ise `0799f9f` senkron noktasından türetilmiş MATLAB portu olduğu
  tarihçe/provenance bölümünde doğru biçimde ayrıldı.
- [ ] `Phase Noise Nedir?`, `için için`, `iteraston`, `db/decade` ve karışık
  Türkçe-İngilizce terimler düzeltildi.
- [ ] Yinelenen `Şekil 2.1` numarası ve bütün metin içi şekil başvuruları Word
  çapraz başvurularıyla yenilendi.
- [ ] R&S'den alınan her görselde parça, şekil numarası ve birleşik PDF sayfası
  belirtiliyor.
- [ ] R&S donanım blokları ile MATLAB'da modellenen bloklar açıkça ayrılıyor.
- [ ] Optimizasyon tablosundaki FFT boyu `2^nextpow2(2*Nc-1)` olarak düzeltildi;
  kontrollü benchmark olmadan kesin hız/eşdeğerlik iddiası kalmadı.
- [ ] Tamamlanmış `run_comparisons` klasörünün bütün `summary.csv` satırları ham
  MAT dosyalarıyla eşleşiyor.
- [ ] Final LPF taramasında 75 kHz dahil dokuz değer ve dokuz panelli güncel
  MATLAB grafiği kullanılıyor; eski sekiz panelli şekil kaldırıldı.
- [ ] Referans RMS listesinde `sigma_DUT` yerine `sigma_ref` kullanılıyor.
- [ ] Büyük yineleme klasöründe 20.000 noktası aynı config ile tamamlanmış ve
  özet/PNG içinde yer alıyor; bütün raw config'lerde `N=1.000.000` doğrulandı.
- [ ] `run_comparisons` (LPF 200 kHz, DUT/Ref 0,05 rad, temel 100 yineleme) ile
  `run_iterations` (LPF 100 kHz, DUT 0,02 rad, Ref 0,05 rad) sonuçları aynı
  config'miş gibi birleştirilmedi.
- [ ] `7.5` yarım cümlesi teorik 7,96 dB farkıyla ve final sonuçlarla
  tamamlandı; `7.6 Logaritmik bin sayısının etkisi` eklendi.
- [ ] Rapordaki her sayı nihai CSV/MAT dosyasından yeniden okunmuş; eski
  `PROJE_RAPORU_TASLAGI.md`, önceki `RESULTS_ANALYSIS.md` veya eski profil
  sayıları otomatik olarak taşınmamış.
- [ ] Süre karşılaştırmaları aynı MATLAB sürümü ve aynı makine koşuluna ait.
- [ ] Kontrolsüz bir hızlanma çarpanı veya kesin yeniden üretilebilirlik iddiası
  bulunmuyor.
- [ ] Şekillerde eksen birimleri, legend, config ve kaynak bilgisi okunabilir.
- [ ] `settling_samples`, MAE bandı, RNG ve donanım soyutlaması sınırlamalar
  bölümünde yer alıyor.
- [ ] Kaynakça içinde R&S uygulama notu ve kullanılan temel matematiksel
  kaynaklar eksiksiz gösteriliyor.
- [ ] Özet, otomatik içindekiler, toplu bulgular, tartışma, sınırlamalar,
  sonuç, kaynakça ve provenance eki belgede bulunuyor.
- [ ] Nihai DOCX görsel olarak bütün sayfalarda render edilip kontrol edildi.
