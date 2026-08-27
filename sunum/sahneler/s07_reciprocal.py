import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


X_IST, X_BUY = -0.42, 0.34
H_IST, H_BUY = 38.0, 96.0


class EtkiReciprocal(Slide):
    bolum = "3.2 · RECIPROCAL MIXING"
    baslik = "Büyük komşu sinyal, zayıf sinyali yutar"

    def construct(self):
        self.kur_baslik()

        def eksen(y):
            ax = Axes(x_range=[-1, 1, 1], y_range=[-4, 108, 50],
                      x_length=8.3, y_length=2.15,
                      axis_config={"stroke_color": RULE, "stroke_width": 1.6,
                                   "include_ticks": False, "include_tip": False})
            ax.move_to([-1.55, y, 0])
            return ax

        ax1 = eksen(0.60)
        ax2 = eksen(-2.35)

        def ic_rozet(ax, metin, renk):
            r = rozet(metin, renk, fs=15).scale(0.8)
            r.move_to(ax.get_corner(UL) + RIGHT * (r.width / 2 + 0.12)
                      + DOWN * (r.height / 2 + 0.04))
            return r

        r1 = ic_rozet(ax1, "İDEAL DURUM", C_OK)
        r2 = ic_rozet(ax2, "GERÇEK DURUM", C_DUT)

        def cizgi(ax, x, h, renk, sw=4.5):
            return Line(ax.c2p(x, 0), ax.c2p(x, h)).set_stroke(renk, sw)

        def if_filtre(ax):
            pts = []
            for u in np.linspace(-1, 1, 500):
                d = abs(u - X_IST)
                pts.append(ax.c2p(u, max(100 * np.exp(-(d / 0.135) ** 6), 2)))
            return VMobject().set_points_smoothly(pts)\
                .set_stroke(C_REF2, 2.2, opacity=0.85)

        # ================= İDEAL =================
        self.play(Create(ax1), FadeIn(r1), run_time=0.7)
        ist1 = cizgi(ax1, X_IST, H_IST, C_OK)
        buy1 = cizgi(ax1, X_BUY, H_BUY, C_WARN)
        l_ist = Text("istenen zayıf sinyal", font=FONT, font_size=15, color=C_OK)
        l_ist.next_to(ist1, UP, buff=0.1)
        l_buy = Text("istenmeyen büyük sinyal", font=FONT, font_size=15, color=C_WARN)
        l_buy.next_to(buy1, UP, buff=0.1)
        self.play(Create(ist1), FadeIn(l_ist), Create(buy1), FadeIn(l_buy),
                  run_time=1.1)

        filt1 = if_filtre(ax1)
        f_lbl = Text("IF filtresi", font=FONT, font_size=15, color=C_REF2)
        f_lbl.next_to(ax1.c2p(X_IST, 100), UP, buff=0.08).shift(RIGHT * 1.15)
        self.play(Create(filt1), FadeIn(f_lbl), run_time=1.0)

        n1 = VGroup(
            Text("✓", font=FONT, weight=BOLD, font_size=30, color=C_OK),
            Text("Büyük sinyal IF\nfiltresiyle reddedilir", font=FONT,
                 font_size=18, color=INK_DIM, line_spacing=0.9),
        ).arrange(RIGHT, buff=0.22)
        n1.next_to(ax1, RIGHT, buff=0.35).set_y(ax1.get_center()[1])
        self.play(FadeIn(n1, shift=LEFT * 0.2), run_time=0.7)
        self.wait(1.4)

        # ================= GERÇEK =================
        self.play(Create(ax2), FadeIn(r2), run_time=0.7)

        ist2 = cizgi(ax2, X_IST, H_IST, C_OK)
        self.play(Create(ist2), run_time=0.5)

        yay = ValueTracker(0.0)   # etek yayılması 0 -> 1

        def buyuk_egri():
            s = yay.get_value()
            w = 0.02 + 1.20 * s
            k = 0.68 * s
            pts = []
            for u in np.linspace(-1, 1, 620):
                d = abs(u - X_BUY)
                tepe = H_BUY * np.exp(-(d / 0.016) ** 2)
                etek = H_BUY * k / (1 + (d / w) ** 1.4)
                pts.append(ax2.c2p(u, max(tepe, etek, 1.5)))
            return VMobject().set_points_smoothly(pts).set_stroke(C_WARN, 3)

        buy2 = always_redraw(buyuk_egri)
        self.add(buy2)
        self.play(yay.animate.set_value(1.0), run_time=2.2)

        etek_lbl = Text("faz gürültüsü etekleri", font=FONT, font_size=15,
                        color=C_WARN)
        etek_lbl.move_to(ax2.c2p(0.78, 76))
        self.play(FadeIn(etek_lbl), run_time=0.5)

        filt2 = if_filtre(ax2)
        self.play(Create(filt2), run_time=0.8)

        # ---- gömülme ----
        gomulme = Polygon(
            *[ax2.c2p(u, min(H_BUY * 0.68 / (1 + (abs(u - X_BUY) / 1.20) ** 1.4),
                             108))
              for u in np.linspace(X_IST - 0.20, X_IST + 0.20, 40)],
            *[ax2.c2p(u, 0) for u in np.linspace(X_IST + 0.20, X_IST - 0.20, 40)],
            stroke_width=0, fill_color=C_DUT, fill_opacity=0.32)
        vurgu = Circle(radius=0.42, color=C_DUT, stroke_width=3)
        vurgu.move_to(ax2.c2p(X_IST, H_IST * 0.75))
        self.play(FadeIn(gomulme), Create(vurgu),
                  Flash(ax2.c2p(X_IST, H_IST), color=C_DUT,
                        line_length=0.22, num_lines=14), run_time=1.2)

        n2 = VGroup(
            Text("✗", font=FONT, weight=BOLD, font_size=30, color=C_DUT),
            Text("Yayılan enerji istenen\nsinyalin üzerini örter", font=FONT,
                 font_size=18, color=INK_DIM, line_spacing=0.9),
        ).arrange(RIGHT, buff=0.22)
        n2.next_to(ax2, RIGHT, buff=0.35).set_y(ax2.get_center()[1])
        self.play(FadeIn(n2, shift=LEFT * 0.2), run_time=0.7)

        son = Text("Gerçek spektrumlar keskin değildir: filtre büyük sinyali "
                   "reddetse bile faz gürültüsü bandın içine düşer.",
                   font=FONT, weight=MEDIUM, font_size=19, color=C_GOLD)
        son.set(width=min(son.width, 12.2))
        son.to_edge(DOWN, buff=0.3)
        self.play(FadeIn(son, shift=UP * 0.12), run_time=1.0)
        self.wait(2.6)
