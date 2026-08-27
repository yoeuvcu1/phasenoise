"""
Ortak tema, renk paleti ve yardımcı bileşenler.
Rapordaki eğri renk kodu korunur: Cross-PSD = mavi (düz), gerçek DUT = kırmızı (kesikli).
"""
from manim import *
import numpy as np

# ---------------- RENK PALETİ ----------------
BG          = "#0A0E1A"   # arka plan
INK         = "#E8EDF7"   # birincil metin
INK_DIM     = "#8A97B0"   # ikincil metin
RULE        = "#243049"   # ayraç / ızgara

C_CROSS     = "#4F8DFD"   # Cross-PSD kestirimi  (rapor: mavi düz)
C_DUT       = "#FF5A5A"   # gerçek DUT           (rapor: kırmızı kesikli)
C_DUT_SIG   = "#22D3EE"   # DUT sinyali / fazörü
C_REF1      = "#FBBF24"   # Referans 1
C_REF2      = "#C084FC"   # Referans 2
C_OK        = "#34D399"   # olumlu vurgu
C_WARN      = "#FB923C"   # uyarı vurgusu
C_GOLD      = "#F5C542"   # başlık vurgusu

FONT = "Avenir Next"
MONO = "SF Mono"

# ---------------- TİPOGRAFİ ----------------
def H1(s, size=44, color=INK, weight=BOLD):
    return Text(s, font=FONT, weight=weight, font_size=size, color=color)

def H2(s, size=30, color=INK, weight=MEDIUM):
    return Text(s, font=FONT, weight=weight, font_size=size, color=color)

def P(s, size=24, color=INK_DIM, weight=NORMAL):
    return Text(s, font=FONT, weight=weight, font_size=size, color=color)

def Small(s, size=19, color=INK_DIM):
    return Text(s, font=FONT, weight=NORMAL, font_size=size, color=color)

def Num(s, size=34, color=C_GOLD):
    return Text(s, font=FONT, weight=BOLD, font_size=size, color=color)


class Slide(Scene):
    """Ortak arka plan + başlık şeridi olan temel sahne."""
    bolum = ""      # üst sol köşedeki bölüm etiketi
    baslik = ""     # sahne başlığı

    def setup(self):
        self.camera.background_color = BG
        self.chrome = VGroup()

    def kur_baslik(self, baslik=None, bolum=None, anim=True):
        baslik = baslik if baslik is not None else self.baslik
        bolum  = bolum  if bolum  is not None else self.bolum

        parts = VGroup()
        if bolum:
            tag = Text(bolum, font=FONT, weight=BOLD, font_size=17, color=C_GOLD)
            tag.to_corner(UL, buff=0.45)
            parts.add(tag)
        t = H1(baslik, size=38)
        if t.width > config.frame_width - 1.5:
            t.set(width=config.frame_width - 1.5)
        t.to_edge(UP, buff=0.85).to_edge(LEFT, buff=0.7)
        line = Line(LEFT, RIGHT, color=RULE, stroke_width=2)
        line.set_width(config.frame_width - 1.4)
        line.next_to(t, DOWN, buff=0.28).to_edge(LEFT, buff=0.7)
        parts.add(t, line)
        self.chrome = parts
        if anim:
            self.play(LaggedStart(*[FadeIn(m, shift=DOWN*0.15) for m in parts],
                                  lag_ratio=0.15), run_time=0.9)
        else:
            self.add(parts)
        return parts

    def govde(self):
        """Başlık altındaki kullanılabilir alanın üst kenarı."""
        return self.chrome[-1].get_bottom()[1] - 0.35


# ---------------- YARDIMCI BİLEŞENLER ----------------
def kutu(label, w=2.6, h=0.95, color=INK, fill=None, fs=21, weight=MEDIUM,
         radius=0.14, sw=2.4):
    """Blok diyagram kutusu."""
    r = RoundedRectangle(width=w, height=h, corner_radius=radius,
                         stroke_color=color, stroke_width=sw,
                         fill_color=fill if fill else BG,
                         fill_opacity=1.0 if fill else 0.85)
    txt = Text(label, font=FONT, weight=weight, font_size=fs, color=INK)
    if txt.width > w - 0.3:
        txt.scale((w - 0.3) / txt.width)
    txt.move_to(r.get_center())
    g = VGroup(r, txt)
    g.kutu_govde = r
    return g


def ok(a, b, color=INK_DIM, sw=3.0, tip=0.2, buff=0.12):
    return Arrow(a, b, color=color, stroke_width=sw,
                 max_tip_length_to_length_ratio=0.28,
                 tip_length=tip, buff=buff)


def madde(metin, renk=C_GOLD, fs=24, w=10.5):
    """Renkli işaretli madde satırı."""
    dot = Dot(radius=0.055, color=renk)
    t = Text(metin, font=FONT, font_size=fs, color=INK_DIM,
             line_spacing=0.9)
    if t.width > w:
        t.scale(w / t.width)
    dot.next_to(t, LEFT, buff=0.28).align_to(t, UP).shift(DOWN*0.14)
    return VGroup(dot, t)


def maddeler(satirlar, renk=C_GOLD, fs=24, buff=0.42, w=10.5):
    g = VGroup(*[madde(s, renk, fs, w) for s in satirlar])
    g.arrange(DOWN, aligned_edge=LEFT, buff=buff)
    return g


def rozet(metin, renk=C_GOLD, fs=22, pad=0.22):
    """Sayısal sonuçlar için çerçeveli rozet."""
    t = Text(metin, font=FONT, weight=BOLD, font_size=fs, color=renk)
    r = RoundedRectangle(width=t.width + 2*pad, height=t.height + 1.5*pad,
                         corner_radius=0.12, stroke_color=renk,
                         stroke_width=2, fill_color=renk, fill_opacity=0.10)
    r.move_to(t.get_center())
    return VGroup(r, t)


def tablo(basliklar, satirlar, fs=20, col_w=None, satir_h=0.52,
          basmalik_renk=C_GOLD, vurgu_satir=None, hiza=None):
    """
    Sütunları gerçekten hizalanmış tablo. Hücreler mutlak x konumlarına
    yerleştirilir, satırlar yalnız y ekseninde istiflenir.
    hiza: sütun başına "c" (orta) veya "l" (sola dayalı); varsayılan hepsi orta.
    """
    ncol = len(basliklar)
    if col_w is None:
        col_w = [2.4] * ncol
    if hiza is None:
        hiza = ["c"] * ncol
    toplam = sum(col_w)
    # sütun merkezleri, tablo x=0'da ortalanacak biçimde
    merkez = []
    kenar = []
    acc = -toplam / 2.0
    for w in col_w:
        kenar.append(acc)
        merkez.append(acc + w / 2.0)
        acc += w

    def hucre(metin, j, renk, wgt):
        t = Text(str(metin), font=FONT, weight=wgt, font_size=fs, color=renk)
        if t.width > col_w[j] - 0.25:
            t.scale((col_w[j] - 0.25) / t.width)
        if hiza[j] == "l":
            t.move_to([kenar[j] + 0.12 + t.width / 2, 0, 0])
        else:
            t.move_to([merkez[j], 0, 0])
        return t

    g = VGroup()
    y = 0.0
    hdr = VGroup(*[hucre(b, j, basmalik_renk, BOLD)
                   for j, b in enumerate(basliklar)])
    for m in hdr:
        m.set_y(y)
    g.add(hdr)

    y -= 0.42
    cizgi = Line([-toplam / 2, y, 0], [toplam / 2, y, 0],
                 color=RULE, stroke_width=2)
    g.add(cizgi)

    y -= 0.20
    for i, row in enumerate(satirlar):
        vurgulu = (vurgu_satir is not None and i == vurgu_satir)
        renk = INK if vurgulu else INK_DIM
        wgt = BOLD if vurgulu else NORMAL
        y -= satir_h
        rg = VGroup(*[hucre(c, j, renk, wgt) for j, c in enumerate(row)])
        for m in rg:
            m.set_y(y)
        g.add(rg)
    return g


# ---------------- SİNYAL ÜRETİMİ ----------------
def guc_yasasi_faz(n, rms, egim=3.0, seed=0):
    """PSD ~ 1/f^egim olan faz gürültüsü dizisi (koddaki yöntemin aynısı)."""
    rng = np.random.default_rng(seed)
    if n % 2:
        n += 1
    w = rng.standard_normal(n)
    X = np.fft.fft(w)
    fb = np.concatenate([np.arange(0, n//2 + 1), np.arange(n//2 - 1, 0, -1)]).astype(float)
    fb[0] = 1.0
    H = 1.0 / np.sqrt(fb ** egim)      # genlik şekillendirme -> PSD 1/f^egim
    H[0] = 0.0
    x = np.real(np.fft.ifft(X * H))
    x -= x.mean()
    x /= np.sqrt(np.mean(x**2))
    return rms * x


# ---------------- FAZ GÜRÜLTÜSÜ GRAFİĞİ ----------------
import pickle as _pickle
import os as _os

_VERI = None


def sweep_verisi():
    """veri/sweep.pkl içindeki önceden hesaplanmış tarama sonuçlarını döndürür."""
    global _VERI
    if _VERI is None:
        yol = _os.path.join(_os.path.dirname(_os.path.abspath(__file__)),
                            "veri", "sweep.pkl")
        with open(yol, "rb") as fh:
            _VERI = _pickle.load(fh)
    return _VERI


def ssb_ekseni(x_range=(0, 6, 1), y_range=(-170, -10, 20),
               x_length=8.4, y_length=4.4, eksen_yazi=True):
    """
    Offset frekansı (log Hz) - dBc/Hz ekseni.
    y aralığı 0'ı içermediği için manim x eksenini üste koyar; burada görünür
    bir kopya alta taşınır ve orijinal x ekseni gizlenir (c2p bozulmaz).
    Dönüş: (ax, gorsel) — gorsel alt eksen ve yazıları içerir, sahneye eklenir.
    """
    ax = Axes(
        x_range=list(x_range), y_range=list(y_range),
        x_length=x_length, y_length=y_length,
        x_axis_config={"scaling": LogBase(10),
                       "numbers_to_include":
                           [10 ** e for e in range(int(x_range[0]),
                                                   int(x_range[1]) + 1)],
                       "font_size": 20, "stroke_color": RULE,
                       "stroke_width": 1.8, "include_tip": False},
        y_axis_config={"numbers_to_include":
                           list(range(int(y_range[0]) + 10,
                                      int(y_range[1]) + 1, 40)),
                       "font_size": 20, "stroke_color": RULE,
                       "stroke_width": 1.8, "include_tip": False},
    )
    ax.y_axis.set_color(RULE)
    for n in getattr(ax.y_axis, "numbers", []):
        n.set_color(INK_DIM)

    alt_eksen = ax.x_axis.copy()
    alt_eksen.set_color(RULE)
    for n in getattr(alt_eksen, "numbers", []):
        n.set_color(INK_DIM)
    # eksen ÇİZGİSİNİ hizala (etiketler dahil bbox merkezini değil)
    _x0 = 10.0 ** x_range[0]
    _hedef = ax.c2p(_x0, y_range[0])[1]
    _kaynak = alt_eksen.number_to_point(_x0)[1]
    alt_eksen.shift(UP * (_hedef - _kaynak))
    ax.x_axis.set_opacity(0)

    gorsel = VGroup(alt_eksen)
    if eksen_yazi:
        xl = Text("Offset Frekansı (Hz)", font=FONT, font_size=19, color=INK_DIM)
        xl.next_to(alt_eksen, DOWN, buff=0.26)
        yl = Text("Faz Gürültüsü (dBc/Hz)", font=FONT, font_size=19,
                  color=INK_DIM).rotate(PI / 2)
        yl.next_to(ax.y_axis, LEFT, buff=0.20)
        gorsel.add(xl, yl)
    return ax, gorsel


def ssb_egri(ax, f, L, renk, sw=3.0, kesikli=False, x_range=(0, 6),
             y_range=(-170, -10)):
    """Log-binlenmiş SSB eğrisini eksene çizer (eksen sınırlarına kırpar)."""
    import numpy as _np
    f = _np.asarray(f, dtype=float)
    L = _np.asarray(L, dtype=float)
    m = (f >= 10.0 ** x_range[0]) & (f <= 10.0 ** x_range[1])
    f, L = f[m], _np.clip(L[m], y_range[0] + 0.5, y_range[1] - 0.5)
    if len(f) < 2:
        return VMobject()
    pts = [ax.c2p(fi, li) for fi, li in zip(f, L)]
    mo = VMobject().set_points_smoothly(pts)
    if kesikli:
        mo = DashedVMobject(mo, num_dashes=int(len(pts) * 0.9), dashed_ratio=0.55)
    return mo.set_stroke(renk, sw)


def egri_lejandi(ogeler, fs=17):
    """[(renk, kesikli, etiket), ...] -> lejant VGroup."""
    g = VGroup()
    for renk, kesikli, etiket in ogeler:
        ln = Line(ORIGIN, RIGHT * 0.5).set_stroke(renk, 3.2)
        if kesikli:
            ln = DashedVMobject(ln, num_dashes=4, dashed_ratio=0.55)\
                .set_stroke(renk, 3.2)
        t = Text(etiket, font=FONT, font_size=fs, color=INK_DIM)
        g.add(VGroup(ln, t).arrange(RIGHT, buff=0.18))
    g.arrange(DOWN, aligned_edge=LEFT, buff=0.18)
    cerceve = RoundedRectangle(width=g.width + 0.45, height=g.height + 0.38,
                               corner_radius=0.1, stroke_color=RULE,
                               stroke_width=1.5, fill_color="#0E1524",
                               fill_opacity=0.9)
    cerceve.move_to(g.get_center())
    return VGroup(cerceve, g)
