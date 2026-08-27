import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
from s18_taramalar import dipnot_ekle
import numpy as np


class PDvsCross(Slide):
    bolum = "9 · SONUÇ"
    baslik = "İki yöntemin aynı koşullarda karşılaştırılması"

    def construct(self):
        self.kur_baslik()
        dipnot_ekle(self)
        v = sweep_verisi()["pdvscross"]

        # rapordaki bant içi MAE değerleri
        RAPOR = {0.01: dict(pd="0,20 dB", cross="0,10 dB"),
                 0.10: dict(pd="6,94 dB", cross="0,89 dB")}
        SATIR_Y = {0.01: 0.15, 0.10: -2.30}
        SUTUN_X = {"pd": -3.55, "cross": 3.55}

        sabit = Small("DUT RMS 0,05 rad   ·   200 ortalama", size=17)
        sabit.move_to([0, 1.62, 0])
        ust_b = VGroup(
            Text("Tek kanal faz detektörü", font=FONT, weight=BOLD,
                 font_size=21, color=C_WARN).move_to([SUTUN_X["pd"], 1.12, 0]),
            Text("İki kanallı çapraz korelasyon", font=FONT, weight=BOLD,
                 font_size=21, color=C_OK).move_to([SUTUN_X["cross"], 1.12, 0]))
        self.play(FadeIn(sabit), FadeIn(ust_b), run_time=0.7)

        paneller = {}
        for sr in (0.01, 0.10):
            for tur in ("pd", "cross"):
                ax, gorsel = ssb_ekseni(x_range=(1, 5, 1), y_range=(-150, -20, 20),
                                        x_length=4.35, y_length=1.40,
                                        eksen_yazi=False)
                VGroup(ax, gorsel).move_to([SUTUN_X[tur], SATIR_Y[sr], 0])
                paneller[(sr, tur)] = (ax, gorsel)

        for sr in (0.01, 0.10):
            rz = rozet(f"Ref RMS\n{str(sr).replace('.', ',')} rad",
                       C_DUT_SIG if sr == 0.01 else C_DUT, fs=16)
            rz.set(width=min(rz.width, 2.35)).move_to([0, SATIR_Y[sr], 0])
            self.play(FadeIn(rz), run_time=0.4)

            for tur, renk in (("pd", C_WARN), ("cross", C_OK)):
                ax, gorsel = paneller[(sr, tur)]
                r = v[sr][tur][0]
                d = ssb_egri(ax, r["f_dut"], r["L_dut"], C_DUT, 2.2, True,
                             (1, 5), (-150, -20))
                c = ssb_egri(ax, r["f_cross"], r["L_cross"], C_CROSS, 2.6,
                             False, (1, 5), (-150, -20))
                mae_t = Text(f"bant içi MAE  {RAPOR[sr][tur]}", font=FONT,
                             weight=BOLD, font_size=19, color=renk)
                mae_t.move_to([SUTUN_X[tur], SATIR_Y[sr] - 1.20, 0])
                self.play(Create(ax.y_axis), FadeIn(gorsel), run_time=0.35)
                self.play(Create(d), Create(c), FadeIn(mae_t), run_time=0.9)
                paneller[(sr, tur)] = (ax, gorsel, d, c, mae_t)

        lej = egri_lejandi([(C_CROSS, False, "ölçüm sonucu"),
                            (C_DUT, True, "gerçek DUT")], fs=15)
        lej.scale(0.74).move_to([0, -1.08, 0])
        self.play(FadeIn(lej), run_time=0.5)
        self.wait(1.0)

        # kötü durumu vurgula
        kotu = paneller[(0.10, "pd")]
        cerceve = SurroundingRectangle(
            VGroup(kotu[0].y_axis, kotu[1], kotu[2], kotu[3], kotu[4]),
            color=C_DUT, stroke_width=3, buff=0.18, corner_radius=0.12)
        self.play(Create(cerceve), run_time=0.8)

        son = Text("Referans gürültüsü yükseldiğinde tek kanallı model sapıyor; "
                   "çapraz korelasyon gerçek DUT eğrisine oturmaya devam ediyor.",
                   font=FONT, weight=MEDIUM, font_size=19, color=C_GOLD)
        son.set(width=min(son.width, 11.6))
        son.move_to([0.3, -3.86, 0])
        self.play(FadeIn(son, shift=UP * 0.12), run_time=1.2)
        self.wait(2.8)


class SonucKapanis(Slide):
    bolum = "9 · SONUÇ VE GELECEK ÇALIŞMALAR"
    baslik = "Çıkarılan sonuçlar"

    def construct(self):
        self.kur_baslik()

        ms = maddeler([
            "İki referans kanallı faz dedektörü mimarisi GNU Octave ortamında "
            "gerçeklendi;\nDUT faz gürültüsü kompleks Cross-PSD ortalamasıyla "
            "kestirildi",
            "Kestirim, aynı Monte Carlo popülasyonunun filtresiz DUT "
            "periodogramıyla karşılaştırıldı",
            "LPF kesim frekansının, DUT ve referans RMS değerlerinin ve "
            "iterasyon\nsayısının etkisi karşılaştırmalarla ortaya konuldu",
            "Logaritmik bin sayısının yalnız gözlemi etkilediği görüldü",
        ], renk=C_DUT_SIG, fs=18, w=11.2)
        ms.arrange(DOWN, aligned_edge=LEFT, buff=0.30)
        ms.to_edge(LEFT, buff=0.85)
        ms.shift(UP * (1.70 - ms.get_top()[1]))
        self.play(LaggedStart(*[FadeIn(m, shift=RIGHT * 0.25) for m in ms],
                              lag_ratio=0.28), run_time=2.6)
        self.wait(1.4)

        kut = RoundedRectangle(width=12.3, height=1.95, corner_radius=0.18,
                               stroke_color=C_GOLD, stroke_width=2.5,
                               fill_color=C_GOLD, fill_opacity=0.09)
        ic = VGroup(
            Text("En önemli sonuç", font=FONT, weight=BOLD, font_size=21,
                 color=C_GOLD),
            Text("Referans RMS değeri olabildiğince düşük olmalıdır; düşük değilse\n"
                 "bile yüksek iterasyon sayılarıyla bu problem aşılabilir.",
                 font=FONT, weight=MEDIUM, font_size=22, color=INK,
                 line_spacing=0.95),
            Text("İki kanallı çapraz korelasyon yönteminin diğer yöntemlere "
                 "kıyasla en büyük avantajı budur.",
                 font=FONT, font_size=18, color=INK_DIM),
        ).arrange(DOWN, buff=0.20)
        if ic.width > 11.8:
            ic.set(width=11.8)
        kut.stretch_to_fit_width(max(ic.width + 1.0, 9.0))
        kut.stretch_to_fit_height(ic.height + 0.65)
        ic.move_to(kut.get_center())
        g = VGroup(kut, ic)
        g.set_x(0).shift(UP * (-3.46 - g.get_bottom()[1]))
        self.play(FadeIn(g, shift=UP * 0.2), run_time=1.4)
        self.wait(2.0)

        gelecek = Small("Gelecek çalışmalar: ADC kuantalaması, saat jitteri, "
                        "kanal uyumsuzluğu ve gerçek mikser doğrusal-olmama "
                        "etkilerinin modele eklenmesi", size=16)
        gelecek.set(width=min(gelecek.width, 12.0))
        gelecek.move_to([0, -3.84, 0])
        self.play(FadeIn(gelecek), run_time=0.9)
        self.wait(2.6)


class Kapanis(Slide):
    def construct(self):
        R = 1.5
        merkez = np.array([0.0, -0.35, 0.0])
        t = ValueTracker(0.0)
        NS = 4096
        jit = guc_yasasi_faz(NS, 0.30, 3.0, seed=31)
        sonme = ValueTracker(1.0)

        def phi(x):
            i = (x * 95.0) % NS
            i0 = int(np.floor(i)); i1 = (i0 + 1) % NS; a = i - i0
            return (jit[i0] * (1 - a) + jit[i1] * a) * sonme.get_value()

        def uc():
            th = 2 * PI * 0.4 * t.get_value() + phi(t.get_value()) + PI / 2
            return merkez + R * np.array([np.cos(th), np.sin(th), 0.0])

        cember = Circle(radius=R, color=RULE, stroke_width=2).move_to(merkez)
        fazor = always_redraw(lambda: Arrow(merkez, uc(), buff=0, color=C_DUT_SIG,
                                            stroke_width=5,
                                            max_tip_length_to_length_ratio=0.16))
        nokta = always_redraw(lambda: Dot(uc(), radius=0.07, color=C_DUT_SIG))
        iz = TracedPath(uc, stroke_color=C_DUT_SIG, stroke_width=2.6,
                        stroke_opacity=0.5, dissipating_time=2.0)

        self.add(cember, iz, fazor, nokta)
        self.play(t.animate.set_value(2.5), run_time=2.5, rate_func=linear)
        self.play(t.animate.set_value(5.5), sonme.animate.set_value(0.0),
                  run_time=3.0, rate_func=linear)

        tesekkur = Text("Teşekkürler", font=FONT, weight=BOLD, font_size=48,
                        color=INK)
        ad = Text("Ömer Faruk Yazıcı", font=FONT, weight=MEDIUM, font_size=25,
                  color=INK_DIM)
        cizgi = Line(LEFT, RIGHT, color=C_GOLD, stroke_width=3).set_width(1.8)
        blok = VGroup(tesekkur, cizgi, ad).arrange(DOWN, buff=0.32)
        blok.move_to(merkez + DOWN * 0.0)

        self.play(FadeOut(cember), FadeOut(fazor), FadeOut(nokta),
                  run_time=0.8)
        self.play(Write(tesekkur), run_time=1.2)
        self.play(GrowFromEdge(cizgi, LEFT), FadeIn(ad, shift=UP * 0.15),
                  run_time=0.9)
        self.wait(2.5)
