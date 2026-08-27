"""
Octave modelinin (phasedetector with cross correlation optimized) hafifletilmiş
numpy portu. Sunumdaki eğriler bu port ile üretilir; algoritma adımları birebir
aynıdır, yalnız N ve iterasyon sayıları sunum için küçültülmüştür.
"""
import numpy as np
from scipy.signal import butter, lfilter


def faz_gurultusu(n, rms, rng):
    """generate_phase_noise.m: beyaz gürültüyü 1/sqrt(f^3) ile şekillendirir."""
    w = rng.standard_normal(n)
    X = np.fft.fft(w)
    fb = np.concatenate([np.arange(0, n // 2 + 1),
                         np.arange(n // 2 - 1, 0, -1)]).astype(float)
    fb[0] = 1.0
    H = 1.0 / np.sqrt(fb ** 3)
    H[0] = 0.0
    x = np.real(np.fft.ifft(X * H))
    x -= x.mean()
    x /= np.sqrt(np.mean(x ** 2))
    return rms * x


def log_bin(f, P, nbin):
    """logbin_phase_noise.m: geometrik frekans, aritmetik lineer PSD ortalaması."""
    m = np.isfinite(f) & np.isfinite(P) & (f > 0) & (P >= 0)
    f, P = f[m], P[m]
    kenar = np.logspace(np.log10(f.min()), np.log10(f.max()), nbin + 1)
    idx = np.clip(np.searchsorted(kenar, f, side="right") - 1, 0, nbin - 1)
    fb, Pb = [], []
    for b in range(nbin):
        sel = idx == b
        if sel.any():
            fb.append(np.exp(np.mean(np.log(f[sel]))))
            Pb.append(np.mean(P[sel]))
    fb, Pb = np.array(fb), np.array(Pb)
    return fb, 10 * np.log10(0.5 * Pb + 1e-300)


def kosu(N=1 << 15, fs=1e6, f0=2e5, A=1.0, fc=5e4, order=4,
         s_dut=0.05, s_ref=0.05, M=100, nbin=100, settle=512, seed=0,
         tek_kanal=False):
    """
    run_simulation.m akışı: mikser -> LPF -> /K_pd -> asin -> DC silme ->
    Cross-PSD (kompleks ortalama). tek_kanal=True ise klasik faz detektörü
    (tek kanalın güç spektrumu, lineer ortalama) hesaplanır.
    """
    rng = np.random.default_rng(seed)
    t = np.arange(N) / fs
    tas = 2 * np.pi * f0 * t
    quad = tas + np.pi / 2
    K_pd = A ** 2 / 2

    b, a = butter(order, fc / (fs / 2), btype="low")
    Nc = N - settle
    nfft = 1 << int(np.ceil(np.log2(2 * Nc - 1)))
    npos = nfft // 2 + 1
    f = np.arange(npos) * fs / nfft

    S_cross = np.zeros(npos, dtype=complex)
    S_dut = np.zeros(npos)

    for _ in range(M):
        ph_d = faz_gurultusu(N, s_dut, rng)
        x_dut = A * np.cos(tas + ph_d)

        kanallar = []
        for _k in range(1 if tek_kanal else 2):
            ph_r = faz_gurultusu(N, s_ref, rng)
            x_ref = A * np.cos(quad + ph_r)
            y = lfilter(b, a, x_dut * x_ref) / K_pd
            y = np.arcsin(np.clip(y, -1.0, 1.0))[settle:]
            kanallar.append(y - y.mean())

        if tek_kanal:
            X = np.fft.rfft(kanallar[0], nfft)
            P = (X * np.conj(X)).real / (fs * Nc)
            P[1:-1] *= 2
            S_cross += P
        else:
            X1 = np.fft.rfft(kanallar[0], nfft)
            X2 = np.fft.rfft(kanallar[1], nfft)
            C = X1 * np.conj(X2) / (fs * Nc)
            C[1:-1] *= 2
            S_cross += C

        d = ph_d[settle:]
        d = d - d.mean()
        D = np.fft.rfft(d, nfft)
        Pd = (D * np.conj(D)).real / (fs * Nc)
        Pd[1:-1] *= 2
        S_dut += Pd

    S_cross /= M
    S_dut /= M
    v = f > 0
    fc_b, L_cross = log_bin(f[v], np.abs(S_cross[v]), nbin)
    fd_b, L_dut = log_bin(f[v], S_dut[v], nbin)
    return dict(f_cross=fc_b, L_cross=L_cross, f_dut=fd_b, L_dut=L_dut)


def mae(r, n=200):
    """run_simulation.m ile aynı MAE: ortak bantta 200 log noktaya interpolasyon."""
    lo = max(r["f_cross"].min(), r["f_dut"].min())
    hi = min(r["f_cross"].max(), r["f_dut"].max())
    fk = np.logspace(np.log10(lo), np.log10(hi), n)
    a = np.interp(np.log10(fk), np.log10(r["f_cross"]), r["L_cross"])
    b = np.interp(np.log10(fk), np.log10(r["f_dut"]), r["L_dut"])
    return float(np.mean(np.abs(a - b)))


def kosu_checkpointli(kontrol_M, N=1 << 16, fs=1e6, f0=2e5, A=1.0, fc=5e4,
                      order=4, s_dut=0.02, s_ref=0.1, nbin=100, settle=512,
                      seed=0, tek_kanal=False):
    """
    Tek bir birikimli koşudan birden çok M değeri için eğri döndürür.
    Yakınsamayı doğru temsil eder: M büyüdükçe aynı akış üzerine eklenir.
    """
    rng = np.random.default_rng(seed)
    t = np.arange(N) / fs
    tas = 2 * np.pi * f0 * t
    quad = tas + np.pi / 2
    K_pd = A ** 2 / 2
    b, a = butter(order, fc / (fs / 2), btype="low")
    Nc = N - settle
    nfft = 1 << int(np.ceil(np.log2(2 * Nc - 1)))
    npos = nfft // 2 + 1
    f = np.arange(npos) * fs / nfft

    S_cross = np.zeros(npos, dtype=complex)
    S_dut = np.zeros(npos)
    cikti = {}
    hedefler = sorted(kontrol_M)

    for m in range(1, max(hedefler) + 1):
        ph_d = faz_gurultusu(N, s_dut, rng)
        x_dut = A * np.cos(tas + ph_d)
        kanallar = []
        for _k in range(1 if tek_kanal else 2):
            ph_r = faz_gurultusu(N, s_ref, rng)
            y = lfilter(b, a, x_dut * (A * np.cos(quad + ph_r))) / K_pd
            y = np.arcsin(np.clip(y, -1.0, 1.0))[settle:]
            kanallar.append(y - y.mean())

        if tek_kanal:
            X = np.fft.rfft(kanallar[0], nfft)
            P = (X * np.conj(X)).real / (fs * Nc)
            P[1:-1] *= 2
            S_cross += P
        else:
            X1 = np.fft.rfft(kanallar[0], nfft)
            X2 = np.fft.rfft(kanallar[1], nfft)
            C = X1 * np.conj(X2) / (fs * Nc)
            C[1:-1] *= 2
            S_cross += C

        d = ph_d[settle:] - ph_d[settle:].mean()
        D = np.fft.rfft(d, nfft)
        Pd = (D * np.conj(D)).real / (fs * Nc)
        Pd[1:-1] *= 2
        S_dut += Pd

        if m in kontrol_M:
            v = f > 0
            fc_b, L_c = log_bin(f[v], np.abs(S_cross[v] / m), nbin)
            fd_b, L_d = log_bin(f[v], S_dut[v] / m, nbin)
            cikti[m] = dict(f_cross=fc_b, L_cross=L_c, f_dut=fd_b, L_dut=L_d)
    return cikti
