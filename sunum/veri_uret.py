"""Sunumdaki bütün parametrik tarama eğrilerini önceden hesaplar."""
import numpy as np, pickle, time, os
import simulasyon as S

CIK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "veri")
os.makedirs(CIK, exist_ok=True)
N = 1 << 16
veri = {}
t0 = time.time()

# 1) LPF kesim frekansı taraması
print("LPF taramasi...", flush=True)
veri["lpf"] = {}
for i, fc in enumerate([1e3, 5e3, 1e4, 2.5e4, 5e4, 1e5, 2e5, 3e5]):
    r = S.kosu(N=N, fc=fc, M=100, seed=100 + i)
    veri["lpf"][fc] = (r, S.mae(r))
    print(f"  fc={fc/1e3:g} kHz  MAE={veri['lpf'][fc][1]:.3f}", flush=True)

# 2) DUT RMS taraması
print("DUT RMS taramasi...", flush=True)
veri["dut"] = {}
for i, sd in enumerate([0.01, 0.02, 0.05, 0.1, 0.2, 0.5]):
    r = S.kosu(N=N, s_dut=sd, s_ref=0.05, M=100, seed=200 + i)
    veri["dut"][sd] = (r, S.mae(r))
    print(f"  sigma_DUT={sd}  MAE={veri['dut'][sd][1]:.3f}", flush=True)

# 3) Referans RMS taraması
print("Ref RMS taramasi...", flush=True)
veri["ref"] = {}
for i, sr in enumerate([0.01, 0.02, 0.05, 0.1, 0.2, 0.5]):
    r = S.kosu(N=N, s_dut=0.05, s_ref=sr, M=100, seed=300 + i)
    veri["ref"][sr] = (r, S.mae(r))
    print(f"  sigma_ref={sr}  MAE={veri['ref'][sr][1]:.3f}", flush=True)

# 4) Log-bin sayısı
print("Bin taramasi...", flush=True)
veri["bin"] = {}
for i, nb in enumerate([25, 50, 100, 200]):
    r = S.kosu(N=N, nbin=nb, M=100, seed=400 + i)
    veri["bin"][nb] = (r, S.mae(r))
    print(f"  bin={nb}  MAE={veri['bin'][nb][1]:.3f}", flush=True)

# 5) İterasyon yakınsaması (tek birikimli koşu, rapordaki koşullar)
print("Iterasyon yakinsamasi...", flush=True)
kont = [1, 5, 20, 50, 120, 300, 700, 1500, 3000]
veri["iter"] = S.kosu_checkpointli(kont, N=N, s_dut=0.02, s_ref=0.1,
                                   fc=5e4, seed=500)
for m in kont:
    print(f"  M={m}  MAE={S.mae(veri['iter'][m]):.3f}", flush=True)

# 6) Tek kanal PD  vs  Cross-correlation
print("PD vs Cross...", flush=True)
veri["pdvscross"] = {}
for i, sr in enumerate([0.01, 0.10]):
    rp = S.kosu(N=N, s_dut=0.05, s_ref=sr, M=200, seed=600 + i, tek_kanal=True)
    rc = S.kosu(N=N, s_dut=0.05, s_ref=sr, M=200, seed=650 + i, tek_kanal=False)
    veri["pdvscross"][sr] = dict(pd=(rp, S.mae(rp)), cross=(rc, S.mae(rc)))
    print(f"  ref={sr}  PD MAE={S.mae(rp):.3f}  Cross MAE={S.mae(rc):.3f}",
          flush=True)

with open(os.path.join(CIK, "sweep.pkl"), "wb") as fh:
    pickle.dump(veri, fh)
print(f"\nTamamlandi: {time.time()-t0:.1f} s -> {CIK}/sweep.pkl")
