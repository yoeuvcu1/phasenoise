import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class AsinOptimizasyon(Slide):
    bolum = "7.2 · YAPILAN OPTİMİZASYONLAR"
    baslik = "Küçük açı yaklaşımından asin()'e geçiş"

    def construct(self):
        self.kur_baslik()

        ax = Axes(x_range=[0, 1.35, 0.25], y_range=[0, 1.35, 0.25],
                  x_length=5.5, y_length=4.0,
                  axis_config={"stroke_color": RULE, "stroke_width": 1.8,
                               "include_ticks": True, "include_tip": False,
                               "tick_size": 0.05})
        ax.move_to([-3.65, -0.85, 0])
        xl = Small("Δφ  (rad)", size=17).next_to(ax, DOWN, buff=0.22)
        yl = Small("çıkış", size=17).rotate(PI / 2).next_to(ax, LEFT, buff=0.18)
        self.play(Create(ax), FadeIn(xl), FadeIn(yl), run_time=0.8)

        dogru = ax.plot(lambda u: u, x_range=[0, 1.32, 0.01]).set_stroke(C_OK, 3)
        sinus = ax.plot(np.sin, x_range=[0, 1.32, 0.01]).set_stroke(C_WARN, 3.4)
        l_d = Text("küçük açı: sin(Δφ) ≈ Δφ", font=FONT, weight=BOLD,
                   font_size=17, color=C_OK)
        l_s = Text("gerçek detektör: sin(Δφ)", font=FONT, weight=BOLD,
                   font_size=17, color=C_WARN)
        l_d.move_to(ax.c2p(0.42, 1.20))
        l_s.move_to(ax.c2p(0.95, 0.58))

        self.play(Create(dogru), FadeIn(l_d), run_time=1.0)
        self.play(Create(sinus), FadeIn(l_s), run_time=1.2)

        # sıkışma bölgesi
        alan = VMobject().set_points_as_corners(
            [ax.c2p(u, u) for u in np.linspace(0, 1.32, 80)] +
            [ax.c2p(u, np.sin(u)) for u in np.linspace(1.32, 0, 80)]
        ).set_fill(C_DUT, 0.22).set_stroke(width=0)
        sik = Text("sıkışma", font=FONT, weight=BOLD, font_size=18, color=C_DUT)
        sik.move_to(ax.c2p(1.16, 1.02))
        self.play(FadeIn(alan), FadeIn(sik), run_time=1.0)

        dusuk = DashedLine(ax.c2p(0.25, 0), ax.c2p(0.25, 1.32),
                           color=INK_DIM, stroke_width=1.6, dash_length=0.08)
        dusuk_l = Small("düşük RMS\nbölgesi", size=14)
        dusuk_l.next_to(ax.c2p(0.25, 1.32), UP, buff=0.06)
        self.play(Create(dusuk), FadeIn(dusuk_l), run_time=0.7)
        self.wait(1.2)

        # ---- sonuçlar ----
        b = Text("Sonuç: LPF ve Kpd normalizasyonundan sonra\n"
                 "doğrusal olmayan asin() geri dönüşümü uygulandı",
                 font=FONT, weight=BOLD, font_size=21, color=INK,
                 line_spacing=0.95)
        b.move_to([3.35, 1.42, 0])

        k1 = self._kart("Düşük gürültü",
                        "DUT 0,02 rad · Ref 0,05 rad",
                        "MAE değişimi  <  0,01 dB",
                        "küçük açı yaklaşımı bu bölgede geçerli", C_OK)
        k2 = self._kart("Yüksek gürültü",
                        "DUT 0,20 rad · Ref 0,50 rad",
                        "MAE  2,04 dB  →  1,25 dB",
                        "üç bağımsız koşuda 0,53 – 1,16 dB kazanç", C_GOLD)
        kartlar = VGroup(k1, k2).arrange(DOWN, buff=0.34)
        kartlar.next_to(b, DOWN, buff=0.42).set_x(3.35)

        self.play(FadeIn(b, shift=LEFT * 0.2), run_time=1.0)
        self.play(FadeIn(k1, shift=LEFT * 0.2), run_time=0.9)
        self.play(FadeIn(k2, shift=LEFT * 0.2), run_time=0.9)

        rz = rozet("ortalama iyileşme  ≈  0,79 dB", C_GOLD, fs=21)
        rz.next_to(kartlar, DOWN, buff=0.30).set_x(3.35)
        if rz.get_bottom()[1] < -3.85:
            rz.set_y(-3.85 + rz.height / 2)
        self.play(FadeIn(rz, scale=0.94), run_time=0.9)
        self.wait(2.6)

    @staticmethod
    def _kart(baslik, kosul, sonuc, alt, renk):
        b = Text(baslik, font=FONT, weight=BOLD, font_size=19, color=renk)
        k = Text(kosul, font=FONT, font_size=16, color=INK_DIM)
        s = Text(sonuc, font=FONT, weight=BOLD, font_size=19, color=INK)
        a = Text(alt, font=FONT, font_size=15, color=INK_DIM)
        ic = VGroup(b, k, s, a).arrange(DOWN, aligned_edge=LEFT, buff=0.14)
        c = RoundedRectangle(width=max(ic.width + 0.6, 5.6), height=ic.height + 0.5,
                             corner_radius=0.13, stroke_color=renk,
                             stroke_width=1.8, fill_color=renk, fill_opacity=0.06)
        c.move_to(ic.get_center())
        ic.align_to(c, LEFT).shift(RIGHT * 0.3)
        return VGroup(c, ic)
