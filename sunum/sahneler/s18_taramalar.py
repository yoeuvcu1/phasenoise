import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
import numpy as np

DIPNOT = ("eğriler aynı Octave modelinin sunum için küçültülmüş N ile yeniden "
          "üretilmiş halidir; MAE değerleri rapordaki tam ölçekli koşulardandır")


def dipnot_ekle(sahne):
    t = Text(DIPNOT, font=FONT, font_size=11, color=INK_DIM)
    t.set_opacity(0.55).to_edge(DOWN, buff=0.08).to_edge(LEFT, buff=0.3)
    sahne.add(t)
    return t


class LPFTaramasi(Slide):
    bolum = "8.2 · LPF KESİM FREKANSI KARŞILAŞTIRMASI"
    baslik = "Kesim frekansı ölçüm bandını belirler"

    def construct(self):
        self.kur_baslik()
        dipnot_ekle(self)
        v = sweep_verisi()["lpf"]

        ax, etk = ssb_ekseni(x_range=(1, 6, 1), y_range=(-170, -10, 20),
                             x_length=7.1, y_length=4.30)
        VGroup(ax, etk).move_to([-2.80, -0.60, 0])
        self.play(Create(ax.y_axis), FadeIn(etk), run_time=1.0)

        test = MathTex(r"f_c = 1,\ 5,\ 10,\ 25,\ 50,\ 100,\ 200,\ 300\ \mathrm{kHz}",
                       font_size=25, color=INK)
        test.next_to(self.chrome[2], DOWN, buff=0.28).to_edge(LEFT, buff=0.75)
        self.play(FadeIn(test), run_time=0.6)

        lej = egri_lejandi([(C_CROSS, False, "Cross-PSD kestirimi"),
                            (C_DUT, True, "gerçek DUT periodogramı")], fs=16)
        lej.scale(0.82)
        lej.move_to(ax.c2p(10 ** 1.05, -155) + RIGHT * lej.width / 2
                    + UP * lej.height / 2)
        self.play(FadeIn(lej), run_time=0.5)

        fcler = [1e3, 5e3, 1e4, 2.5e4, 5e4, 1e5, 2e5, 3e5]
        r0 = v[fcler[0]][0]
        dut_e = ssb_egri(ax, r0["f_dut"], r0["L_dut"], C_DUT, 2.8, True,
                         (1, 6), (-170, -10))
        self.play(Create(dut_e), run_time=1.2)

        cross_e = ssb_egri(ax, r0["f_cross"], r0["L_cross"], C_CROSS, 3.0,
                           False, (1, 6), (-170, -10))
        kesim = always_redraw(lambda: VMobject())

        def kesim_cizgi(fc):
            ln = DashedLine(ax.c2p(fc, -170), ax.c2p(fc, -10),
                            color=C_GOLD, stroke_width=2, dash_length=0.1)
            lb = Text(f"fc = {fc/1e3:g} kHz", font=FONT, weight=BOLD,
                      font_size=19, color=C_GOLD)
            lb.next_to(ln, UP, buff=0.1)
            if lb.get_right()[0] > ax.get_right()[0]:
                lb.next_to(ln, UP, buff=0.1).align_to(ax, RIGHT)
            return VGroup(ln, lb)

        kg = kesim_cizgi(fcler[0])
        self.play(Create(cross_e), Create(kg), run_time=1.2)
        self.wait(0.8)

        for fc in fcler[1:]:
            r = v[fc][0]
            yeni = ssb_egri(ax, r["f_cross"], r["L_cross"], C_CROSS, 3.0,
                            False, (1, 6), (-170, -10))
            yeni_kg = kesim_cizgi(fc)
            self.play(Transform(cross_e, yeni), Transform(kg, yeni_kg),
                      run_time=0.85)

        self.wait(0.6)

        # ---- yorum ----
        notlar = VGroup(
            madde("Düşük fc dar ölçüm bandı,\nyüksek fc geniş offset aralığı",
                  C_GOLD, fs=19, w=5.2),
            madde("Karşılaştırılan DUT periodogramı\nFİLTRESİZ: kesim üstünde\n"
                  "ayrışma beklenen sonuçtur", C_DUT, fs=19, w=5.2),
            madde("MAE yorumlanırken esas olarak\nLPF geçiş bandı dikkate alınmalı",
                  C_OK, fs=19, w=5.2),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.48)
        notlar.move_to([4.05, 0.35, 0])
        self.play(LaggedStart(*[FadeIn(n, shift=LEFT * 0.2) for n in notlar],
                              lag_ratio=0.3), run_time=2.0)

        rz = VGroup(rozet("en düşük tam bant MAE   50 kHz'de  0,805 dB", C_OK, fs=17),
                    rozet("en yüksek MAE   300 kHz'de  2,458 dB", C_WARN, fs=17))
        rz.arrange(DOWN, buff=0.24).scale(0.92)
        rz.move_to([4.05, -2.55, 0])
        self.play(FadeIn(rz, shift=UP * 0.15), run_time=1.0)
        self.wait(2.6)


class RMSTaramalari(Slide):
    bolum = "8.3 – 8.4 · DUT VE REFERANS RMS KARŞILAŞTIRMASI"
    baslik = "Hangi RMS değeri ölçümü bozar?"

    def construct(self):
        self.kur_baslik()
        dipnot_ekle(self)
        v = sweep_verisi()

        def panel(x, veri_anahtari, degerler, baslik, renk):
            ax, gorsel = ssb_ekseni(x_range=(1, 6, 1), y_range=(-170, -10, 20),
                                    x_length=5.35, y_length=2.80,
                                    eksen_yazi=False)
            VGroup(ax, gorsel).move_to([x, -0.62, 0])
            b = Text(baslik, font=FONT, weight=BOLD, font_size=21, color=renk)
            b.next_to(ax.y_axis, UP, buff=0.24).set_x(x)
            return ax, b, gorsel

        ax1, b1, g1 = panel(-3.45, "dut", None, "DUT RMS değişiyor", C_DUT_SIG)
        ax2, b2, g2 = panel(3.45, "ref", None, "Referans RMS değişiyor", C_REF1)
        yl = Text("dBc/Hz", font=FONT, font_size=17, color=INK_DIM).rotate(PI / 2)
        yl.next_to(ax1.y_axis, LEFT, buff=0.18)

        vurgu = Text("İkisi benzer görünse de kritik olan referanstır: yüksek "
                     "referans RMS'i doğruluk için çok daha fazla iterasyon ister.",
                     font=FONT, weight=MEDIUM, font_size=19, color=C_GOLD)
        vurgu.set(width=min(vurgu.width, 12.0))
        vurgu.move_to([0, 1.58, 0])

        self.play(Create(ax1.y_axis), Create(ax2.y_axis), FadeIn(g1), FadeIn(g2),
                  FadeIn(b1), FadeIn(b2), FadeIn(yl), FadeIn(vurgu), run_time=1.2)

        sigmalar = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5]

        def ilk(ax, anahtar):
            r = v[anahtar][sigmalar[0]][0]
            d = ssb_egri(ax, r["f_dut"], r["L_dut"], C_DUT, 2.4, True,
                         (1, 6), (-170, -10))
            c = ssb_egri(ax, r["f_cross"], r["L_cross"], C_CROSS, 2.8, False,
                         (1, 6), (-170, -10))
            return d, c

        d1, c1 = ilk(ax1, "dut")
        d2, c2 = ilk(ax2, "ref")
        self.play(Create(d1), Create(c1), Create(d2), Create(c2), run_time=1.4)

        et1 = Text("σ_DUT = 0,01 rad", font=FONT, weight=BOLD, font_size=19,
                   color=C_DUT_SIG)
        et2 = Text("σ_ref = 0,01 rad", font=FONT, weight=BOLD, font_size=19,
                   color=C_REF1)
        et1.next_to(g1, DOWN, buff=0.26).set_x(ax1.get_center()[0])
        et2.next_to(g2, DOWN, buff=0.26).set_x(ax2.get_center()[0])
        self.play(FadeIn(et1), FadeIn(et2), run_time=0.5)

        for sg in sigmalar[1:]:
            rd = v["dut"][sg][0]
            rr = v["ref"][sg][0]
            n_d1 = ssb_egri(ax1, rd["f_dut"], rd["L_dut"], C_DUT, 2.4, True,
                            (1, 6), (-170, -10))
            n_c1 = ssb_egri(ax1, rd["f_cross"], rd["L_cross"], C_CROSS, 2.8,
                            False, (1, 6), (-170, -10))
            n_d2 = ssb_egri(ax2, rr["f_dut"], rr["L_dut"], C_DUT, 2.4, True,
                            (1, 6), (-170, -10))
            n_c2 = ssb_egri(ax2, rr["f_cross"], rr["L_cross"], C_CROSS, 2.8,
                            False, (1, 6), (-170, -10))
            s_txt = f"{sg:.2f}".replace(".", ",")
            ne1 = Text(f"σ_DUT = {s_txt} rad", font=FONT, weight=BOLD,
                       font_size=19, color=C_DUT_SIG).move_to(et1)
            ne2 = Text(f"σ_ref = {s_txt} rad", font=FONT, weight=BOLD,
                       font_size=19, color=C_REF1).move_to(et2)
            self.play(Transform(d1, n_d1), Transform(c1, n_c1),
                      Transform(d2, n_d2), Transform(c2, n_c2),
                      Transform(et1, ne1), Transform(et2, ne2), run_time=0.9)

        self.wait(0.6)

        s1 = VGroup(
            MathTex(r"\Delta L = 20\log_{10}\frac{\sigma_{D,2}}{\sigma_{D,1}}",
                    font_size=26, color=INK),
            Small("aynı spektral şekilde RMS arttıkça seviye yükselir", size=16),
        ).arrange(DOWN, buff=0.14)
        s1.next_to(et1, DOWN, buff=0.34).set_x(ax1.get_center()[0])

        s2 = VGroup(
            Text("MAE   0,549 dB  →  4,805 dB", font=FONT, weight=BOLD,
                 font_size=21, color=C_WARN),
            Small("ref RMS 0,01 → 0,50 rad · mutlak fark 4,256 dB", size=16),
            Small("küçük açı sürümünde bu fark 8 dB üzerindeydi", size=15),
        ).arrange(DOWN, buff=0.12)
        s2.next_to(et2, DOWN, buff=0.28).set_x(ax2.get_center()[0])

        self.play(FadeIn(s1, shift=UP * 0.12), run_time=0.9)
        self.play(FadeIn(s2, shift=UP * 0.12), run_time=0.9)
        self.wait(1.4)

        self.wait(2.4)


class BinSayisi(Slide):
    bolum = "8.5 · LOGARİTMİK BİN SAYISININ ETKİSİ"
    baslik = "Bin sayısı ölçüm kalitesini değil, gözlemi etkiler"

    def construct(self):
        self.kur_baslik()
        dipnot_ekle(self)
        v = sweep_verisi()["bin"]

        ax, etk = ssb_ekseni(x_range=(1, 6, 1), y_range=(-170, -10, 20),
                             x_length=6.9, y_length=4.15)
        VGroup(ax, etk).move_to([-2.95, -0.75, 0])
        self.play(Create(ax.y_axis), FadeIn(etk), run_time=0.9)

        binler = [25, 50, 100, 200]
        r0 = v[binler[0]][0]
        d = ssb_egri(ax, r0["f_dut"], r0["L_dut"], C_DUT, 2.6, True,
                     (1, 6), (-170, -10))
        c = ssb_egri(ax, r0["f_cross"], r0["L_cross"], C_CROSS, 3.0, False,
                     (1, 6), (-170, -10))
        et = Text("25 bin", font=FONT, weight=BOLD, font_size=26, color=C_GOLD)
        et.move_to(ax.get_corner(UR) + LEFT * (et.width / 2 + 0.35)
                   + DOWN * 0.4)
        self.play(Create(d), Create(c), FadeIn(et), run_time=1.3)

        for nb in binler[1:]:
            r = v[nb][0]
            nd = ssb_egri(ax, r["f_dut"], r["L_dut"], C_DUT, 2.6, True,
                          (1, 6), (-170, -10))
            nc = ssb_egri(ax, r["f_cross"], r["L_cross"], C_CROSS, 3.0, False,
                          (1, 6), (-170, -10))
            ne = Text(f"{nb} bin", font=FONT, weight=BOLD, font_size=26,
                      color=C_GOLD).move_to(et)
            self.play(Transform(d, nd), Transform(c, nc), Transform(et, ne),
                      run_time=1.0)

        notlar = VGroup(
            madde("Daha çok bin → daha fazla\nayrıntı, daha fazla saçılma",
                  C_GOLD, fs=19, w=5.1),
            madde("En düşük gözlenen MAE\n100 bin için 0,682 dB", C_OK, fs=19, w=5.1),
            madde("Her bin değeri yeni rastgele\ngerçekleşimlerle çalıştırıldığı için\n"
                  "fark yalnız çözünürlüğe bağlanamaz", C_DUT_SIG, fs=19, w=5.1),
            madde("İstatistiksel optimum\niddiası kurulmamıştır", C_WARN,
                  fs=19, w=5.1),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.44)
        notlar.move_to([4.0, -0.35, 0])
        self.play(LaggedStart(*[FadeIn(n, shift=LEFT * 0.2) for n in notlar],
                              lag_ratio=0.28), run_time=2.4)
        self.wait(2.6)
