import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class CrossVektorOrtalama(Slide):
    """Cross-PSD'nin neden işe yaradığının kompleks düzlemde gösterimi."""
    bolum = "5.3 · YÖNTEMİN ÖZÜ"
    baslik = "Neden çarpım ve ortalama işe yarıyor?"

    def construct(self):
        self.kur_baslik()

        # ================= 1. Terimlerin ayrışması =================
        e0 = MathTex(r"Y_1=", r"D", r"+", r"R_1", r"\qquad",
                     r"Y_2=", r"D", r"+", r"R_2", font_size=34)
        for i in (1, 6):
            e0[i].set_color(C_DUT_SIG)
        e0[3].set_color(C_REF1)
        e0[8].set_color(C_REF2)
        e0.move_to([0, 1.15, 0])
        self.play(Write(e0), run_time=1.2)

        e1 = MathTex(r"Y_1 Y_2^{*}=",
                     r"|D|^2", r"+", r"D R_2^{*}", r"+",
                     r"R_1 D^{*}", r"+", r"R_1 R_2^{*}", font_size=34)
        e1[1].set_color(C_DUT_SIG)
        for i in (3, 5, 7):
            e1[i].set_color(C_WARN)
        e1.move_to([0, -0.15, 0])
        self.play(Write(e1), run_time=1.5)
        self.wait(0.6)

        alt1 = Text("her iterasyonda AYNI\ngerçek ve pozitif", font=FONT,
                    weight=BOLD, font_size=18, color=C_DUT_SIG, line_spacing=0.9)
        alt1.next_to(e1[1], DOWN, buff=0.5)
        ok1 = ok(alt1.get_top(), e1[1].get_bottom(), C_DUT_SIG, sw=2.4, tip=0.14)

        alt2 = Text("her iterasyonda RASTGELE faz", font=FONT, weight=BOLD,
                    font_size=18, color=C_WARN)
        alt2.next_to(VGroup(e1[3], e1[7]), DOWN, buff=0.5)
        ok2 = VGroup(*[ok(alt2.get_top(), e1[i].get_bottom(), C_WARN,
                          sw=2.0, tip=0.12) for i in (3, 5, 7)])

        self.play(GrowArrow(ok1), FadeIn(alt1), run_time=0.9)
        self.play(LaggedStart(*[GrowArrow(a) for a in ok2], lag_ratio=0.15),
                  FadeIn(alt2), run_time=1.1)
        self.wait(2.0)

        ust = VGroup(e0, e1, alt1, ok1, alt2, ok2)
        hatirlatma = VGroup(
            MathTex(r"|D|^2", font_size=26, color=C_DUT_SIG),
            Text("her iterasyonda aynı", font=FONT, font_size=17, color=INK_DIM),
            Text("+", font=FONT, font_size=20, color=INK_DIM),
            MathTex(r"DR_2^{*}+R_1D^{*}+R_1R_2^{*}", font_size=26, color=C_WARN),
            Text("rastgele fazlı", font=FONT, font_size=17, color=INK_DIM),
        ).arrange(RIGHT, buff=0.24)
        hatirlatma.set(width=min(hatirlatma.width, 8.1))
        hatirlatma.move_to([-2.55, self.govde() - 0.30, 0])
        self.play(FadeOut(ust), FadeIn(hatirlatma), run_time=1.0)

        # ================= 2. Kompleks düzlem =================
        MER = np.array([-3.15, -1.05, 0.0])
        BIRIM = 0.80
        T = 1.95                                  # gerçek |D|^2 (birim)
        SIG = 2.30                                # gürültü std (birim)

        eksen = VGroup(
            Arrow(MER + LEFT * 2.5, MER + RIGHT * 3.5, buff=0, color=RULE,
                  stroke_width=2, tip_length=0.16),
            Arrow(MER + DOWN * 2.2, MER + UP * 2.3, buff=0, color=RULE,
                  stroke_width=2, tip_length=0.16))
        re_l = Small("Re", size=17).next_to(eksen[0], RIGHT, buff=0.08)
        im_l = Small("Im", size=17).next_to(eksen[1], UP, buff=0.08)

        hedef = Dot(MER + RIGHT * T * BIRIM, radius=0.10, color=C_DUT_SIG)
        hedef_ok = Arrow(MER, MER + RIGHT * T * BIRIM, buff=0, color=C_DUT_SIG,
                         stroke_width=5, max_tip_length_to_length_ratio=0.2)
        hedef_l = Text("|D|²  aranan değer", font=FONT, weight=BOLD,
                       font_size=17, color=C_DUT_SIG)
        hedef_l.next_to(hedef, UP, buff=0.48)

        self.play(Create(eksen), FadeIn(re_l), FadeIn(im_l), run_time=0.7)
        self.play(GrowArrow(hedef_ok), FadeIn(hedef), FadeIn(hedef_l),
                  run_time=0.9)

        rng = np.random.default_rng(12)
        NMAX = 900
        gur = (rng.standard_normal(NMAX) + 1j * rng.standard_normal(NMAX)) * SIG
        kum = np.cumsum(gur)

        logM = ValueTracker(0.0)

        def M():
            return max(1, int(round(np.exp(logM.get_value()))))

        def nokta(z):
            return MER + np.array([z.real * BIRIM, z.imag * BIRIM, 0.0])

        def bulut():
            m = M()
            g = VGroup()
            adim = max(1, m // 260)
            for k in range(0, m, adim):
                z = T + gur[k]
                g.add(Dot(nokta(z), radius=0.028, color=C_WARN,
                          fill_opacity=0.40))
            return g

        def ortalama_z():
            m = M()
            return T + kum[m - 1] / m

        ort_ok = always_redraw(lambda: Arrow(
            MER, nokta(ortalama_z()), buff=0, color=C_CROSS, stroke_width=5.5,
            max_tip_length_to_length_ratio=0.2))
        belirsizlik = always_redraw(lambda: Circle(
            radius=min(SIG / np.sqrt(M()) * BIRIM, 2.05),
            color=C_WARN, stroke_width=2, stroke_opacity=0.5)
            .move_to(MER + RIGHT * T * BIRIM))
        blt = always_redraw(bulut)

        sayac = VGroup(
            Text("iterasyon  M =", font=FONT, weight=MEDIUM, font_size=22,
                 color=INK_DIM),
            Integer(1, font_size=30, color=C_GOLD)).arrange(RIGHT, buff=0.2)
        sayac[1].add_updater(lambda m: m.set_value(M()))
        sayac.move_to([3.45, 0.15, 0])

        aciklama = VGroup(
            madde("Tek iterasyonda sonuç gürültü içinde kaybolur",
                  C_WARN, fs=19, w=4.5),
            madde("Rastgele fazlı terimler birbirini götürür",
                  C_CROSS, fs=19, w=4.5),
            madde("Kalan hata  ∝  1/√M  ile küçülür",
                  C_OK, fs=19, w=4.5),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.42)
        aciklama.move_to([3.75, -2.05, 0])

        lgnd = VGroup(
            VGroup(Dot(radius=0.05, color=C_WARN),
                   Small("tek iterasyon sonuçları", size=15)
                   ).arrange(RIGHT, buff=0.18),
            VGroup(Line(ORIGIN, RIGHT * 0.36).set_stroke(C_CROSS, 4),
                   Small("M iterasyonun ortalaması", size=15)
                   ).arrange(RIGHT, buff=0.18),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.18)
        lgnd.move_to([3.62, 1.02, 0])

        self.add(blt, belirsizlik, ort_ok)
        self.play(FadeIn(sayac), FadeIn(lgnd), run_time=0.7)
        self.play(FadeIn(aciklama[0], shift=LEFT * 0.2), run_time=0.7)
        self.wait(1.2)

        self.play(logM.animate.set_value(np.log(12)), run_time=2.2,
                  rate_func=linear)
        self.play(FadeIn(aciklama[1], shift=LEFT * 0.2), run_time=0.6)
        self.play(logM.animate.set_value(np.log(120)), run_time=2.6,
                  rate_func=linear)
        self.play(FadeIn(aciklama[2], shift=LEFT * 0.2), run_time=0.6)
        self.play(logM.animate.set_value(np.log(NMAX)), run_time=2.8,
                  rate_func=linear)

        # yakınsama vurgusu
        self.play(Flash(nokta(ortalama_z()), color=C_OK, line_length=0.25,
                        num_lines=16, flash_radius=0.45), run_time=0.9)
        self.wait(2.4)
