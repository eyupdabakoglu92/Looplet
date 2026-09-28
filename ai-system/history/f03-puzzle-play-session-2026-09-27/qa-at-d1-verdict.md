# F03 — puzzle-play-session: QA Raporu (F03-QA-D1 — Loop Glass Play, final görsel QA)

QA turu: 2026-09-28 · Görev: F03-QA-D1 · QA Stage: final · QA Scope: client-only · Release Scope: none · Visual Scope: existing-parity
Doğrulanan revizyon: HEAD `5798c70`, temiz ağaç. `app/`, `packages/`, `tools/`, `pubspec.lock`, `melos.yaml` teslim commit'i `b8b5f60` ile birebir aynı (`git diff --stat b8b5f60 HEAD -- …` boş).
Önceki rapor (2026-09-21, HEAD 5be4dc6, Approved with Notes; yalnız davranış/erişilebilirlik) byte-for-byte arşivde: [history/f03-puzzle-play-session-2026-09-27/qa-before-phase-d1.md](../../history/f03-puzzle-play-session-2026-09-27/qa-before-phase-d1.md).
Kanıt klasörü: [qa/d1/](qa/d1/) — ekran görüntüleri `QA-*`, videolar `QV-*`, ölçüm/probe kayıtları `QM-*`, QA'ya ait araçlar `qa/d1/src/` (`qa-frames.swift`, `qa-pixels.swift`).

---

## 0. QA Execution Plan

* **Stage / Scope:** final / client-only; release scope yok (architecture §17).
* **Modüller + tetikleyici:**
  * `core` — her tur;
  * `client-ui` — Flutter `/play` yüzeyi, header/back, loading/error, HUD state'leri, F05 overlay;
  * `visual-quality` — Visual Scope `existing-parity`, gate Ready for QA;
  * `stateful-flow` — snapshot write-through, kill/relaunch resume, tutorial ack/re-show, lifecycle.
* **Regression Depth: full** (Tech Lead planı): bütün Play yüzeyi yeniden çizildi, cross-feature F05 overlay ve paylaşılan design-layer bileşenleri değişti, won geometrisi taşındı.
* **Evidence Reuse: allowed**, fingerprint geçerli (E03). Yine de otomatik suite'ler ve integration bu turda QA tarafından **yeniden çalıştırıldı** (E01, E02). Frontend'in runtime yakalamaları yalnız karşılaştırma girdisidir; skor ve verdict yalnız QA'nın kendi runtime kanıtına dayanır.
* **Canonical target / runtime sınıfı:** iOS Simulator 18.6 — iPhone 16 `D0011CE7` (birincil), 16e `6DBDFD97`, 16 Pro Max `02FDE776`.
  * QA build: `flutter build ios --simulator --debug`, HEAD 5798c70, üç cihaza kuruldu (`App` binary SHA-1 `17125f5d0335…`).
  * State'e gerçek uygulama yoluyla gidildi: `design/src/seed-sim.sh` + Home CONTINUE.
  * Gesture'lar simülatör touch-path ile verildi.
  * Kanıt sınıfları: runtime-screenshot, runtime-video (`simctl io recordVideo`), piksel ölçümü.
* **Fail-fast checkpoint:** önce suite'ler + integration + build; hepsi yeşil olunca (E01–E04) runtime journey'lere geçildi.

## 1. Evidence Ledger

Tüm satırlar **EXECUTED THIS RUN** (QA, 2026-09-28, 5798c70 build, yukarıdaki üç simülatör). Yalnız E31–E32 kısmen REUSED (belirtildi). Ham ölçümler `qa/d1/QM-measurements.txt` ve `QM-*-probe.txt` içindedir.

| Evidence ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E01 | Statik analiz + unit/widget suite'leri + format | automated | `melos run analyze`; `melos run test`; `dart format --output=none --set-exit-if-changed app packages tools` | host, Flutter 3.32.8 / Dart 3.8.1 | analyze exit 0 (No issues); test exit 0 — app **405 passed / 0 failed / 0 skipped**, core 22, content 17, dictionary 32, authoring 25, engine 83, solver 23; format exit 0 | 5798c70 (app = b8b5f60); 2026-09-27T22:29Z | in-memory Drift, validator/asset override'ları (test dosyaları) |
| E02 | Cihaz üzerinde integration: gesture, 0 çift sayım, resume + tampered cache, lifecycle (paused mid-drag / mid-animation) | repeatable integration / runtime | `flutter test integration_test -d D0011CE7…` | iPhone 16 sim | **13 / 13 passed**, exit 0 (grup 1–4) | 5798c70; aynı oturum | in-memory DB; gerçek app kodu |
| E03 | Fingerprint | static | `git diff --stat b8b5f60 HEAD -- app packages tools pubspec.lock melos.yaml` | repo | boş | HEAD 5798c70 | — |
| E04 | QA build | build | `flutter build ios --simulator --debug`; `simctl install` ×3 | 3 sim | exit 0; üçü de kuruldu | 5798c70 | — |
| E05 | §11.5 (1)–(4) idle L5 geometri/renk | runtime-screenshot + ölçüm | CONTINUE → L5; `measure-d1` D1-00 ↔ `QA-16-01-idle-L5.png` | iPhone 16 | 16 özellik **max 0.67 pt**; token yamaları ΔE ≤ 1.48; tek sapma sağ-üst zemin ışığı ΔE 3.35 (bilinen LoopBackdrop yaklaşımı) | QM-measurements `PC-QA-16-idle` | — |
| E06 | §11.5 (5) row + column lift, settle, ghost, rim/rails/dim fade | runtime-video + screenshot | L5 satır 2 tutuldu → R2; sütun 2 tutuldu → D2 | iPhone 16 | rim + glow, kenar ray'ler (satır: yanlar, sütun: üst/alt), rest %42, wrap ghost ≈%30 kart içine kırpılmış; `HAMLE` tutulurken 0, settle sonrası +1. Settle probe: tepe **+1.0 pt = stride'ın %1.5'i**, dönüş ≈ settle başı +150 ms (80 % = 152 ms), rim ≈ +30–45 ms sonra temiz | `QA-16-02`, `QA-16-03`, `QV-16-row-column-lift.mp4`, `QM-settle-probe.txt` | — |
| E07 | AC2 / AC3 + write-through | runtime | aynı hamleler; `kv.active_session` okundu | iPhone 16 | `["R2","D2"]`, moveCount 2, undo 3 | sqlite okuması | — |
| E08 | AC4 eşik altı | runtime | satır 3'te 12 pt sürükleme | iPhone 16 | hamle yok, `HAMLE` 2, snapshot değişmedi | `QA-16-05` | — |
| E09 | AC6 + §11.5 (8) undo kotası | runtime | undo ×2 → 0 hamle; hamle + undo → kota 0; hamle ×2; kota 0'da undo ×2 | iPhone 16 | 2 kalan: iki lime + bir %25; 0 hamlede pill %55; kota 0: %55, üç sönük nokta; kota 0'da dokunuş **no-op, prompt yok**; D1-02 paritesi max 0.67 pt | `QA-16-06/07/08`, `crops/hud-*.jpg` | — |
| E10 | AC7 restart + pressed | runtime | restart basılı tutuldu → bırakıldı | iPhone 16 | basılıyken dolgu/kenar parlıyor; bırakınca diyalogsuz sıfırlama: 0 hamle, kota 3, restartCount 1 | `QA-16-09/10`, `crops/hud-restart-pressed.jpg` | — |
| E11 | AC5 kilit sırasında girdi | runtime + E02 | settle sırasında gelen ikinci swipe ve undo dokunuşu | iPhone 16 | ikisi de düşürüldü (snapshot +1 yerine değişmedi); kuyruğa alınmadı. Kasıtlı zamanlamayla 0 çift sayım E02 grup 2'de | sqlite okumaları | zamanlama tool gecikmesiyle, E02 deterministik |
| E12 | AC10 ayrıl / dön / öldür | runtime | chevron → Home ("Seviye 5 · sürüyor"); kill + relaunch → CONTINUE; kenar kaydırma | iPhone 16 | aynı ızgara, `HAMLE` 1, kota 3, restartCount 1 korundu; kenar kaydırma = chevron | `QA-16-11`, `QA-16-12` | — |
| E13 | Reddedilen hamle (L3 yalnız satır) | runtime-video | sütun 2 aşağı, tutup bırakma | iPhone 16 | 140 ms bounce: bırakıştan ≈120–140 ms'de rest; `HAMLE` 0, snapshot boş | `QV-16-rejected-bounce-L3.mp4`, `QM-bounce-probe.txt`, `QA-16-13` | — |
| E14 | §11.5 (6) L26 locked + frozen, gri tonlama | runtime + ölçüm | CONTINUE → L26; gri profil dönüşümü | iPhone 16 | `SEVİYE 26`; kilit ikonu + indigo, kar tanesi + kesikli kenar + buz; gri tonlamada ayırt edilebilir; D1-05 paritesi max 0.67 pt | `QA-16-14`, `QA-16-14g` | — |
| E15 | §11.5 (10) OS metin taraması L26 | runtime + ölçüm | `content_size` large → xL → xxL → xxxL → AX5 | iPhone 16 | bütün Play metni 1.3× cap'te, geometri sabit — **ama `HAMLE` etiketi xxL'den itibaren kartın yuvarlak alt kenarının dışına taşıyor** (F03-QA-D1-01) | `QA-16-15/16/17-*`, `crops/hamle-*.jpg`, QM-measurements | — |
| E16 | §11.5 (7) thaw L23 | runtime-video + probe | seed `["R1","D3","U4"]` → sütun 4 yukarı | iPhone 16 | `thawedFrozenCells ["2,1"]`; buz → krem **cross-fade** ≈7 karede (settle'dan ≈115–130 ms, 180 ms önden yüklü eğri), kar tanesi solarak küçülüyor; durum değişimi değil | `QV-16-thaw-L23.mp4`, `QM-thaw-probe.txt`, `crops/thaw-*.jpg` | — |
| E17 | §11.5 (9) tutorial 1.0×, ghost gizle/dön, HUD kullanılabilir | runtime-video + ölçüm | L4 ack yok; satır sürükle-tut → R4; undo | iPhone 16 | pill boşluğu **10.0 / 9.7 pt**; touch-down'da ghost ≈120 ms'de soluyor, pill kalıyor; idle'dan ≈620 ms sonra ≈130 ms'de geri; R4 ack yazmadı; undo çalıştı (kota 2), harcanan nokta ≈117 ms'de söndü | `QA-16-20/21/22`, `QV-16-tutorial-ghost-drag.mp4`, `QV-16-tutorial-undo.mp4`, `QM-tutorial-probe.txt` | — |
| E18 | F05 AC11 | runtime | gate öncesi force-quit → relaunch → CONTINUE | iPhone 16 | tutorial yeniden gösterildi | `QA-16-23` | — |
| E19 | F05 AC4 + tekrar gösterilmeme + 4–6 dışı | runtime | sütun hamlesi D2; relaunch; L7 ack yok | iPhone 16 | pill + ghost kalktı, `journey_col_tutorial_ack` yazıldı; L4'te ack sonrası ve L7'de pill bandında piksel yok | `QA-16-24/25/26`, sqlite | — |
| E20 | Tutorial 1.3× cap | runtime + ölçüm | AX5 | iPhone 16 | iki satır, sparkle gizli; boşluk **7.3 / 6.7 pt** | `QA-16-37`, `crops/tut-ax5-band.jpg` | — |
| E21 | §11.5 (13) load error + çıkışlar + metin ölçeği | runtime | kurulu bundle'da `journey-tr-07.json` bozuldu; CONTINUE; kenar kaydırma; pill; boyut taraması | iPhone 16 | kart + çizilmiş `loopBreak` + Türkçe metin, ham exception yok; kenar kaydırma ve pill → Home; pill etiketi AX5'te iki satıra akıyor — **başlık xxxL/AX'te "yüklenemedi" / "." olarak kırılıyor** (F03-QA-D1-02). Asset geri yüklendi (SHA-1 `2fef993c2391…` = repo) | `QA-16-27/28/29-*/30`, `crops/err-ax5-card.jpg` | bozulma yalnız simülatör bundle'ında |
| E22 | §11.5 (12) loading → loaded | runtime-video | CONTINUE → L26, kareler | iPhone 16 | route push içinde skeleton: `SEVİYE 26` + 25 cam hücre; rail / `HAMLE` / HUD / spinner yok; kart üst 306.6 pt ve alt kenar 643.5–644.5 pt iki karede aynı | `QV-16-loading-L26.mp4` | yükleme < 300 ms |
| E23 | Won moment §16 (§19.9 (1) ile) | runtime-video + ölçüm | debug L01: R0 Perfect; Retry; R1 + R0 (2★); xxxL; Kapat | iPhone 16 | dock ≈ T0 + 615 ms, scrim ≈ T0 + 650, panel ≈ T0 + 700 (**T0 + 600 öncesi hiçbir şey yok**); taşlar hedef taşlarına ortalı (228.7–289 pt, rail merkezi 258.8), rail taşları görünmez; panel omurgası 316–318.7 pt ≥ 0.36 H (306.7), seam altına ≥ 22 pt; xxxL'de compact yoğunluk, satır açık, kontroller ≥ 44 pt; Retry rail'i geri getiriyor; Kapat → Home; debug setinde yalnız chevron | `QA-16-31…35`, `QV-16-won-L01-perfect.mp4`, `QM-won-probe.txt` | — |
| E24 | §11.5 (11) Reduce Motion açık | runtime-video + capture | `ReduceMotionEnabled 1`, relaunch; L23 thaw; L4 tutorial | iPhone 16 | lift anında (tek karede %42); settle overshoot'suz monoton ease-out; thaw settle karesinde anında; ghost statik (≈1.8 s'lik dört yakalama byte-identical) | `QV-16-reduced-motion-lift-thaw.mp4`, `QM-reduced-motion-probe.txt`, `QA-16-36` | — |
| E25 | iPhone 16e: idle, sütun, tutorial | runtime + ölçüm | L5 idle; sütun tutma; L4 tutorial 1.0× / AX5 | 16e | S-v-16e ile max **0.67 pt**; sütun ray'leri üst/alt; pill boşluğu **9.3 / 8.7 → 6.3 / 6.0 pt** | `QA-16e-01…04` | — |
| E26 | iPhone 16 Pro Max: idle, sütun, tutorial | runtime + ölçüm | aynı | Pro Max | D1-v Pro Max render ile max **0.67 pt**; S-v ile yalnız restart +3.17 pt (S-v, 44-pt kararından eski — beklenen); pill boşluğu **12.0 / 12.0 → 8.7 / 8.3 pt** | `QA-pm-01…04` | — |
| E27 | Multi-touch → yalnız ilk parmak | runtime | iki parmak zıt yönlere (satır 1 sağa, satır 3 sola); kontrol: tek parmak aynı yol | iPhone 16 | iki parmakta **0 hamle**; tek parmakta R1 uygulandı (F03-QA-D1-03) | `QA-16-38`, sqlite | — |
| E28 | Diagonal eşitlik → yatay | runtime | dx 40 / dy 38 | iPhone 16 | R2 (yatay) | sqlite | — |
| E29 | Kontrast (en düşük çift) | runtime piksel | `HAMLE` etiketi ve kart dolgusu örneklendi | iPhone 16 | etiket #AEB4CA (token birebir) / dolgu 51,60,106 → **5.1 : 1** | QM-measurements | — |
| E30 | §11.5 (14) legacy yok | runtime + static | bütün D1 yakalamaları; `grep -rn "Icons\." app/lib` | 3 sim / repo | Material ikon, sistem fontu ya da PlayTheme rengi D1 yüzeylerinde görülmedi; grep yalnız `completion_panel.dart` doc yorumu | yakalamalar | — |
| E31 | VoiceOver semantiği | automated (runtime yok) | E01 içindeki widget testleri (geri "Geri, Seviye 26", tek rail düğümü, "n / 3 hak", ipucu bir kez, ghost hariç, 300 ms sonra "Yükleniyor") | widget | geçti (E01) — **REUSED sınıf: automated**; bu host'ta çalışma zamanı VoiceOver sürücüsü yok | 5798c70 | test harness |
| E32 | Klavye odak halkası | automated (runtime yok) | `components_test.dart` "QA-03: focus ring …" (E01) | widget | geçti; simülatöre donanım Tab gönderilemedi — §19.9 (4) sınıfı | 5798c70 | test harness |

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Expected | Evidence IDs | Result |
| --- | --- | --- | --- |
| AC1 / J1 açılış | hedef, ızgara, `HAMLE 0`, undo 3, restart; hedef ızgaradan ayrık | E05, E25, E26 | PASS |
| AC2 / AC3 satır–sütun kaydırma | yalnız o hat bir hücre, +1 | E06, E07, E28 | PASS |
| AC4 eşik altı | hamle yok | E08, E13 (sütun tutup bırakma L3) | PASS |
| AC5 animasyonda girdi | düşürülür, kuyruk yok, çift sayım yok | E11, E02 | PASS |
| AC6 undo kotası | 0'da no-op, prompt yok | E09 | PASS |
| AC7 restart | diyalogsuz sıfırlama, ızgaradan uzak | E10 | PASS |
| AC8 / AC11 kazanma | kilit + vurgu + animasyon + panel; kazanç yalnız settle'da | E23, E02 | PASS |
| AC9 hat vurgusu | rim + ray'ler | E06, E25, E26 | PASS |
| AC10 resume | geri / kenar kaydırma / kill → birebir | E12, E02 | PASS |
| F05 AC4 / AC11 | ilk sütun hamlesi ack yazar; gate öncesi quit → yeniden gösterim | E17, E18, E19 | PASS |
| J4 reddedilen hamle | 140 ms bounce, `HAMLE` değişmez | E13 | PASS |
| J6 thaw | 180 ms cross-fade; RM'de anında | E16, E24 | PASS |
| J10 loading | kart rect sabit, spinner yok | E22 | PASS |
| J11 load error | kart + `loopBreak` + pill → `/`; geri → çağıran; ham metin yok; AX5'te akış | E21 | **FAIL** (F03-QA-D1-02, yalnız metin ölçeği) |
| J13 won §16 (amended) | T0 + 600; dock hedefte; panel satırı örtmez; ≥ 44 pt; Retry | E23 | PASS |
| Metin taraması (§11.5 (10)) | AX5'e kadar kırpma/örtüşme/kelime içi kırılma yok | E15, E20, E21 | **FAIL** (F03-QA-D1-01, -02) |
| Reduce Motion açık / kapalı | azaltılmış yollar / tam hareket | E24 / E06, E16, E17 | PASS |
| Misuse: settle'da girdi, undo/restart | düşürülür | E11 | PASS |
| Misuse: multi-touch | yalnız ilk parmak | E27 | FAIL (F03-QA-D1-03 — güvenli sonuç, D1 öncesi) |
| Misuse: diagonal eşitlik | yatay | E28 | PASS |
| Misuse: arka plan mid-drag / mid-settle | yırtık hamle yok | E02 grup 4 | PASS |
| Misuse: panelden Retry / Kapat; Next | Retry yeniden başlatır; Kapat → Home; Next "yakında" (F05) | E23 | PASS |
| Misuse: 4–6 dışı / ack sonrası tutorial | gösterilmez | E19 | PASS |

## Client & UI Compliance

| Kontrol | Evidence | Sonuç |
| --- | --- | --- |
| Header: chevron + `SEVİYE NN` iki haneli, seviyeye bağlı; debug setinde yalnız chevron; ≥ 44 pt | E05, E14, E23 | PASS |
| Back / kenar kaydırma / sistem geri: çağırana döner, snapshot korunur, onay yok; `won`'da gizli | E12, E21, E23 | PASS |
| Loading (skeleton, spinner yok) / error (tek aksiyon) / disabled / pressed / selected (lift) | E22, E21, E09, E10, E06 | PASS (error metin ölçeği hariç — F03-QA-D1-02) |
| Controller → görünür UI eşlemesi (`HAMLE` settle'da, kota noktaları, thaw) | E06, E09, E16 | PASS |
| F05 overlay: pill HUD üstünde, kontrol örtmüyor; ghost parmak altında oynamıyor (A-1, A-6 düzeltmesi) | E17, E20, E25, E26 | PASS |
| `ui-design.md` §12a matrisi — her satır runtime'da görüldü | E05–E26 | PASS (odak halkası E32 sınıfında) |
| Metin ölçeği davranışı (§19.3 (1), §11.5 (10)) | E15, E21 | **FAIL** — F03-QA-D1-01, -02 |

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Expected | Evidence IDs | Result |
| --- | --- | --- | --- | --- |
| settled move → snapshot | oyuncu / idle | her settle / undo / restart sonrası write-through | E07, E09, E10, E17 | PASS |
| back → Home → CONTINUE | oyuncu / inProgress | aynı durum | E12 | PASS |
| OS kill → relaunch → CONTINUE | OS / inProgress | aynı durum (kota, restartCount dahil) | E12, E02 | PASS |
| paused mid-drag / mid-animation | OS / tracking, animating | hamle yok / settle tamamlanır | E02 | PASS |
| tampered `thawedFrozenCells` | depolama / resume | yeniden türetilir | E02 | PASS |
| tutorial gate öncesi quit | OS / L4, ack yok | yeniden gösterim | E18 | PASS |
| gate (sütun hamlesi) → ack → relaunch | oyuncu / L4 | ack kalıcı, bir daha yok | E19 | PASS |
| won → `completed` + clear → Kapat | oyuncu / won | Home'da aktif oturum yok | E23 | PASS |
| bozuk asset → error → Home | içerik / L7 | tek çıkış, crash yok | E21 | PASS |

## Visual Quality Verdict

Bağımsız runtime skoru; Frontend/UI self-score'u kullanılmadı. Kapsam: `won` dışındaki Play state'leri ve F05 overlay. Won moment yalnız §16 (+ §19.9 (1)) kurallarına göre değerlendirildi (E23, PASS) ve puana katılmadı.

| Rubric Dimension | Score / 10 | Runtime Evidence | Notes |
| --- | --- | --- | --- |
| Experience Fit | 9 | E05, E14, E17 | Seçilmiş Loop Glass dili çekirdek döngüde sakin ve bilinçli; hybrid dönem (legacy Home / won) kabul edilmiş |
| Visual Hierarchy | 10 | E05, E06, E17 | her state'te tek odak: board, kaldırılan hat, eriyen taş, ipucu; hedef board ile eşleşiyor ama yarışmıyor; HUD sessiz |
| Layout, Rhythm and Responsiveness | 8 | E05, E25, E26, E20, E15 | üç cihazda ≤ 0.67 pt; tutorial bütçesi her ölçekte ≥ 6 pt — ama dinamik tipte `HAMLE` etiketi kartından taşıyor (F-01) |
| Typography and Content Craft | 8 | E14, E15, E21 | iki OFL aile, `tnum`, Türkçe büyük harf doğru; ama xxL+'da etiket taşması ve xxxL+'da hata başlığında "." yetim satırı (F-01, F-02) |
| Color, Surface and Asset System | 10 | E05, E14, E29, E30 | token yamaları ΔE ≤ 1.5, anlam başına tek vurgu (periwinkle / lime), çizilmiş ikonlar, gri tonlamada okunur özel taşlar; zemin ışığı ΔE 3.35 kabul edilmiş gradient yaklaşımı |
| Interaction, State and Feedback | 9 | E06, E09, E10, E13, E16, E21, E22 | her state ayırt edilebilir ve runtime'da görüldü; bounce, pressed, kota; multi-touch sapması (F-03, D1 öncesi) |
| Motion and Sensory Quality | 9 | E06, E13, E16, E17, E24 | settle %1.5 / 80 %, 140 ms bounce, thaw cross-fade, ghost 120 / 600 / 160 ms, bütün reduced yollar anında; audio/haptic yalnız niyet (F11 planlı değil) |
| Originality and Product Identity | 9 | E06, E21 | wrap ghost + kenar ray'leri mekaniği gösteriyor; `loopBreak` glifi ürün metaforu; navy-glass tarifi kategoride yaygın |
| Accessibility and Inclusive Quality | 7 | E15, E21, E29, E24, E31, E32 | kontrast 5.1 : 1, non-colour cue'lar, 44 pt, RM iyi — ama OS metin boyutu xxL'den itibaren birincil durum kartında taşma (F-01) ve xxxL+ hata başlığı kırılması (F-02); VoiceOver ve odak halkası runtime'da doğrulanamadı (yalnız automated) |
| Implementation Fidelity and Polish | 8 | E05, E14, E25, E26, E15 | varsayılan ölçekte render'lara ≤ 0.83 pt; 1.3× cap'te D1-10 etiketi kart içinde gösteriyor, runtime göstermiyor — frontend.md NTLC-3 / A11Y-16-text "örtüşme yok" kaydı yalnız kart merkezinde doğru |

Final Score: `87 / 100`

Lowest Dimension: `Accessibility and Inclusive Quality — 7 / 10`

Fail Conditions: `clipping / overflow — HAMLE etiketi MovesCard'ın yuvarlak alt kenarını xxL (1.235×) → AX5 aralığında aşıyor; D1-10 render'ı ile açıklanmamış belirgin sapma (F03-QA-D1-01)`

Runtime Evidence Complete: `Yes` (VoiceOver ve odak halkası belirtilen automated sınıfta; Android kapsam dışı sınır)

Result: `FAIL`

## 3. Findings

**F03-QA-D1-01 — `HAMLE` etiketi büyük OS metin boyutlarında kartının dışına taşıyor**
* Severity / Type: **Major** / görsel + erişilebilirlik (implementation defect). Blocking.
* İlgili: ui-design §11.5 (10) ve (16); architecture §19.3 (1); F03-FE-D1 (MovesCard, 1.3× cap); rubric fail condition "clipping / overflow".
* Expected: bütün Play metni 1.3× cap'te kendi kabı içinde kalır; D1-10'da etiket kartın içinde.
* Actual: etiketin mürekkep kutusu cap'te x 304.7–361.7, y 138.7–150.0 pt. Kart ise x 301.0–365.3, alt kenar ≈ 152.3 pt, köşe yarıçapı ≈ 24 pt. "H" ve "E" alt köşelerde kartın yay kenarını ≈ 5–6 pt aşıyor ve kenar çizgisinin üstünden geçiyor.
  * Görünür olduğu boyutlar: xxL (1.235×), xxxL ve bütün AX boyutları; xL'de kenara değiyor.
  * Yalnız kart merkezinde ≈ 2 pt içeride; frontend.md NTLC-3 / A11Y-16-text'teki "no clipping or overlap" kaydı bu yüzden eksik.
* Adımlar: `seed-sim.sh <16> 26 - 1` → CONTINUE → `xcrun simctl ui <16> content_size extra-extra-large` (veya xxxL / AX5).
* Evidence: E15 — `QA-16-16-L26-text-ax5.png`, `crops/hamle-ax5-corner-left-x4.jpg`, `crops/hamle-ax5-corner-right-x4.jpg`, `crops/hamle-extra-extra-large.jpg`, `crops/hamle-ax5-render.jpg`, QM-measurements.
* Kök neden önerisi: F00 `MovesCard`'ın cap'teki iç yerleşimi (minimum yükseklik ve etiketin alt boşluğu / tracking); follow-up MOVESCARD-CAP-MARGIN ile aynı yüzey. Design-layer düzenleme yetkisi Tech Lead'de; token değeri değişmemeli.

**F03-QA-D1-02 — Load-error başlığı xxxL ve üstünde kelimenin sonundaki "." ile kırılıyor**
* Severity / Type: **Minor** / tipografi + erişilebilirlik (implementation defect). Blocking — §11.5 (10) kabul maddesi runtime'da sağlanmıyor.
* İlgili: ui-design §11.5 (10) ("mid-word break yok"); architecture §19.9 (3) (başlık, AX5'te kelime içinde kırılmasın diye 1.3×'e sınırlandı).
* Expected: "Bu bulmaca yüklenemedi." her OS boyutunda kelime sınırlarında akar.
* Actual: 1.3× cap'te "yüklenemedi." kartın metin sütunundan geniş. Nokta ayrı üçüncü satıra zorla kırılıyor (başlık yüksekliği 2 satır ≈ 77 pt → 3 satır ≈ 115–120 pt).
  * Görünür olduğu boyutlar: xxxL ve bütün AX boyutları; xxL'de iki satır, sorun yok.
* Adımlar: kurulu bundle'da `journey-tr-07.json` bozulur → L7 CONTINUE → `content_size extra-extra-extra-large`. Sonra asset geri yüklenir.
* Evidence: E21 — `QA-16-28-load-error-ax5.png`, `crops/err-ax5-card.jpg`, `QA-16-29-*`, QM-measurements.
* Kök neden önerisi: `_LoadErrorView` başlık rolü (`LoopText.headline` 28·s × 1.3) kart iç genişliğine göre çok büyük. Çözüm (rol boyutu, kart iç boşluğu veya ölçekleme kuralı) UI / Tech Lead kararı.

**F03-QA-D1-03 — İki parmakla zıt yönde kaydırma hiçbir hamle üretmiyor (ilk parmak onurlandırılmıyor)**
* Severity / Type: **Minor** / contract sapması (davranış), **D1 öncesi** — gesture kodu 2026-09-06'dan (3a6e854) beri aynı; D1 değiştirmedi. D1 gate'i için non-blocking; routing Tech Lead'de.
* İlgili: architecture §6 ("tracking follows only the first pointer"), prd §4 edge case ("honor only the first touch"); F03 closure 2026-09-21 notu: multi-touch runtime'da denenmemişti.
* Expected: ilk parmağın hamlesi uygulanır, ikinci yok sayılır.
* Actual: satır 1 sağa + satır 3 sola eşzamanlı → 0 hamle. Aynı yol tek parmakla → R1. `GestureDetector` pan tanıyıcısı bütün pointer'ları tek odak deltasında birleştiriyor; zıt deltalar birbirini götürüp eşik altına düşüyor.
  * Sonuç güvenli: çift hamle ya da yırtık durum yok.
* Evidence: E27 — `QA-16-38.jpg`, sqlite okumaları.

## 4. Pending Evidence

* Scenario: Android görünümü ve `disableAnimations` runtime davranışı.
  * Required class: runtime; target: Android emulator/cihaz; owner: DevOps/Release Engineer (ANDROID-CI-EVIDENCE).
  * Re-evaluation trigger: Android CI/emülatör hazır olduğunda.
  * Bu gate'i durdurmaz (brief'te belirtilmiş sınır).

VoiceOver (E31) ve donanım klavye odak halkası (E32) automated sınıfta kaldı. Brief ve §19.9 (4) bu sınıfı kabul ediyor; ayrı pending kaydı açılmadı.

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey / derinlik:** full.
  * `/play` bütün state'leri, F05 overlay, design-layer (`tile.dart`, `buttons.dart`, `icons.dart`, `play_decor.dart`) ve won geometrisi runtime'da; paylaşılan bileşenlerin geri kalanı E01'de.
  * AC1–AC11 ve F05 AC4 / AC11 regresyonu PASS.
* **Reused:**
  * E31 / E32 — yalnız automated sınıf; testler bu turda yeniden çalıştırıldı.
  * Portre kilidi / rotasyon yeniden denenmedi: `Info.plist` ve kök navigasyon D1'de değişmedi; önceki QA (rev c0cba44) PASS.
* **Invalidated:** yok. Frontend'in RT/RV kayıtları karşılaştırma girdisi olarak kullanıldı; hiçbiri skor kanıtı sayılmadı.
* **Bağımsız QA probe'ları:**
  * suite'ler ve integration yeniden (E01, E02);
  * QA'ya ait `qa-frames` / `qa-pixels` ile settle, bounce, thaw, ghost, won zamanlaması ve piksel ölçümleri;
  * `measure-d1` QA yakalamaları üzerinde yeniden çalıştırıldı ve Frontend'in parity sayılarını ≤ 0.83 pt ile teyit etti.
* **Ek bulgu:** frontend.md'deki A11Y-16-text / NTLC-3 "no clipping or overlap" iddiası runtime'da çelişiyor (F03-QA-D1-01). Rapor düzeltmesi gerekiyor.

## 6. Final Verdict

* `QA Result: Rejected`
* Blocking Issues: F03-QA-D1-01, F03-QA-D1-02
* Required Fixes:
  1. `HAMLE` etiketi 1.3× cap'te MovesCard içinde kalsın (xxL → AX5; köşe yayları dahil); D1-10 ile eşleşsin.
  2. Load-error başlığı xxxL → AX5'te kelime sınırında aksın (yetim "." yok).
  3. Düzeltme sonrası metin taraması (large / xL / xxL / xxxL / AX5) üç cihazda yeniden; F03.D1-VISUAL-QA yeniden skorlanır.
* Non-blocking Notes:
  * F03-QA-D1-03: multi-touch ilk-parmak sözleşmesi (D1 öncesi, güvenli sonuç) — Tech Lead routing kararı.
  * frontend.md NTLC-3 / A11Y-16-text kaydının düzeltilmesi.
  * Android, VoiceOver ve fiziksel parmak sınırları.
  * Skor 87 / 100. Sorun yalnız dinamik tipte: iki bulgunun etkilediği boyutlar dışında yüzey güçlü (hiyerarşi ve renk/yüzey 10, varsayılan ölçekte parity ≤ 0.83 pt).

## 7. Tech Lead Note

* **Kök neden alanı / rol:**
  * F-01 — design-layer `MovesCard` cap yerleşimi (Frontend/Mobile Developer; design-layer düzenleme yetkisi Tech Lead kararıyla, MOVESCARD-CAP-MARGIN ile birleşebilir);
  * F-02 — `_LoadErrorView` başlık rolü (Frontend; ölçü seçimi UI Designer / Tech Lead);
  * F-03 — gesture tanıyıcısı (Frontend; D1 kapsamına alınıp alınmayacağı Tech Lead kararı).
* **Routing:** rework → Frontend/Mobile Developer, ardından Tech Lead checkpoint ve hedefli re-QA.
  * Re-QA kapsamı: metin taraması + etkilenen yüzeyler.
  * Diğer bütün kanıt, `app/` fingerprint'i değişmediği sürece yeniden kullanılabilir.
  * Depth değişikliği gerekmiyor.
* **Workflow notu:**
  * Visual Quality Gate Ready for QA'da kalır; F03.D1-VISUAL-QA = FAIL.
  * Rotasyon tuzağı yok, release etkisi yok.
  * Simülatör ayarları geri yüklendi: üç cihazda content size `large`, Reduce Motion 0; level-07 asset'i repo hash'ine döndü.

## Sonraki Komut

```text
Run Tech Lead
```
