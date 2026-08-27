# -*- coding: utf-8 -*-
"""Her sahne için konuşmacı notu (rapordaki metne dayanır)."""

NOTLAR = {
"Baslik": "İki referans kanallı faz dedektörü mimarisini sayısal olarak kuruyoruz, "
    "kanallarda ortak olan DUT bileşenini Cross-PSD ortalamasıyla kestiriyoruz.",
"Giris": "Faz gürültüsü haberleşmede modülasyon kalitesini ve komşu kanal "
    "performansını, radarda güçlü yansımalar yanındaki zayıf hedeflerin "
    "seçilebilirliğini, sayısal sistemlerde saat jitterini sınırlar. Kritik nokta: "
    "ölçüm sisteminin kendi gürültü tabanı da bir sınır koyar.",
"FazGurultusuNedir": "İdeal osilatör tek spektral çizgi üretir. Gerçekte termal "
    "etkiler, aktif eleman gürültüsü, rezonatör kayıpları ve besleme değişimleri "
    "anlık fazı rastgele kaydırır. Bu projede genlik gürültüsü ε(t) ihmal edilip "
    "yalnız faz gürültüsü ele alınır.",
"ZamanFrekans": "Zaman bölgesi baskın frekansı gösterir ama gürültüyü ayırt "
    "ettirmez. Fourier dönüşümüyle sinyalin hangi frekansta hangi güçte olduğunu "
    "görürüz; faz gürültüsü taşıyıcı çevresinde yan bant olarak ortaya çıkar.",
"SSBTanimi": "Faz gürültüsü, taşıyıcıdan belirli offsette 1 Hz bant genişliğine "
    "normalize edilmiş tek yan bant güç oranıdır. L(f) = ½·Sφ(f), logaritmik "
    "gösterimde dBc/Hz.",
"EtkiRegrowth": "Yerel osilatördeki faz gürültüsü giriş sinyaliyle karışır ve "
    "mikser çıkışına aynen biner. LTE, 5G NR ve Wi-Fi gibi geniş bantlarda komşu "
    "kanala güç sızıntısı olarak görülür.",
"EtkiReciprocal": "Karşılıklı karıştırma, istenen küçük sinyal büyük istenmeyen "
    "bir sinyale yakınken ortaya çıkar. Gerçek spektrumlar keskin olmadığı için "
    "büyük sinyalin yayılan enerjisi istenen sinyali bastırabilir.",
"EtkiConstellation": "APSK ve QAM gibi şemalarda her nokta genlik ve faz bilgisi "
    "taşır. Faz gürültüsü noktaları yay boyunca dağıtır; bulutlar karar "
    "sınırlarını aştığında bit hataları artar.",
"GurultuCesitleri": "Genel güç yasası modeli Sφ(f) = Σ hα f^α. Bu projede "
    "yalnızca Flicker FM karakterinde, PSD'si 1/f³ olan gürültü kullanılmıştır; "
    "güç genliğin karesi olduğu için genlik filtresi 1/√(f³) uygulanır.",
"OlcumTuru": "Absolute phase noise bir kaynağın toplam faz gürültüsüdür. "
    "Additive/residual ise amplifikatör, mikser gibi iki portlu bir elemanın "
    "işarete kendi eklediği gürültüdür.",
"YontemDogrudan": "DUT doğrudan spektrum analizörüne bağlanır. Basit ve hızlıdır "
    "ama ölçülebilecek en düşük seviye analizörün kendi LO faz gürültüsü ve "
    "gürültü tabanıyla sınırlıdır.",
"YontemFazDetektoru": "DUT, 90° faz farkındaki düşük gürültülü bir referansla "
    "mikserde çarpılır; LPF sonrası çıkış y(t) ≈ φ_D(t) − φ_R(t) olur. Taşıyıcı "
    "bastırıldığı için hassasiyet yüksektir, ancak ölçüm referans gürültüsünü de "
    "içerir.",
"YontemCross": "DUT iki bağımsız ölçüm kanalına ayrılır, her kanalda farklı bir "
    "referans kullanılır. İki kanalın cross-PSD'sinde ortak DUT bileşeni korunur, "
    "bağımsız referans gürültüleri iterasyon ortalamasıyla bastırılır.",
"CrossVektorOrtalama": "Y₁Y₂* açıldığında |D|² terimi her iterasyonda aynı, "
    "gerçek ve pozitiftir; diğer üç terim rastgele fazlıdır. Kompleks ortalamada "
    "rastgele fazlılar birbirini götürür, kalan hata 1/√M ile küçülür. "
    "İterasyon sayısı arttıkça ölçüm süresi de doğru orantılı uzar.",
"ModelBlok": "Aynı DUT iki faz detektörüne ortak uygulanır; her kanal DC silme, "
    "normalizasyon ve LPF'den geçer, sonra FFT tabanlı Cross-PSD alınır ve "
    "iterasyonlar boyunca ortalanır.",
"GurultuUretimi": "Her iterasyonda yeni DUT ve iki ayrı referans faz dizisi "
    "üretilir. Referansların merkez fazına π/2 eklenir. Seed, zaman damgasının "
    "büyük bir asal sayıyla çarpımının modülasyonundan üretilir; böylece diziler "
    "tamamen bağımsız olur.",
"MikserKpd": "Çarpım, faz farkını taşıyan taban bant bileşeniyle 2f₀ çevresindeki "
    "toplam bileşeni birlikte üretir. 4. derece Butterworth toplam bileşeni "
    "bastırır; çıkış K_pd = A²/2'ye bölünür ve asin() ile faz farkına çevrilir.",
"CrossPSDOrtalama": "Kompleks spektrumlar bütün yinelemelerde toplanır; magnitude "
    "işlemi kompleks ortalamadan SONRA uygulanır. Aksi hâlde korelasyonsuz "
    "referans bileşenlerinin iptali korunmaz.",
"LogBinlemeMAE": "Bin merkezi geometrik frekans ortalaması, bin gücü doğrusal "
    "PSD'nin aritmetik ortalamasıdır. SSB dönüşümü binlemeden sonra yapılır. MAE, "
    "ortak bantta 200 log noktaya enterpolasyondan sonraki ortalama mutlak dB farkı.",
"Kapsam": "PLL, LNA ve ADC blokları ayrıca modellenmemiştir; kuantalama, saat "
    "jitteri, kanal sızıntısı, kazanç/faz uyumsuzluğu ve mikser doğrusal-olmama "
    "etkileri ideal kabul edilmiştir. Sonuçlar yöntem davranışını temsil eder.",
"KodAkisi": "run_comparisons.m parametreleri tanımlar, run_comparisons_main.m her "
    "değeri bağımsız çalıştırıp kaydeder, ana hesaplamalar run_simulation.m "
    "içindedir.",
"AsinOptimizasyon": "Küçük açı yaklaşımı yüksek RMS'te sonucu yanıltıyor ve "
    "düzeltme faktörü gerektiriyordu. Düşük gürültüde fark 0,01 dB'nin altında; "
    "DUT 0,2 / ref 0,5 rad'da MAE ortalama 2,04 dB'den 1,25 dB'ye indi.",
"Optimizasyonlar": "En önemli değişiklik, xcorr üzerinden spektruma geçmek yerine "
    "cross-spectrum'un doğrudan hesaplanmasıdır: matematiksel olarak eşdeğer, "
    "büyük örnek ve iterasyon sayılarında çok daha hızlı.",
"TemelParametreler": "N = 1.000.000, fs = 1 MHz, f₀ = 200 kHz, LPF 4. derece "
    "50 kHz, DUT ve referans RMS 0,05 rad, 100 iterasyon, 100 log-bin. Her deneyde "
    "yalnız incelenen parametre değişir.",
"LPFTaramasi": "LPF hem 2f₀ bileşenini bastırır hem de ölçülebilen offset bandını "
    "belirler. Karşılaştırılan DUT periodogramı filtresiz olduğu için kesim "
    "üstündeki ayrışma beklenen bir sonuçtur; MAE geçiş bandına bakılarak "
    "yorumlanmalıdır.",
"RMSTaramalari": "İkisi benzer görünse de kritik olan referanstır. Yüksek referans "
    "RMS'i sonlu iterasyonda daha fazla artık bileşen bırakır; aynı doğruluk için "
    "çok daha fazla iterasyon, dolayısıyla zaman ve enerji gerekir.",
"BinSayisi": "Bin sayısı ölçüm kalitesini değil sadece gözlemi etkiler. Her bin "
    "değeri yeni rastgele gerçekleşimlerle çalıştırıldığından fark yalnız "
    "çözünürlüğe bağlanamaz; istatistiksel optimum iddiası kurulmamıştır.",
"IterasyonYakinsama": "σ_DUT 0,02, σ_ref 0,10 rad: referanslar DUT'tan yaklaşık "
    "13,98 dB daha gürültülü. Tam bant MAE 16,699 dB'den 0,845 dB'ye iniyor. "
    "Ara noktalarda monoton değil — her nokta bağımsız realizasyonlarla çalıştığı "
    "için yerel artışlar Monte Carlo değişkenliğiyle uyumlu.",
"DekadAnalizi": "Tam bant tek sayısı geçiş bandındaki uyumu kesim üstündeki artık "
    "ayrışmadan ayırmaz. Dekad ayrımında 20.000 iterasyonda 10 kHz altı 0,16–0,38 "
    "dB'ye inerken 10–100 kHz 2,28 dB, 100–467 kHz 2,53 dB kalıyor — bu fark ölçüm "
    "bandının dışında. Taşıyıcıya yakın offsetlerde birkaç yüz iterasyon yeterken "
    "yüksek offsetlerde çok daha fazlası gerekiyor.",
"PDvsCross": "Eşit şartlarda: referans RMS 0,01 rad'da iki yöntem de gerçek DUT'a "
    "yakınsıyor. Referans 0,10 rad'a çıkınca tek kanallı model 6,94 dB hata "
    "veriyor, çapraz korelasyon 0,89 dB'de kalıyor.",
"SonucKapanis": "Çıkarılabilecek en önemli sonuç: referans RMS'i olabildiğince "
    "düşük olmalı; düşük olmasa dahi yüksek iterasyon sayılarıyla problem "
    "aşılabiliyor. İki kanallı çapraz korelasyonun en büyük avantajı budur.",
"Kapanis": "Teşekkürler.",
}
