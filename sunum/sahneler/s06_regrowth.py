import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class EtkiRegrowth(Slide):
    bolum = "3.1 · SPECTRAL REGROWTH"
    baslik = "Yerel osilatörün gürültüsü çıkışa aynen taşınır"

    def construct(self):
        self.kur_baslik()

        # ---- mikser zinciri ----
        giris = kutu("Giriş sinyali", w=2.5, h=0.85, color=C_DUT_SIG, fs=19)
        carpim = Circle(radius=0.42, color=INK, stroke_width=3)
        capraz = VGroup(Line(UL, DR).set_length(0.42), Line(DL, UR).set_length(0.42))
        capraz.set_stroke(INK, 3).move_to(carpim.get_center())
        mikser = VGroup(carpim, capraz)
        cikis = kutu("Çıkış", w=1.9, h=0.85, color=C_WARN, fs=19)
        lo = kutu("Yerel Osilatör\n(LO)", w=2.4, h=1.0, color=C_REF1, fs=18)

        giris.move_to([-4.6, 0.85, 0])
        mikser.move_to([-1.5, 0.85, 0])
        cikis.move_to([1.5, 0.85, 0])
        lo.move_to([-1.5, -1.25, 0])

        a1 = ok(giris.get_right(), mikser.get_left(), C_DUT_SIG)
        a2 = ok(mikser.get_right(), cikis.get_left(), C_WARN)
        a3 = ok(lo.get_top(), mikser.get_bottom(), C_REF1)

        zincir = VGroup(giris, mikser, cikis, lo, a1, a2, a3)
        zincir.scale(1.06).move_to([-2.0, 0.15, 0])

        self.play(LaggedStart(FadeIn(giris), GrowArrow(a1), FadeIn(mikser),
                              FadeIn(lo), GrowArrow(a3), GrowArrow(a2),
                              FadeIn(cikis), lag_ratio=0.25), run_time=2.2)

        # ---- LO gürültüsü çıkışa biner ----
        def mini_spektrum(x, y, genislik, gurultu, renk, en=2.05, boy=1.05):
            ax = Axes(x_range=[-1, 1, 1], y_range=[0, 1.15, 1],
                      x_length=en, y_length=boy,
                      axis_config={"stroke_color": RULE, "stroke_width": 1.2,
                                   "include_ticks": False, "include_tip": False})
            ax.move_to([x, y, 0])
            f = lambda u: np.exp(-(u / genislik) ** 2) + \
                gurultu * np.exp(-np.abs(u) / 0.55) * (1 - np.exp(-(u / genislik) ** 2))
            c = ax.plot(f, x_range=[-1, 1, 0.006]).set_stroke(renk, 2.6)
            alan = ax.plot(f, x_range=[-1, 1, 0.006])
            alan = VMobject().set_points_as_corners(
                [ax.c2p(-1, 0)] + [ax.c2p(u, f(u)) for u in np.linspace(-1, 1, 240)]
                + [ax.c2p(1, 0)]).set_fill(renk, 0.22).set_stroke(width=0)
            return VGroup(ax, alan, c)

        sp_lo_temiz = mini_spektrum(lo.get_center()[0] - 2.35,
                                    lo.get_center()[1], 0.04, 0.0, C_REF1)
        sp_lo_gur = mini_spektrum(lo.get_center()[0] - 2.35,
                                  lo.get_center()[1], 0.04, 0.55, C_REF1)
        sp_cik_temiz = mini_spektrum(cikis.get_center()[0] + 2.1,
                                     cikis.get_center()[1], 0.04, 0.0, C_WARN)
        sp_cik_gur = mini_spektrum(cikis.get_center()[0] + 2.1,
                                   cikis.get_center()[1], 0.04, 0.55, C_WARN)

        l1 = Small("temiz LO", size=15).next_to(sp_lo_temiz, DOWN, buff=0.1)
        l2 = Small("temiz çıkış", size=15).next_to(sp_cik_temiz, DOWN, buff=0.1)

        self.play(FadeIn(sp_lo_temiz), FadeIn(l1),
                  FadeIn(sp_cik_temiz), FadeIn(l2), run_time=1.0)
        self.wait(1.0)

        l1b = Text("faz gürültülü LO", font=FONT, font_size=15, color=C_REF1)
        l1b.move_to(l1)
        l2b = Text("gürültü çıkışa biner", font=FONT, font_size=15, color=C_WARN)
        l2b.move_to(l2)

        self.play(Transform(sp_lo_temiz, sp_lo_gur), FadeTransform(l1, l1b),
                  run_time=1.2)
        self.play(Transform(sp_cik_temiz, sp_cik_gur), FadeTransform(l2, l2b),
                  run_time=1.2)
        self.wait(1.4)

        # ---- komşu kanala sızıntı ----
        self.play(FadeOut(VGroup(zincir, sp_lo_temiz, sp_cik_temiz, l1b, l2b)),
                  run_time=0.8)

        alt_b = H2("Sonuç: komşu kanala güç sızıntısı", size=27, color=INK)
        alt_b.move_to([0, self.govde() - 0.32, 0])
        self.play(FadeIn(alt_b, shift=DOWN * 0.15), run_time=0.6)

        ax = Axes(x_range=[-3, 3, 1], y_range=[-80, 6, 20],
                  x_length=9.6, y_length=3.5,
                  axis_config={"stroke_color": RULE, "stroke_width": 1.6,
                               "include_ticks": False, "include_tip": False})
        ax.move_to([0, -1.05, 0])

        kanal = Rectangle(width=ax.c2p(0.55, 0)[0] - ax.c2p(-0.55, 0)[0],
                          height=ax.c2p(0, 6)[1] - ax.c2p(0, -72)[1],
                          stroke_width=0, fill_color=C_OK, fill_opacity=0.10)
        kanal.move_to([ax.c2p(0, -33)[0], ax.c2p(0, -33)[1], 0])
        kanal_lbl = Text("kendi kanalı", font=FONT, font_size=16, color=C_OK)
        kanal_lbl.next_to(ax.c2p(0, 6), UP, buff=0.1)

        komsu = VGroup(
            Rectangle(width=ax.c2p(2.3, 0)[0] - ax.c2p(0.75, 0)[0],
                      height=ax.c2p(0, 6)[1] - ax.c2p(0, -72)[1],
                      stroke_width=0, fill_color=C_WARN, fill_opacity=0.10)
            .move_to([(ax.c2p(0.75, 0)[0] + ax.c2p(2.3, 0)[0]) / 2,
                      ax.c2p(0, -33)[1], 0]),
            Rectangle(width=ax.c2p(2.3, 0)[0] - ax.c2p(0.75, 0)[0],
                      height=ax.c2p(0, 6)[1] - ax.c2p(0, -72)[1],
                      stroke_width=0, fill_color=C_WARN, fill_opacity=0.10)
            .move_to([-(ax.c2p(0.75, 0)[0] + ax.c2p(2.3, 0)[0]) / 2 +
                      2 * ax.c2p(0, 0)[0], ax.c2p(0, -33)[1], 0]))
        komsu_lbl = Text("komşu kanal", font=FONT, font_size=16, color=C_WARN)
        komsu_lbl.next_to(ax.c2p(1.5, 6), UP, buff=0.1)

        self.play(Create(ax), FadeIn(kanal), FadeIn(komsu),
                  FadeIn(kanal_lbl), FadeIn(komsu_lbl), run_time=1.0)

        def kanal_egri(seviye):
            def f(u):
                govde = 3.0 * np.exp(-(u / 0.42) ** 8)
                etek = seviye - 22 * np.log10(np.abs(u) / 0.5 + 1)
                return max(govde if np.abs(u) < 0.5 else -70, etek, -70)
            return ax.plot(f, x_range=[-3, 3, 0.006])

        e_dusuk = kanal_egri(-62).set_stroke(C_OK, 3)
        e_orta = kanal_egri(-42).set_stroke(C_REF1, 3)
        e_yuksek = kanal_egri(-24).set_stroke(C_DUT, 3.4)

        def lg_ogesi(renk, metin):
            return VGroup(Line(ORIGIN, RIGHT * 0.42).set_stroke(renk, 3),
                          Text(metin, font=FONT, font_size=16, color=INK_DIM)
                          ).arrange(RIGHT, buff=0.16)
        lg = VGroup(lg_ogesi(C_OK, "düşük faz gürültüsü"),
                    lg_ogesi(C_REF1, "orta"),
                    lg_ogesi(C_DUT, "yüksek faz gürültüsü")
                    ).arrange(RIGHT, buff=0.75)
        lg.move_to(np.array([0.0, 0.62, 0.0]))

        self.play(Create(e_dusuk), FadeIn(lg[0]), run_time=1.1)
        self.wait(0.5)
        self.play(Create(e_orta), FadeIn(lg[1]), run_time=1.0)
        self.play(Create(e_yuksek), FadeIn(lg[2]), run_time=1.0)

        uyari = Text("yüksek gürültüde belirgin sızıntı ve bozulma",
                     font=FONT, weight=MEDIUM, font_size=20, color=C_DUT)
        uyari.next_to(ax, DOWN, buff=0.34)
        self.play(FadeIn(uyari, shift=UP * 0.1), run_time=0.8)
        self.wait(2.4)
