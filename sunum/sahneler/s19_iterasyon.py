import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from manim import *
from tema import *
from s18_taramalar import dipnot_ekle
import numpy as np

# Rapordaki tam ölçekli koşuların M ve tam bant MAE değerleri
RAPOR = [(1, 16.699), (50, 6.340), (250, 2.501), (500, 3.242), (1000, 1.856),
         (2000, 2.623), (5000, 1.259), (10000, 1.297), (20000, 0.845)]
# Sunumdaki eğrileri üreten küçültülmüş koşunun checkpoint'leri
EGRI_M = [1, 5, 20, 50, 120, 300, 700, 1500, 3000]


def bin_ayir(n):
    return f"{n:,}".replace(",", ".")


class IterasyonYakinsama(Slide):
    bolum = "8.6 · İTERASYON SAYILARININ KARŞILAŞTIRILMASI"
    baslik = "İterasyon arttıkça kestirim gerçek DUT'a oturuyor"

    def construct(self):
        self.kur_baslik()
        dipnot_ekle(self)
        v = sweep_verisi()["iter"]

        kosul = MathTex(r"\sigma_{DUT}=0{,}02\ \mathrm{rad}\qquad{}"
                        r"\sigma_{ref}=0{,}10\ \mathrm{rad}\qquad{}"
                        r"f_{c}=50\ \mathrm{kHz}", font_size=25, color=INK)
        kosul.move_to([-0.3, 1.62, 0])
        self.play(FadeIn(kosul), run_time=0.7)

        fark = rozet("referanslar DUT'tan  20·log₁₀(0,10/0,02) ≈ 13,98 dB  "
                     "daha gürültülü", C_WARN, fs=17).scale(0.92)
        fark.move_to([-0.3, 0.98, 0])
        self.play(FadeIn(fark, scale=0.96), run_time=0.7)

        ax, etk = ssb_ekseni(x_range=(1, 6, 1), y_range=(-170, -10, 20),
                             x_length=7.0, y_length=3.20)
        VGroup(ax, etk).move_to([-2.95, -1.12, 0])
        self.play(Create(ax.y_axis), FadeIn(etk), run_time=0.8)

        r0 = v[EGRI_M[0]]
        dut_e = ssb_egri(ax, r0["f_dut"], r0["L_dut"], C_DUT, 2.8, True,
                         (1, 6), (-170, -10))
        cross_e = ssb_egri(ax, r0["f_cross"], r0["L_cross"], C_CROSS, 3.0,
                           False, (1, 6), (-170, -10))
        lej = egri_lejandi([(C_CROSS, False, "Cross-PSD kestirimi"),
                            (C_DUT, True, "gerçek DUT periodogramı")], fs=15)
        lej.scale(0.82)
        lej.move_to(ax.c2p(10 ** 1.05, -150) + RIGHT * lej.width / 2
                    + UP * lej.height / 2)
        self.play(Create(dut_e), Create(cross_e), FadeIn(lej), run_time=1.5)

        # ---- sayaçlar ----
        m_lbl = Text("iterasyon", font=FONT, font_size=20, color=INK_DIM)
        m_val = Text("1", font=FONT, weight=BOLD, font_size=52, color=C_GOLD)
        mae_lbl = Text("tam bant MAE", font=FONT, font_size=20, color=INK_DIM)
        mae_val = Text("16,699 dB", font=FONT, weight=BOLD, font_size=38,
                       color=C_DUT)
        sayac = VGroup(m_lbl, m_val, mae_lbl, mae_val)\
            .arrange(DOWN, buff=0.18)
        sayac.move_to([4.35, 0.05, 0])
        self.play(FadeIn(sayac), run_time=0.6)

        # ---- MAE - M mini grafiği ----
        mini = Axes(x_range=[0, 4.4, 1], y_range=[0, 18, 6],
                    x_length=3.5, y_length=1.85,
                    axis_config={"stroke_color": RULE, "stroke_width": 1.4,
                                 "include_ticks": False, "include_tip": False})
        mini.move_to([4.35, -2.42, 0])
        mini_l = Small("MAE (dB)  –  log M", size=14)
        mini_l.next_to(mini, DOWN, buff=0.14)
        self.play(Create(mini), FadeIn(mini_l), run_time=0.5)

        noktalar = VGroup()
        cizgiler = VGroup()
        onceki = None
        self.add(noktalar, cizgiler)

        for i, (m_r, mae_r) in enumerate(RAPOR):
            p = mini.c2p(np.log10(max(m_r, 1)) if m_r > 1 else 0.0, mae_r)
            d = Dot(p, radius=0.055, color=C_GOLD)
            anims = [FadeIn(d, scale=0.7)]
            if onceki is not None:
                ln = Line(onceki, p).set_stroke(C_GOLD, 2, opacity=0.6)
                cizgiler.add(ln)
                anims.append(Create(ln))
            noktalar.add(d)
            onceki = p

            if i > 0:
                r = v[EGRI_M[i]]
                n_c = ssb_egri(ax, r["f_cross"], r["L_cross"], C_CROSS, 3.0,
                               False, (1, 6), (-170, -10))
                n_d = ssb_egri(ax, r["f_dut"], r["L_dut"], C_DUT, 2.8, True,
                               (1, 6), (-170, -10))
                nm = Text(bin_ayir(m_r), font=FONT, weight=BOLD, font_size=52,
                          color=C_GOLD).move_to(m_val)
                renk = C_OK if mae_r < 2.0 else (C_WARN if mae_r < 7 else C_DUT)
                nmae = Text(f"{mae_r:.3f} dB".replace(".", ","), font=FONT,
                            weight=BOLD, font_size=38, color=renk).move_to(mae_val)
                anims += [Transform(cross_e, n_c), Transform(dut_e, n_d),
                          Transform(m_val, nm), Transform(mae_val, nmae)]
            self.play(*anims, run_time=0.95)

        self.play(Flash(sayac[3].get_center(), color=C_OK, line_length=0.3,
                        num_lines=16, flash_radius=1.0), run_time=0.9)

        son = Text("Tam bant MAE  16,699 dB  →  0,845 dB     (toplam azalma 15,854 dB)",
                   font=FONT, weight=BOLD, font_size=21, color=C_OK)
        son.set(width=min(son.width, 11.4))
        son.to_edge(DOWN, buff=0.30)
        self.play(FadeIn(son, shift=UP * 0.12), run_time=1.0)
        self.wait(2.4)


class DekadAnalizi(Slide):
    bolum = "8.6 · DEKAD BANTLARINDA MAE"
    baslik = "Artık hata nerede kalıyor?"

    def construct(self):
        self.kur_baslik()

        basliklar = ["İter.", "1–10 Hz", "10–100 Hz", "0,1–1 kHz", "1–10 kHz",
                     "10–100 kHz", "100–467 kHz", "Tam bant"]
        veri = [
            ("1", "11,303", "15,626", "18,423", "18,879", "18,075", "15,960", "16,699"),
            ("50", "7,127", "6,841", "6,584", "6,617", "6,601", "3,734", "6,340"),
            ("250", "2,023", "2,380", "3,260", "3,489", "2,001", "0,758", "2,501"),
            ("500", "3,016", "2,866", "3,657", "3,807", "4,270", "1,010", "3,242"),
            ("1.000", "0,885", "1,654", "2,039", "2,171", "3,047", "0,904", "1,856"),
            ("2.000", "0,979", "1,728", "3,111", "3,313", "2,123", "5,899", "2,623"),
            ("5.000", "0,895", "0,590", "0,879", "0,814", "1,928", "3,504", "1,259"),
            ("10.000", "0,611", "0,815", "0,980", "1,119", "2,621", "1,780", "1,297"),
            ("20.000", "0,381", "0,172", "0,157", "0,279", "2,277", "2,526", "0,845"),
        ]
        col_w = [1.35, 1.55, 1.65, 1.65, 1.55, 1.75, 1.85, 1.55]
        toplam = sum(col_w)
        merkez, acc = [], -toplam / 2
        for w in col_w:
            merkez.append(acc + w / 2)
            acc += w

        FS = 16
        g = VGroup()
        y = 1.30
        hdr = VGroup()
        for j, b in enumerate(basliklar):
            t = Text(b, font=FONT, weight=BOLD, font_size=FS, color=C_GOLD)
            if t.width > col_w[j] - 0.18:
                t.scale((col_w[j] - 0.18) / t.width)
            t.move_to([merkez[j], y, 0])
            hdr.add(t)
        g.add(hdr)
        cz = Line([-toplam / 2, y - 0.30, 0], [toplam / 2, y - 0.30, 0],
                  color=RULE, stroke_width=2)
        g.add(cz)

        satir_gruplari = []
        yy = y - 0.30
        for i, row in enumerate(veri):
            yy -= 0.36
            son_satir = (i == len(veri) - 1)
            rg = VGroup()
            for j, c in enumerate(row):
                if j == 0:
                    renk, wgt = (C_GOLD if son_satir else INK), BOLD
                else:
                    val = float(c.replace(",", "."))
                    renk = C_OK if val < 1.0 else (C_DUT_SIG if val < 2.5
                                                   else (C_WARN if val < 8 else C_DUT))
                    wgt = BOLD if son_satir else NORMAL
                t = Text(c, font=FONT, weight=wgt, font_size=FS, color=renk)
                t.move_to([merkez[j], yy, 0])
                rg.add(t)
            g.add(rg)
            satir_gruplari.append(rg)

        y_hdr = y
        y_son = yy
        g.shift(UP * (1.52 - (y_hdr + 0.40)))
        y_hdr += (1.52 - (y_hdr + 0.40))
        y_son += (1.52 - (y_hdr + 0.40)) * 0  # g ile birlikte kaydı

        self.play(FadeIn(hdr), Create(cz), run_time=0.8)
        self.play(LaggedStart(*[FadeIn(r, shift=RIGHT * 0.18)
                                for r in satir_gruplari], lag_ratio=0.16),
                  run_time=2.6)
        self.wait(1.0)

        # ---- ölçüm bandı içi / dışı ayrımı ----
        sol = merkez[1] - col_w[1] / 2
        sag_ic = merkez[4] + col_w[4] / 2
        sag_dis = merkez[6] + col_w[6] / 2
        ust = hdr.get_top()[1] + 0.14
        altk = satir_gruplari[-1].get_bottom()[1] - 0.16

        def bant(x0, x1, renk, etiket):
            r = Rectangle(width=x1 - x0, height=ust - altk,
                          stroke_width=0, fill_color=renk, fill_opacity=0.10)
            r.move_to([(x0 + x1) / 2, (ust + altk) / 2, 0])
            t = Text(etiket, font=FONT, weight=BOLD, font_size=17, color=renk)
            t.next_to(r, UP, buff=0.09)
            return VGroup(r, t)

        ic = bant(sol, sag_ic, C_OK, "LPF geçiş bandı içi")
        dis = bant(sag_ic, sag_dis, C_WARN, "ölçüm bandı dışı")
        self.play(FadeIn(ic), FadeIn(dis), run_time=1.1)
        self.wait(1.2)

        son_vurgu = SurroundingRectangle(satir_gruplari[-1], color=C_GOLD,
                                         stroke_width=2.2, buff=0.12,
                                         corner_radius=0.08)
        self.play(Create(son_vurgu), run_time=0.7)

        notlar = VGroup(
            madde("20.000 iterasyonda 10 kHz altındaki bütün bantlarda "
                  "MAE 0,16 – 0,38 dB", C_OK, fs=18, w=12.2),
            madde("10–100 kHz'de 2,28 dB, 100–467 kHz'de 2,53 dB kalıyor: DUT "
                  "periodogramı filtresiz olduğu için bu fark ölçüm bandının dışında",
                  C_WARN, fs=18, w=12.2),
            madde("1–10 kHz bandı 18,88 dB'den 0,28 dB'ye indi — ölçüm bandı "
                  "içinde yakınsama açıkça sürüyor", C_DUT_SIG, fs=18, w=12.2),
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.22)
        notlar.to_edge(DOWN, buff=0.16).to_edge(LEFT, buff=0.6)
        self.play(LaggedStart(*[FadeIn(n, shift=RIGHT * 0.2) for n in notlar],
                              lag_ratio=0.3), run_time=2.2)
        self.wait(2.6)
