import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
from s10_yontemler import mikser_sembol
import numpy as np


def cross_diyagrami():
    """İki kanallı cross-correlation blok diyagramını VGroup olarak kurar."""
    dut = kutu("DUT", w=1.9, h=1.0, color=C_DUT_SIG, fs=22)
    dut.move_to([-5.15, 0.0, 0])

    parcalar = {}
    kanallar = VGroup()
    for isim, y, renk, ref_isim in (("k1", 1.55, C_REF1, "Referans 1"),
                                    ("k2", -1.55, C_REF2, "Referans 2")):
        mx = mikser_sembol(renk=renk)
        ref = kutu(ref_isim, w=2.15, h=0.85, color=renk, fs=18)
        lpf = kutu("LPF", w=1.35, h=0.85, color=INK, fs=18)
        mx.move_to([-2.45, y, 0])
        ref.move_to([-2.45, y + (1.42 if y > 0 else -1.42), 0])
        lpf.move_to([0.15, y, 0])
        a_ref = ok(ref.get_bottom() if y > 0 else ref.get_top(),
                   mx.get_top() if y > 0 else mx.get_bottom(), renk)
        a_lpf = ok(mx.get_right(), lpf.get_left(), INK_DIM)
        g = VGroup(mx, ref, lpf, a_ref, a_lpf)
        parcalar[isim] = g
        kanallar.add(g)

    dal = VGroup()
    for y in (1.55, -1.55):
        p0 = dut.get_right()
        p1 = np.array([-4.05, p0[1], 0])
        p2 = np.array([-4.05, y, 0])
        dal.add(VMobject().set_points_as_corners([p0, p1, p2])
                .set_stroke(C_DUT_SIG, 3))
        dal.add(ok(p2, np.array([-2.85, y, 0]), C_DUT_SIG))
    dugum = Dot(np.array([-4.05, 0.0, 0]), radius=0.07, color=C_DUT_SIG)

    cross = kutu("Cross-PSD\nS₁₂(f)", w=2.5, h=1.3, color=C_CROSS, fs=19)
    cross.move_to([3.05, 0.0, 0])
    birlesim = VGroup(
        VMobject().set_points_as_corners(
            [np.array([0.83, 1.55, 0]), np.array([1.72, 1.55, 0]),
             np.array([1.72, 0.35, 0])]).set_stroke(INK_DIM, 2.6),
        VMobject().set_points_as_corners(
            [np.array([0.83, -1.55, 0]), np.array([1.72, -1.55, 0]),
             np.array([1.72, -0.35, 0])]).set_stroke(INK_DIM, 2.6),
        ok(np.array([1.72, 0.0, 0]), cross.get_left(), INK_DIM))

    ort = kutu("İterasyon\nortalaması", w=2.45, h=1.2, color=C_OK, fs=18)
    ort.move_to([6.05, 0.0, 0])
    son_ok = ok(cross.get_right(), ort.get_left(), C_OK)

    tam = VGroup(dut, dal, dugum, kanallar, birlesim, cross, son_ok, ort)
    return tam, dict(dut=dut, dal=dal, dugum=dugum, kanallar=kanallar,
                     birlesim=birlesim, cross=cross, son_ok=son_ok, ort=ort)


class YontemCross(Slide):
    bolum = "5.3 · CROSS-CORRELATION İLE FAZ DETEKTÖRÜ"
    baslik = "Aynı DUT, iki bağımsız referans"

    def construct(self):
        self.kur_baslik()

        dia, p = cross_diyagrami()
        dia.scale_to_fit_height(5.25).move_to([0.0, -1.05, 0])

        self.play(FadeIn(p["dut"]), Create(p["dal"]), FadeIn(p["dugum"]),
                  run_time=1.1)
        self.play(FadeIn(p["kanallar"][0]), FadeIn(p["kanallar"][1]),
                  run_time=1.3)
        self.play(Create(p["birlesim"]), FadeIn(p["cross"]), run_time=1.1)
        self.play(GrowArrow(p["son_ok"]), FadeIn(p["ort"]), run_time=0.7)
        self.wait(1.4)

        # diyagramı küçültüp denklemlere yer aç
        self.play(dia.animate.scale_to_fit_height(3.20).move_to([0.0, 0.55, 0]),
                  run_time=1.2)

        # ---- kanal denklemleri ----
        e1 = MathTex(r"y_1(t)\approx", r"\phi_D(t)", r"-", r"\phi_{R1}(t)",
                     font_size=30)
        e2 = MathTex(r"y_2(t)\approx", r"\phi_D(t)", r"-", r"\phi_{R2}(t)",
                     font_size=30)
        e1[1].set_color(C_DUT_SIG); e1[3].set_color(C_REF1)
        e2[1].set_color(C_DUT_SIG); e2[3].set_color(C_REF2)
        eq = VGroup(e1, e2).arrange(DOWN, aligned_edge=LEFT, buff=0.34)
        eq.move_to([-3.75, -2.55, 0])

        self.play(Write(e1), run_time=0.8)
        self.play(Write(e2), run_time=0.8)

        c_o = SurroundingRectangle(VGroup(e1[1], e2[1]), color=C_DUT_SIG,
                                   stroke_width=2, buff=0.09, corner_radius=0.07)
        c_b = SurroundingRectangle(VGroup(e1[3], e2[3]), color=C_WARN,
                                   stroke_width=2, buff=0.09, corner_radius=0.07)
        l_o = Text("ortak", font=FONT, weight=BOLD, font_size=16, color=C_DUT_SIG)
        l_b = Text("bağımsız", font=FONT, weight=BOLD, font_size=16, color=C_WARN)
        l_o.next_to(c_o, DOWN, buff=0.12)
        l_b.next_to(c_b, DOWN, buff=0.12)

        self.play(Create(c_o), FadeIn(l_o), run_time=0.7)
        self.play(Create(c_b), FadeIn(l_b), run_time=0.7)
        self.wait(1.0)

        # ---- cross-psd eşitliği ----
        e3 = MathTex(r"S_{12}(f)=\mathbb{E}\bigl\{Y_1(f)\,Y_2^{*}(f)\bigr\}",
                     r"\;\longrightarrow\;", r"S_D(f)", font_size=30)
        e3[2].set_color(C_DUT_SIG)
        kut = SurroundingRectangle(e3, color=C_OK, stroke_width=2.2,
                                   buff=0.22, corner_radius=0.12)
        g3 = VGroup(kut, e3).move_to([3.40, -2.30, 0])

        alt = Text("Ortak DUT bileşeni korunur; bağımsız referans\ngürültüleri "
                   "iterasyon ortalamasıyla sönümlenir",
                   font=FONT, weight=MEDIUM, font_size=18, color=C_GOLD,
                   line_spacing=0.95)
        alt.set(width=min(alt.width, 6.0))
        alt.next_to(g3, DOWN, buff=0.24)

        self.play(Write(e3), Create(kut), run_time=1.5)
        self.play(FadeIn(alt), run_time=0.8)
        self.wait(2.6)
