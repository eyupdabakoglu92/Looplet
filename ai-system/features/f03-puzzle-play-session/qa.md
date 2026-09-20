# F03 — puzzle-play-session: QA Raporu (final, re-verify 2)

QA turu: 2026-09-21 · Görev: F03-QA-REVERIFY2 · QA Stage: final · QA Scope: client-only · Release Scope: none
Doğrulanan revizyon: HEAD `5be4dc6`, temiz ağaç. `app/`, `packages/`, `content/` `cf747f8` ile birebir aynı (`git diff cf747f8 HEAD -- app` boş; fark yalnız `ai-system/` dokümanları). Bu rapor önceki (2026-09-20, rev c0cba44, Rejected) raporun yerini alır; önceki bulguların kapanışı §3'tedir.

---

## 0. QA Execution Plan

* **Stage / Scope:** final / client-only. Release scope yok.
* **Modüller ve tetikleyiciler:** `core` (her tur) · `client-ui` (Flutter istemci, gesture/route/UI state; `frontend.md` mevcut) · `stateful-flow` (persistence, resume, lifecycle/interruption; architecture §9/§12). `visual-quality` yok: Visual Scope = none (bu reopen'da görsel çıktı eklenmedi/değişmedi).
* **Regression Depth: full.** Gerekçe: final gate + ortak gesture/lifecycle/persistence yüzeyi (`puzzle_board.dart`, controller) + F04/F05'in paylaştığı reduce-motion okumaları.
* **Evidence Reuse: allowed**, fingerprint c0cba44 → cf747f8: değişen tek app dosyaları `home_screen.dart`, `journey/column_tutorial_overlay.dart`, `play/play_session_controller.dart` (+`cancelDrag`), `play/play_session_screen.dart` (1 okuma), `play/widgets/puzzle_board.dart` (Listener + `_abort`), `rating/completion_panel.dart` (2 okuma), yeni `reduce_motion.dart` + testler. `main.dart`, `ios/`, pubspec, packages, persistence, content **değişmedi**.
* **Canonical target / runtime sınıfı:** iOS Simulator 18.6, iPhone 16 (393×852) birincil; 16e (390×844) ve 16 Pro Max (440×956) cihaz suite'i. Debug build, gerçek `main.dart` kökü, diskteki gerçek Drift store'u (sqlite3 ile okundu).
* **Fail-fast checkpoint:** aktif QA kapısı + `qa-preflight` PASS → gate'ler (analyze/format/test/build) PASS → en küçük kritik probe (gerçek uygulama geçişi, kesilen sürükleme) PASS → geniş doğrulama. Durdurucu hard prerequisite oluşmadı.
* **Bildirilen sınırlar:** simulator pointer'ı sentetiktir (fiziksel parmak yok); Android capture Pending (platform.md §14, kapsam dışı: iOS hedefi); OS Grayscale bu turda yeniden yürütülmedi (REUSED).

## 1. Evidence Ledger

| ID | Claim / Scenario | Class | Command / Action | Target | Result / Counts | Provenance / Fingerprint | Isolation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E1 | Statik ve otomatik kapılar | static / automated functional | `melos run analyze` · `melos run format:check` · `melos run test` | workspace | analyze exit 0 (yalnız önceden var olan 1 `looplet_solver` info), format exit 0 (155 dosya, 0 değişti), **197 paket + 243 app test geçti**, 0 fail | HEAD 5be4dc6 | widget testleri in-memory DB + override; reduce-motion bayrakları taklit |
| E2 | Debug build | build | `flutter build ios --simulator --debug` | app | exit 0 (20.9 s) | HEAD 5be4dc6 | build ≠ davranış |
| E3 | Cihaz suite'i (13 test, group 4 dahil) | repeatable integration | `flutter test integration_test/play_session_test.dart -d <UDID>` | iPhone 16e; iPhone 16 Pro Max (QA'nın kendi koşusu) | **13/13 pass, exit 0** (57 s / 67 s); Tech Lead + Frontend iPhone 16'da 13/13 | cf747f8 (app aynı) | in-memory DB; sentetik `PointerCancel`, OS iptali değil |
| E4 | **F03-QA-03:** tutulan sürüklemede gerçek OS uygulama geçişi ×3 | runtime | 10 s'lik `touch_path` + 1 Hz screenshot günlüğü, ardından `simctl launch com.apple.mobilesafari`, sonra uygulamaya dönüş; store `sqlite3` | iPhone 16 | **PASS ×3**: koşu 1 (satır 1 sağa; 02:09:34 karesinde satır kalkık, dokunuş aşağıda, MOVES 0 → 02:09:35 geçiş), koşu 2 (satır 3 sola), koşu 3 (sütun 2 aşağı). Dönüşte grid değişmemiş, MOVES 0, idle; store `appliedMoves: []`, `moveCount: 0` üç koşuda da | rev 5be4dc6; aynı repro c0cba44'te 3/3 FAIL idi | ekran görüntüleri oturum scratchpad'inde (repoda tutulmadı) |
| E5 | Cihaz kilidi sırasında tutulan sürükleme (2. tetikleyici) | runtime | tutulan sürükleme + Simulator Cmd+L. İlk deneme: menü tıklaması kilitlemedi, sürükleme dokunuş bitince normal bırakma olarak `R4` işlendi — geçerli bir bırakma, tetikleyici sayılmaz. İkinci deneme: klavye kısayolu ekranı karartıp kilitledi | iPhone 16 | **PASS**: kilitten sonra store `["R4"]`, yeni hamle yok; uyandırıp kilit açınca satır 1 dokunulmamış, MOVES 1, idle | rev 5be4dc6 | — |
| E6 | Soğuk başlatma: kesintilerden sonra kill → relaunch → CONTINUE | runtime | `simctl terminate` → `launch` → CONTINUE | iPhone 16 | **PASS**: grid değişmemiş, MOVES 0 | rev 5be4dc6 | gerçek store |
| E7 | Genuine release regresyonu (gerçek dokunuş) | runtime | `swipe` / uzun `touch_path`; store `appliedMoves` | iPhone 16 | **PASS**: 10 pt eşik altı → hamle yok; near-diagonal 60×56 → satır kayması (`R2`); ekran dışına (x=388) bırakma → `R0` commit; bu seviyede sütun sürükleme → reddedildi, MOVES değişmedi; 10 s tutulup bırakılan sürükleme → `R4` commit + persist | rev 5be4dc6 | — |
| E8 | AC9 kaldırma/vurgu (tutulan dokunuş, tam çözünürlüklü kare) | runtime | E4 koşu 1'in kare kırpması | iPhone 16 | **PASS**: sürüklenen satır kalkık ve parlak, diğer satırlar kısılmış, sarma hayaleti (`S`) kenarda, sol ray vurgusu | rev 5be4dc6 | — |
| E9 | Boşta uygulama geçişi (dokunuş yok) | runtime | 1 hamle (`D0`), `simctl launch` Safari → dönüş | iPhone 16 | **PASS**: store `journey-tr-05 ["D0"]` önce/sonra aynı; MOVES 1 | rev 5be4dc6 | — |
| E10 | **F03-QA-04:** gerçek Settings > Accessibility > Motion > Reduce Motion **AÇIK** (ek "Prefer Cross-Fade Transitions" satırı görünür → aktif), relaunch; F05 halkası | runtime | 8 kare / ~4 s, düğüm bölgesi piksel özeti (md5) | iPhone 16 | **PASS**: düğüm 8 karede **aynı** (statik) | rev 5be4dc6 | — |
| E11 | E10 kontrolü: Reduce Motion **KAPALI** | runtime | aynı yöntem (düğüm konumu güncellendi: 3/30, seviye 4 sürüyor) | iPhone 16 | 8 karede **8 farklı** özet → düğüm nefes alıyor; yöntem ayırt edici | rev 5be4dc6 | düğüm konumu E10'dan farklı (seviye 1 vs 4); mekanizma aynı |
| E12 | Reduce Motion AÇIK: F03 kazanma + F04 açılış | runtime + video | debug L01 (1 hamlelik kazanma), `simctl recordVideo`, 0,1 s kare tablosu | iPhone 16 | **PASS**: T0 ≈ 6,45 s; statik amber satır + dikiş yerinde ≈ 300 ms bekler; satır dock'a çapraz solar (≈ 160 ms), scrim + panel solarak gelir; ≈ T0+0,66 s'de dinlenme; **3 yıldız birden dolu**; glide/slide/yıldız sıralaması yok | rev 5be4dc6; aynı senaryo c0cba44'te FAIL idi | video oturum scratchpad'inde |
| E13 | Reduce Motion AÇIK: F05 öğretici hayaleti (seviye 4) + Journey akışı | runtime | seviye 1–3 çözümü (`L0 L0`, `L3 L3`, `L1 L1`, her biri Perfect + SONRAKİ) → seviye 4; tam ekran 8 kare özeti | iPhone 16 | **PASS**: ipucu + hayalet görünür, 8 karede **aynı** (statik); kontrol KAPALI: **8/8 farklı** (döngü); ilk sütun hamlesiyle öğretici temizlendi | rev 5be4dc6 | debug puzzle'lar öğretici göstermez; Journey yolu kullanıldı |
| E14 | Reduce Motion KAPALI: normal kazanma dizisi geri geliyor (seviye 4, `U0 U3 R3 D4`) | runtime + video | 75 ms kare tablosu | iPhone 16 | **PASS**: amber satır ≈ 0,6 s tutulur → dock'a kayar (glide) → panel yukarı kayar → yıldızlar tek tek vurulur (yalnız panel dinlendikten sonra) | rev 5be4dc6 | — |
| E15 | Journey ilerleme / Next Level (Reduce Motion açık) | runtime | seviye 1→2→3→4→5 SONRAKİ zinciri | iPhone 16 | **PASS**: ana ekran `3 / 30`, "Seviye 4 · sürüyor"; seviye 4 kazanılınca seviye 5'e geçildi | rev 5be4dc6 | — |

**REUSED** (kaynak koşu: QA 2026-09-20, rev c0cba44; fingerprint geçerli, ilgili dosya yolu dokunulmadı): R1 portrait kilidi / döndürme (`main.dart`, `Info.plist` değişmedi); R2 gerçek kill/relaunch resume ve persistence (persistence yolu, DB, `main.dart` değişmedi; E6 ile ayrıca yeniden doğrulandı); R3 chevron / iOS kenar kaydırma / replaced-route Close çıkışları (`play_session_screen.dart` yalnız 1 okuma değişti; E13/E15 zinciri Next Level replaced-route'unu bu turda yeniden yürüttü); R4 F04 varyantları ve normal hareket kazanma kareleri (16/16e/Pro Max, XXXL dahil; bu turda spot: satır 0 [E12], satır 4 [E14]); R5 tampered `thawedFrozenCells` + misuse seti; R6 greyscale yaklaşık kontrolü; R7 büyük metin (XXXL) yerleşimi.
**INVALIDATED ve bu turda yeniden yürütülen:** LIFECYCLE-LIVE (E4–E6, E9), AC9 (E8), gesture regresyonu (E7), tüm reduce-motion yolları (E10–E14), CURRENT-REVISION (E1–E3).

## 2. Acceptance & Critical Journey Coverage

| AC / Journey | Beklenen | Evidence | Sonuç |
| --- | --- | --- | --- |
| AC1–AC8 temel etkileşim (grid, hamle, sayaç, kazanma, undo/restart, reddedilen hamle, eşik) | çalışıyor | E7, E12–E15 (+ REUSED R5) | PASS |
| AC9 sürükleme sırasında kaldırma/vurgu | görünür | E8 | PASS |
| AC10 resume | kill/relaunch grid + MOVES korunur | E6, R2 | PASS |
| architecture §12: tutulan dokunuş kesilirse **hamle yok**, idle | OS geçişi ve kilit | E4, E5 | **PASS** (önceki FAIL kapandı) |
| architecture §12: boşta arka plana alma | durum aynı | E9 | PASS |
| architecture §12: animasyon sırasında pause → deterministik son durum | settled, kayıp/yarım hamle yok | E3 (group 4, `paused mid-animation`) | PASS (yalnız otomasyon; ~190 ms'lik pencerede gerçek OS geçişi güvenilir zamanlanamadı) |
| architecture §18 / ui-design §16.2: OS reduce-motion yolu | iOS'ta erişilebilir | E10–E14 | **PASS** (önceki FAIL kapandı) |
| Gerçek bırakmalar (plaka içi/dışı, uzun tutma) hâlâ çözülür | commit | E7 | PASS |
| Negatif/misuse: eşik altı, çapraz, sütun reddi, kill sonrası, kesinti sonrası | güvenli durum | E6, E7, E9 (+ R5) | PASS |
| F04 paneli: Perfect / SONRAKİ / Yeniden / Kapat, Reduce Motion açık/kapalı | tam ve tıklanabilir | E12–E15 | PASS |
| F05 halka / öğretici: reduce-motion açık statik, kapalı canlı | iki yönlü | E10–E11, E13 | PASS |

## Client & UI Compliance

| Journey / State / Navigation | Sonuç | Evidence |
| --- | --- | --- |
| Ekran hedefi: hedef kelime rayı, board, HAMLE, geri chevron; header sibling'lerle tutarlı | PASS | E4, E12–E15 |
| Kazanma: girdi kilidi, chevron gizli, panel ancak kazanma dizisinden sonra | PASS (azaltılmış ve normal) | E12, E14 |
| Panel çıkışları: Next Level (replaced-route), Kapat → `/` | PASS | E13, E15 |
| Öğretici: gate, ilk sütun hamlesiyle temizlenir, reduce-motion'da statik | PASS | E13 |
| `ui-design.md` §16 niyeti (dock satırı, hayalet hücre, tek glow, panel ≤ %64) — regresyon gözlemi | Regresyon yok (spot: satır 0 azaltılmış, satır 4 normal) | E12, E14 |
| Animasyon sırasında girdi (çift kayıt) | Reddedilir (integration group 2) | E3 |

## Stateful Flow & Integration

| Boundary / Transition | Actor / Start State | Beklenen | Evidence | Sonuç |
| --- | --- | --- | --- | --- |
| tracking → OS iptali/geçişi → paused → resumed | tutulan dokunuş, satır kalkık | hamle yok, idle, store değişmez | E4 ×3, E5 | PASS |
| cold boot, persisted state ile | kesinti sonrası kill | son settled snapshot | E6, R2 | PASS |
| idle → paused → resumed | hamle sonrası, dokunuş yok | durum aynı | E9 | PASS |
| won → completed snapshot / kapanış → unlock / SONRAKİ | seviye 1–4 | ilerleme 3/30, sonraki seviye açık | E13, E15 | PASS |
| Listener sahipliği: `Listener` yalnız PointerCancel'de `_abort`; ardından gelen `onPanEnd` fazı `idle` görüp no-op | kaynak + davranış | çift çözümleme yok | E4 (store) + kaynak incelemesi | PASS |

## 3. Findings

Yeni bulgu **yok**. Önceki bulguların kapanışı:

| ID | Başlık | Durum | Kanıt |
| --- | --- | --- | --- |
| F03-QA-01 | Kazanma dizisi/geometri | Kapalı (önceki tur, c0cba44) | REUSED R4 + E12/E14 spot |
| F03-QA-02 | Cihaz suite group 4 | Kapalı (önceki tur) | E3 (16e, Pro Max) |
| F03-QA-03 | Kesilen sürükleme hamle olarak işleniyordu | **Kapalı** | E4 ×3, E5, E6 |
| F03-QA-04 | iOS Reduce Motion yok sayılıyordu | **Kapalı** | E10–E14 |

Not (QA-03 kök nedeni): önceki raporun mekanizma notu (`_onPanCancel → _release`) eksikti. Frontend'in düzeltmesi, kabul edilmiş bir pan'in `PointerCancel`'inin Flutter'da `onPanEnd` olarak geldiğini gösterir (iki negatif kontrolle); QA gerçek OS geçişiyle sonucu bağımsız doğruladı (E4). Sözleşme değişikliği gerekmez.

## 5. Regression & Evidence Reuse

* **Etkilenen yüzey / depth:** gesture yolu (`puzzle_board.dart`), controller iptal API'si, altı reduce-motion çağrı noktası (F03, F04 paneli ×2, F05 halka + öğretici). Derinlik full: gate'ler, cihaz suite'i 2 genişlikte, gerçek OS kesintisi, gerçek Reduce Motion açık/kapalı, genuine-release regresyonu, Journey zinciri (F04/F05 paylaşılan yol) çalıştırıldı.
* **Reused:** R1–R7; gerekçe = ilgili dosyalar değişmedi (fingerprint).
* **Invalidated ve yeniden yürütülen:** LIFECYCLE-LIVE, AC9, gesture, reduce-motion, CURRENT-REVISION.
* **Bağımsız QA probe:** E4 (gerçek OS geçişi ×3, farklı satır/sütun/eksen), E5 (gerçek cihaz kilidi), E10–E14 (gerçek Settings anahtarı + açık/kapalı kontrol çifti). Teslim sahibinin özeti kopyalanmadı; her sonuç QA'nın kendi çalıştırmasıdır.
* **F04/F05 etkisi:** yalnız bayrak kaynağı; davranış ve kabul kriterleri değişmedi; runtime'da açık/kapalı iki yönde doğrulandı.

## 6. Final Verdict

* `QA Result: Approved with Notes`
* Blocking Issues: None
* Required Fixes: None
* Non-blocking Notes:
  1. **Runtime'da uygulanmayan / yalnız otomatik kanıtlı:** tüm 30 seviye tamamlanınca terminal halka bloom'unun reduce-motion'da statik olması (widget testleri her iki bayrak + kontrolle geçer; runtime'da 30/30'a ulaşılmadı); çok parmaklı kullanım (ikinci parmağın iptali birincinin sürüklemesini iptal eder — AC dışı, gözlenmedi); fiziksel parmak doğruluğu; animasyon penceresinde gerçek OS pause zamanlaması (integration group 4 kanıtı).
  2. **Tahta kaydırma/sekme animasyonu** iOS Reduce Motion'da normal hızda çalışır (sözleşme yok; Android `disableAnimations`'ta Flutter kısaltır) — Tech Lead kararı: rework değil.
  3. **Bilinen tasarım gözlemleri (rework değil):** kazanma anında dimlenmiş satır 0'ın dock ile panel arasında şerit olarak görünmesi; ui-design §8/§16.2'deki 30 ms L→R amber stagger uygulanmamış (karolar birlikte geçer).
  4. **Görsel kalite bu raporun kapsamı dışındadır** (Visual Scope none): F03 yüzeylerinin yeni Design Foundation / Visual Quality Gate altındaki bağımsız değerlendirmesi Design Adoption Route'a aittir. Android capture Pending (platform.md §14).
  5. Kanıt görüntüleri/videoları oturum scratchpad'indedir, repoya eklenmedi; tekrar üretme adımları E4–E14'te yazılıdır.

## 7. Tech Lead Note

* **Root-cause alanı:** F03-QA-03/04 Frontend/Mobile Developer alanındaydı ve kapandı; başka rol/rework gerekmiyor.
* **Routing / depth:** blocking yok; closure review Tech Lead'de. Board/system-state senkronu ve F03 kapanışı Tech Lead kararıdır. Sonraki iş kuyruğu: F05-QA-STRICT (F03 rework kilidi kalkar), F08 yerel kanıt ve Design Adoption Route Faz B.
* **Workflow notu:** Visual Scope = none ile verilen onay yalnız davranış/erişilebilirlik kapsamlıdır. F03 terminal `Done` yapılırsa görsel yüzeylerin Design Adoption Route'ta yeniden değerlendirilmesi ve gerekirse görsel rework olarak yeniden açılması Tech Lead tarafından kayda geçirilmelidir.
* **Ortam notu:** Reduce Motion testten sonra KAPALI konuma geri alındı (E-son durum doğrulandı); üç simulator açık; iPhone 16'daki uygulama store'u seviye 5'te (yerel test verisi).

## Sonraki Komut

```text
Run Tech Lead
```
