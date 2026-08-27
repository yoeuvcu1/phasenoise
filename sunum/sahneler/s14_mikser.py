import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class MikserKpd(Slide):
    bolum = "6.2 · MİKSER, LPF VE FAZ DETEKTÖRÜ KAZANCI"
    baslik = "Çarpımdan faz farkına"

    def construct(self):
        self.kur_baslik()

        # ---- giriş sinyalleri ----
        g1 = MathTex(r"x_{DUT}=A\cos(\omega_0 t+\phi_{DUT})",
                     font_size=30, color=C_DUT_SIG)
        g2 = MathTex(r"x_{ref}=A\cos\!\Bigl(\omega_0 t+\tfrac{\pi}{2}"
                     r"+\phi_{ref}\Bigr)", font_size=30, color=C_REF1)
        gir = VGroup(g1, g2).arrange(RIGHT, buff=1.1)
        gir.move_to([0, 1.35, 0])
        self.play(Write(g1), Write(g2), run_time=1.5)

        # ---- çarpım ----
        c1 = MathTex(r"v_{PD}=x_{DUT}\cdot x_{ref}", font_size=32, color=INK)
        c1.move_to([0, 0.35, 0])
        self.play(Write(c1), run_time=0.9)

        c2 = MathTex(r"v_{PD}=", r"\frac{A^2}{2}",
                     r"\Bigl[\,\sin(\phi_{DUT}-\phi_{ref})",
                     r"-\sin(2\omega_0 t+\phi_{DUT}+\phi_{ref})\,\Bigr]",
                     font_size=31)
        c2[1].set_color(C_GOLD)
        c2[2].set_color(C_OK)
        c2[3].set_color(C_WARN)
        c2.move_to([0, -0.55, 0])
        self.play(TransformMatchingShapes(c1.copy(), c2), run_time=1.5)
        self.wait(0.8)

        et_tb = Text("taban bant:\nfaz farkını taşır", font=FONT, weight=BOLD,
                     font_size=17, color=C_OK, line_spacing=0.9)
        et_tb.next_to(c2[2], DOWN, buff=0.45)
        et_2f = Text("2f₀ çevresindeki\ntoplam bileşen", font=FONT, weight=BOLD,
                     font_size=17, color=C_WARN, line_spacing=0.9)
        et_2f.next_to(c2[3], DOWN, buff=0.45)
        self.play(FadeIn(et_tb, shift=UP * 0.1), FadeIn(et_2f, shift=UP * 0.1),
                  run_time=1.0)
        self.wait(1.4)

        # ---- LPF spektrumu ----
        self.play(FadeOut(VGroup(gir, c1)),
                  VGroup(c2, et_tb, et_2f).animate.scale(0.86)
                  .move_to([0, 1.35, 0]), run_time=1.1)

        ax = Axes(x_range=[0, 1, 1], y_range=[0, 1.25, 1],
                  x_length=8.6, y_length=1.85,
                  axis_config={"stroke_color": RULE, "stroke_width": 1.6,
                               "include_ticks": False, "include_tip": False})
        ax.move_to([-0.7, -1.35, 0])

        tb = VMobject().set_points_smoothly(
            [ax.c2p(u, 1.0 * np.exp(-(u / 0.055) ** 2) + 0.02)
             for u in np.linspace(0, 1, 300)]).set_stroke(C_OK, 3)
        f2 = VMobject().set_points_smoothly(
            [ax.c2p(u, 0.92 * np.exp(-((u - 0.72) / 0.05) ** 2) + 0.02)
             for u in np.linspace(0, 1, 300)]).set_stroke(C_WARN, 3)
        l_tb = Small("taban bant (Δφ)", size=16).next_to(ax.c2p(0.03, 1.0), UR, buff=0.05)
        l_2f = Small("2f₀ = 400 kHz", size=16).next_to(ax.c2p(0.72, 0.92), UP, buff=0.08)
        self.play(Create(ax), Create(tb), Create(f2), FadeIn(l_tb), FadeIn(l_2f),
                  run_time=1.4)

        # 4. derece butterworth tepkisi
        fcx = 0.30
        filt = VMobject().set_points_smoothly(
            [ax.c2p(u, 1.12 / np.sqrt(1 + (u / fcx) ** 8))
             for u in np.linspace(0, 1, 400)]).set_stroke(C_REF2, 2.6)
        f_lbl = Text("4. derece Butterworth LPF", font=FONT, weight=BOLD,
                     font_size=17, color=C_REF2)
        f_lbl.next_to(ax.c2p(0.32, 1.12), UR, buff=0.06)
        self.play(Create(filt), FadeIn(f_lbl), run_time=1.2)
        self.play(f2.animate.set_stroke(C_WARN, 3, opacity=0.18),
                  FadeOut(l_2f), run_time=1.0)
        bastir = Text("bastırılır", font=FONT, weight=BOLD, font_size=17,
                      color=C_DUT)
        bastir.move_to(ax.c2p(0.72, 0.55))
        self.play(FadeIn(bastir), run_time=0.5)

        # ---- K_pd ve asin ----
        kpd = MathTex(r"K_{pd}=\frac{A^2}{2}", font_size=34, color=C_GOLD)
        adim = VGroup(
            MathTex(r"\frac{y_{LPF}}{K_{pd}}=\sin(\Delta\phi)",
                    font_size=28, color=INK),
            MathTex(r"\Delta\phi=\arcsin\!\Bigl(\frac{y_{LPF}}{K_{pd}}\Bigr)",
                    font_size=28, color=C_OK),
        ).arrange(DOWN, buff=0.32)
        sag = VGroup(kpd, adim).arrange(DOWN, buff=0.5)
        kut = RoundedRectangle(width=sag.width + 0.85, height=sag.height + 0.7,
                               corner_radius=0.14, stroke_color=C_GOLD,
                               stroke_width=2, fill_color=C_GOLD, fill_opacity=0.07)
        kut.move_to(sag.get_center())
        grup = VGroup(kut, sag).scale(0.92).to_edge(RIGHT, buff=0.42)
        grup.set_y(-1.35)

        self.play(FadeIn(grup, shift=LEFT * 0.25), run_time=1.3)
        self.wait(2.6)
