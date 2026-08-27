import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class SSBTanimi(Slide):
    bolum = "2.2 · TEK YAN BANT (SSB) FAZ GÜRÜLTÜSÜ"
    baslik = "Faz gürültüsü nasıl sayıya dökülür?"

    def construct(self):
        self.kur_baslik()

        ax = Axes(x_range=[-1, 1, 0.5], y_range=[-95, 12, 20],
                  x_length=7.5, y_length=3.0,
                  axis_config={"stroke_color": RULE, "stroke_width": 1.8,
                               "include_ticks": False, "include_tip": False})
        ax.move_to([-2.1, 0.30, 0])

        def etek(x):
            return -18 - 26 * np.log10(np.abs(x) * 60 + 1)

        sol = ax.plot(etek, x_range=[-1, -0.012, 0.004]).set_stroke(C_DUT_SIG, 3)
        sag = ax.plot(etek, x_range=[0.012, 1, 0.004]).set_stroke(C_DUT_SIG, 3)
        tasiyici = Line(ax.c2p(0, -95), ax.c2p(0, 8)).set_stroke(C_REF1, 4.5)

        f_lbl = Text("frekans", font=FONT, font_size=18, color=INK_DIM)
        f_lbl.next_to(ax.c2p(1, -95), RIGHT, buff=0.16).shift(UP * 0.12)
        c_lbl = Text("taşıyıcı  f₀", font=FONT, weight=BOLD, font_size=19, color=C_REF1)
        c_lbl.next_to(ax.c2p(0, 8), UP, buff=0.14)

        self.play(Create(ax), FadeIn(f_lbl), run_time=0.7)
        self.play(Create(tasiyici), FadeIn(c_lbl), run_time=0.7)
        self.play(Create(sol), Create(sag), run_time=1.3)

        etek_lbl = Text("faz gürültüsü yan bantları", font=FONT, font_size=18,
                        color=C_DUT_SIG)
        etek_lbl.next_to(ax.c2p(-0.62, etek(-0.62)), UP, buff=0.3)
        self.play(FadeIn(etek_lbl), run_time=0.5)
        self.wait(0.8)

        # ---- offset ve 1 Hz dilim ----
        FM = 0.46
        offset_ok = DoubleArrow(ax.c2p(0, -74), ax.c2p(FM, -74),
                                color=C_GOLD, stroke_width=2.6,
                                tip_length=0.16, buff=0)
        offset_lbl = MathTex(r"f", font_size=28, color=C_GOLD)
        offset_lbl.next_to(offset_ok, DOWN, buff=0.12)
        offset_alt = Text("taşıyıcıdan offset", font=FONT, font_size=15, color=C_GOLD)
        offset_alt.next_to(offset_lbl, DOWN, buff=0.08)

        self.play(GrowFromCenter(offset_ok), FadeIn(offset_lbl),
                  FadeIn(offset_alt), run_time=0.9)

        dilim = Polygon(ax.c2p(FM - 0.022, -95), ax.c2p(FM - 0.022, etek(FM)),
                        ax.c2p(FM + 0.022, etek(FM)), ax.c2p(FM + 0.022, -95),
                        stroke_color=C_OK, stroke_width=2,
                        fill_color=C_OK, fill_opacity=0.4)
        dilim_lbl = Text("1 Hz", font=FONT, weight=BOLD, font_size=16, color=C_OK)
        dilim_lbl.next_to(dilim, UP, buff=0.1)
        self.play(FadeIn(dilim, scale=0.8), FadeIn(dilim_lbl), run_time=0.8)

        oran = VGroup(
            Text("1 Hz'lik yan bant gücü", font=FONT, font_size=18, color=C_OK),
            Line(LEFT, RIGHT, color=INK_DIM, stroke_width=1.6).set_width(3.1),
            Text("taşıyıcı gücü", font=FONT, font_size=18, color=C_REF1),
        ).arrange(DOWN, buff=0.14)
        birim = Text("dBc / Hz", font=FONT, weight=BOLD, font_size=28, color=INK)
        esittir = Text("=", font=FONT, font_size=26, color=INK_DIM)
        grup = VGroup(oran, esittir, birim).arrange(RIGHT, buff=0.3)
        grup.scale(0.80).to_edge(RIGHT, buff=0.4).set_y(0.85)

        self.play(FadeIn(grup, shift=LEFT * 0.25), run_time=1.1)
        self.wait(1.6)

        # ---- eşitlikler ----
        e1 = MathTex(r"\mathcal{L}(f)=\tfrac{1}{2}\,S_{\phi}(f)",
                     font_size=36, color=INK)
        e2 = MathTex(r"\mathcal{L}(f)=10\log_{10}\!\Bigl[\tfrac{1}{2}S_{\phi}(f)\Bigr]"
                     r"\quad[\mathrm{dBc/Hz}]", font_size=30, color=INK)
        eq = VGroup(e1, e2).arrange(DOWN, buff=0.30)
        eq.move_to(np.array([0.0, -2.52, 0.0]))

        aciklama = Small("Sφ(f) : faz değişimlerinin tek taraflı güç spektral yoğunluğu",
                         size=17)
        aciklama.move_to(np.array([0.0, -3.42, 0.0]))

        self.play(FadeOut(etek_lbl), Write(e1), run_time=1.1)
        self.play(FadeIn(aciklama), Write(e2), run_time=1.3)
        self.wait(2.8)
