# ÇAPRAZ KORELASYON YÖNTEMİYLE FAZ GÜRÜLTÜSÜ ÖLÇÜMÜ

## GNU Octave Tabanlı Benzetim, Optimizasyon ve Sonuçların İncelenmesi

**Proje Raporu Taslağı**

**Hazırlayan:** [Ad Soyad]  
**Kurum / Bölüm:** [Kurum ve Bölüm]  
**Danışman:** [Danışman Adı]  
**Tarih:** [Tarih]

> **Durum:** Bu belge tamamlanmamış bir rapor taslağıdır. Sonuç bölümleri
> 2026-08-19 ve 2026-08-20 tarihli yerel deneylerin anlık görüntüsüdür.
> Referans verilen `results/` MAT, CSV ve PNG dosyaları Git tarafından izlenmez;
> mevcut zaman tabanlı RNG nedeniyle temiz bir clone üzerinde bit düzeyinde aynı
> sonuç garanti edilmez. Güncel çalışma alanı ve kullanım için kök `README.md`
> ile `phasedetector with cross correlation optimized/README.md` esas alınır.

---

## Özet

Bu projede, bir test cihazının (Device Under Test, DUT) faz gürültüsünün iki
bağımsız referans kanalı ve çapraz korelasyon yöntemi kullanılarak ölçülmesi
GNU Octave ortamında modellenmiştir. Çalışmanın temel amacı, her iki ölçüm
kanalında ortak olan DUT faz gürültüsünü korurken referans kaynaklarına ait
korelasyonsuz gürültü bileşenlerini çok sayıda ölçümün ortalamasıyla
bastırmaktır.

Benzetimde DUT ve iki referans için faz gürültülü taşıyıcılar üretilmiştir.
DUT sinyali, kendisine göre 90 derece faz farkına sahip iki bağımsız referans
ile ayrı ayrı karıştırılmıştır. Karıştırıcı çıkışları Butterworth alçak geçiren
filtreden geçirilmiş, faz dedektörü kazancı ile ölçeklenmiş ve iki kanalın
çapraz güç spektral yoğunluğu (Cross-Power Spectral Density, Cross-PSD)
hesaplanmıştır. Faz gürültüsü kaynakları beyaz gürültünün frekans bölgesinde
şekillendirilmesiyle oluşturulmuş ve `1/f³` güç spektral yoğunluğu elde
edilmiştir.

Hesaplama süresini azaltmak amacıyla ilk sürümde kullanılan `xcorr`,
`ifftshift` ve yeniden `fft` alma zinciri kaldırılmıştır. Bunun yerine
korelasyon teoreminden yararlanılarak iki kanalın FFT’lerinin doğrudan
çarpımı hesaplanmıştır. FFT uzunluğu, doğrusal korelasyon uzunluğunu kapsayan
en yakın ikinin kuvveti olarak seçilmiştir. Ayrıca filtre katsayıları önbelleğe
alınmış, iki ölçüm kanalı tek bir matris üzerinde filtrelenmiş, sabit hesaplar
döngü dışına taşınmış ve spektrum dizileri önceden ayrılmıştır.

Kaydedilmiş güncel sonuçlarda `DUT RMS = 0,20 rad`, `Ref1 RMS = Ref2 RMS =
0,02 rad` ve 100 iterasyon için Cross-PSD tahmini ile DUT referans
periodogramı arasındaki ortalama mutlak fark `0,092 dB` olarak bulunmuştur.
Bu sonuç, referansların RMS faz gürültüsü DUT’ninkinden küçük olduğunda DUT faz
gürültüsünün yüksek doğrulukla elde edilebildiğini göstermektedir. Daha zor
olan `DUT RMS = 0,02 rad` ve `Ref RMS = 0,05 rad` koşulunda ise iterasyon
sayısının 1’den 20.000’e çıkarılması hatayı `14,098 dB` değerinden
`1,614 dB` değerine düşürmüştür. Böylece çapraz korelasyon yönteminde bağımsız
referans gürültülerinin iterasyon ortalamasıyla bastırıldığı doğrulanmıştır.

**Anahtar kelimeler:** Faz gürültüsü, phase noise, çapraz korelasyon,
Cross-PSD, FFT, osilatör, dBc/Hz, GNU Octave.

---

## 1. Giriş

İdeal bir osilatörün frekans spektrumu, yalnızca taşıyıcı frekansında bulunan
sonsuz dar bir çizgiden oluşur. Gerçek osilatörlerde ise termal gürültü, aktif
eleman gürültüsü, rezonatör kayıpları, güç kaynağı dalgalanmaları, mekanik
titreşimler ve çevresel etkiler nedeniyle sinyalin anlık fazı ideal değerinin
çevresinde değişir. Bu rastgele değişim, taşıyıcının iki yanında gürültü
etekleri meydana getirir ve faz gürültüsü olarak adlandırılır.

Faz gürültüsü birçok sistemin başarımını doğrudan etkiler. Haberleşme
sistemlerinde hata vektör büyüklüğünü (Error Vector Magnitude, EVM) ve bit hata
oranını artırır. Radar sistemlerinde yakın hedeflerin ayırt edilmesini
zorlaştırır. Analog-sayısal dönüştürücülerde örnekleme saati belirsizliği
oluşturarak etkin çözünürlüğü sınırlar. Frekans sentezleyicilerde komşu kanal
girişimini, zamanlama sistemlerinde ise jitter değerini belirler.

Düşük seviyeli bir DUT faz gürültüsünün ölçülmesindeki temel problem, ölçüm
sisteminin veya referans osilatörün kendi gürültüsünün DUT gürültüsünü
örtmesidir. Tek kanallı bir ölçümde bu gürültüler birbirinden ayrılamaz.
Çapraz korelasyon yönteminde aynı DUT iki bağımsız kanalla ölçülür. DUT
gürültüsü iki kanalda ortak olduğundan korunur; referanslara ve kanallara özgü
bağımsız gürültüler ise kompleks çapraz spektrum ortalaması sırasında
bastırılır.

Bu çalışmada söz konusu ölçüm yöntemi sayısal ortamda modellenmiş, farklı DUT
ve referans RMS değerlerinin, iterasyon sayısının, alçak geçiren filtre kesim
frekansının ve logaritmik bin sayısının sonuç üzerindeki etkileri
incelenmiştir. Ayrıca ilk kod ile optimize edilmiş kod arasındaki algoritmik
farklar açıklanmıştır.

## 2. Faz Gürültüsü Nedir?

Bir sinüs işaretini zaman ekseninde izlediğimizi düşünelim. İdeal durumda
işaretin her periyodu tam beklenen anda başlar ve sıfır geçişleri hiç yer
değiştirmez. Gerçek bir osilatörde ise bu geçişler çok küçük miktarlarda öne
veya arkaya kayar. Başka bir ifadeyle işaretin genliği aynı kalsa bile anlık
fazı ideal değerinin çevresinde dolaşır. Bu rastgele faz hareketine **faz
gürültüsü** denir.

Faz gürültülü bir taşıyıcı basitçe şu şekilde gösterilebilir:

> **v(t) = A · cos(2πf₀t + φ(t))**

Burada `A` genlik, `f₀` taşıyıcı frekansı,
`φ(t)` ise zamana göre değişen küçük faz hatasıdır. Projedeki model genlik
değişimini değil, yalnızca bu faz hatasını ele almaktadır.

Bu hareket zaman grafiğinde küçük kaymalar olarak görünürken frekans
spektrumunda taşıyıcının iki yanına yayılan bir gürültü eteği oluşturur.
Taşıyıcıya yakın frekanslardaki etek yüksekse osilatörün kısa süreli kararlılığı
düşüktür. Taşıyıcıdan uzaklaştıkça görülen düz gürültü tabanı ise çoğunlukla
ölçüm sistemi ve beyaz faz gürültüsüyle ilişkilidir.

Faz gürültüsü genellikle `dBc/Hz` birimiyle verilir. Bu birim, taşıyıcıdan
belirli bir uzaklıktaki 1 Hz genişliğindeki gürültü gücünün taşıyıcı gücüne
oranını anlatır. Örneğin `−100 dBc/Hz @ 10 kHz`, taşıyıcıdan 10 kHz uzaktaki
1 Hz’lik gürültü gücünün taşıyıcıdan 100 dB düşük olduğu anlamına gelir.

Küçük faz hataları için tek yan bant faz gürültüsü ile fazın güç spektral
yoğunluğu arasındaki ilişki şöyledir:

> **L(f) = 10 · log₁₀(Sφ(f) / 2)**

Bu formül kodda hesaplanan `rad²/Hz` türündeki faz PSD’sini
grafiklerde kullanılan `dBc/Hz` değerine çevirmek için kullanılmaktadır.
Belirli bir frekans aralığındaki faz gürültüsü doğrusal güçte toplanırsa RMS
faz hatası elde edilir. Aynı hata taşıyıcı frekansına bölünerek zaman jitteri
olarak da ifade edilebilir.

### 2.1. Faz gürültüsü çeşitleri ve spektral görünümleri

Faz gürültüsü tek bir fiziksel etkiden oluşmaz. Farklı gürültü mekanizmaları
spektrumda farklı eğimler meydana getirir. Logaritmik bir grafikte bu eğimler
gürültü türünü anlamayı kolaylaştırır.

| Gürültü çeşidi | Yaklaşık PSD davranışı | Tipik eğim | Spektrumda nasıl görünür? |
|---|---:|---:|---|
| Beyaz faz gürültüsü | Sabit | 0 dB/dekad | Taşıyıcıdan uzakta düz bir gürültü tabanı |
| Flicker faz gürültüsü | `1/f` | −10 dB/dekad | Taşıyıcıya yaklaşırken yavaş yükselen etek |
| Beyaz frekans gürültüsü | `1/f²` | −20 dB/dekad | Daha belirgin eğimli orta bölge |
| Flicker frekans gürültüsü | `1/f³` | −30 dB/dekad | Taşıyıcıya yakın bölgede dikleşen etek |
| Rastgele yürüyüş frekans gürültüsü | `1/f⁴` | −40 dB/dekad | Çok düşük offsette oldukça dik bir yükseliş |

Gerçek bir osilatörde bu bölgelerin birkaç tanesi aynı grafikte görülebilir.
Yakın offsette `1/f³`, orta bölgede `1/f²`, daha uzakta ise düz beyaz gürültü
tabanı baskın olabilir. Bu projedeki `generate_phase_noise.m` fonksiyonu
özellikle `1/f³` biçiminde faz gürültüsü üretmektedir. Bu nedenle benzetim
grafiklerinde ana eğimin yaklaşık `−30 dB/dekad` olması beklenir.

### 2.2. Rastgele gürültü ile spur arasındaki fark

Spektrumda görülen her tepe rastgele faz gürültüsü değildir. Besleme
frekansı, sayısal saat sızıntısı veya PLL karşılaştırma frekansı gibi periyodik
etkiler belirli offsetlerde ince çizgiler oluşturur. Bunlara spur denir.
Rastgele faz gürültüsü sürekli bir etek şeklindeyken spur tek bir frekansta
dar bir tepe olarak görülür. Mevcut benzetim yalnızca rastgele `1/f³`
gürültüsünü üretmekte, ayrıca spur oluşturmamaktadır.

## 3. Faz Gürültüsü Nasıl Ölçülür?

Faz gürültüsünü ölçmenin tek bir yolu yoktur. Kullanılacak yöntem DUT’un
frekansına, beklenen gürültü seviyesine, ölçülmek istenen offset aralığına ve
eldeki referans kaynaklarına göre seçilir.

| Yöntem | Kısaca çalışma biçimi | Güçlü yanı | Dikkat edilmesi gereken nokta |
|---|---|---|---|
| Doğrudan spektrum analizi | Taşıyıcı çevresi analizörde doğrudan izlenir | Kurulumu basittir, spur’lar açıkça görülür | Analizörün kendi gürültüsü DUT’u örtebilir |
| Faz dedektörü | DUT temiz bir referansla 90 derece faz farkında karşılaştırılır | Yakın offsetlerde hassastır | Referans gürültüsü de sonuca eklenir |
| PLL tabanlı ölçüm | DUT ile referans arasındaki fark bir PLL ile takip edilir | Frekans farkını kararlı tutar | PLL transfer fonksiyonu hesaba katılmalıdır |
| Gecikme hattı | Sinyalin gecikmeli ve doğrudan kolları karşılaştırılır | İkinci osilatör gerektirmeyebilir | Düşük offset hassasiyeti gecikmeyle sınırlıdır |
| Sayısal I/Q ölçümü | I ve Q örneklerinden anlık faz çıkarılır | Sayısal işleme esnekliği yüksektir | ADC saati ve I/Q hataları sonucu etkiler |
| Çapraz korelasyon | Aynı DUT iki bağımsız kanalda ölçülür | Kanal gürültü tabanının altına inebilir | İki kanalın gerçekten bağımsız olması gerekir |

Doğrudan spektrum analizi en kolay yöntemdir; ancak çok temiz bir DUT
ölçülüyorsa analizörün kendi lokal osilatörü sınır hâline gelir. Faz dedektörü
yönteminde daha hassas sonuç alınabilir, fakat kullanılan referansın gürültüsü
DUT gürültüsünden ayrılamaz. Çapraz korelasyon yöntemi bu sorunu iki bağımsız
referans kullanarak azaltır ve bu projenin temelini oluşturur.

## 4. Çapraz Korelasyon Yönteminin Mantığı

### 4.1. Neden iki kanal kullanılıyor?

İki kişinin aynı konuşmayı farklı, bağımsız gürültülerin bulunduğu iki odadan
dinlediğini düşünelim. Her iki kayıtta da konuşma aynıdır; odalardaki gürültü
ise farklıdır. Kayıtların ortak kısmı arandığında konuşma korunur, bağımsız oda
gürültüleri ortalamada azalır. Çapraz korelasyon ölçümünde de DUT faz
gürültüsü ortak konuşma, iki referansın gürültüsü ise bağımsız oda gürültüsü
gibi davranır.

Faz dedektörlerinden çıkan iki kanal küçük faz farkı bölgesinde yaklaşık
olarak aşağıdaki gibi düşünülebilir:

> **y₁ = φD − φR1, &nbsp;&nbsp; y₂ = φD − φR2**

Bu gösterimde DUT’a ait `φD` iki kanalda da bulunur. `φR1` yalnızca birinci,
`φR2` ise yalnızca ikinci kanaldadır.

İki kanalın çapraz spektrumu hesaplandığında ortak DUT terimi aynı fazda
toplanır. DUT ile referanslar ve iki referans birbirinden bağımsızsa diğer
çapraz terimlerin uzun süreli ortalaması sıfıra yaklaşır. Bu durum kısa olarak
şöyle yazılabilir:

> **S₁₂(f) = E{Y₁(f) · conj(Y₂(f))} ≈ SD(f)**

Formülün anlattığı temel fikir, iki kanalda ortak olan
spektrumun DUT spektrumu olduğudur.

### 4.2. Faz dedektörü ve alçak geçiren filtre

DUT sinyali, kendisine göre 90 derece kaydırılmış iki referansla ayrı ayrı
çarpılır. Çarpım sonucunda biri faz farkını taşıyan düşük frekanslı bileşen,
diğeri taşıyıcı frekansının yaklaşık iki katında bulunan yüksek frekanslı
bileşen olmak üzere iki parça oluşur. Butterworth alçak geçiren filtre yüksek
frekanslı parçayı bastırır ve faz farkını taşıyan taban bant işaretini bırakır.

Karıştırıcının küçük-sinyal faz kazancı `Kpd=A²/2` değeridir. Filtre çıkışı bu
kazanca bölündüğünde kanalın ölçeği yaklaşık olarak rad cinsinden faz hatasına
dönüşür. Faz farkı büyüdüğünde çıkış tam doğrusal değildir; kod bu etki için
ölçülen toplam güce dayalı bir düzeltme katsayısı uygulamaktadır.

### 4.3. İterasyon sayısı neden önemli?

Teorik olarak bağımsız referans terimlerinin beklenen değeri sıfırdır, ancak
tek bir sonlu kayıtta bu terimler tam olarak sıfır çıkmaz. Her iterasyonda yeni
DUT ve referans gerçekleştirmeleri üretilir ve kompleks Cross-PSD değerleri
ortalama alınmadan önce toplanır. İterasyon sayısı arttıkça rastgele referans
artığı küçülür.

İdeal koşullarda bu artığın standart sapması yaklaşık `1/√K` ile azalır;
burada `K` iterasyon sayısıdır. dB cinsinden beklenen iyileşme yaklaşık
`5·log₁₀(K)` mertebesindedir. Bu yalnızca bağımsız gürültü için geçerlidir.
Ortak saat, kanal sızıntısı veya filtre uyumsuzluğu gibi sistematik etkiler
iterasyon sayısı artırılarak yok edilemez.

### 4.4. Korelasyonun FFT ile hızlı hesaplanması

İlk kodda önce `xcorr` ile zaman bölgesi korelasyonu oluşturuluyor, dizi
`ifftshift` ile düzenleniyor ve ardından yeniden FFT alınıyordu. Korelasyon
teoremi aynı sonucun iki kanal FFT’sinin çarpımından doğrudan elde
edilebileceğini söyler:

> **S₁₂[k] = Y₁[k] · conj(Y₂[k]) / (fs · M)**

Güncel kod bu işlemi şu şekilde yapmaktadır:

```matlab
X = fft(channels, nfft, 1);
S_cross = X(:, 1) .* conj(X(:, 2)) / (fs * channel_length);
```

Doğrusal korelasyon uzunluğunu kapsamak için FFT boyu `2M−1` değerinden küçük
olmamalıdır. Kod bunu kapsayan en yakın ikinin kuvvetini seçmektedir:

```matlab
nfft = 2^nextpow2(2 * M - 1);
```

İkinin kuvveti olan uzunluklar FFT tarafından daha verimli işlenir. Buradaki
sıfır doldurma yalnızca frekans noktalarını sıklaştırır; gerçek ölçüm
çözünürlüğünü veya toplam gücü değiştirmez.

### 4.5. Sonucun dBc/Hz’e çevrilmesi

FFT’den elde edilen tek taraflı faz PSD’si önce iterasyonlar boyunca doğrusal
güçte ortalanır. Daha sonra logaritmik frekans aralıklarında binlenir ve
`10·log₁₀(Sφ/2)` dönüşümüyle dBc/Hz cinsine çevrilir. Bu sıra önemlidir;
dB değerlerini doğrudan ortalamak fiziksel olarak doğru değildir.

Faz dedektörünün `sin(φ)` biçimindeki doğrusal olmayan davranışı da toplam
ölçülen güçten hesaplanan bir katsayıyla düzeltilir. Küçük RMS değerlerinde bu
katsayı 1’e çok yakındır. DUT RMS değeri büyüdükçe katsayının 1’den
uzaklaşması, küçük-faz yaklaşımının zayıfladığını gösterir.

## 5. Benzetim Modeli ve Kodun Çalışma Yapısı

### 5.1. Temel dosyalar

Aktif proje kodu `phasedetector with cross correlation optimized/`
klasöründedir.

| Dosya | Görevi |
|---|---|
| `run_single.m` | Tek bir parametre takımıyla benzetimi çalıştırır ve sonucu çizer |
| `run_comparisons.m` | Parametre taramalarını ve temel ayarları tanımlar |
| `run_iterations.m` | Yalnızca iterasyon sayısını tarar |
| `run_simulation.m` | Ana benzetim, ortalama, düzeltme ve hata hesabını yürütür |
| `measure_iteration.m` | Tek iterasyondaki iki kanallı ölçüm zincirini kurar |
| `generate_phase_noise.m` | Belirlenen RMS değerinde `1/f³` faz gürültüsü üretir |
| `mixer.m` | DUT’u iki referans sinyaliyle ayrı ayrı çarpar |
| `lowpass_filter.m` | Butterworth alçak geçiren filtreyi tasarlar ve uygular |
| `compute_cross_psd.m` | FFT tabanlı kompleks Cross-PSD hesaplar |
| `compute_periodogram.m` | DUT faz dizisinin tek taraflı periodogramını hesaplar |
| `logbin_phase_noise.m` | Logaritmik binleme ve SSB dönüşümünü gerçekleştirir |
| `run_comparisons_main.m` | Taramaları çalıştırır ve sonuçları MAT, CSV ve PNG olarak kaydeder |

### 5.2. Faz gürültüsü üretimi

`generate_phase_noise.m` fonksiyonunda aşağıdaki adımlar uygulanmaktadır:

1. `randn` ile beyaz Gauss gürültüsü üretilir.
2. Beyaz gürültünün FFT’si alınır.
3. FFT genliği `1/sqrt(f³)` ile çarpılır.
4. DC bileşeni sıfırlanır.
5. Ters FFT ile zaman bölgesine dönülür.
6. Dizinin ortalaması kaldırılır.
7. Dizi önce birim RMS’e, ardından istenen `phase_rms` değerine ölçeklenir.

Hedef PSD `1/f³` olduğu için genlik spektrumuna bunun karekökü olan
`1/sqrt(f³)` uygulanmaktadır. Fonksiyon çift uzunlukta `N` değeri
gerektirmektedir.

### 5.3. Taşıyıcıların oluşturulması

Her iterasyonda yeni bir DUT faz gürültüsü gerçekleştirmesi üretilir. DUT
taşıyıcısı aşağıdaki temel ifadeye göre oluşturulur:

> **xD[n] = A · cos(2πf₀n / fs + φD[n])**

İki referansın faz gürültüsü birbirinden bağımsız olarak oluşturulur. Her
referans taşıyıcısına 90 derecelik merkez faz farkı eklenir:

> **xRi[n] = A · cos(2πf₀n / fs + π/2 + φRi[n])**

Aynı iterasyondaki DUT sinyali iki ölçüm kanalında ortaktır. Ref1 ve Ref2 ise
ayrı rastgele gerçekleştirmelerdir. Çapraz korelasyon yönteminin çalışması için
bu ayrım zorunludur.

### 5.4. Tek iterasyondaki işlem sırası

Bir ölçüm iterasyonunda aşağıdaki işlem zinciri uygulanır:

1. Yeni DUT, Ref1 ve Ref2 faz gürültüsü dizileri oluşturulur.
2. DUT ve iki quadrature referans taşıyıcısı üretilir.
3. DUT, iki referansla ayrı kanallarda çarpılır.
4. İki karıştırıcı çıkışı Butterworth alçak geçiren filtreden geçirilir.
5. Filtre çıkışları `Kpd=A²/2` değerine bölünür.
6. Seçilen başlangıç örnekleri atılarak filtre geçici rejimi çıkarılır.
7. Her kanalın DC ortalaması kaldırılır.
8. İki kanalın kompleks Cross-PSD değeri FFT ile hesaplanır.
9. Aynı DUT faz dizisinin periodogramı karşılaştırma amacıyla hesaplanır.

### 5.5. İterasyonların ortalanması

Cross-PSD değerleri kompleks biçimde toplanmaktadır:

```matlab
S_cross_sum = S_cross_sum + S_cross_current;
```

Mutlak değer, iterasyonlar tamamlanıp kompleks ortalama alındıktan sonra
uygulanmaktadır. Her iterasyonda önce mutlak değer alınsaydı korelasyonsuz
kompleks bileşenler birbirini götüremez ve çapraz korelasyon kazancı
kaybedilirdi.

DUT periodogramları da dB alanında değil, doğrusal PSD alanında toplanıp
ortalaması alınmaktadır. Güç spektrumlarının fiziksel olarak doğru ortalaması
bu şekilde yapılır.

### 5.6. Logaritmik binleme

Faz gürültüsü geniş bir offset frekansı aralığında incelendiği için sonuçlar
logaritmik frekans ekseninde gösterilmektedir. Her logaritmik bin için merkez
frekansı geometrik ortalama, PSD değeri ise doğrusal güçlerin aritmetik
ortalamasıyla hesaplanmaktadır. Ardından sonuç dBc/Hz cinsine çevrilmektedir.

İlk kodda bin içindeki maksimum PSD değeri kullanılırken optimize edilmiş
kodda aritmetik ortalama kullanılmaktadır. Böylece tek bir tepenin bütün bini
temsil etmesi önlenmiş ve yorumla uyumlu gerçek ortalama güç elde edilmiştir.

### 5.7. Hata metriği

Cross-PSD ve ortalama DUT periodogramı ortak frekans aralığında 200
logaritmik noktaya enterpole edilmektedir. Ortalama mutlak hata, her ortak
frekans noktasındaki dB farklarının mutlak değerlerinin ortalaması alınarak
hesaplanmaktadır:

> **MAE = ortalama(|Lcross(f) − LDUT(f)|)**

Bu değer iki eğrinin ortalama dB farkını verir.
Tek bir offset frekansındaki hatayı veya en büyük hatayı ifade etmez.

## 6. Yapılan Optimizasyonlar

### 6.1. Optimizasyonların özeti

| Optimizasyon | İlk yaklaşım | Güncel yaklaşım | Etkisi |
|---|---|---|---|
| Çapraz spektrum hesabı | `xcorr → ifftshift → fft` | `FFT(x₁)·conj(FFT(x₂))` | Ara dizi ve ek dönüşüm kaldırıldı |
| FFT uzunluğu | Doğrudan `2M−1` | `2^nextpow2(2M−1)` | Radix-2 FFT’ye uygun uzunluk elde edildi |
| Filtre tasarımı | Her iterasyonda yeniden tasarım | Katsayıların önbelleğe alınması | Tekrarlanan `butter` hesabı kaldırıldı |
| Kanal filtreleme | İki ayrı filtre çağrısı | İki kolonlu matris için tek çağrı | Vektörleştirilmiş işlem sağlandı |
| İterasyon ortalaması | Her adımda kayan ortalama | Toplama ve sonunda bölme | Döngü içindeki bölme sayısı azaltıldı |
| Bellek kullanımı | Dinamik dizi büyümesi | Önceden dizi ayırma | Bellek tahsisi azaltıldı |
| Logaritmik bin | Bin içindeki maksimum | Doğrusal aritmetik ortalama | Daha temsil edici ortalama güç elde edildi |
| Sonuç yapısı | Kullanılmayan Welch alanları | Yalnız gerekli Cross-PSD ve DUT sonuçları | Dosya ve bellek yükü azaltıldı |

### 6.2. `xcorr` yerine doğrudan FFT kullanılması

İlk kodda çapraz korelasyon zaman bölgesinde hesaplanmakta, sıfır gecikme
dizinin başına taşınmakta ve tekrar FFT alınmaktaydı:

```matlab
r_cross = xcorr(channel_1, channel_2, "biased");
r_cross_ordered = ifftshift(r_cross);
S_cross_two_sided = fft(r_cross_ordered) / fs;
```

Optimize edilmiş kod aynı sonucu doğrudan frekans bölgesinde hesaplamaktadır:

```matlab
channel_spectra = fft(channels, nfft, 1);
S_cross_two_sided = channel_spectra(:, 1) ...
    .* conj(channel_spectra(:, 2)) / (fs * channel_length);
```

Bu değişiklik matematiksel sonucu değiştirmeden işlem zincirini kısaltmıştır.
Projede aynı veriyle eski ve yeni kodu karşılaştıran kontrollü bir benchmark
kaydı bulunmadığı için kesin bir hızlanma oranı verilmemiştir. Bununla
birlikte ara korelasyon dizisi ve ikinci dönüşüm kaldırıldığı için işlem ve
bellek maliyeti azalmıştır.

### 6.3. FFT uzunluğunun ikinin kuvveti seçilmesi

İlk yöntemde `2M−1` uzunluğunda FFT kullanılmaktaydı. Bu uzunluk çoğu durumda
uygun olmayan asal çarpanlar içerebilir ve FFT algoritmasını yavaşlatabilir.
Güncel kodda

```matlab
nfft_cross = 2^nextpow2(2 * channel_length - 1);
```

ifadesi kullanılmıştır. Böylece lineer korelasyon uzunluğu korunurken ikinin
kuvveti olan bir FFT boyutu elde edilmiştir.

Bu noktada önemli bir ayrım vardır: sıfır doldurma gerçek frekans
çözünürlüğünü artırmaz. Yalnızca mevcut spektrumun daha sık bir frekans
ızgarasında örneklenmesini sağlar. Toplam güç değişmez ve normalizasyonda
gerçek örnek sayısı kullanılmaya devam edilir.

### 6.4. Filtre katsayılarının önbelleğe alınması

`lowpass_filter.m` içinde `fs`, kesim frekansı veya filtre derecesi değişmediği
sürece Butterworth katsayıları `persistent` değişkenlerde tutulmaktadır. Bu
sayede her iterasyonda iki kez filtre tasarımı yapılmamaktadır. Ayrıca iki
kanal tek bir matrisin kolonları olarak aynı `filter` çağrısıyla işlenmektedir.

### 6.5. Döngü dışına alınan hesaplar

Aşağıdaki değerler iterasyon döngüsünden önce bir kez hesaplanmaktadır:

- Zaman ekseni
- Taşıyıcı fazı
- Quadrature referans fazı
- Faz dedektörü kazancı
- FFT uzunluğu
- Frekans ekseni
- Cross-PSD ve DUT PSD toplam dizileri

Bu sayede döngü içinde yalnızca her rastgele gerçekleştirmede değişmesi gereken
işlemler bırakılmıştır.

## 7. Kullanılan Benzetim Parametreleri

`run_comparisons.m` dosyasındaki güncel temel ayarlar aşağıdaki gibidir.

| Parametre | Temel değer | Açıklama |
|---|---:|---|
| `N` | 100.000 | Her gerçekleştirmedeki örnek sayısı |
| `fs` | 1 MHz | Örnekleme frekansı |
| `A` | 1 | Taşıyıcı genliği |
| `f0` | 50 kHz | Taşıyıcı frekansı |
| `settling_samples` | 0 | Başlangıçta atılacak filtre örneği |
| `lpf_cutoff` | 10 kHz | Alçak geçiren filtre kesim frekansı |
| `lpf_order` | 4 | Butterworth filtre derecesi |
| `phase_rms_dut` | 0,02 rad | Temel DUT RMS faz gürültüsü |
| `phase_rms_ref1` | 0,02 rad | Referans 1 RMS faz gürültüsü |
| `phase_rms_ref2` | 0,02 rad | Referans 2 RMS faz gürültüsü |
| `number_of_iterations` | 100 | Temel Cross-PSD ortalama sayısı |
| `number_of_log_bins` | 100 | Logaritmik bin sayısı |

Her parametre taramasında yalnızca incelenen parametre değiştirilmiş, diğer
parametreler temel değerlerinde tutulmuştur. Her koşu yeni rastgele
gerçekleştirmeler kullandığı için sonuçlarda Monte Carlo kaynaklı küçük
dalgalanmalar bulunmaktadır.

## 8. Benzetim Sonuçları

Bu bölümdeki temel sonuçlar
`results/20260819_123914852_*` klasörlerindeki güncel çoklu DUT
gerçekleştirmeli koşulardan alınmıştır. Yüksek iterasyon deneyi ise
`results/20260820_081605998_iterations` klasöründedir.

### 8.1. İterasyon sayısının etkisi

Bu taramada DUT ve iki referansın RMS değerleri `0,02 rad` olarak tutulmuştur.

| İterasyon sayısı | MAE (dB) | Düzeltme katsayısı | Süre (s) |
|---:|---:|---:|---:|
| 1 | 2,330 | 1,000787 | 0,341 |
| 10 | 2,220 | 1,000417 | 1,137 |
| 50 | 2,007 | 1,000440 | 4,610 |
| 100 | 0,902 | 1,000472 | 8,902 |
| 200 | 0,310 | 1,000366 | 17,566 |
| 300 | 0,344 | 1,000386 | 27,110 |

İterasyon sayısı arttıkça genel olarak Cross-PSD eğrisi DUT periodogramına
yaklaşmıştır. Hatanın her adımda kesin olarak azalması beklenmemelidir. Her
parametre değeri farklı rastgele gerçekleştirmelerle çalıştırıldığı için
sonuçlar istatistiksel dalgalanma içermektedir. Örneğin 200 iterasyonda
`0,310 dB`, 300 iterasyonda `0,344 dB` hata elde edilmiştir. Buna karşılık
hesaplama süresinin iterasyon sayısıyla yaklaşık doğrusal arttığı görülmüştür.

![Şekil 1. İterasyon sayısının Cross-PSD sonucuna etkisi](<phasedetector with cross correlation optimized/results/20260819_123914852_iterations/plots/iterations_comparison.png>)

*Şekil 1. İterasyon sayısı arttıkça Cross-PSD tahmininin ortalama DUT
periodogramına yaklaşması.*

### 8.2. Referans RMS değerinin etkisi

Bu taramada DUT RMS değeri `0,02 rad`, iterasyon sayısı 100 olarak
tutulmuştur.

| Ref1 = Ref2 RMS (rad) | Ref/DUT oranı | MAE (dB) | Düzeltme katsayısı |
|---:|---:|---:|---:|
| 0,01 | 0,5 | 0,834 | 1,000403 |
| 0,02 | 1 | 1,376 | 1,000459 |
| 0,05 | 2,5 | 1,413 | 1,000499 |
| 0,10 | 5 | 4,142 | 1,001534 |
| 0,20 | 10 | 16,759 | 1,001872 |
| 0,50 | 25 | 14,513 | 1,013130 |

Referans RMS değeri DUT RMS değerinden düşükken Cross-PSD ve DUT eğrileri iyi
uyuşmuştur. Referans gürültüsü arttıkça 100 iterasyon sonunda kalan bağımsız
gürültü artığı büyümüş ve hata yükselmiştir. `Ref=0,20 rad` ve
`Ref=0,50 rad` koşullarında 100 iterasyonun yeterli olmadığı görülmektedir.

Son iki değerde hatanın monoton olmaması yöntemin teorisiyle çelişmez. Her
koşu farklı rastgele diziler kullanmaktadır ve düşük SNR bölgesinde kompleks
ortalamanın mutlak değerinin alınması pozitif yanlılık oluşturabilmektedir.

![Şekil 2. Referans RMS değerinin Cross-PSD sonucuna etkisi](<phasedetector with cross correlation optimized/results/20260819_123914852_rms_ref/plots/rms_ref_comparison.png>)

*Şekil 2. Referans gürültüsü yükseldikçe sonlu iterasyon sayısında kalan
korelasyonsuz gürültü artığının büyümesi.*

### 8.3. DUT RMS değerinin etkisi

Bu taramada iki referansın RMS değeri `0,02 rad`, iterasyon sayısı 100 olarak
tutulmuştur.

| DUT RMS (rad) | Ref/DUT oranı | MAE (dB) | Düzeltme katsayısı |
|---:|---:|---:|---:|
| 0,01 | 2 | 4,286 | 1,000149 |
| 0,02 | 1 | 1,274 | 1,000345 |
| 0,05 | 0,4 | 0,179 | 1,002573 |
| 0,10 | 0,2 | 0,118 | 1,010103 |
| 0,20 | 0,1 | 0,092 | 1,040340 |
| 0,50 | 0,04 | 0,462 | 1,284903 |

DUT RMS değeri referanslardan küçük olduğunda ortak DUT bileşeninin bağımsız
referans artığı içinden çıkarılması zorlaşmıştır. `DUT=0,01 rad` için hata
`4,286 dB`’dir. DUT seviyesi referansların üzerine çıktığında sonuç hızla
iyileşmiştir. `DUT=0,20 rad`, `Ref1=Ref2=0,02 rad` ve 100 iterasyon koşulunda
MAE yalnızca `0,092 dB` olmuştur.

DUT RMS değeri `0,50 rad` olduğunda hata yeniden `0,462 dB` değerine,
doğrusalsızlık düzeltme katsayısı ise `1,2849` değerine çıkmıştır. Bu durum,
büyük faz sapmalarında `sin(φ)≈φ` yaklaşımının zayıfladığını göstermektedir.
Global düzeltme katsayısı toplam gücü düzeltse de yüksek RMS koşulunda
spektral şekli kusursuz biçimde geri getiremeyebilir.

![Şekil 3. DUT RMS değerinin Cross-PSD sonucuna etkisi](<phasedetector with cross correlation optimized/results/20260819_123914852_rms_dut/plots/rms_dut_comparison.png>)

*Şekil 3. Referans RMS değeri DUT RMS değerinden küçük olduğunda Cross-PSD
tahmini ile DUT periodogramının çakışması.*

### 8.4. Alçak geçiren filtre kesim frekansının etkisi

| LPF kesim frekansı | MAE (dB) | Düzeltme katsayısı |
|---:|---:|---:|
| 1 kHz | 0,880 | 1,000469 |
| 5 kHz | 2,272 | 1,000456 |
| 7,5 kHz | 0,968 | 1,000413 |
| 10 kHz | 0,382 | 1,000394 |
| 25 kHz | 6,195 | 1,000428 |
| 50 kHz | 4,878 | 1,002034 |

Alçak geçiren filtre, karıştırma sonucunda oluşan yüksek frekanslı toplam
bileşenini bastırmalı; ancak ölçülmek istenen taban bant faz gürültüsünü
gereksiz biçimde kesmemelidir. Bu koşu grubunda en düşük hata 10 kHz kesim
frekansında elde edilmiştir.

Mevcut hata metriği filtrelenmiş Cross-PSD’yi filtresiz DUT periodogramıyla
geniş ortak frekans bandında karşılaştırmaktadır. Bu nedenle filtre kesim
frekansının üzerindeki zayıflama da MAE değerine dâhil olmaktadır. Filtre
karşılaştırmasının daha anlamlı olması için hata hesabı LPF geçiş bandının
altındaki kullanıcı tanımlı ölçüm bandıyla sınırlandırılmalıdır.

### 8.5. Logaritmik bin sayısının etkisi

| Logaritmik bin sayısı | MAE (dB) | Düzeltme katsayısı |
|---:|---:|---:|
| 10 | 2,298 | 1,000432 |
| 25 | 1,353 | 1,000389 |
| 50 | 1,838 | 1,000317 |
| 80 | 0,272 | 1,000440 |
| 100 | 1,187 | 1,000427 |
| 200 | 0,304 | 1,000369 |

Az sayıda bin spektrumu fazla yumuşatarak yerel ayrıntıları gizleyebilir. Çok
sayıda bin ise her binde daha az FFT noktası kalmasına ve eğri varyansının
artmasına neden olabilir. Sonuçlarda monoton bir optimum görülmemektedir.
Bunun önemli nedeni her bin sayısının ayrı bir rastgele benzetim koşusuyla
denenmiş olmasıdır.

Bin sayısının etkisini diğer rastgele etkilerden ayırmak için aynı tam
çözünürlüklü PSD kaydı farklı bin sayılarıyla tekrar işlenmelidir. Böylece
karşılaştırılan bütün eğriler aynı veri üzerinden elde edilmiş olur.

### 8.6. Yüksek iterasyonlu zor ölçüm koşulu

Ek deneyde aşağıdaki parametreler kullanılmıştır:

| Parametre | Değer |
|---|---:|
| DUT RMS | 0,02 rad |
| Ref1 RMS | 0,05 rad |
| Ref2 RMS | 0,05 rad |
| LPF kesim frekansı | 100 kHz |
| Logaritmik bin sayısı | 100 |

Bu koşulda her referansın RMS faz gürültüsü DUT’ninkinin 2,5 katıdır.

| İterasyon sayısı | MAE (dB) | Süre (s) |
|---:|---:|---:|
| 1 | 14,098 | 0,154 |
| 10 | 2,699 | 0,343 |
| 50 | 4,004 | 1,220 |
| 100 | 2,598 | 2,392 |
| 200 | 2,871 | 3,788 |
| 500 | 2,541 | 10,050 |
| 1.000 | 1,799 | 19,502 |
| 2.000 | 2,016 | 47,228 |
| 5.000 | 1,731 | 126,300 |
| 10.000 | 1,690 | 215,046 |
| 20.000 | 1,614 | 469,230 |

Referanslar DUT’tan daha gürültülü olmasına rağmen iterasyon sayısı arttıkça
ölçülen eğri DUT spektrumuna yaklaşmıştır. Bir iterasyonda `14,098 dB` olan
hata, 20.000 iterasyonda `1,614 dB` değerine düşmüştür.

Hatanın yüksek iterasyonlarda sıfıra yaklaşmaması yalnızca referans
gürültüsünden kaynaklanmamaktadır. Filtre transfer fonksiyonu, sonlu kayıt
uzunluğu, tüm bantta hesaplanan MAE ve `abs(S_cross)` kullanımının oluşturduğu
pozitif yanlılık da kalan hata tabanına katkıda bulunmaktadır.

![Şekil 4. Yüksek iterasyon sayısının zor ölçüm koşulundaki etkisi](<phasedetector with cross correlation optimized/results/20260820_081605998_iterations/plots/iterations_comparison.png>)

*Şekil 4. Referanslar DUT’tan daha gürültülü olduğu hâlde iterasyon sayısının
artırılmasıyla Cross-PSD tahmininin DUT spektrumuna yaklaşması.*

## 9. Sonuçların Genel Değerlendirmesi

Elde edilen sonuçlar çapraz korelasyon yönteminin beklenen temel davranışını
doğrulamaktadır:

1. İki kanalda ortak olan DUT faz gürültüsü kompleks Cross-PSD ortalamasında
   korunmuştur.
2. İki bağımsız referansa ait korelasyonsuz bileşenler iterasyon sayısı
   arttıkça bastırılmıştır.
3. Referans RMS değeri DUT RMS değerinden küçük olduğunda düşük hata elde
   edilmiştir.
4. Referans gürültüsü DUT’tan büyük olduğunda daha fazla iterasyona ihtiyaç
   duyulmuştur.
5. Çok yüksek DUT RMS değerlerinde faz dedektörünün sinüs doğrusalsızlığı
   belirgin hâle gelmiştir.
6. İterasyon sayısının artırılması istatistiksel hatayı azaltmış, ancak filtre
   ve model kaynaklı sistematik hata tabanını ortadan kaldırmamıştır.

Projenin hedefini doğrudan gösteren sonuç `DUT=0,20 rad`,
`Ref1=Ref2=0,02 rad` ve 100 iterasyon koşuludur. Referans RMS değeri DUT RMS
değerinin onda biri olduğundan referansların bağımsız gürültü katkısı daha
kolay bastırılmıştır. Cross-PSD tahmini DUT periodogramını `0,092 dB` ortalama
hata ile izlemiştir. Bu koşulda 100 kompleks spektrum ortalaması DUT faz
gürültüsünü çıkarmak için yeterli olmuştur.

Daha zor olan `Ref RMS > DUT RMS` koşulundaki 20.000 iterasyon deneyi de
yöntemin yalnızca düşük gürültülü referanslarla sınırlı olmadığını
göstermektedir. Bununla birlikte bu durumda daha uzun hesaplama süresi ve daha
yüksek kalan hata söz konusudur.

## 10. Sonuç

Bu projede iki bağımsız referans kanalına dayalı çapraz korelasyon faz
gürültüsü ölçüm yöntemi başarıyla modellenmiştir. Quadrature karıştırma ile
faz farkı taban banda taşınmış, Butterworth alçak geçiren filtre ile toplam
frekans bileşeni bastırılmış, faz dedektörü kazancı ile rad ölçeğine geçilmiş
ve iki ölçüm kanalının Cross-PSD değeri hesaplanmıştır.

İlk kodda kullanılan zaman bölgesi korelasyon zinciri yerine doğrudan FFT
çarpımının kullanılması en önemli hesaplama optimizasyonudur. FFT uzunluğunun
ikinin kuvveti seçilmesi, filtre katsayılarının önbelleğe alınması, iki kanalın
vektörleştirilmiş biçimde filtrelenmesi, sabit hesapların döngü dışına alınması
ve dizilerin önceden ayrılması diğer temel iyileştirmelerdir.

Çalışmanın temel sonucu şu şekilde ifade edilebilir:

> Referans kaynaklarının RMS faz gürültüsü DUT’ninkinden küçük olduğunda,
> yeterli sayıda kompleks Cross-PSD ortalaması alınarak DUT faz gürültüsü
> yüksek doğrulukla elde edilebilmektedir.

Bu sonuç `DUT=0,20 rad`, `Ref1=Ref2=0,02 rad` ve 100 iterasyon için elde
edilen `0,092 dB` MAE değeriyle desteklenmektedir. Ayrıca referansların
DUT’tan daha gürültülü olduğu durumda bile iterasyon sayısı 20.000’e
çıkarıldığında hata `14,098 dB` değerinden `1,614 dB` değerine düşmüştür.
Dolayısıyla iterasyon sayısı, ölçüm tabanını düşüren temel parametredir;
ancak sistematik hatalar nedeniyle iyileşme sonsuza kadar devam etmez.

## 11. Sınırlamalar ve Gelecek Çalışmalar

1. Mevcut gürültü üreticisi yalnızca `1/f³` PSD oluşturmaktadır. `1/f⁰` ile
   `1/f⁴` arasındaki bileşenlerin birlikte tanımlanabildiği genel bir güç
   kanunu modeli eklenmelidir.
2. MAE hesabı filtrelenmiş Cross-PSD ile filtresiz DUT periodogramını geniş
   bantta karşılaştırmaktadır. Kullanıcı tanımlı offset ölçüm bandı
   eklenmelidir.
3. Temel karşılaştırma ayarında `settling_samples=0` kullanılması IIR filtrenin
   başlangıç geçici rejimini sonuca katabilir. Filtre zaman sabitine bağlı
   otomatik settling süresi belirlenmelidir.
4. Periodogramda dikdörtgen pencere kullanılmaktadır. Hann pencereli Welch
   veya segmentli Cross-PSD seçeneği incelenmelidir.
5. Düşük SNR koşulunda `abs(S_cross)` pozitif yanlılık oluşturabilir.
   `real(S_cross)` tahmini, negatif çapraz güç değerlerinin işlenmesi ve güven
   aralıkları araştırılmalıdır.
6. Zaman tabanlı seed kullanımında DUT, Ref1 ve Ref2 dizilerinin gerçekten
   bağımsız olduğu korelasyon testleriyle doğrulanmalıdır.
7. Aynı rastgele veri kullanılarak eski `xcorr` yöntemi ile yeni FFT yöntemi
   için süre ve bellek benchmark’ı yapılmalıdır.
8. Her parametre koşusu birden fazla bağımsız tekrar ile çalıştırılmalı; MAE
   ortalaması, standart sapması ve güven aralığı raporlanmalıdır.
9. Referanslar arasına kontrollü korelasyon eklenerek kanal sızıntısına
   duyarlılık ölçülmelidir.
10. Model; ADC kuantalaması, örnekleme saati jitteri, karıştırıcı gürültüsü,
    kanal kazanç/faz uyumsuzluğu ve donanım gürültü tabanıyla genişletilmelidir.

## Kaynakça

1. IEEE Std 1139-2008, *IEEE Standard Definitions of Physical Quantities for
   Fundamental Frequency and Time Metrology: Random Instabilities*.
2. E. Rubiola, *Phase Noise and Frequency Stability in Oscillators*, Cambridge
   University Press, 2008.
3. D. B. Leeson, “A Simple Model of Feedback Oscillator Noise Spectrum,”
   *Proceedings of the IEEE*, cilt 54, sayı 2, ss. 329-330, 1966.
4. E. Rubiola ve F. Vernotte, “The Cross-Spectrum Experimental Method,”
   arXiv:1003.0113, 2010, <https://arxiv.org/abs/1003.0113>.
5. Hewlett-Packard, *Phase Noise Characterization of Microwave Oscillators:
   Frequency Discriminator Method*, Product Note 11729C-2.
6. Keysight Technologies, *Phase Noise Measurement Guide*.
7. GNU Octave, *Signal Package Documentation*.

## Ek A. Temel Algoritmanın Sözde Kodu

```text
Yapılandırma değerlerini doğrula
Zaman, taşıyıcı, quadrature faz ve FFT boyunu hesapla
Cross-PSD ve DUT PSD toplam dizilerini sıfırla

Her iterasyon için
    Yeni DUT faz gürültüsü üret
    DUT taşıyıcısını oluştur

    Bağımsız Ref1 ve Ref2 faz gürültülerini üret
    İki quadrature referans taşıyıcısını oluştur

    DUT × Ref1 ve DUT × Ref2 karıştırma işlemlerini yap
    İki kanalı Butterworth alçak geçiren filtreden geçir
    Kpd değerine böl
    Geçici rejim örneklerini ve DC bileşenini kaldır

    Y1 = FFT(kanal 1)
    Y2 = FFT(kanal 2)
    S12 = Y1 × conj(Y2) / (fs × M)
    Kompleks S12 değerini toplama ekle

    Aynı DUT faz dizisinin periodogramını hesapla
    Doğrusal DUT PSD toplamına ekle
Son

Kompleks Cross-PSD ortalamasını hesapla
Doğrusal DUT PSD ortalamasını hesapla
sin(φ) doğrusalsızlık düzeltmesini uygula
Spektrumları logaritmik binle
Tek taraflı PSD değerlerini dBc/Hz’e dönüştür
Ortak frekans ekseninde MAE hesapla
Spektrumları, parametreleri, metrikleri ve grafikleri kaydet
```

## Ek B. Raporda Kullanılan Sonuç Dosyaları

- `phasedetector with cross correlation optimized/results/20260819_123914852_iterations/summary.csv`
- `phasedetector with cross correlation optimized/results/20260819_123914852_rms_ref/summary.csv`
- `phasedetector with cross correlation optimized/results/20260819_123914852_rms_dut/summary.csv`
- `phasedetector with cross correlation optimized/results/20260819_123914852_lpf_cutoff/summary.csv`
- `phasedetector with cross correlation optimized/results/20260819_123914852_log_bins/summary.csv`
- `phasedetector with cross correlation optimized/results/20260820_081605998_iterations/summary.csv`
