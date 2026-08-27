#!/usr/bin/env python3
"""Bütün sahneleri paralel olarak render eder ve cikti/video altında toplar."""
import os, sys, json, shutil, subprocess, time
from concurrent.futures import ThreadPoolExecutor, as_completed

KOK = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, KOK)
from sahne_listesi import SAHNELER

MANIM = os.path.join(KOK, ".venv", "bin", "manim")
MEDIA = os.path.join(KOK, ".render")
CIKTI = os.path.join(KOK, "cikti", "video")
KALITE = sys.argv[1] if len(sys.argv) > 1 else "-qh"
PARALEL = int(sys.argv[2]) if len(sys.argv) > 2 else 4
KLASOR = {"-ql": "480p15", "-qm": "720p30", "-qh": "1080p60", "-qk": "2160p60"}[KALITE]

os.makedirs(CIKTI, exist_ok=True)


def render(i, dosya, sinif, baslik, medya=None):
    t0 = time.time()
    medya = medya or MEDIA
    p = subprocess.run(
        [MANIM, KALITE, "--disable_caching", "--media_dir", medya,
         os.path.join(KOK, "sahneler", dosya), sinif],
        capture_output=True, text=True, cwd=KOK)
    _ = medya
    if p.returncode != 0:
        return (i, sinif, None, p.stderr[-1500:], time.time() - t0)
    kaynak = os.path.join(medya, "videos", dosya[:-3], KLASOR, f"{sinif}.mp4")
    if not os.path.exists(kaynak):
        return (i, sinif, None, "cikti dosyasi bulunamadi", time.time() - t0)
    hedef = os.path.join(CIKTI, f"{i:02d}_{sinif}.mp4")
    shutil.copy2(kaynak, hedef)
    return (i, sinif, hedef, None, time.time() - t0)


def main():
    print(f"{len(SAHNELER)} sahne · kalite {KALITE} · {PARALEL} paralel iş\n")
    sonuc = {}
    with ThreadPoolExecutor(max_workers=PARALEL) as ex:
        isler = {ex.submit(render, i, d, c, b): (i, c)
                 for i, (d, c, b) in enumerate(SAHNELER, 1)}
        for f in as_completed(isler):
            i, sinif, hedef, hata, sure = f.result()
            if hata:
                print(f"  ✗ {i:02d} {sinif:24s} HATA ({sure:.0f}s)")
                print("     " + hata.strip().splitlines()[-1][:160])
            else:
                print(f"  ✓ {i:02d} {sinif:24s} {sure:6.0f}s")
            sonuc[i] = (sinif, hedef, hata)

    # LaTeX/paralel yarışlarından düşenleri seri olarak yeniden dene
    kalanlar = [(i, d, c, b) for i, (d, c, b) in enumerate(SAHNELER, 1)
                if not sonuc.get(i, (None, None))[1]]
    if kalanlar:
        print(f"\n{len(kalanlar)} sahne seri olarak yeniden deneniyor...")
        for i, d, c, b in kalanlar:
            i2, sinif, hedef, hata, sure = render(i, d, c, b)
            print(("  ✓ " if hedef else "  ✗ ") + f"{i:02d} {sinif:24s} {sure:6.0f}s")
            sonuc[i] = (sinif, hedef, hata)

    # manifest
    kayitlar = []
    for i, (d, c, b) in enumerate(SAHNELER, 1):
        sinif, hedef, hata = sonuc.get(i, (c, None, "render edilmedi"))
        if hedef:
            sure = subprocess.run(
                ["ffprobe", "-v", "error", "-show_entries", "format=duration",
                 "-of", "csv=p=0", hedef], capture_output=True, text=True).stdout.strip()
            kayitlar.append(dict(no=i, sinif=c, baslik=b,
                                 dosya=os.path.basename(hedef),
                                 sure=round(float(sure), 2)))
    with open(os.path.join(KOK, "cikti", "manifest.json"), "w") as fh:
        json.dump(kayitlar, fh, ensure_ascii=False, indent=2)

    basarili = sum(1 for v in sonuc.values() if v[1])
    toplam = sum(k["sure"] for k in kayitlar)
    print(f"\n{basarili}/{len(SAHNELER)} sahne hazır · toplam süre "
          f"{int(toplam//60)} dk {int(toplam%60)} sn")
    print(f"cikti: {CIKTI}")


if __name__ == "__main__":
    main()
