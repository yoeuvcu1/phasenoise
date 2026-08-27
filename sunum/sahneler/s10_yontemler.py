import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


def mikser_sembol(r=0.40, renk=INK):
    c = Circle(radius=r, color=renk, stroke_width=3)
    d = r * 0.70
    x = VGroup(Line([-d, -d, 0], [d, d, 0]),
               Line([-d, d, 0], [d, -d, 0])).set_stroke(renk, 3)
    x.move_to(c.get_center())
    return VGroup(c, x)


class YontemDogrudan(Slide):
    bolum = "5.1 · DOĞRUDAN SPEKTRAL ANALİZ"
    baslik = "En basit yöntem: DUT'u doğrudan analizöre bağla"

    def construct(self):
        self.kur_baslik()

        dut = kutu("DUT", w=2.0, h=1.0, color=C_DUT_SIG, fs=22)
        sa = kutu("Spektrum\nAnalizörü", w=2.9, h=1.35, color=INK, fs=20)
        dut.move_to([-3.6, 0.85, 0])
        sa.move_to([0.6, 0.85, 0])
        a = ok(dut.get_right(), sa.get_left(), C_DUT_SIG)

        self.play(FadeIn(dut), GrowArrow(a), FadeIn(sa), run_time=1.2)

        # ekran
        ax = Axes(x_range=[0, 1, 1], y_range=[-90, 10, 20],
                  x_length=3.3, y_length=1.9,
                  axis_config={"stroke_color": RULE, "stroke_width": 1.4,
                               "include_ticks": False, "include_tip": False})
        ax.next_to(sa, RIGHT, buff=0.9)
        egri = ax.plot(lambda u: max(-14 - 30 * np.log10(abs(u - 0.5) * 40 + 1), -78),
                       x_range=[0, 1, 0.004]).set_stroke(C_DUT_SIG, 2.6)
        a2 = ok(sa.get_right(), ax.get_left() + LEFT * 0.1, INK_DIM)
        self.play(GrowArrow(a2), Create(ax), Create(egri), run_time=1.2)

        taban = DashedLine(ax.c2p(0, -62), ax.c2p(1, -62),
                           color=C_DUT, stroke_width=2.4, dash_length=0.1)
        taban_lbl = Text("analizörün kendi gürültü tabanı", font=FONT,
                         font_size=15, color=C_DUT)
        taban_lbl.next_to(taban, DOWN, buff=0.08)
        self.play(Create(taban), FadeIn(taban_lbl), run_time=0.9)

        arti = maddeler(["Basit ve hızlı",
                         "Sonuç doğrudan dBc/Hz\nolarak okunur"],
                        renk=C_OK, fs=20, w=5.0)
        eksi = maddeler(["Ölçülebilen en düşük seviye, analizörün\nkendi yerel "
                         "osilatör faz gürültüsü ve\ngürültü tabanıyla sınırlıdır",
                         "Analizörün faz gürültüsü DUT'den\nyeterince düşük olmalı"],
                        renk=C_DUT, fs=20, w=5.6)
        sol = VGroup(Text("Avantaj", font=FONT, weight=BOLD, font_size=22,
                          color=C_OK), arti)\
            .arrange(DOWN, aligned_edge=LEFT, buff=0.3)
        sag = VGroup(Text("Sınırlama", font=FONT, weight=BOLD, font_size=22,
                          color=C_DUT), eksi)\
            .arrange(DOWN, aligned_edge=LEFT, buff=0.3)
        alt = VGroup(sol, sag).arrange(RIGHT, buff=1.1, aligned_edge=UP)
        alt.scale(0.98).to_edge(DOWN, buff=0.45)

        self.play(FadeIn(sol, shift=UP * 0.2), run_time=0.9)
        self.play(FadeIn(sag, shift=UP * 0.2), run_time=0.9)
        self.wait(2.4)


class YontemFazDetektoru(Slide):
    bolum = "5.2 · FAZ DETEKTÖRÜ YÖNTEMİ"
    baslik = "Taşıyıcıyı bastır, sadece faz farkını ölç"

    def construct(self):
        self.kur_baslik()

        dut = kutu("DUT", w=1.9, h=0.95, color=C_DUT_SIG, fs=21)
        ref = kutu("Referans\nosilatör", w=2.3, h=1.15, color=C_REF1, fs=19)
        mx = mikser_sembol()
        lpf = kutu("LPF", w=1.5, h=0.95, color=INK, fs=20)
        fft = kutu("FFT / PSD", w=2.2, h=0.95, color=C_CROSS, fs=19)

        dut.move_to([-4.9, 0.95, 0])
        mx.move_to([-1.9, 0.95, 0])
        ref.move_to([-1.9, -0.95, 0])
        lpf.move_to([0.55, 0.95, 0])
        fft.move_to([3.35, 0.95, 0])

        a1 = ok(dut.get_right(), mx.get_left(), C_DUT_SIG)
        a2 = ok(ref.get_top(), mx.get_bottom(), C_REF1)
        a3 = ok(mx.get_right(), lpf.get_left(), INK_DIM)
        a4 = ok(lpf.get_right(), fft.get_left(), INK_DIM)

        q = Text("90°", font=FONT, weight=BOLD, font_size=17, color=C_REF1)
        q.next_to(a2, RIGHT, buff=0.1)

        zincir = VGroup(dut, a1, mx, ref, a2, q, lpf, a3, fft, a4)
        zincir.move_to([-0.35, 0.75, 0])

        self.play(LaggedStart(FadeIn(dut), GrowArrow(a1), FadeIn(mx),
                              FadeIn(ref), GrowArrow(a2), FadeIn(q),
                              GrowArrow(a3), FadeIn(lpf),
                              GrowArrow(a4), FadeIn(fft),
                              lag_ratio=0.22), run_time=2.6)

        cikis = MathTex(r"y(t)", r"\;\approx\;", r"\phi_D(t)",
                        r"\;-\;", r"\phi_R(t)", font_size=40, color=INK)
        cikis[2].set_color(C_DUT_SIG)
        cikis[4].set_color(C_REF1)
        cikis.move_to([0.0, -2.00, 0])
        kut = SurroundingRectangle(cikis, color=RULE, stroke_width=2,
                                   buff=0.28, corner_radius=0.12)
        self.play(Create(kut), Write(cikis), run_time=1.4)
        self.wait(1.0)

        arti = madde("Taşıyıcı bastırıldığı için doğrudan spektral analize göre "
                     "çok daha yüksek hassasiyet", C_OK, fs=21, w=11.0)
        eksi = madde("Ölçüm hem DUT hem referans gürültüsünü içerir → "
                     "referans, DUT'den belirgin şekilde sessiz olmalı",
                     C_DUT, fs=21, w=11.0)
        alt = VGroup(arti, eksi).arrange(DOWN, aligned_edge=LEFT, buff=0.4)
        alt.to_edge(DOWN, buff=0.42).to_edge(LEFT, buff=0.9)

        self.play(FadeIn(arti, shift=RIGHT * 0.2), run_time=0.9)
        self.play(FadeIn(eksi, shift=RIGHT * 0.2), run_time=0.9)

        # referans gürültüsü vurgusu
        vur = SurroundingRectangle(cikis[4], color=C_DUT, stroke_width=2.5,
                                   buff=0.1, corner_radius=0.08)
        soru = Text("bu terim ölçüme karışıyor", font=FONT, weight=MEDIUM,
                    font_size=18, color=C_DUT)
        soru.next_to(vur, RIGHT, buff=0.35)
        self.play(Create(vur), FadeIn(soru), run_time=1.0)
        self.wait(2.4)
