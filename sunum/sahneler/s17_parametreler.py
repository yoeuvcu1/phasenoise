import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class KodAkisi(Slide):
    bolum = "7.1 · MODELİN FONKSİYON AKIŞI"
    baslik = "Octave modelinin yapısı"

    def construct(self):
        self.kur_baslik()

        a = kutu("run_comparisons.m", w=4.2, h=0.9, color=C_REF1, fs=20)
        b = kutu("run_comparisons_main.m", w=4.9, h=0.9, color=C_REF2, fs=20)
        c = kutu("run_simulation.m", w=4.2, h=0.9, color=C_CROSS, fs=20)
        d = kutu("measure_iteration.m", w=4.4, h=0.9, color=INK, fs=19)
        e = kutu("compute_cross_psd.m", w=4.4, h=0.9, color=INK, fs=19)

        zincir = VGroup(a, b, c).arrange(DOWN, buff=0.60)
        zincir.move_to([-0.75, -0.18, 0])
        alt = VGroup(d, e).arrange(DOWN, buff=0.40)
        alt.next_to(c, RIGHT, buff=1.05).set_y(c.get_center()[1])

        o1 = ok(a.get_bottom(), b.get_top(), INK_DIM)
        o2 = ok(b.get_bottom(), c.get_top(), INK_DIM)
        o3 = ok(c.get_right(), d.get_left(), INK_DIM)
        o4 = ok(c.get_right(), e.get_left(), INK_DIM)

        aciklamalar = [
            ("test edilecek\nparametreleri tanımlar", a),
            ("her değeri bağımsız çalıştırır\nve sonuçları kaydeder", b),
            ("ana hesaplamalar\nburada yapılır", c),
        ]

        self.play(FadeIn(a), run_time=0.6)
        for txt, hedef in aciklamalar:
            pass
        self.play(GrowArrow(o1), FadeIn(b), run_time=0.7)
        self.play(GrowArrow(o2), FadeIn(c), run_time=0.7)
        self.play(GrowArrow(o3), FadeIn(d), GrowArrow(o4), FadeIn(e),
                  run_time=0.9)

        notlar = VGroup()
        for txt, hedef in aciklamalar:
            t = Text(txt, font=FONT, font_size=16, color=INK_DIM)
            if t.width > 3.45:
                t.set(width=3.45)
            t.next_to(hedef, LEFT, buff=0.28)
            notlar.add(t)
        self.play(LaggedStart(*[FadeIn(n, shift=RIGHT * 0.15) for n in notlar],
                              lag_ratio=0.25), run_time=1.4)
        self.wait(1.2)

        vurgu = Text("Her iterasyonda yeni bir DUT, Ref1 ve Ref2 realizasyonu "
                     "oluşturulur;\naynı iterasyondaki iki kanal ortak DUT'u "
                     "kullanırken referanslar bağımsızdır.",
                     font=FONT, weight=MEDIUM, font_size=20, color=C_GOLD,
                     line_spacing=1.0)
        vurgu.set(width=min(vurgu.width, 12.0))
        vurgu.to_edge(DOWN, buff=0.45)
        self.play(FadeIn(vurgu, shift=UP * 0.12), run_time=1.1)
        self.wait(2.4)


class Optimizasyonlar(Slide):
    bolum = "7.2 · YAPILAN OPTİMİZASYONLAR"
    baslik = "Önceki yöntemden optimize edilmiş yönteme"

    def construct(self):
        self.kur_baslik()

        satirlar = [
            ["xcorr → ifftshift → fft", "doğrudan  X₁X₂*", "daha az işlem"],
            ["NFFT = 2Nc − 1", "nextpow2(2Nc − 1)", "radix-2 hızlı FFT"],
            ["LPF her iterasyonda tasarlanıyor", "katsayılar bir kez hesaplanıyor",
             "tekrarlı işlem kaldırıldı"],
            ["kanallar ayrı filtreleniyor", "iki kolon tek çağrıda",
             "vektörleştirme"],
            ["her iterasyonda kayan ortalama", "topla, sonda böl",
             "daha az bölme"],
            ["log-bin içinde maksimum", "lineer PSD ortalaması",
             "daha doğru ortalama güç"],
            ["kullanılmayan Welch sonuçları", "yalnız Cross-PSD ve DUT FFT",
             "daha sade çıktı"],
            ["kontrolsüz girişler", "validate_config doğrulaması",
             "hataların erken yakalanması"],
        ]
        tb = tablo(["Önceki Yöntem", "Optimize Edilmiş Yöntem", "Kazanım"],
                   satirlar, fs=18, col_w=[4.5, 4.6, 3.7], vurgu_satir=0,
                   hiza=["l", "l", "l"])
        tb.scale(0.93)
        tb.move_to([0, -0.35, 0])

        self.play(FadeIn(tb[0]), Create(tb[1]), run_time=0.8)
        self.play(LaggedStart(*[FadeIn(r, shift=RIGHT * 0.2) for r in tb[2:]],
                              lag_ratio=0.18), run_time=2.6)
        self.wait(1.2)

        e = MathTex(r"S_{12}(f)=\frac{X_1 X_2^{*}}{f_s N_c}",
                    font_size=32, color=C_OK)
        rz = rozet("matematiksel olarak eşdeğer, büyük N ve M'de çok daha hızlı",
                   C_OK, fs=19)
        g = VGroup(e, rz).arrange(RIGHT, buff=0.6)
        g.to_edge(DOWN, buff=0.42)
        self.play(FadeIn(g, shift=UP * 0.15), run_time=1.1)
        self.wait(2.4)


class TemelParametreler(Slide):
    bolum = "8.1 · TEMEL SİMÜLASYON PARAMETRELERİ"
    baslik = "Karşılaştırmaların varsayılan değerleri"

    def construct(self):
        self.kur_baslik()

        sol = tablo(["Parametre", "Değer"],
                    [["Örnek sayısı N", "1.000.000"],
                     ["Örnekleme frekansı", "1 MHz"],
                     ["Taşıyıcı frekansı", "200 kHz"],
                     ["Taşıyıcı genliği", "1"],
                     ["LPF derecesi", "4"]],
                    fs=21, col_w=[4.3, 3.0])
        sag = tablo(["Parametre", "Değer"],
                    [["LPF kesim frekansı", "50 kHz"],
                     ["DUT RMS", "0,05 rad"],
                     ["Ref. 1 / Ref. 2 RMS", "0,05 rad"],
                     ["İterasyon sayısı", "100"],
                     ["Log-bin sayısı", "100"]],
                    fs=21, col_w=[4.3, 3.0])
        ikili = VGroup(sol, sag).arrange(RIGHT, buff=1.1, aligned_edge=UP)
        ikili.move_to([0, 0.55, 0])

        self.play(FadeIn(sol[0]), Create(sol[1]),
                  FadeIn(sag[0]), Create(sag[1]), run_time=0.9)
        self.play(LaggedStart(*[FadeIn(r, shift=UP * 0.15)
                                for r in list(sol[2:]) + list(sag[2:])],
                              lag_ratio=0.13), run_time=2.0)
        self.wait(1.0)

        n1 = madde("Her deneyde yalnızca incelenen parametre değiştirilir, "
                   "diğerleri temel değerinde tutulur.", C_GOLD, fs=21, w=11.5)
        n2 = madde("Uzun iterasyon karşılaştırmasında kesim frekansı 50 kHz, "
                   "referans RMS'i yakınsamayı daha net göstermek için "
                   "DUT'den yüksek seçilmiştir.", C_DUT_SIG, fs=21, w=11.5)
        notlar = VGroup(n1, n2).arrange(DOWN, aligned_edge=LEFT, buff=0.42)
        notlar.to_edge(DOWN, buff=0.6).to_edge(LEFT, buff=0.85)
        self.play(FadeIn(n1, shift=RIGHT * 0.2), run_time=0.9)
        self.play(FadeIn(n2, shift=RIGHT * 0.2), run_time=0.9)
        self.wait(2.6)
