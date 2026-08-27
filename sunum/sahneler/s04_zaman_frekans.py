import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np


def _spektrum(gurultulu, n=2048, fs=1.0, f0=0.16, rms=0.5, seed=3):
    t = np.arange(n) / fs
    ph = guc_yasasi_faz(n, rms, 3.0, seed=seed) if gurultulu else np.zeros(n)
    x = np.cos(2 * PI * f0 * t + ph)
    w = np.hanning(n)
    X = np.abs(np.fft.rfft(x * w)) ** 2
    X /= X.max()
    f = np.fft.rfftfreq(n, 1 / fs)
    return f, 10 * np.log10(X + 1e-12)


class ZamanFrekans(Slide):
    bolum = "2.1 · ZAMAN VE FREKANS BÖLGESİ"
    baslik = "Gürültüyü ancak frekans bölgesinde görebiliriz"

    def construct(self):
        self.kur_baslik()

        UST_Y, ALT_Y = 0.30, -2.28
        SOL_X, SAG_X = -4.05, 2.85
        EN, BOY = 4.6, 1.52

        def zaman_ekseni(x, y):
            ax = Axes(x_range=[0, 1, 1], y_range=[-1.3, 1.3, 1],
                      x_length=EN, y_length=BOY,
                      axis_config={"stroke_color": RULE, "stroke_width": 1.5,
                                   "include_ticks": False, "include_tip": False})
            ax.move_to([x, y, 0])
            return ax

        def frek_ekseni(x, y):
            ax = Axes(x_range=[0, 1, 1], y_range=[-62, 8, 10],
                      x_length=EN, y_length=BOY,
                      axis_config={"stroke_color": RULE, "stroke_width": 1.5,
                                   "include_ticks": False, "include_tip": False})
            ax.move_to([x, y, 0])
            return ax

        NT = 900
        tt = np.linspace(0, 1, NT)
        ph_n = guc_yasasi_faz(NT, 0.85, 3.0, seed=11)

        ax_t1 = zaman_ekseni(SOL_X, UST_Y)
        ax_t2 = zaman_ekseni(SOL_X, ALT_Y)
        ax_f1 = frek_ekseni(SAG_X, UST_Y)
        ax_f2 = frek_ekseni(SAG_X, ALT_Y)

        w1 = ax_t1.plot(lambda u: np.cos(2 * PI * 5.2 * u),
                        x_range=[0, 1, 0.0015]).set_stroke(C_DUT_SIG, 3)
        w2 = ax_t2.plot(lambda u: np.cos(2 * PI * 5.2 * u +
                                         np.interp(u, tt, ph_n)),
                        x_range=[0, 1, 0.0015]).set_stroke(C_DUT_SIG, 3)

        f_i, S_i = _spektrum(False, seed=5)
        f_n, S_n = _spektrum(True, rms=0.55, seed=9)
        msk = f_i <= 0.34

        def dbc_egri(ax, f, S, m):
            pts = [ax.c2p(v / 0.34, max(s, -62)) for v, s in zip(f[m], S[m])]
            return VMobject().set_points_smoothly(pts)

        s1 = dbc_egri(ax_f1, f_i, S_i, msk).set_stroke(C_REF2, 3)
        s2 = dbc_egri(ax_f2, f_n, S_n, msk).set_stroke(C_REF2, 3)

        def etiket(ax, s, konum=DOWN, buff=0.16, fs=18, renk=INK_DIM):
            t = Text(s, font=FONT, font_size=fs, color=renk)
            t.next_to(ax, konum, buff=buff)
            return t

        # ---- üst satır: ideal ----
        rozet_i = rozet("İDEAL", C_OK, fs=17).scale(0.82)
        rozet_g = rozet("FAZ GÜRÜLTÜLÜ", C_WARN, fs=17).scale(0.82)
        rozet_i.align_to(ax_t1, LEFT).set_y(ax_t1.get_top()[1] + 0.32)
        rozet_g.align_to(ax_t2, LEFT).set_y(ax_t2.get_top()[1] + 0.32)

        zd = Text("Zaman Bölgesi", font=FONT, weight=BOLD, font_size=21, color=INK)
        fd = Text("Frekans Bölgesi", font=FONT, weight=BOLD, font_size=21, color=INK)
        zd.move_to([SOL_X, 1.78, 0])
        fd.move_to([SAG_X, 1.78, 0])

        self.play(FadeIn(zd), FadeIn(fd), run_time=0.5)
        self.play(FadeIn(rozet_i), Create(ax_t1), run_time=0.7)
        self.play(Create(w1), run_time=1.3)

        ft_ok = ok(ax_t1.get_right() + RIGHT * 0.12,
                   ax_f1.get_left() + LEFT * 0.12, color=C_GOLD, sw=3.2)
        ft_lbl = Text("Fourier", font=FONT, font_size=16, color=C_GOLD)
        ft_lbl.next_to(ft_ok, UP, buff=0.08)
        self.play(GrowArrow(ft_ok), FadeIn(ft_lbl), Create(ax_f1), run_time=0.9)
        self.play(Create(s1), run_time=1.1)

        tek = Text("tek spektral çizgi", font=FONT, font_size=17, color=C_OK)
        tek.next_to(ax_f1, DOWN, buff=0.12)
        self.play(FadeIn(tek), run_time=0.5)
        self.wait(1.2)

        # ---- alt satır: gürültülü ----
        self.play(FadeIn(rozet_g), Create(ax_t2), run_time=0.7)
        self.play(Create(w2), run_time=1.4)

        ft_ok2 = ok(ax_t2.get_right() + RIGHT * 0.12,
                    ax_f2.get_left() + LEFT * 0.12, color=C_GOLD, sw=3.2)
        self.play(GrowArrow(ft_ok2), Create(ax_f2), run_time=0.8)
        self.play(Create(s2), run_time=1.2)

        etek = Text("taşıyıcı çevresinde yan bantlar", font=FONT,
                    font_size=17, color=C_WARN)
        etek.next_to(ax_f2, DOWN, buff=0.12)
        self.play(FadeIn(etek), run_time=0.5)
        self.wait(1.0)

        # ---- vurgu ----
        vurgu = Text("Zaman bölgesinde neredeyse aynı görünen iki sinyal, "
                     "frekans bölgesinde tamamen ayrışır.",
                     font=FONT, weight=MEDIUM, font_size=21, color=C_GOLD)
        vurgu.set(width=min(vurgu.width, 11.6))
        vurgu.move_to(np.array([-0.6, -3.72, 0.0]))
        self.play(FadeIn(vurgu, shift=UP * 0.15), run_time=1.0)
        self.wait(2.6)
