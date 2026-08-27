import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class CrossPSDOrtalama(Slide):
    bolum = "6.3 · KOMPLEKS CROSS-PSD VE DOĞRUSAL ORTALAMA"
    baslik = "Magnitude, kompleks ortalamadan SONRA alınır"

    def construct(self):
        self.kur_baslik()

        e = MathTex(r"\hat{S}_{12}[k]=\frac{X_1[k]\,X_2^{*}[k]}{f_s M}",
                    font_size=38, color=INK)
        e.move_to([0, 1.35, 0])
        self.play(Write(e), run_time=1.2)

        nyq = Small("DC ve Nyquist kutuları tek taraflı dönüşümde ikiyle çarpılmaz",
                    size=17)
        nyq.next_to(e, DOWN, buff=0.28)
        self.play(FadeIn(nyq), run_time=0.6)
        self.wait(0.7)

        # ---- iki yol karşılaştırması ----
        def yol(baslik, adimlar, sonuc, renk, dogru):
            b = Text(baslik, font=FONT, weight=BOLD, font_size=21, color=renk)
            ad = VGroup(*[Text(a, font=FONT, font_size=18, color=INK_DIM)
                          for a in adimlar]).arrange(DOWN, buff=0.16)
            isaret = Text("✓" if dogru else "✗", font=FONT, weight=BOLD,
                          font_size=34, color=renk)
            s = Text(sonuc, font=FONT, weight=BOLD, font_size=19, color=renk)
            son_g = VGroup(isaret, s).arrange(RIGHT, buff=0.2)
            ic = VGroup(b, ad, son_g).arrange(DOWN, buff=0.3)
            c = RoundedRectangle(width=5.5, height=ic.height + 0.75,
                                 corner_radius=0.15, stroke_color=renk,
                                 stroke_width=2, fill_color=renk,
                                 fill_opacity=0.07)
            c.move_to(ic.get_center())
            return VGroup(c, ic)

        dogru_y = yol("Kullanılan yöntem",
                      ["kompleks spektrumları topla",
                       "iterasyon sayısına böl",
                       "en sonda |·| al"],
                      "referans gürültüsü sönümlenir", C_OK, True)
        yanlis_y = yol("Yapılsaydı hatalı olurdu",
                       ["her iterasyonda |·| al",
                        "sonra ortalamayı hesapla",
                        "işaret bilgisi kaybolur"],
                       "iptal gerçekleşmez", C_DUT, False)
        ikili = VGroup(dogru_y, yanlis_y).arrange(RIGHT, buff=0.85)
        ikili.move_to([0, -1.35, 0])

        self.play(FadeIn(dogru_y, shift=UP * 0.2), run_time=1.0)
        self.play(FadeIn(yanlis_y, shift=UP * 0.2), run_time=1.0)
        self.wait(1.6)

        alt = Text("Filtresiz DUT faz dizilerinin dikdörtgen pencereli "
                   "periodogramları da aynı yinelemelerde lineer güç alanında "
                   "ortalanır → iki eğri aynı Monte Carlo popülasyonuna dayanır.",
                   font=FONT, weight=MEDIUM, font_size=19, color=C_GOLD,
                   line_spacing=1.0)
        alt.set(width=min(alt.width, 12.2))
        alt.to_edge(DOWN, buff=0.35)
        self.play(FadeIn(alt, shift=UP * 0.1), run_time=1.1)
        self.wait(2.6)


class LogBinlemeMAE(Slide):
    bolum = "6.4 · LOGARİTMİK BİNLEME VE DEĞERLENDİRME METRİĞİ"
    baslik = "Eğrileri karşılaştırılabilir hale getirmek"

    def construct(self):
        self.kur_baslik()

        adimlar = [
            ("Bin merkezi", "geometrik frekans ortalaması", C_DUT_SIG),
            ("Bin gücü", "doğrusal PSD'nin aritmetik ortalaması", C_REF1),
            ("SSB dönüşümü", "dBc/Hz'e geçiş binlemeden SONRA uygulanır", C_REF2),
        ]
        g = VGroup()
        for i, (b, a, renk) in enumerate(adimlar):
            no = Text(str(i + 1), font=FONT, weight=BOLD, font_size=20, color=BG)
            cc = Circle(radius=0.24, color=renk, fill_color=renk, fill_opacity=1,
                        stroke_width=0)
            no.move_to(cc.get_center())
            bt = Text(b, font=FONT, weight=BOLD, font_size=21, color=renk)
            at = Text(a, font=FONT, font_size=19, color=INK_DIM)
            satir = VGroup(VGroup(cc, no), bt, at).arrange(RIGHT, buff=0.28)
            g.add(satir)
        g.arrange(DOWN, aligned_edge=LEFT, buff=0.38)
        g.move_to([-0.2, 1.15, 0]).to_edge(LEFT, buff=1.0)

        self.play(LaggedStart(*[FadeIn(s, shift=RIGHT * 0.25) for s in g],
                              lag_ratio=0.3), run_time=2.2)
        self.wait(1.0)

        # ---- MAE ----
        mae_b = Text("Değerlendirme metriği: MAE", font=FONT, weight=BOLD,
                     font_size=24, color=C_GOLD)
        mae_e = MathTex(r"\mathrm{MAE}=\frac{1}{J}\sum_{j=1}^{J}"
                        r"\Bigl|\,\mathcal{L}_{cross}(f_j)-"
                        r"\mathcal{L}_{DUT}(f_j)\,\Bigr|",
                        font_size=34, color=INK)
        mae_a = Small("iki log-bin eğrisi ortak frekans aralığında "
                      "200 logaritmik noktaya enterpole edilir", size=17)
        blok = VGroup(mae_b, mae_e, mae_a).arrange(DOWN, buff=0.28)
        kut = RoundedRectangle(width=blok.width + 1.1, height=blok.height + 0.8,
                               corner_radius=0.16, stroke_color=C_GOLD,
                               stroke_width=2, fill_color=C_GOLD, fill_opacity=0.07)
        kut.move_to(blok.get_center())
        grup = VGroup(kut, blok).move_to([0, -1.85, 0])
        self.play(FadeIn(grup, shift=UP * 0.2), run_time=1.3)
        self.wait(2.6)


class Kapsam(Slide):
    bolum = "6.5 · MODELİN KAPSAMI"
    baslik = "Neyi modelledik, neyi modellemedik?"

    def construct(self):
        self.kur_baslik()

        def sutun(baslik, ogeler, renk, isaret):
            b = Text(baslik, font=FONT, weight=BOLD, font_size=23, color=renk)
            satirlar = VGroup()
            for o in ogeler:
                ik = Text(isaret, font=FONT, weight=BOLD, font_size=19, color=renk)
                t = Text(o, font=FONT, font_size=19, color=INK_DIM)
                if t.width > 4.7:
                    t.set(width=4.7)
                satirlar.add(VGroup(ik, t).arrange(RIGHT, buff=0.22,
                                                   aligned_edge=UP))
            satirlar.arrange(DOWN, aligned_edge=LEFT, buff=0.26)
            return VGroup(b, satirlar).arrange(DOWN, aligned_edge=LEFT, buff=0.4)

        var = sutun("Modellenen", [
            "1/f³ karakterli bağımsız faz gürültüsü realizasyonları",
            "Quadrature çalışan çarpım tipi faz detektörü",
            "4. derece Butterworth LPF ve DC silme",
            "FFT tabanlı kompleks Cross-PSD ve iterasyon ortalaması",
        ], C_OK, "✓")
        yok = sutun("İdeal kabul edilen", [
            "PLL, LNA ve ADC blokları",
            "Kuantalama ve örnekleme saati jitteri",
            "Kanal sızıntısı, kazanç / faz uyumsuzluğu",
            "Sıcaklık ve gerçek mikser doğrusal-olmama etkileri",
        ], C_WARN, "○")

        ikili = VGroup(var, yok).arrange(RIGHT, buff=1.25, aligned_edge=UP)
        ikili.move_to([0, 0.55, 0])
        ayrac = Line(UP, DOWN, color=RULE, stroke_width=1.6)
        ayrac.set_height(ikili.height + 0.4).move_to(ikili.get_center())
        ayrac.set_x((var.get_right()[0] + yok.get_left()[0]) / 2)

        self.play(FadeIn(var, shift=RIGHT * 0.2), run_time=1.1)
        self.play(Create(ayrac), run_time=0.4)
        self.play(FadeIn(yok, shift=LEFT * 0.2), run_time=1.1)
        self.wait(1.4)

        rz = rozet("Sonuçlar ticari bir analizörün mutlak duyarlılığını değil, "
                   "yöntemin davranışını temsil eder", C_GOLD, fs=20)
        rz.to_edge(DOWN, buff=0.55)
        self.play(FadeIn(rz, scale=0.96), run_time=1.1)
        self.wait(2.6)
