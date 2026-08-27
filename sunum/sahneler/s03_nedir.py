import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class FazGurultusuNedir(Slide):
    """Fazör -> dalga şekli kurgusuyla ideal ve gerçek osilatör karşılaştırması."""
    bolum = "2 · FAZ GÜRÜLTÜSÜ NEDİR?"
    baslik = "İdeal osilatör: sabit hızda dönen bir fazör"

    def construct(self):
        self.kur_baslik()

        R = 1.42
        MERKEZ = np.array([-4.35, -0.55, 0.0])
        X0, X1 = -2.35, 5.9
        F0 = 0.62                      # görsel dönme hızı (tur/s)
        SURE = 2.0 / F0                # tam iki tur

        # ---- fazör düzlemi ----
        cember = Circle(radius=R, color=RULE, stroke_width=2).move_to(MERKEZ)
        eks = VGroup(
            Line(MERKEZ + LEFT * (R + 0.28), MERKEZ + RIGHT * (R + 0.28),
                 color=RULE, stroke_width=1.4),
            Line(MERKEZ + DOWN * (R + 0.28), MERKEZ + UP * (R + 0.28),
                 color=RULE, stroke_width=1.4))
        duzlem = VGroup(eks, cember)

        # ---- dalga ekseni ----
        eksen = Axes(x_range=[0, 1, 1], y_range=[-1.35, 1.35, 1],
                     x_length=X1 - X0, y_length=2 * R * 1.12,
                     axis_config={"stroke_color": RULE, "stroke_width": 1.6,
                                  "include_ticks": False, "include_tip": False})
        eksen.move_to(np.array([(X0 + X1) / 2, MERKEZ[1], 0]))
        t_lbl = Text("t", font=FONT, font_size=20, color=INK_DIM)
        t_lbl.next_to(eksen.c2p(1, 0), RIGHT, buff=0.18)

        self.play(FadeIn(duzlem), Create(eksen), FadeIn(t_lbl), run_time=1.0)

        # ---- fazör sürücüsü ----
        t = ValueTracker(0.0)
        NS = 8192
        jit = guc_yasasi_faz(NS, 0.52, 3.0, seed=21)
        gurultu_on = ValueTracker(0.0)   # 0 = ideal, 1 = gürültülü

        def phi(x):
            i = (x * 190.0) % NS
            i0 = int(np.floor(i)); i1 = (i0 + 1) % NS; a = i - i0
            return (jit[i0] * (1 - a) + jit[i1] * a) * gurultu_on.get_value()

        # theta 90 derece kaymalı: dikey izdüşüm tam olarak cos(2*pi*f0*t + phi)
        def theta(x):
            return 2 * PI * F0 * x + phi(x) + PI / 2

        def tip():
            th = theta(t.get_value())
            return MERKEZ + R * np.array([np.cos(th), np.sin(th), 0.0])

        def kalem():
            x = t.get_value() / SURE
            th = theta(t.get_value())
            return np.array([X0 + (X1 - X0) * min(x, 1.0),
                             MERKEZ[1] + R * np.sin(th), 0.0])

        fazor = always_redraw(lambda: Arrow(MERKEZ, tip(), buff=0,
                                            color=C_DUT_SIG, stroke_width=5,
                                            max_tip_length_to_length_ratio=0.17))
        tip_dot = always_redraw(lambda: Dot(tip(), radius=0.07, color=C_DUT_SIG))
        pen_dot = always_redraw(lambda: Dot(kalem(), radius=0.07, color=C_DUT_SIG))
        baglanti = always_redraw(lambda: DashedLine(
            tip(), kalem(), color=INK_DIM, stroke_width=1.7,
            dash_length=0.09, stroke_opacity=0.55))
        iz = TracedPath(kalem, stroke_color=C_DUT_SIG, stroke_width=3.4)

        self.add(iz, baglanti, fazor, tip_dot, pen_dot)

        esitlik = MathTex(r"x_{\text{ideal}}(t)=A\cos(2\pi f_0 t)",
                          font_size=38, color=INK)
        esitlik.move_to(np.array([0.0, -2.42, 0.0]))

        self.play(t.animate.set_value(SURE), run_time=SURE,
                  rate_func=linear)
        self.play(Write(esitlik), run_time=1.0)
        self.wait(1.2)

        # ---- gerçek osilatöre geçiş ----
        yeni_b = H1("Gerçek osilatör: faza rastgele sapmalar biner", size=38)
        yeni_b.move_to(self.chrome[1]).align_to(self.chrome[1], LEFT)
        self.play(FadeOut(self.chrome[1], shift=UP * 0.2),
                  FadeIn(yeni_b, shift=UP * 0.2), run_time=0.7)
        self.chrome[1] = yeni_b

        sebep = Small("termal etkiler  ·  aktif eleman gürültüsü  ·  rezonatör "
                      "kayıpları  ·  besleme değişimleri", size=19)
        sebep.next_to(self.chrome[2], DOWN, buff=0.22).to_edge(LEFT, buff=0.7)
        self.play(FadeIn(sebep), run_time=0.5)

        # izi sıfırla ve gürültülü koşuyu çiz
        self.remove(iz)
        eski_iz = TracedPath(kalem)
        t.set_value(0.0)
        iz2 = TracedPath(kalem, stroke_color=C_DUT_SIG, stroke_width=3.4)
        ideal_iz = eksen.plot(lambda u: np.cos(2 * PI * F0 * u * SURE),
                              x_range=[0, 1, 0.002])
        ideal_iz.set_stroke(INK_DIM, 2.0, opacity=0.35)
        self.add(ideal_iz, iz2)

        self.play(gurultu_on.animate.set_value(1.0), run_time=0.4)
        self.play(t.animate.set_value(SURE), run_time=SURE, rate_func=linear)

        yeni_esitlik = MathTex(r"x(t)=\bigl[A+\varepsilon(t)\bigr]\,"
                               r"\cos\!\bigl(2\pi f_0 t+\phi(t)\bigr)",
                               font_size=38, color=INK)
        yeni_esitlik.move_to(esitlik)
        self.play(TransformMatchingShapes(esitlik, yeni_esitlik), run_time=1.2)
        self.wait(1.0)

        # ---- terim açıklamaları (denklemin altında tek satır) ----
        aciklama = VGroup(
            self._terim(r"A", "nominal genlik", INK),
            self._terim(r"\varepsilon(t)", "genlik gürültüsü", C_WARN),
            self._terim(r"f_0", "taşıyıcı frekansı", INK),
            self._terim(r"\phi(t)", "faz hatası", C_DUT_SIG),
        ).arrange(RIGHT, buff=0.62, aligned_edge=DOWN)
        if aciklama.width > 12.2:
            aciklama.set(width=12.2)
        aciklama.move_to(np.array([0.0, -3.22, 0.0]))
        self.play(LaggedStart(*[FadeIn(a, shift=UP * 0.18) for a in aciklama],
                              lag_ratio=0.22), run_time=1.5)
        self.wait(1.8)

        # ---- sadeleştirme: sadece faz gürültüsü ----
        cizik = Line(aciklama[1].get_left(), aciklama[1].get_right(),
                     color=C_WARN, stroke_width=3)
        self.play(Create(cizik), run_time=0.6)
        self.wait(0.5)

        not_t = Text("Bu projede yalnızca faz gürültüsü ele alınıyor",
                     font=FONT, weight=MEDIUM, font_size=24, color=C_GOLD)
        not_t.move_to(np.array([0.0, -3.22, 0.0]))

        son = MathTex(r"x(t)=A\cos\!\bigl(2\pi f_0 t+\phi(t)\bigr)",
                      font_size=42, color=INK)
        son.move_to(yeni_esitlik)
        kutu_s = SurroundingRectangle(son, color=C_OK, stroke_width=2.5,
                                      buff=0.25, corner_radius=0.12)
        self.play(FadeOut(aciklama), FadeOut(cizik),
                  FadeIn(not_t, shift=UP * 0.15),
                  TransformMatchingShapes(yeni_esitlik, son), run_time=1.3)
        self.play(Create(kutu_s), run_time=0.7)
        self.wait(2.4)

    @staticmethod
    def _terim(sym, aciklama, renk):
        m = MathTex(sym, font_size=28, color=renk)
        c = Text(":  " + aciklama, font=FONT, font_size=20, color=INK_DIM)
        c.next_to(m, RIGHT, buff=0.12)
        return VGroup(m, c)
