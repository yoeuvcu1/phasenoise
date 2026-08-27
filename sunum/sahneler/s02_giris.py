import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


class Giris(Slide):
    bolum = "1 · GİRİŞ"
    baslik = "Faz gürültüsü neyi sınırlar?"

    def construct(self):
        self.kur_baslik()

        # ---- üç uygulama alanı ----
        def kart(ikon_fn, ust, alt, renk):
            cerceve = RoundedRectangle(width=3.55, height=3.5, corner_radius=0.18,
                                       stroke_color=RULE, stroke_width=2,
                                       fill_color="#101728", fill_opacity=1)
            ikon = ikon_fn(renk)
            ikon.set(height=1.05).move_to(cerceve.get_top() + DOWN * 1.05)
            b = Text(ust, font=FONT, weight=BOLD, font_size=23, color=renk)
            b.next_to(ikon, DOWN, buff=0.42)
            a = Text(alt, font=FONT, font_size=18, color=INK_DIM,
                     line_spacing=1.0)
            a.set(width=min(a.width, 2.95))
            a.next_to(b, DOWN, buff=0.28)
            return VGroup(cerceve, ikon, b, a)

        def ikon_haberlesme(c):
            g = VGroup()
            for i, r in enumerate([0.30, 0.55, 0.80]):
                g.add(Arc(radius=r, start_angle=-PI/4, angle=PI/2,
                          color=c, stroke_width=4 - i * 0.7))
            g.add(Dot(radius=0.09, color=c))
            return g

        def ikon_radar(c):
            g = VGroup(Circle(radius=0.62, color=c, stroke_width=3),
                       Circle(radius=0.33, color=c, stroke_width=1.8,
                              stroke_opacity=0.5),
                       Line(ORIGIN, 0.62 * np.array([np.cos(PI/3), np.sin(PI/3), 0]),
                            color=c, stroke_width=4),
                       Dot(0.45 * np.array([np.cos(-PI/6), np.sin(-PI/6), 0]),
                           radius=0.075, color=C_WARN))
            return g

        def ikon_saat(c):
            g = VGroup()
            base = Line(LEFT * 0.75, RIGHT * 0.75, color=c, stroke_width=3)
            pts = []
            for i in range(7):
                x = -0.72 + i * 0.24
                pts += [[x, -0.3, 0], [x, 0.32, 0], [x + 0.12, 0.32, 0],
                        [x + 0.12, -0.3, 0]]
            g.add(VMobject().set_points_as_corners([np.array(p) for p in pts])
                  .set_stroke(c, 3))
            g.add(base.shift(DOWN * 0.62))
            return g

        kartlar = VGroup(
            kart(ikon_haberlesme, "Haberleşme",
                 "Modülasyon kalitesi ve\nkomşu kanal performansı", C_DUT_SIG),
            kart(ikon_radar, "Radar",
                 "Güçlü yansımalar yanında\nzayıf hedeflerin seçilebilirliği", C_REF1),
            kart(ikon_saat, "Sayısal sistemler",
                 "Saat jitteri ve\nörnekleme doğruluğu", C_REF2),
        ).arrange(RIGHT, buff=0.5)
        kartlar.scale(0.93).move_to(UP * 0.35)

        self.play(LaggedStart(*[FadeIn(k, shift=UP * 0.25) for k in kartlar],
                              lag_ratio=0.25), run_time=2.0)
        self.wait(1.4)

        # ---- kilit fikir ----
        kutu_v = RoundedRectangle(width=11.6, height=1.25, corner_radius=0.16,
                                  stroke_color=C_GOLD, stroke_width=2.2,
                                  fill_color="#1A1608", fill_opacity=0.85)
        vurgu = Text("Düşük gürültülü bir osilatörü ölçebilmek, yalnız DUT'a değil\n"
                     "ölçüm sisteminin kendi gürültü tabanına da bağlıdır.",
                     font=FONT, weight=MEDIUM, font_size=23, color=INK,
                     line_spacing=0.95)
        vurgu.move_to(kutu_v.get_center())
        vg = VGroup(kutu_v, vurgu).next_to(kartlar, DOWN, buff=0.55)

        self.play(FadeIn(kutu_v, scale=0.96), Write(vurgu), run_time=1.6)
        self.wait(2.2)

        # ---- amaç ----
        self.play(FadeOut(kartlar, shift=UP * 0.3),
                  vg.animate.to_edge(UP, buff=1.7).set_opacity(0.45),
                  run_time=1.0)

        amac_b = Text("Çalışmanın amacı", font=FONT, weight=BOLD,
                      font_size=27, color=C_GOLD)
        ms = maddeler([
            "İki referans kanallı faz dedektörü mimarisini sayısal olarak kurmak",
            "Kanallarda ortak olan DUT bileşenini Cross-PSD ortalamasıyla kestirmek",
            "Temel parametrelerin uçtan uca spektral uyuma etkisini incelemek",
        ], renk=C_OK, fs=25)
        blok = VGroup(amac_b, ms).arrange(DOWN, aligned_edge=LEFT, buff=0.5)
        blok.next_to(vg, DOWN, buff=0.85).to_edge(LEFT, buff=1.2)

        self.play(FadeIn(amac_b, shift=RIGHT * 0.2), run_time=0.6)
        self.play(LaggedStart(*[FadeIn(m, shift=RIGHT * 0.3) for m in ms],
                              lag_ratio=0.35), run_time=2.0)
        self.wait(2.5)
