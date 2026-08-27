#!/usr/bin/env python3
"""cikti/sunum.html — klavyeyle gezilen, notlu sunum kabuğunu üretir."""
import os, sys, json

KOK = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, KOK)
from notlar import NOTLAR

man = json.load(open(os.path.join(KOK, "cikti", "manifest.json")))
for k in man:
    k["not"] = NOTLAR.get(k["sinif"], "")
veri = json.dumps(man, ensure_ascii=False)
toplam = sum(k["sure"] for k in man)

HTML = """<!doctype html>
<html lang="tr"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>İki Kanallı Cross-PSD ile Faz Gürültüsü Ölçümü — Sunum</title>
<style>
  :root{
    --bg:#0A0E1A; --ink:#E8EDF7; --dim:#8A97B0; --rule:#243049;
    --gold:#F5C542; --cyan:#22D3EE; --ok:#34D399;
    --font:"Avenir Next","Helvetica Neue",-apple-system,system-ui,sans-serif;
  }
  *{box-sizing:border-box;margin:0;padding:0}
  html,body{height:100%;background:var(--bg);color:var(--ink);font-family:var(--font);overflow:hidden}
  #sahne{position:fixed;inset:0;display:flex;align-items:center;justify-content:center;background:#000}
  video{width:100%;height:100%;object-fit:contain;background:#000}

  /* üst bar */
  #ust{position:fixed;top:0;left:0;right:0;padding:12px 20px;display:flex;
       align-items:center;justify-content:flex-end;gap:14px;z-index:20;
       background:linear-gradient(180deg,rgba(10,14,26,.55),rgba(10,14,26,0));
       transition:opacity .35s;pointer-events:none}
  #ust.gizle{opacity:0}
  #no{font-weight:700;font-size:13px;color:var(--gold);letter-spacing:.06em;
      background:rgba(245,197,66,.12);border:1px solid rgba(245,197,66,.35);
      border-radius:6px;padding:4px 10px;white-space:nowrap}
  #baslik{font-size:15px;color:var(--dim);font-weight:500}

  /* ilerleme */
  #ilerleme{position:fixed;left:0;right:0;bottom:0;height:3px;background:rgba(255,255,255,.07);z-index:25}
  #dolu{height:100%;width:0;background:linear-gradient(90deg,var(--cyan),var(--gold));transition:width .15s linear}

  /* alt bar */
  #alt{position:fixed;left:0;right:0;bottom:0;padding:16px 22px 20px;z-index:20;
       display:flex;align-items:flex-end;gap:18px;
       background:linear-gradient(0deg,rgba(10,14,26,.94),rgba(10,14,26,0));
       transition:opacity .3s}
  #alt.gizle{opacity:0;pointer-events:none}
  body.temiz #ust,body.temiz #alt{opacity:0;pointer-events:none}
  #notmetni{flex:1;font-size:14px;line-height:1.55;color:var(--dim);max-width:70ch}
  #notmetni b{color:var(--ink);font-weight:600}
  .btn{background:rgba(255,255,255,.06);border:1px solid var(--rule);color:var(--ink);
       border-radius:8px;padding:8px 13px;font-family:var(--font);font-size:13px;
       cursor:pointer;white-space:nowrap;transition:.15s}
  .btn:hover{background:rgba(255,255,255,.12);border-color:var(--dim)}
  .btn.aktif{border-color:var(--gold);color:var(--gold);background:rgba(245,197,66,.1)}
  #kontrol{display:flex;gap:8px;align-items:center}
  #sayac{font-size:12px;color:var(--dim);font-variant-numeric:tabular-nums;min-width:78px;text-align:right}

  /* içindekiler */
  #liste{position:fixed;inset:0;background:rgba(10,14,26,.985);z-index:40;
         padding:46px 54px;overflow-y:auto;display:none}
  #liste.acik{display:block}
  #liste h2{font-size:20px;margin-bottom:4px}
  #liste .altyazi{font-size:13px;color:var(--dim);margin-bottom:26px}
  .izgara{display:grid;grid-template-columns:repeat(auto-fill,minmax(310px,1fr));gap:9px}
  .oge{display:flex;gap:12px;align-items:center;padding:10px 13px;border:1px solid var(--rule);
       border-radius:9px;cursor:pointer;transition:.15s;background:rgba(255,255,255,.02)}
  .oge:hover{border-color:var(--cyan);background:rgba(34,211,238,.07)}
  .oge.simdi{border-color:var(--gold);background:rgba(245,197,66,.1)}
  .oge .n{font-size:12px;font-weight:700;color:var(--gold);min-width:22px}
  .oge .t{font-size:13.5px;color:var(--ink);line-height:1.35}
  .oge .s{font-size:11px;color:var(--dim);margin-left:auto;font-variant-numeric:tabular-nums}

  /* yardım */
  #yardim{position:fixed;right:22px;top:60px;z-index:30;background:rgba(16,23,40,.96);
          border:1px solid var(--rule);border-radius:10px;padding:16px 18px;display:none;font-size:13px}
  #yardim.acik{display:block}
  #yardim div{display:flex;gap:12px;margin:6px 0;color:var(--dim)}
  kbd{background:rgba(255,255,255,.08);border:1px solid var(--rule);border-bottom-width:2px;
      border-radius:5px;padding:1px 7px;font-family:ui-monospace,monospace;font-size:11.5px;color:var(--ink)}
</style></head><body>

<div id="sahne"><video id="v" preload="auto" playsinline></video></div>
<div id="ust"><span id="baslik"></span><span id="no"></span></div>

<div id="alt">
  <div id="notmetni"></div>
  <div id="kontrol">
    <button class="btn" id="bOnceki">◀</button>
    <button class="btn" id="bOynat">⏸</button>
    <button class="btn" id="bSonraki">▶</button>
    <button class="btn" id="bOto">otomatik: kapalı</button>
    <button class="btn" id="bListe">içindekiler</button>
    <span id="sayac"></span>
  </div>
</div>

<div id="ilerleme"><div id="dolu"></div></div>

<div id="yardim">
  <div><kbd>→</kbd><kbd>Space</kbd><span>sonraki sahne</span></div>
  <div><kbd>←</kbd><span>önceki sahne</span></div>
  <div><kbd>R</kbd><span>sahneyi baştan oynat</span></div>
  <div><kbd>P</kbd><span>duraklat / devam</span></div>
  <div><kbd>A</kbd><span>otomatik ilerleme</span></div>
  <div><kbd>O</kbd><span>içindekiler</span></div>
  <div><kbd>N</kbd><span>notları gizle</span></div>
  <div><kbd>F</kbd><span>tam ekran</span></div>
  <div><kbd>?</kbd><span>bu yardım</span></div>
</div>

<div id="liste">
  <h2>İçindekiler</h2>
  <div class="altyazi">__TOPLAM__ · bir sahneye atlamak için tıklayın · kapatmak için <kbd>O</kbd> veya <kbd>Esc</kbd></div>
  <div class="izgara" id="izgara"></div>
</div>

<script>
const S = __VERI__;
const v = document.getElementById('v');
let i = 0, oto = false, notGizli = false;

const $ = id => document.getElementById(id);

function mmss(s){const m=Math.floor(s/60);const k=Math.round(s%60);return m+':'+String(k).padStart(2,'0');}

function yukle(n, oynat=true){
  i = Math.max(0, Math.min(S.length-1, n));
  const s = S[i];
  v.src = 'video/' + s.dosya;
  $('no').textContent = String(s.no).padStart(2,'0') + ' / ' + S.length;
  $('baslik').textContent = s.baslik;
  $('notmetni').innerHTML = s['not'] ? '<b>Not:</b> ' + s['not'] : '';
  $('sayac').textContent = mmss(s.sure);
  document.querySelectorAll('.oge').forEach((o,k)=>o.classList.toggle('simdi',k===i));
  if(oynat){ v.play().catch(()=>{}); }
  guncelleOynat();
}

function guncelleOynat(){ $('bOynat').textContent = v.paused ? '▶︎' : '⏸'; }

function sonraki(){ if(i < S.length-1) yukle(i+1); }
function onceki(){ if(i > 0) yukle(i-1); }

v.addEventListener('timeupdate', ()=>{
  if(v.duration) $('dolu').style.width = (v.currentTime/v.duration*100)+'%';
});
v.addEventListener('ended', ()=>{ if(oto) sonraki(); });
v.addEventListener('play', guncelleOynat);
v.addEventListener('pause', guncelleOynat);

// fare hareketsizken kontrolleri gizle
let sayacGizle;
function uyandir(){
  document.body.classList.remove('temiz');
  clearTimeout(sayacGizle);
  sayacGizle = setTimeout(()=>{ if(!$('liste').classList.contains('acik'))
                                  document.body.classList.add('temiz'); }, 2800);
}
document.addEventListener('mousemove', uyandir);
document.addEventListener('keydown', uyandir);
uyandir();

document.addEventListener('keydown', e=>{
  if(e.key==='Escape'){ $('liste').classList.remove('acik'); $('yardim').classList.remove('acik'); return; }
  switch(e.key){
    case 'ArrowRight': case ' ': case 'PageDown': e.preventDefault(); sonraki(); break;
    case 'ArrowLeft': case 'PageUp': e.preventDefault(); onceki(); break;
    case 'r': case 'R': v.currentTime=0; v.play(); break;
    case 'p': case 'P': v.paused ? v.play() : v.pause(); break;
    case 'a': case 'A': oto=!oto; $('bOto').textContent='otomatik: '+(oto?'açık':'kapalı');
                        $('bOto').classList.toggle('aktif',oto); break;
    case 'o': case 'O': $('liste').classList.toggle('acik'); break;
    case 'n': case 'N': notGizli=!notGizli; $('alt').classList.toggle('gizle',notGizli);
                        $('ust').classList.toggle('gizle',notGizli); break;
    case 'f': case 'F': document.fullscreenElement ? document.exitFullscreen()
                                                   : document.documentElement.requestFullscreen(); break;
    case '?': $('yardim').classList.toggle('acik'); break;
    case 'Home': yukle(0); break;
    case 'End': yukle(S.length-1); break;
  }
});

$('bSonraki').onclick = sonraki;
$('bOnceki').onclick = onceki;
$('bOynat').onclick = ()=> v.paused ? v.play() : v.pause();
$('bOto').onclick = ()=>{ oto=!oto; $('bOto').textContent='otomatik: '+(oto?'açık':'kapalı');
                          $('bOto').classList.toggle('aktif',oto); };
$('bListe').onclick = ()=> $('liste').classList.toggle('acik');

const iz = $('izgara');
S.forEach((s,k)=>{
  const d = document.createElement('div');
  d.className='oge';
  d.innerHTML = `<span class="n">${String(s.no).padStart(2,'0')}</span>
                 <span class="t">${s.baslik}</span>
                 <span class="s">${mmss(s.sure)}</span>`;
  d.onclick = ()=>{ $('liste').classList.remove('acik'); yukle(k); };
  iz.appendChild(d);
});

yukle(0, false);
uyandir();
</script></body></html>
"""

html = (HTML.replace("__VERI__", veri)
            .replace("__TOPLAM__", f"{len(man)} sahne · toplam "
                                   f"{int(toplam//60)} dk {int(toplam%60)} sn"))
yol = os.path.join(KOK, "cikti", "sunum.html")
open(yol, "w", encoding="utf-8").write(html)
print(f"yazıldı: {yol}  ({len(html)//1024} KB)")
