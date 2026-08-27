import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class GurultuCesitleri(Slide):
    bolum = "4.1 · SPEKTRAL EĞİME GÖRE"
    baslik = "Faz gürültüsü çeşitleri: güç yasası modeli"

    def construct(self):
        self.kur_baslik()

        model = MathTex(r"S_{\phi}(f)=\sum_{\alpha=-4}^{0} h_{\alpha}\,f^{\alpha}",
                        font_size=34, color=INK)
        model.move_to([-3.6, 1.30, 0])
        self.play(Write(model), run_time=1.0)

        # ---- log-log eksen ----
        ax = Axes(x_range=[0, 5, 1], y_range=[-100, 20, 20],
                  x_length=5.35, y_length=4.05,
                  axis_config={"stroke_color": RULE, "stroke_width": 1.8,
                               "include_ticks": False, "include_tip": False})
        ax.move_to([-3.45, -1.10, 0])
        xl = Small("offset frekansı  (log)", size=17)
        xl.next_to(ax, DOWN, buff=0.16)
        yl = Small("Sφ(f)  (dB)", size=17).rotate(PI / 2)
        yl.next_to(ax, LEFT, buff=0.16)
        self.play(Create(ax), FadeIn(xl), FadeIn(yl), run_time=0.8)

        # eğim segmentleri: (isim, egim db/dekad, renk)
        seg = [("1/f⁴", -40, "#F87171"),
               ("1/f³", -30, C_GOLD),
               ("1/f²", -20, C_OK),
               ("1/f",  -10, C_DUT_SIG),
               ("sabit", 0,  C_REF2)]

        y = 12.0
        x = 0.15
        parcalar = VGroup()
        etiketler = VGroup()
        for isim, egim, renk in seg:
            dx = 0.95
            y2 = y + egim * dx
            ln = Line(ax.c2p(x, y), ax.c2p(x + dx, y2)).set_stroke(renk, 5)
            lb = Text(isim, font=FONT, weight=BOLD, font_size=18, color=renk)
            lb.next_to(ln.get_center(), UR, buff=0.06).shift(LEFT * 0.12)
            parcalar.add(ln)
            etiketler.add(lb)
            x += dx
            y = y2

        for ln, lb in zip(parcalar, etiketler):
            self.play(Create(ln), FadeIn(lb), run_time=0.45)

        yakin = Small("taşıyıcıya yakın", size=15)
        uzak = Small("taşıyıcıdan uzak", size=15)
        yakin.next_to(ax.c2p(0.5, -100), UP, buff=0.08)
        uzak.next_to(ax.c2p(4.5, -100), UP, buff=0.08)
        self.play(FadeIn(yakin), FadeIn(uzak), run_time=0.5)

        # ---- tablo ----
        tb = tablo(["Gürültü türü", "Sφ(f)", "Eğim", "Baskın bölge"],
                   [["Random-walk FM", "1/f⁴", "−40 dB/dek", "çok yakın"],
                    ["Flicker FM", "1/f³", "−30 dB/dek", "yakın offset"],
                    ["White FM", "1/f²", "−20 dB/dek", "orta offset"],
                    ["Flicker PM", "1/f", "−10 dB/dek", "orta/uzak"],
                    ["White PM", "sabit", "0 dB/dek", "uzak bölge"]],
                   fs=19, col_w=[2.5, 1.05, 1.65, 1.75], vurgu_satir=1)
        tb.scale(0.95)
        tb.move_to([3.35, 0.35, 0])
        self.play(FadeIn(tb, shift=LEFT * 0.2), run_time=1.2)
        self.wait(1.6)

        # ---- bu projede kullanılan ----
        kut = RoundedRectangle(width=6.4, height=1.55, corner_radius=0.15,
                               stroke_color=C_GOLD, stroke_width=2.5,
                               fill_color=C_GOLD, fill_opacity=0.09)
        ic = VGroup(
            Text("Bu projede: Flicker FM  (Sφ ∝ 1/f³)", font=FONT, weight=BOLD,
                 font_size=22, color=C_GOLD),
            MathTex(r"H(f)=1/\sqrt{f^{3}}\ \ \longrightarrow\ \ S_{\phi}(f)\propto 1/f^{3}",
                    font_size=25, color=INK_DIM),
            Small("güç, genliğin karesi olduğu için genlik filtresi karekök alınır",
                  size=15),
        ).arrange(DOWN, buff=0.16)
        ic.move_to(kut.get_center())
        grup = VGroup(kut, ic).move_to([3.35, -2.55, 0])

        vurgu_ln = parcalar[1].copy().set_stroke(C_GOLD, 13, opacity=0.45)
        self.play(FadeIn(grup, shift=UP * 0.2), FadeIn(vurgu_ln), run_time=1.2)
        self.wait(2.6)


class OlcumTuru(Slide):
    bolum = "4.2 · ÖLÇÜM TÜRÜNE GÖRE"
    baslik = "Absolute ve additive (residual) faz gürültüsü"

    def construct(self):
        self.kur_baslik()

        # ---- absolute ----
        osc = kutu("Osilatör /\nSinyal Kaynağı", w=3.0, h=1.25,
                   color=C_DUT_SIG, fs=19)
        out1 = Dot(radius=0.09, color=C_DUT_SIG)
        a1 = ok(osc.get_right(), osc.get_right() + RIGHT * 1.5, C_DUT_SIG)
        out1.move_to(osc.get_right() + RIGHT * 1.62)
        g1 = VGroup(osc, a1, out1)
        g1.move_to([-3.6, 1.05, 0])

        b1 = Text("Absolute phase noise", font=FONT, weight=BOLD,
                  font_size=25, color=C_DUT_SIG)
        a1t = Text("Bir osilatörün veya sinyal kaynağının\ntoplam faz gürültüsü",
                   font=FONT, font_size=20, color=INK_DIM, line_spacing=0.95)
        blok1 = VGroup(b1, a1t).arrange(DOWN, aligned_edge=LEFT, buff=0.22)
        blok1.next_to(g1, RIGHT, buff=1.0).set_y(g1.get_center()[1])

        self.play(FadeIn(g1, shift=RIGHT * 0.2), run_time=0.9)
        self.play(FadeIn(blok1, shift=LEFT * 0.2), run_time=0.9)
        self.wait(1.3)

        # ---- additive / residual ----
        gir = Dot(radius=0.09, color=INK_DIM)
        dev = kutu("İki portlu eleman\n(amplifikatör, mikser,\nfrekans dönüştürücü)",
                   w=3.4, h=1.55, color=C_REF1, fs=17)
        cik = Dot(radius=0.09, color=C_REF1)
        gir.move_to(dev.get_left() + LEFT * 1.5)
        cik.move_to(dev.get_right() + RIGHT * 1.5)
        a2 = ok(gir.get_center(), dev.get_left(), INK_DIM)
        a3 = ok(dev.get_right(), cik.get_center(), C_REF1)
        eklenen = Text("+ eklenen gürültü", font=FONT, weight=BOLD,
                       font_size=17, color=C_REF1)
        eklenen.next_to(dev, DOWN, buff=0.22)
        g2 = VGroup(gir, a2, dev, a3, cik, eklenen)
        g2.move_to([-3.35, -1.75, 0])

        b2 = Text("Additive / residual phase noise", font=FONT, weight=BOLD,
                  font_size=25, color=C_REF1)
        a2t = Text("İki portlu bir elemanın işarete\nkendi eklediği gürültü",
                   font=FONT, font_size=20, color=INK_DIM, line_spacing=0.95)
        blok2 = VGroup(b2, a2t).arrange(DOWN, aligned_edge=LEFT, buff=0.22)
        blok2.next_to(g2, RIGHT, buff=0.75).set_y(g2.get_center()[1])

        self.play(FadeIn(g2, shift=RIGHT * 0.2), run_time=0.9)
        self.play(FadeIn(blok2, shift=LEFT * 0.2), run_time=0.9)

        ayrac = Line(LEFT, RIGHT, color=RULE, stroke_width=1.6)
        ayrac.set_width(12.0).set_y(-0.35)
        self.add(ayrac)
        self.wait(2.6)
