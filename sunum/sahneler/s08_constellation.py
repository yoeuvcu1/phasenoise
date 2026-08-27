import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class EtkiConstellation(Slide):
    bolum = "3.3 · HABERLEŞME SİSTEMLERİ"
    baslik = "Faz gürültüsü sembolleri yay boyunca dağıtır"

    def construct(self):
        self.kur_baslik()

        R = 2.28
        MERKEZ = np.array([-3.35, -0.62, 0.0])
        NOKTA = 34

        eks = VGroup(
            Line(MERKEZ + LEFT * R * 1.15, MERKEZ + RIGHT * R * 1.15,
                 color=RULE, stroke_width=1.5),
            Line(MERKEZ + DOWN * R * 1.15, MERKEZ + UP * R * 1.15,
                 color=RULE, stroke_width=1.5))
        i_lbl = Text("I", font=FONT, font_size=18, color=INK_DIM)
        q_lbl = Text("Q", font=FONT, font_size=18, color=INK_DIM)
        i_lbl.next_to(eks[0], RIGHT, buff=0.1)
        q_lbl.next_to(eks[1], UP, buff=0.1)

        seviyeler = [-1.5, -0.5, 0.5, 1.5]
        ideal = [np.array([a, b, 0]) * (R / 2.05) for a in seviyeler
                 for b in seviyeler]

        noktalar = VGroup(*[Dot(MERKEZ + p, radius=0.075, color=C_DUT_SIG)
                            for p in ideal])
        baslik16 = Text("16-QAM", font=FONT, weight=BOLD, font_size=22, color=INK)
        baslik16.move_to(MERKEZ + UP * (R * 1.15 + 0.42))

        self.play(FadeIn(eks), FadeIn(i_lbl), FadeIn(q_lbl),
                  FadeIn(baslik16), run_time=0.7)
        self.play(LaggedStart(*[GrowFromCenter(d) for d in noktalar],
                              lag_ratio=0.03), run_time=1.5)

        aciklama = maddeler([
            "Her nokta bir sembolü temsil eder",
            "Genlik ve faz bilgisini birlikte taşır",
            "APSK / QAM gibi şemalar faz doğruluğuna bağlıdır",
        ], renk=C_DUT_SIG, fs=21, w=5.6)
        aciklama.scale(0.95).to_edge(RIGHT, buff=0.7).set_y(1.55)
        self.play(LaggedStart(*[FadeIn(m, shift=LEFT * 0.2) for m in aciklama],
                              lag_ratio=0.3), run_time=1.6)
        self.wait(1.2)

        # ---- faz gürültüsü bulutu ----
        sigma = ValueTracker(0.0)
        rng = np.random.default_rng(4)
        ofs = rng.standard_normal((len(ideal), NOKTA))
        rad = rng.standard_normal((len(ideal), NOKTA)) * 0.16

        def bulut():
            s = sigma.get_value()
            g = VGroup()
            for k, p in enumerate(ideal):
                r = np.linalg.norm(p)
                th0 = np.arctan2(p[1], p[0])
                for j in range(NOKTA):
                    th = th0 + ofs[k, j] * s
                    rr = r * (1 + rad[k, j] * s * 0.55)
                    g.add(Dot(MERKEZ + rr * np.array([np.cos(th), np.sin(th), 0]),
                              radius=0.028,
                              color=C_DUT_SIG, fill_opacity=0.55))
            return g

        blt = always_redraw(bulut)
        self.add(blt)
        self.play(FadeOut(noktalar), run_time=0.4)

        olcer = VGroup(
            Text("faz gürültüsü", font=FONT, font_size=18, color=INK_DIM),
            DecimalNumber(0, num_decimal_places=2, font_size=30, color=C_GOLD,
                          unit=r"\ \mathrm{rad}"),
        ).arrange(RIGHT, buff=0.25)
        olcer[1].add_updater(lambda m: m.set_value(sigma.get_value()))
        olcer.next_to(aciklama, DOWN, buff=0.9).align_to(aciklama, LEFT)
        self.play(FadeIn(olcer), run_time=0.5)

        self.play(sigma.animate.set_value(0.09), run_time=2.0)
        self.wait(0.6)
        self.play(sigma.animate.set_value(0.19), run_time=2.2)

        # ---- karar sınırları ve hata ----
        sinirlar = VGroup()
        for v in [-1.0, 0.0, 1.0]:
            x = v * (R / 2.05)
            sinirlar.add(DashedLine(MERKEZ + np.array([x, -R * 1.1, 0]),
                                    MERKEZ + np.array([x, R * 1.1, 0]),
                                    color=C_WARN, stroke_width=1.6,
                                    dash_length=0.08, stroke_opacity=0.7))
            sinirlar.add(DashedLine(MERKEZ + np.array([-R * 1.1, x, 0]),
                                    MERKEZ + np.array([R * 1.1, x, 0]),
                                    color=C_WARN, stroke_width=1.6,
                                    dash_length=0.08, stroke_opacity=0.7))
        self.play(Create(sinirlar), run_time=1.0)

        hata = Text("Bulutlar karar sınırlarını aştığında\nbit hataları artar",
                    font=FONT, weight=MEDIUM, font_size=22, color=C_DUT,
                    line_spacing=0.95)
        hata.next_to(olcer, DOWN, buff=0.55).align_to(aciklama, LEFT)
        self.play(FadeIn(hata, shift=UP * 0.15), run_time=0.9)
        self.play(sigma.animate.set_value(0.34), run_time=2.0)
        self.wait(2.2)
