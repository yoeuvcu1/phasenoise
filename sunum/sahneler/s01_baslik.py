import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class Baslik(Slide):
    """Açılış: gürültülü fazör arka planı üzerinde başlık."""

    def construct(self):
        # ---- arka plan: jitterli fazör ve izi ----
        R = 1.62
        merkez = np.array([4.62, -0.35, 0.0])

        cember = Circle(radius=R, color=RULE, stroke_width=2).move_to(merkez)
        cember_ic = Circle(radius=R, color=C_DUT_SIG, stroke_width=1.2,
                           stroke_opacity=0.25).move_to(merkez)

        t = ValueTracker(0.0)
        NS = 4096
        jit = guc_yasasi_faz(NS, 0.34, 3.0, seed=7)

        def faz_gurultusu(x):
            i = (x * 90.0) % NS
            i0 = int(np.floor(i)); i1 = (i0 + 1) % NS; a = i - i0
            return jit[i0] * (1 - a) + jit[i1] * a

        def aci(x):
            return 2 * PI * 0.42 * x + faz_gurultusu(x)

        fazor = always_redraw(lambda: Arrow(
            merkez, merkez + R * np.array([np.cos(aci(t.get_value())),
                                           np.sin(aci(t.get_value())), 0.0]),
            buff=0, color=C_DUT_SIG, stroke_width=5,
            max_tip_length_to_length_ratio=0.16))

        uc = always_redraw(lambda: Dot(
            merkez + R * np.array([np.cos(aci(t.get_value())),
                                   np.sin(aci(t.get_value())), 0.0]),
            radius=0.075, color=C_DUT_SIG))

        iz = TracedPath(uc.get_center, stroke_color=C_DUT_SIG,
                        stroke_width=2.6, stroke_opacity=0.55,
                        dissipating_time=2.2)

        arka = VGroup(cember, cember_ic)
        self.add(arka, iz, fazor, uc)
        self.play(t.animate.set_value(2.4), run_time=2.4, rate_func=linear)

        # ---- başlık bloğu ----
        ust = Text("BİTİRME PROJESİ  ·  2025", font=FONT, weight=BOLD,
                   font_size=18, color=C_GOLD)
        b1 = Text("İki Kanallı Cross-PSD Yöntemiyle", font=FONT,
                  weight=BOLD, font_size=46, color=INK)
        b2 = Text("Faz Gürültüsü Ölçümünün Simülasyonu", font=FONT,
                  weight=BOLD, font_size=46, color=INK)
        cizgi = Line(LEFT, RIGHT, color=C_GOLD, stroke_width=3).set_width(2.0)
        yazar = Text("Ömer Faruk Yazıcı", font=FONT, weight=MEDIUM,
                     font_size=27, color=INK_DIM)
        alt = Text("GNU Octave  ·  Monte Carlo  ·  Cross-Correlation",
                   font=FONT, font_size=19, color=INK_DIM)

        basliklar = VGroup(b1, b2).arrange(DOWN, aligned_edge=LEFT, buff=0.16)
        basliklar.set(width=7.15)
        cizgi.set_width(1.9)
        blok = VGroup(ust, basliklar, cizgi, yazar, alt)
        blok.arrange(DOWN, aligned_edge=LEFT, buff=0.36)
        blok.to_edge(LEFT, buff=0.9)
        blok.set_y(0.0)

        self.play(
            LaggedStart(
                FadeIn(ust, shift=RIGHT * 0.2),
                Write(b1, run_time=1.0),
                Write(b2, run_time=1.0),
                GrowFromEdge(cizgi, LEFT),
                FadeIn(yazar, shift=UP * 0.15),
                FadeIn(alt, shift=UP * 0.15),
                lag_ratio=0.35),
            t.animate.set_value(2.4 + 4.2),
            run_time=4.2, rate_func=linear)

        self.play(t.animate.set_value(2.4 + 4.2 + 2.0),
                  run_time=2.0, rate_func=linear)
