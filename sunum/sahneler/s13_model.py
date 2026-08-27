import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class ModelBlok(Slide):
    bolum = "6 · CROSS-CORRELATION ANALİZÖRÜNÜN MODELİ"
    baslik = "Kurulan sayısal modelin işlem zinciri"

    def construct(self):
        self.kur_baslik()

        W, H, FS = 3.05, 0.85, 18

        def sut(x, renk, ref_isim):
            ref = kutu(ref_isim, w=2.25, h=0.75, color=renk, fs=18)
            pd = kutu("Faz Detektörü", w=W, h=H, color=INK, fs=FS)
            dc = kutu("DC silme + Normalizasyon", w=W, h=H, color=INK, fs=15)
            lpf = kutu("Low-Pass Filter", w=W, h=H, color=INK, fs=FS)
            g = VGroup(pd, dc, lpf).arrange(DOWN, buff=0.48)
            g.move_to([x, -0.35, 0])
            ref.next_to(pd, UP, buff=0.72).set_x(x)
            oklar = VGroup(ok(ref.get_bottom(), pd.get_top(), renk),
                           ok(pd.get_bottom(), dc.get_top(), INK_DIM),
                           ok(dc.get_bottom(), lpf.get_top(), INK_DIM))
            return VGroup(ref, g, oklar), pd, lpf, ref

        s1, pd1, lpf1, ref1 = sut(-3.3, C_REF1, "Referans 1")
        s2, pd2, lpf2, ref2 = sut(3.3, C_REF2, "Referans 2")

        dut = kutu("DUT", w=2.25, h=0.75, color=C_DUT_SIG, fs=20)
        dut.set_x(0).set_y(ref1.get_center()[1])
        y_bus = dut.get_bottom()[1] - 0.36
        dal = VGroup(
            VMobject().set_points_as_corners(
                [dut.get_bottom(), np.array([0, y_bus, 0]),
                 np.array([-3.3, y_bus, 0])]).set_stroke(C_DUT_SIG, 2.8),
            VMobject().set_points_as_corners(
                [dut.get_bottom(), np.array([0, y_bus, 0]),
                 np.array([3.3, y_bus, 0])]).set_stroke(C_DUT_SIG, 2.8),
            ok(np.array([-3.3, y_bus, 0]), pd1.get_top() + LEFT * 0.65, C_DUT_SIG),
            ok(np.array([3.3, y_bus, 0]), pd2.get_top() + LEFT * 0.65, C_DUT_SIG))

        cross = kutu("FFT Tabanlı\nCross-PSD", w=3.5, h=1.0, color=C_CROSS, fs=18)
        ortl = kutu("İterasyonların\nOrtalaması", w=3.5, h=1.0, color=INK, fs=18)
        sonuc = kutu("DUT Faz\nGürültüsü", w=3.4, h=1.0, color=C_OK, fs=19)
        alt = VGroup(cross, ortl, sonuc).arrange(RIGHT, buff=0.75)
        alt.next_to(VGroup(lpf1, lpf2), DOWN, buff=0.95).set_x(0)

        y_bus2 = lpf1.get_bottom()[1] - 0.45
        birles = VGroup(
            VMobject().set_points_as_corners(
                [lpf1.get_bottom(), np.array([-3.3, y_bus2, 0]),
                 np.array([cross.get_center()[0], y_bus2, 0])])
            .set_stroke(INK_DIM, 2.4),
            VMobject().set_points_as_corners(
                [lpf2.get_bottom(), np.array([3.3, y_bus2, 0]),
                 np.array([cross.get_center()[0], y_bus2, 0])])
            .set_stroke(INK_DIM, 2.4),
            ok(np.array([cross.get_center()[0], y_bus2, 0]),
               cross.get_top(), INK_DIM),
            ok(cross.get_right(), ortl.get_left(), INK_DIM),
            ok(ortl.get_right(), sonuc.get_left(), C_OK))

        tam = VGroup(dut, dal, s1, s2, alt, birles)
        tam.scale_to_fit_height(5.35)
        if tam.width > 12.9:
            tam.scale_to_fit_width(12.9)
        tam.move_to([0, -1.05, 0])

        self.play(FadeIn(dut), FadeIn(ref1), FadeIn(ref2), run_time=0.8)
        self.play(Create(dal), run_time=0.9)
        self.play(FadeIn(s1[1]), FadeIn(s2[1]), FadeIn(s1[2]), FadeIn(s2[2]),
                  run_time=1.4)
        self.play(Create(birles[:3]), FadeIn(cross), run_time=1.1)
        self.play(GrowArrow(birles[3]), FadeIn(ortl), run_time=0.8)
        self.play(GrowArrow(birles[4]), FadeIn(sonuc), run_time=0.8)
        self.play(Indicate(sonuc, color=C_OK, scale_factor=1.06), run_time=1.0)
        self.wait(2.4)


class GurultuUretimi(Slide):
    bolum = "6.1 · GÜRÜLTÜ VE TAŞIYICI ÜRETİMİ"
    baslik = "Her iterasyonda tamamen yeni realizasyonlar"

    def construct(self):
        self.kur_baslik()

        ms = maddeler([
            "Her iterasyonda yeni bir DUT faz dizisi ve iki ayrı referans faz dizisi üretilir",
            "Aynı DUT taşıyıcısı iki ölçüm kanalına ortak olarak uygulanır",
            "Referansların merkez fazına π/2 eklenir (quadrature çalışma noktası)",
            "Her sinyalin gürültüsü bağımsız ve ayrı çağrılarda üretilir",
        ], renk=C_GOLD, fs=23, w=11.2)
        ms.move_to([-0.15, 0.95, 0]).to_edge(LEFT, buff=1.0)
        self.play(LaggedStart(*[FadeIn(m, shift=RIGHT * 0.25) for m in ms],
                              lag_ratio=0.3), run_time=2.6)
        self.wait(1.2)

        # ---- seed mekanizması ----
        baslik_s = Text("Bağımsızlığı sağlayan seed mekanizması", font=FONT,
                        weight=BOLD, font_size=23, color=C_DUT_SIG)
        kod = MathTex(r"\text{seed}=\Bigl(173\cdot\bigl\lfloor t_{\mu s}"
                      r"\bigr\rfloor\Bigr)\bmod 10^5",
                      font_size=32, color=INK)
        aciklama = Small("zaman damgasının büyük bir asal sayıyla çarpımı, "
                         "her çağrıda farklı bir rastgele akış üretir", size=18)
        blok = VGroup(baslik_s, kod, aciklama).arrange(DOWN, buff=0.3)
        kut = RoundedRectangle(width=blok.width + 1.0, height=blok.height + 0.85,
                               corner_radius=0.16, stroke_color=C_DUT_SIG,
                               stroke_width=2, fill_color=C_DUT_SIG,
                               fill_opacity=0.07)
        kut.move_to(blok.get_center())
        g = VGroup(kut, blok).move_to([0, -2.15, 0])
        self.play(FadeIn(g, shift=UP * 0.2), run_time=1.3)
        self.wait(2.6)
